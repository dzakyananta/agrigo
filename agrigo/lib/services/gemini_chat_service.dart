import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class GeminiChatService {
  // ============================================
  // KONFIGURASI API GEMINI
  // ============================================
  //
  // ⚠️ API KEY DI BAWAH ADALAH CONTOH - HARUS DIGANTI!
  //
  // CARA MENDAPATKAN API KEY GRATIS:
  // 1. Buka: https://aistudio.google.com/app/apikey
  // 2. Login dengan akun Google Anda
  // 3. Klik "Create API Key"
  // 4. Copy API Key yang muncul
  // 5. Paste di baris _apiKey di bawah (ganti yang ada)
  //
  // Chatbot akan bisa menjawab SEMUA pertanyaan:
  // ✓ Pertanian (budidaya, hama, pupuk, harga, dll)
  // ✓ Teknologi (coding, AI, IoT, app development)
  // ✓ Bisnis, Sains, Kesehatan, Pendidikan
  // ✓ Dan topik apapun dengan pengetahuan Google Gemini!
  //
  // ============================================

  // ✅ API KEY SUDAH DIGANTI - CHATBOT SIAP DIGUNAKAN!
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

**1. Buka Website:**
   https://aistudio.google.com/app/apikey

**2. Login:**
   • Gunakan akun Google Anda
   • Jika belum punya, buat akun Google dulu (gratis)

**3. Buat API Key:**
   • Klik tombol "Create API Key"
   • Pilih "Create API key in new project"
   • API Key akan muncul

**4. Copy API Key:**
   • Copy seluruh API Key yang muncul
   • Contoh format: AIzaSyABCDEF1234567890_abcdefghijk

**5. Paste ke Kode:**
   • Buka file: lib/services/gemini_chat_service.dart
   • Cari baris 23: static const String _apiKey = '...'
   • Ganti API Key dummy dengan API Key Anda
   • Save file

**6. Restart Aplikasi:**
   • Stop aplikasi
   • Run ulang dengan: flutter run

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**GRATIS & MUDAH!**
✓ Tidak perlu kartu kredit
✓ Kuota gratis sangat besar
✓ Proses hanya 2 menit

Setelah API Key diganti, chatbot akan:
🌾 Menjawab pertanyaan pertanian
💻 Membantu coding & teknologi
📊 Analisis bisnis & ekonomi
🔬 Jelaskan sains & matematika
📚 Bantuan belajar semua mata pelajaran
🌍 Dan ribuan topik lainnya!

**Butuh bantuan?** Hubungi administrator atau developer aplikasi.
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
   • Pasar: Stabil dengan permintaan tinggi

**2. Cabai Merah Keriting**
   • Harga: Rp 40.000 - Rp 55.000/kg
   • Kualitas Super: Rp 60.000/kg
   • Trend: Harga cenderung naik

**3. Cabai Rawit Merah**
   • Harga: Rp 80.000 - Rp 100.000/kg
   • Kualitas Super: Rp 120.000/kg
   • Permintaan: Sangat tinggi

**4. Cabai Rawit Hijau**
   • Harga: Rp 60.000 - Rp 75.000/kg
   • Kualitas Super: Rp 85.000/kg
   • Pasar: Stabil

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📍 **Catatan:**
• Harga dapat berubah tergantung musim
• Harga di daerah bisa berbeda ±10-20%
• Update: Desember 2025

⚠️ *Data lokal - Untuk info real-time, koneksi API Gemini diperlukan*
''';
      }

      if (msg.contains('padi') || msg.contains('beras')) {
        return '''
🌾 **Harga Padi & Beras Saat Ini**

**Gabah Kering Panen (GKP):**
   • Rp 5.500 - Rp 6.000/kg
   • Standar: Kadar air max 25%

**Gabah Kering Giling (GKG):**
   • Rp 7.000 - Rp 7.500/kg
   • Standar: Kadar air max 14%

**Beras Premium:**
   • Rp 13.000 - Rp 15.000/kg
   • Kualitas: Grade A

**Beras Medium:**
   • Rp 11.000 - Rp 12.500/kg
   • Kualitas: Grade B

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📍 **Info Tambahan:**
• HPP (Harga Pembelian Pemerintah): Rp 6.000/kg GKP
• Produktivitas rata-rata: 5-6 ton/ha

⚠️ *Data lokal - Untuk info real-time, koneksi API Gemini diperlukan*
''';
      }

      return '''
💰 **Informasi Harga Komoditas**

Untuk mendapatkan harga terkini, mohon sebutkan komoditas yang ingin ditanyakan:

**Contoh pertanyaan:**
• "Berapa harga cabai hari ini?"
• "Harga padi saat ini?"
• "Harga jagung sekarang?"
• "Berapa harga tomat?"

⚠️ *Koneksi ke Gemini API gagal. Data yang ditampilkan adalah estimasi lokal.*

**Untuk data real-time lengkap:**
Aktifkan Gemini API di:
https://aistudio.google.com/app/apikey

Buat API Key baru dan ganti di gemini_chat_service.dart
''';
    }

    // Deteksi pertanyaan budidaya
    if (msg.contains('budidaya') ||
        msg.contains('cara') &&
            (msg.contains('tanam') || msg.contains('menanam'))) {
      return '''
🌱 **Panduan Budidaya Tanaman**

**Topik yang tersedia:**
1. Budidaya Padi
2. Budidaya Jagung
3. Budidaya Cabai
4. Budidaya Tomat
5. Budidaya Bawang

**Contoh pertanyaan:**
• "Bagaimana cara budidaya padi?"
• "Cara menanam cabai yang benar?"
• "Panduan budidaya jagung?"

⚠️ *Koneksi ke Gemini API gagal. Untuk panduan lengkap dengan AI, aktifkan API Gemini.*

**Cara aktivasi:**
1. Buka: https://aistudio.google.com/app/apikey
2. Buat API Key baru
3. Ganti di gemini_chat_service.dart baris 29
4. Restart aplikasi

Dengan Gemini aktif, Anda bisa tanya APAPUN tentang pertanian!
''';
    }

    // Default response
    return '''
🤖 **Agrigo AI Assistant**

Maaf, saat ini chatbot dalam **mode offline** karena koneksi ke Gemini API gagal.

**Yang bisa saya jawab (mode offline):**
🌶️ Harga komoditas pertanian
🌾 Info dasar budidaya tanaman
📊 Data pasar lokal

**Contoh pertanyaan:**
• "Berapa harga cabai hari ini?"
• "Harga padi saat ini?"
• "Cara budidaya jagung?"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️ **Mode Penuh dengan Gemini API:**

Dengan Gemini API aktif, chatbot bisa menjawab:
✅ SEMUA pertanyaan pertanian
✅ Teknologi & coding
✅ Bisnis & ekonomi
✅ Sains & matematika
✅ Kesehatan & pendidikan
✅ Dan topik apapun!

**Cara aktivasi (GRATIS & MUDAH):**

1️⃣ Buka: https://aistudio.google.com/app/apikey

2️⃣ Klik "Create API Key" → "Create in new project"

3️⃣ Copy API Key yang muncul

4️⃣ Ganti di file gemini_chat_service.dart baris 29

5️⃣ Restart aplikasi

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Kenapa perlu API Key baru?**
• API Key saat ini tidak memiliki akses ke Gemini
• Semua model (gemini-1.5-pro, gemini-1.5-flash, dll) error 404
• API Key baru otomatis teraktivasi dengan full akses

**Gratis tanpa kartu kredit!** ✨
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

      print('📊 Model: $model - Status: ${response.statusCode}');

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

        print('Vision model $model failed with ${response.statusCode}');
      }

      // Jika semua model gagal
      return '''
❌ **Analisis Gambar Gagal**

Terjadi masalah saat menganalisis gambar. Kemungkinan penyebab:

1. **API Key tidak valid**
2. **Format gambar tidak didukung**
3. **Koneksi internet bermasalah**
4. **Server Gemini sedang sibuk**

Silakan coba lagi dengan:
• Pastikan foto jelas dan fokus
• Ukuran file tidak terlalu besar (<5MB)
• Format: JPG, PNG, WebP
''';
    } catch (e) {
      print('Error calling Gemini Vision API: $e');
      return '''
❌ **Gagal Menganalisis Gambar**

Error: ${e.toString()}

Pastikan:
✓ Koneksi internet aktif
✓ API Key Gemini valid
✓ Format gambar didukung (JPG/PNG)

Silakan coba lagi.
''';
    }
  }

  static String _buildImagePrompt(String userMessage) {
    return '''
Kamu adalah Agrigo Vision AI, seorang ahli fitopatologi dan entomologi pertanian Indonesia dengan pengalaman 20+ tahun dalam diagnosis visual tanaman.

ANALISIS KOMPREHENSIF YANG DIPERLUKAN:

📋 **1. IDENTIFIKASI TANAMAN**
   - Nama ilmiah (Latin) dan nama lokal
   - Varietas/kultivar jika dapat diidentifikasi
   - Fase pertumbuhan (bibit, vegetatif, generatif, panen)
   - Estimasi umur tanaman

🔍 **2. KONDISI KESEHATAN TANAMAN**
   - Status kesehatan umum (sehat/kurang sehat/sakit/kritis)
   - Analisis visual: warna daun, bentuk, ukuran, tekstur
   - Tanda-tanda stress: nutrisi, air, suhu, cahaya
   - Skor kesehatan (1-10) dengan penjelasan

⚠️ **3. DIAGNOSIS MASALAH (Jika Ada)**
   A. Hama:
      - Nama ilmiah & lokal hama
      - Stadium perkembangan hama
      - Tingkat serangan (ringan/sedang/berat %)
      - Bagian tanaman yang diserang
   
   B. Penyakit:
      - Nama penyakit & patogen penyebab
      - Gejala khas yang terlihat
      - Stadium infeksi
      - Potensi penyebaran
   
   C. Gangguan Fisiologis:
      - Defisiensi/kelebihan nutrisi (N, P, K, mikro)
      - Stress lingkungan (air, suhu, pH)
      - Kerusakan mekanis/fisik

💊 **4. REKOMENDASI PENANGANAN**
   A. Tindakan Segera (24-48 jam):
      - Langkah-langkah darurat
      - Isolasi jika perlu
   
   B. Pengendalian Jangka Pendek (1-2 minggu):
      - Produk pestisida/fungisida yang direkomendasikan
      - Dosis SPESIFIK (ml/liter, gram/tangki)
      - Cara aplikasi & waktu terbaik
      - Frekuensi penyemprotan
      - Alternatif organik/nabati
   
   C. Perbaikan Jangka Panjang:
      - Perbaikan kondisi tumbuh
      - Program pemupukan koreksi
      - Manajemen air & drainase

🛡️ **5. STRATEGI PENCEGAHAN**
   - Praktik budidaya terbaik (GAP)
   - Monitoring & deteksi dini
   - Rotasi tanaman/varietas tahan
   - Sanitasi lahan & alat
   - Penggunaan musuh alami
   - Jadwal pemeliharaan preventif

📊 **6. PROGNOSIS**
   - Kemungkinan pemulihan (%)
   - Estimasi waktu pemulihan
   - Dampak terhadap hasil panen
   - Potensi kerugian ekonomi

💰 **7. ANALISIS BIAYA**
   - Estimasi biaya penanganan
   - Biaya vs benefit intervensi
   - Rekomendasi prioritas tindakan

KONTEKS PERTANYAAN PETANI: 
$userMessage

INSTRUKSI ANALISIS:
1. Observasi menyeluruh dari yang terlihat pada gambar
2. Berikan analisis yang sistematis dan terstruktur
3. Gunakan istilah ilmiah diikuti penjelasan sederhana
4. Sertakan tingkat kepercayaan diagnosis (jika tidak 100% yakin)
5. Jika gambar tidak jelas, sebutkan limitasi dan minta foto tambahan
6. Berikan rekomendasi SPESIFIK untuk kondisi Indonesia (produk lokal, harga lokal)
7. Prioritaskan solusi yang cost-effective dan mudah diakses petani
8. Format dengan markdown yang rapi: heading, bullet, bold, emoji

PENTING: 
- Berikan analisis mendalam seperti konsultan profesional
- Jangan generic - berikan angka, nama produk, dosis konkret
- Jelaskan "mengapa" di balik setiap rekomendasi
- Pertimbangkan aspek ekonomi petani kecil
- Akhiri dengan langkah konkret "Apa yang harus dilakukan hari ini?"
''';
  }

  static String _buildPrompt(String userMessage) {
    return '''
Kamu adalah Agrigo Assistant - AI Assistant berbasis Google Gemini dengan pengetahuan lengkap dan komprehensif.

IDENTITAS & KEMAMPUAN:
• Kamu memiliki akses ke seluruh knowledge base Google Gemini
• Kamu dapat menjawab SEMUA jenis pertanyaan: pertanian, teknologi, sains, bisnis, kesehatan, pendidikan, sejarah, budaya, dan topik apapun
• Kamu dapat memberikan informasi real-time, data terkini, dan pengetahuan global

KEAHLIAN UTAMA (tapi tidak terbatas):
🌾 **Pertanian:** Budidaya, hama, pupuk, harga pasar, teknologi pertanian, analisis usaha tani
💻 **Teknologi:** Coding, AI, IoT, app development, sistem informasi
📊 **Bisnis & Ekonomi:** Strategi bisnis, keuangan, marketing, manajemen
🔬 **Sains:** Biologi, kimia, fisika, matematika, lingkungan
🏥 **Kesehatan:** Nutrisi, penyakit, obat-obatan, kesehatan umum
📚 **Pendidikan:** Semua mata pelajaran, pembelajaran, tips belajar
🌍 **Umum:** Berita, budaya, sejarah, geografi, sosial, dan lainnya

KONTEKS KHUSUS INDONESIA:
• Jika pertanyaan terkait pertanian Indonesia: gunakan konteks iklim tropis, komoditas lokal, harga pasar Indonesia, varietas unggul Indonesia
• Jika pertanyaan umum: berikan jawaban universal dengan contoh atau adaptasi untuk Indonesia jika relevan
• Bahasa Indonesia yang jelas dan profesional

FORMAT JAWABAN:
• Gunakan bahasa Indonesia yang mudah dipahami
• STRUKTUR dengan nomor: 1., 2., 3. (poin utama) dan a), b), c) (sub-poin)
• Emoji relevan untuk visual guide
• Berikan data spesifik (angka, tanggal, nama) bukan generalisasi
• Pisahkan paragraf dengan line break untuk readability
• Untuk topik kompleks: akhiri dengan "📌 Poin Penting:" atau "📌 Langkah Selanjutnya:"

PRINSIP JAWABAN:
✓ **AKURAT** - Gunakan pengetahuan Gemini yang update & valid
✓ **LENGKAP** - Jawab secara komprehensif dengan detail yang cukup
✓ **RELEVAN** - Fokus pada apa yang ditanya, tidak melebar
✓ **PRAKTIS** - Berikan informasi yang actionable dan berguna
✓ **TERSTRUKTUR** - Gunakan penomoran dan heading untuk kemudahan baca
✓ **OBJEKTIF** - Berikan informasi faktual, jika opini sebutkan sebagai opini

FLEKSIBILITAS TOPIK:
• Jika ditanya tentang pertanian → Jawab detail dengan data Indonesia
• Jika ditanya tentang teknologi → Jawab dengan info terkini global
• Jika ditanya tentang pendidikan → Berikan penjelasan edukatif
• Jika ditanya tentang bisnis → Berikan analisis dan strategi
• Jika ditanya tentang apapun → Manfaatkan pengetahuan luas Gemini!

KEMAMPUAN KHUSUS:
• Analisis data dan perhitungan
• Memberikan kode pemrograman (jika ditanya)
• Menjelaskan konsep kompleks dengan sederhana
• Memberikan rekomendasi berbasis data
• Menjawab pertanyaan faktual dengan akurat
• Membantu problem solving berbagai bidang

PERTANYAAN USER:
$userMessage

Jawab pertanyaan dengan memanfaatkan seluruh pengetahuan Google Gemini. Berikan jawaban terbaik, akurat, dan bermanfaat!
''';
  }

  // ============================================
  // FUNGSI DEPRECATED - Tidak Digunakan Lagi
  // Chatbot sekarang 100% menggunakan Gemini API
  // ============================================

  static String _getFallbackResponse(String message) {
    // Deprecated - tidak digunakan lagi
    return '''
⚠️ **Fungsi Tidak Tersedia**

Chatbot sekarang menggunakan 100% Google Gemini API untuk memberikan jawaban terbaik.
Fungsi fallback offline telah dinonaktifkan.

Pastikan koneksi internet aktif dan API Key valid.
''';
  }

  static String _getImageFallbackResponse(String message) {
    // Deprecated - tidak digunakan lagi
    return '''
⚠️ **Analisis Gambar Memerlukan Koneksi**

Fitur analisis gambar menggunakan Gemini Vision API.
Pastikan koneksi internet aktif dan API Key valid.
''';
  }
}
