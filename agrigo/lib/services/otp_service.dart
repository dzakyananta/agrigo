import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OtpService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _otpCollection = 'otp_codes';
  
  /// Generate random 5-digit OTP
  static String generateOtp() {
    final random = Random();
    final otp = random.nextInt(90000) + 10000; // 10000 to 99999
    return otp.toString();
  }
  
  /// Save OTP to Firestore with expiry time (5 minutes)
  static Future<void> saveOtp({
    required String email,
    required String otp,
  }) async {
    final expiryTime = DateTime.now().add(const Duration(minutes: 5));
    
    await _db.collection(_otpCollection).doc(email).set({
      'otp': otp,
      'email': email,
      'expiryTime': Timestamp.fromDate(expiryTime),
      'createdAt': FieldValue.serverTimestamp(),
      'isUsed': false,
    });
  }
  
  /// Verify OTP
  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final doc = await _db.collection(_otpCollection).doc(email).get();
      
      if (!doc.exists) {
        return {
          'success': false,
          'message': 'Kode OTP tidak ditemukan. Silakan kirim ulang.',
        };
      }
      
      final data = doc.data()!;
      final savedOtp = data['otp'] as String;
      final expiryTime = (data['expiryTime'] as Timestamp).toDate();
      final isUsed = data['isUsed'] as bool? ?? false;
      
      // Check if OTP is already used
      if (isUsed) {
        return {
          'success': false,
          'message': 'Kode OTP sudah digunakan. Silakan kirim ulang.',
        };
      }
      
      // Check if OTP is expired
      if (DateTime.now().isAfter(expiryTime)) {
        return {
          'success': false,
          'message': 'Kode OTP sudah kadaluarsa. Silakan kirim ulang.',
        };
      }
      
      // Verify OTP
      if (savedOtp != otp) {
        return {
          'success': false,
          'message': 'Kode OTP salah. Silakan coba lagi.',
        };
      }
      
      // Mark OTP as used
      await _db.collection(_otpCollection).doc(email).update({
        'isUsed': true,
        'usedAt': FieldValue.serverTimestamp(),
      });
      
      return {
        'success': true,
        'message': 'Kode OTP berhasil diverifikasi.',
      };
      
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
  
  /// Delete OTP after successful password reset
  static Future<void> deleteOtp(String email) async {
    await _db.collection(_otpCollection).doc(email).delete();
  }
  
  /// Send OTP via PHP Gmail script
  static Future<bool> sendOtpEmail({
    required String email,
    required String otp,
  }) async {
    // Try multiple endpoints in order
    // 10.0.2.2 = Android Emulator localhost
    // 192.168.124.133 = WiFi IP
    final endpoints = [
      'http://10.0.2.2:8001/send-otp-gmail.php',
      'http://192.168.124.133:8001/send-otp-gmail.php',
      'http://192.168.56.1:8001/send-otp-gmail.php',
    ];
    
    for (var endpoint in endpoints) {
      try {
        print('🔄 Trying endpoint: $endpoint');
        
        final url = Uri.parse(endpoint);
        
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'email': email,
            'otp': otp,
          },
        ).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            print('⏱️ Timeout for: $endpoint');
            throw Exception('Timeout');
          },
        );

        print('📧 Email API Response: ${response.statusCode}');
        print('📧 Response body: ${response.body}');

        if (response.statusCode == 200) {
          try {
            final data = jsonDecode(response.body);
            if (data['success'] == true) {
              print('✅ OTP email berhasil dikirim ke $email via $endpoint');
              return true;
            } else {
              print('❌ OTP email gagal: ${data['message']}');
              // Don't return false yet, try next endpoint
              continue;
            }
          } catch (e) {
            // Jika response bukan JSON, anggap sukses jika status 200
            print('✅ OTP email terkirim via $endpoint');
            return true;
          }
        }

        print('❌ HTTP Error: ${response.statusCode} for $endpoint');
        // Try next endpoint
        
      } catch (e) {
        print('❌ Error with $endpoint: $e');
        // Continue to next endpoint
        continue;
      }
    }
    
    // All endpoints failed
    print('❌ Semua endpoint gagal. Server mungkin tidak berjalan.');
    return false;
  }
  
  /// Reset password via Firebase Admin SDK
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    // Try multiple endpoints in order
    final endpoints = [
      'http://10.0.2.2:8001/reset-password.php',
      'http://192.168.124.133:8001/reset-password.php',
      'http://192.168.56.1:8001/reset-password.php',
    ];
    
    for (var endpoint in endpoints) {
      try {
        print('🔄 Trying reset password endpoint: $endpoint');
        
        final url = Uri.parse(endpoint);
        
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': email,
            'password': newPassword,
          }),
        ).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            print('⏱️ Timeout for: $endpoint');
            throw Exception('Timeout');
          },
        );

        print('🔒 Reset Password API Response: ${response.statusCode}');
        print('🔒 Response body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            print('✅ Password berhasil direset via $endpoint');
            return {
              'success': true,
              'message': data['message'] ?? 'Password berhasil diubah',
            };
          }
        }

        // Handle error response
        try {
          final data = jsonDecode(response.body);
          print('❌ Reset password gagal: ${data['message']}');
          // Don't return yet, try next endpoint
          continue;
        } catch (e) {
          print('❌ HTTP Error: ${response.statusCode} for $endpoint');
          continue;
        }
        
      } catch (e) {
        print('❌ Error with $endpoint: $e');
        // Continue to next endpoint
        continue;
      }
    }
    
    // All endpoints failed
    return {
      'success': false,
      'message': 'Semua endpoint gagal. Server mungkin tidak berjalan.',
    };
  }
}
