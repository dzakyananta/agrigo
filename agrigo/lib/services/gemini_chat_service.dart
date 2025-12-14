import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class GeminiChatService {
  // API KEY - GANTI DENGAN API KEY ANDA
  // Dapatkan di: https://aistudio.google.com/app/apikey
  static const String _apiKey = 'AIzaSyDwdE7v7FZR5XJKRDmZr39cKWuPkm9WtMk';

  // Daftar model yang akan dicoba secara berurutan
  static const List<String> _modelsTry = [
    'gemini-1.5-pro',
    'gemini-1.5-flash',
    'gemini-pro',
    'gemini-1.5-pro-latest',
    'gemini-1.5-flash-latest',
  ];

  static String? _workingModel; // Cache model yang berhasil

  static Future<String> sendMessage(String message) async {
    // Cek apakah API key sudah diganti
    if (_apiKey == 'AIzaSyDSbx8h7XqZ5VqN9fY8KqP9m8vN8j8h8j8') {
      return '''
⚠️ **API KEY BELUM DIGANTI!**

API Key yang digunakan adalah contoh/dummy. Chatbot tidak akan berfungsi tanpa API Key yang valid.

**Cara mendapatkan API Key GRATIS:**

1. Buka: https://aistudio.google.com/app/apikey
2. Login dengan akun Google Anda
3. Klik "Create API Key"
4. Copy API Key yang muncul
5. Ganti di gemini_chat_service.dart baris 10

Setelah API Key diganti, chatbot akan bisa menjawab SEMUA pertanyaan!
''';
    }

    // Jika sudah ada model yang berhasil, langsung pakai itu
    if (_workingModel != null) {
      return _tryModel(_workingModel!, message);
    }

    // Coba semua model sampai ada yang berhasil
    print('🔍 Mencari model Gemini yang tersedia...');
    for (String model in _modelsTry) {
      print('🧪 Mencoba model: $model');
      final result = await _tryModel(model, message);

      // Jika tidak ada error 404, berarti model ini work
      if (!result.contains('404') && !result.contains('not found')) {
        _workingModel = model; // Cache model yang berhasil
        print('✅ Model berhasil: $model');
        return result;
      }
    }

    // Jika semua model gagal
    print('⚠️ Semua model Gemini gagal, menggunakan fallback local data');
    return _getLocalResponse(message);
  }

  static String _getLocalResponse(String message) {
    final msg = message.toLowerCase();

    // Deteksi pertanyaan tentang harga
    if (msg.contains('harga') || msg.contains('berapa')) {
      if (msg.contains('cabai') || msg.contains('cabe')) {
        return '''
🌶️ **Harga Cabai Saat Ini**

**Jenis Cabai dan Harga Pasar:**

**1. Cabai Merah Besar**
   • Harga: Rp 35.000 - Rp 45.000/kg
   • Kualitas Super: Rp 50.000/kg

**2. Cabai Rawit Merah**
   • Harga: Rp 80.000 - Rp 100.000/kg
   • Kualitas Super: Rp 120.000/kg

⚠️ *Data lokal - Untuk info real-time, koneksi API Gemini diperlukan*
''';
      }

      if (msg.contains('padi') || msg.contains('beras')) {
        return '''
🌾 **Harga Padi & Beras Saat Ini**

**Gabah Kering Panen (GKP):**
   • Rp 5.500 - Rp 6.000/kg

**Beras Premium:**
   • Rp 13.000 - Rp 15.000/kg

⚠️ *Data lokal - Untuk info real-time, koneksi API Gemini diperlukan*
''';
      }

      return '💰 Untuk mendapatkan harga terkini, sebutkan komoditas yang ingin ditanyakan.';
    }

    // Default response
    return '''
🤖 **Agrigo AI Assistant**

Maaf, saat ini chatbot dalam **mode offline** karena koneksi ke Gemini API gagal.

**Yang bisa saya jawab (mode offline):**
🌶️ Harga komoditas pertanian
🌾 Info dasar budidaya tanaman

**Contoh pertanyaan:**
• "Berapa harga cabai hari ini?"
• "Harga padi saat ini?"

Untuk mode penuh, aktifkan Gemini API di:
https://aistudio.google.com/app/apikey
''';
  }

  static Future<String> _tryModel(String model, String message) async {
    try {
      final url =
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent';

      final response = await http.post(
        Uri.parse('$url?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': message},
              ],
            },
          ],
          'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 2048},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final result = data['candidates'][0]['content']['parts'][0]['text'];
          return result;
        }
        return 'Tidak ada response dari Gemini API';
      }

      // Return error untuk dicek di loop
      final errorBody = jsonDecode(response.body);
      return 'Error ${response.statusCode}: ${errorBody['error']?['message'] ?? 'Unknown'}';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  // Fungsi untuk mengirim gambar + teks ke Gemini Vision
  static Future<String> sendMessageWithImage(
    String message,
    File imageFile,
  ) async {
    try {
      // Baca gambar sebagai bytes
      Uint8List imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // Coba model vision yang tersedia
      final modelsToTry = [
        'gemini-1.5-pro',
        'gemini-1.5-flash',
        'gemini-pro-vision',
      ];

      for (String model in modelsToTry) {
        final url =
            'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent';

        final response = await http.post(
          Uri.parse('$url?key=$_apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': _buildImagePrompt(message)},
                  {
                    'inline_data': {
                      'mime_type': 'image/jpeg',
                      'data': base64Image,
                    },
                  },
                ],
              },
            ],
            'generationConfig': {'temperature': 0.6, 'maxOutputTokens': 3072},
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['candidates'] != null && data['candidates'].isNotEmpty) {
            return data['candidates'][0]['content']['parts'][0]['text'];
          }
        }
      }

      return '❌ **Analisis Gambar Gagal** - Pastikan API Key valid dan koneksi internet aktif.';
    } catch (e) {
      return '❌ **Gagal Menganalisis Gambar**: ${e.toString()}';
    }
  }

  static String _buildImagePrompt(String userMessage) {
    return '''
Kamu adalah Agrigo Vision AI, ahli pertanian yang menganalisis foto tanaman.

Analisis foto ini dan berikan:
1. Identifikasi tanaman
2. Kondisi kesehatan
3. Masalah yang terlihat (hama/penyakit)
4. Rekomendasi penanganan

Pertanyaan user: $userMessage

Berikan jawaban lengkap dalam bahasa Indonesia dengan format yang rapi.
''';
  }
}
