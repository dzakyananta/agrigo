<!-- @format -->

# Setup Gemini AI untuk Chatbot Agrigo

## ✨ Fitur Baru: AI Vision - Analisis Gambar Tanaman!

Chatbot sekarang mendukung **upload gambar** untuk analisis tanaman:

- 📸 Foto tanaman yang bermasalah
- 🔍 AI akan mengidentifikasi hama/penyakit
- 💡 Dapatkan solusi dan rekomendasi perawatan
- 🌱 Analisis kondisi kesehatan tanaman

## Cara Mendapatkan API Key Google Gemini (GRATIS)

### Langkah 1: Buka Google AI Studio

1. Kunjungi: [https://makersuite.google.com/app/apikey](https://makersuite.google.com/app/apikey)
2. Login dengan akun Google Anda

### Langkah 2: Buat API Key

1. Klik tombol **"Get API Key"** atau **"Create API Key"**
2. Pilih project atau buat project baru
3. Copy API key yang dibuat

### Langkah 3: Paste ke Kode

Buka file: `lib/services/gemini_chat_service.dart`

Ganti baris ini:

```dart
static const String _apiKey = 'AIzaSyDSbx8h7XqZ5VqN9fY8KqP9m8vN8j8h8j8'; // Ganti dengan API key Anda
```

Dengan API key Anda:

```dart
static const String _apiKey = 'PASTE_API_KEY_ANDA_DISINI';
```

### Langkah 4: Save & Restart App

1. Save file `gemini_chat_service.dart`
2. Stop aplikasi
3. Jalankan ulang dengan `flutter run`

## ✅ Fitur Chatbot yang Sudah Terintegrasi

### Dengan Gemini AI (Online):

- ✅ Jawaban cerdas menggunakan Google Gemini AI
- ✅ Konteks pertanian Indonesia
- ✅ Rekomendasi spesifik dan detail
- ✅ Memahami pertanyaan kompleks
- ✅ Jawaban natural dan conversational

### Fallback Mode (Offline):

- ✅ Informasi harga pasar
- ✅ Tips budidaya (Padi, Jagung, Cabai)
- ✅ Panduan pemupukan
- ✅ Pengendalian hama & penyakit
- ✅ Tetap berfungsi tanpa internet

## 🎯 Kemampuan AI Chatbot

### 💬 Mode Teks (Chat Biasa)

Chatbot dapat menjawab tentang:

1. **Harga Pasar**

   - "Berapa harga cabai hari ini?"
   - "Harga padi sekarang berapa?"

2. **Budidaya Tanaman**

   - "Bagaimana cara menanam jagung?"
   - "Tips budidaya padi yang baik?"

3. **Hama & Penyakit**

   - "Cara mengatasi hama ulat di cabai"
   - "Tanaman tomat saya layu, kenapa?"

4. **Pemupukan**

   - "Pupuk apa yang bagus untuk padi?"
   - "Kapan waktu pemupukan jagung?"

5. **Musim Tanam**

   - "Kapan waktu terbaik tanam cabai?"
   - "Musim tanam kedelai kapan?"

6. **Pertanyaan Umum**
   - "Apa komoditas yang paling menguntungkan?"
   - "Bagaimana cara meningkatkan hasil panen?"

### 📸 Mode Vision (Analisis Gambar) ✨ BARU!

**Cara Menggunakan:**

1. Klik tombol **kamera** (ikon biru) di input area
2. Pilih **"Ambil Foto"** atau **"Pilih dari Galeri"**
3. Gambar akan muncul sebagai preview
4. Ketik pertanyaan (opsional) atau langsung kirim
5. AI akan menganalisis gambar dan memberikan diagnosis

**Contoh Kasus:**

- 📸 Foto daun yang menguning

  - AI: "Daun menguning menunjukkan kekurangan nitrogen. Rekomendasi: Tambahkan pupuk Urea..."

- 📸 Foto batang tanaman busuk

  - AI: "Busuk batang kemungkinan penyakit layu bakteri. Solusi: Perbaiki drainase..."

- 📸 Foto hama di daun
  - AI: "Terdeteksi hama trips. Pengendalian: Gunakan perangkap kuning + insektisida..."

**Tips Foto Terbaik:**
✓ Ambil foto di cahaya terang
✓ Fokus pada area yang bermasalah
✓ Jarak dekat (close-up) untuk detail
✓ Hindari foto blur/goyang

## 🔧 Troubleshooting

### Error: API Key tidak valid

- Pastikan API key sudah benar
- Cek apakah API key sudah diaktifkan di Google AI Studio

### Chatbot tidak merespon

- Cek koneksi internet
- Jika offline, akan otomatis menggunakan mode fallback

### Response terlalu lambat

- Normal untuk request pertama (3-5 detik)
- Request selanjutnya akan lebih cepat

## 💡 Tips Penggunaan

1. **Pertanyaan Spesifik** lebih baik daripada pertanyaan umum

   - ✅ Baik: "Bagaimana cara mengatasi hama trips pada cabai?"
   - ❌ Kurang baik: "Ada masalah di tanaman"

2. **Gunakan bahasa Indonesia** untuk hasil terbaik

3. **Sebutkan konteks** jika perlu
   - "Saya di Jawa Barat, tanaman padi umur 50 hari..."

## 🚀 Keuntungan Gemini AI

- ✅ **GRATIS** - Tidak perlu bayar
- ✅ **Powerful** - Model AI terbaru dari Google
- ✅ **Cepat** - Response dalam 2-3 detik
- ✅ **Akurat** - Konteks pertanian Indonesia
- ✅ **Unlimited** - Tidak ada batasan query (fair use)

## 📝 Catatan

- API key bersifat pribadi, jangan share ke orang lain
- Jika digunakan untuk production, pertimbangkan keamanan API key
- Bisa menggunakan environment variables atau Firebase Remote Config

## 🔐 Keamanan (Production)

Untuk aplikasi production, sebaiknya:

1. Simpan API key di backend/server
2. Buat API proxy sendiri
3. Gunakan Firebase Functions
4. Implementasi rate limiting

---

**Update terakhir:** Desember 2025
**Status:** ✅ Fully Integrated & Working
