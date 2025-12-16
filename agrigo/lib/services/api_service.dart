import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Multiple base URL options - pilih yang sesuai:
  // 1. Localhost (untuk emulator Android)
  static const String baseUrlLocalhost = 'http://10.0.2.2:8000/api';
  
  // 2. Network IP (untuk physical device di WiFi yang sama)
  static const String baseUrlNetwork = 'http://192.168.1.14:8000/api';
  
  // 3. Ngrok (untuk testing di device manapun)
  static const String baseUrlNgrok = 'https://YOUR_NGROK_URL/api';
  
  // ACTIVE BASE URL - Ganti sesuai kebutuhan
  static const String baseUrl = baseUrlLocalhost; // Default: emulator
  
  // ============= TOKEN MANAGEMENT =============
  
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
  
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // ============= AUTHENTICATION =============
  
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await saveToken(data['token']);
        return data;
      } else {
        throw Exception(data['message'] ?? 'Login gagal');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        await saveToken(data['token']);
        return data;
      } else {
        throw Exception(data['message'] ?? 'Registrasi gagal');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  static Future<Map<String, dynamic>> getUser() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Gagal mengambil data user');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  static Future<void> logout() async {
    try {
      final headers = await getHeaders();
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: headers,
      );
    } catch (e) {
      // Ignore error
    } finally {
      await clearToken();
    }
  }
  
  // ============= SCHEDULES =============
  
  static Future<List<dynamic>> getSchedules() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/schedules'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['data'] ?? [];
      } else {
        throw Exception(data['message'] ?? 'Gagal mengambil jadwal');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  static Future<Map<String, dynamic>> createSchedule({
    required int commodityId,
    required String startDate,
    required String endDate,
    String? notes,
  }) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/schedules'),
        headers: headers,
        body: jsonEncode({
          'commodity_id': commodityId,
          'start_date': startDate,
          'end_date': endDate,
          'notes': notes,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Gagal membuat jadwal');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  static Future<void> deleteSchedule(int id) async {
    try {
      final headers = await getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/schedules/$id'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Gagal menghapus jadwal');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  // ============= TRANSACTIONS =============
  
  static Future<List<dynamic>> getTransactions() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/transactions'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['data'] ?? [];
      } else {
        throw Exception(data['message'] ?? 'Gagal mengambil transaksi');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  static Future<Map<String, dynamic>> getTransactionSummary() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/transactions/summary'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Gagal mengambil ringkasan');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  static Future<Map<String, dynamic>> createTransaction({
    required String type, // 'income' or 'expense'
    required double amount,
    int? commodityId,
    String? description,
    required String date,
  }) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: headers,
        body: jsonEncode({
          'type': type,
          'amount': amount,
          'commodity_id': commodityId,
          'description': description,
          'date': date,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Gagal membuat transaksi');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  // ============= COMMODITIES =============
  
  static Future<List<dynamic>> getCommodities() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/commodities'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['data'] ?? [];
      } else {
        throw Exception(data['message'] ?? 'Gagal mengambil komoditas');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  // ============= WEATHER =============
  
  static Future<Map<String, dynamic>> getWeather() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/weather'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Gagal mengambil data cuaca');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

// File ini TETAP DIGUNAKAN untuk Web Admin yang pakai MySQL
