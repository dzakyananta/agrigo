<!-- @format -->

# 🎯 PENINGKATAN RESPONSIVITAS CHATBOT

## Ringkasan Perubahan

Chatbot Agrigo sekarang lebih **responsif** dan **spesifik** dalam menangkap pertanyaan user dengan penambahan **penomoran & paragraf** yang jelas untuk kemudahan pemahaman.

---

## ✨ Fitur Baru

### 1. **Deteksi Pertanyaan Spesifik yang Lebih Cerdas**

#### **SEBELUM:**

```
User: "harga cabai"
Bot: [Memberikan harga SEMUA komoditas - padi, jagung, cabai, tomat, dll]
User harus scroll banyak untuk cari info cabai
```

#### **SESUDAH:**

```
User: "harga cabai"
Bot: [HANYA memberikan info harga cabai dengan 5 jenis lengkap]
✅ Cabai Merah Keriting
✅ Cabai Rawit
✅ Cabai Merah Besar
✅ Cabai Hijau
✅ Paprika
```

**Hasil:** User langsung dapat info yang dicari tanpa scroll panjang!

---

### 2. **Penomoran & Paragraf yang Jelas**

#### **SEBELUM:**

```
• Cabai Merah Keriting: Rp 55.000-65.000/kg
• Cabai Rawit: Rp 60.000-80.000/kg
Tips: Jual bertahap, sortasi kualitas, akses pasar
```

#### **SESUDAH:**

```
**1. CABAI MERAH KERITING**
   • Harga Petani: Rp 45.000 - 55.000/kg
   • Harga Pasar: Rp 55.000 - 65.000/kg
   • Harga Retail: Rp 65.000 - 75.000/kg
   • Status: ↗️ TINGGI (naik 15% dari bulan lalu)

**2. CABAI RAWIT HIJAU/MERAH**
   • Harga Petani: Rp 50.000 - 65.000/kg
   • Harga Pasar: Rp 60.000 - 80.000/kg
   ...

**📌 Langkah Selanjutnya:**

1. **Cek harga lokal Anda** via SMS/app
2. **Bandingkan** dengan harga pasar terdekat
3. **Tentukan strategi** jual langsung atau tunda
```

**Hasil:** Informasi terstruktur, mudah dipahami, actionable!

---

### 3. **Deteksi Keyword yang Lebih Pintar**

| Pertanyaan User      | Yang Terdeteksi  | Respons Bot                      |
| -------------------- | ---------------- | -------------------------------- |
| "harga cabai"        | Harga + Cabai    | Info harga 5 jenis cabai SAJA    |
| "harga padi"         | Harga + Padi     | Info harga padi & beras SAJA     |
| "harga jagung"       | Harga + Jagung   | Info harga jagung SAJA           |
| "harga tomat"        | Harga + Tomat    | Info harga tomat SAJA            |
| "harga bawang"       | Harga + Bawang   | Info harga 4 jenis bawang SAJA   |
| "harga pasar" (umum) | Harga saja       | Info harga SEMUA komoditas       |
| "jenis cabai"        | Jenis + Cabai    | Klasifikasi 6 jenis cabai detail |
| "varietas padi"      | Varietas + Padi  | 15+ varietas padi lengkap        |
| "budidaya cabai"     | Budidaya + Cabai | Panduan cabai SAJA               |

---

## 🔍 Contoh Penggunaan

### **Contoh 1: Pertanyaan Spesifik - Harga Cabai**

**Input User:**

```
"Berapa harga cabai hari ini?"
atau
"harga cabai"
atau
"info harga cabe"
```

**Output Bot:** ✅

```
🌶️ INFORMASI HARGA CABAI TERKINI

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 HARGA PASAR SAAT INI:

1. CABAI MERAH KERITING
   • Harga Petani: Rp 45.000 - 55.000/kg
   • Harga Pasar: Rp 55.000 - 65.000/kg
   • Harga Retail: Rp 65.000 - 75.000/kg
   • Status: ↗️ TINGGI

2. CABAI RAWIT HIJAU/MERAH
   • Harga Petani: Rp 50.000 - 65.000/kg
   ...

📈 ANALISIS TREN HARGA CABAI:

Mengapa Harga Naik?
1. Musim hujan → Produksi menurun 30-40%
2. Serangan hama meningkat
3. Permintaan tetap tinggi
...

💡 TIPS UNTUK PETANI:

1. Waktu Tanam Terbaik:
   a) Tanam: April-Mei
   b) Panen: Juli-Oktober
   ...

📌 Langkah Selanjutnya:

1. Cek harga lokal Anda via SMS/app
2. Bandingkan dengan harga pasar terdekat
3. Tentukan strategi jual
```

**Keunggulan:**

- ✅ Fokus HANYA pada cabai
- ✅ Penomoran jelas (1, 2, 3, dan a, b, c)
- ✅ Terstruktur dengan heading
- ✅ Action items di akhir

---

### **Contoh 2: Pertanyaan Spesifik - Jenis Cabai**

**Input User:**

```
"Apa saja jenis cabai?"
atau
"macam-macam cabai"
atau
"varietas cabai"
```

**Output Bot:** ✅

```
🌶️ JENIS-JENIS CABAI DI INDONESIA

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 KLASIFIKASI BERDASARKAN BENTUK & UKURAN:

1. CABAI MERAH BESAR

   Ciri Khas:
   • Panjang: 12-20 cm
   • Diameter: 1,5-2,5 cm
   • Rasa: Pedas sedang
   • Harga: Rp 40.000-55.000/kg

   Varietas Unggul:
   a) PM 999 F1 - Jumbo, 18-20 cm
   b) Pilar F1 - Tahan rebah
   c) Tanjung F1 - Pedas stabil

   Penggunaan:
   • Sambal giling
   • Cabai kering
   • Bumbu masakan

2. CABAI MERAH KERITING

   Ciri Khas:
   • Panjang: 8-15 cm
   • Bentuk: Bergelombang/keriting
   • Rasa: Pedas tinggi
   • Harga: Rp 55.000-65.000/kg (PALING MAHAL!)

   Varietas Unggul:
   a) Laris F1 - Tahan Antraknosa
   b) Gada F1 - Tahan layu bakteri
   ...

📊 TABEL PERBANDINGAN:

| Jenis | Ukuran | Pedas | Harga/kg | Produktivitas |
|-------|--------|-------|----------|---------------|
| Merah Besar | 12-20 cm | ⭐⭐⭐ | Rp 40-55K | 18-22 ton/ha |
| Keriting | 8-15 cm | ⭐⭐⭐⭐ | Rp 55-65K | 20-25 ton/ha |
...

💡 REKOMENDASI PILIHAN:

1. Untuk Pemula:
   • Cabai Merah Keriting (Laris F1)
   • Alasan: Pasar luas, harga stabil tinggi

2. Untuk Lahan Terbatas:
   • Cabai Rawit
   • Alasan: Harga tertinggi per kg

📌 Langkah Selanjutnya:

1. Pilih jenis sesuai kondisi lahan & target pasar
2. Beli benih berkualitas (hibrida F1)
3. Pelajari budidaya spesifik
```

---

### **Contoh 3: Pertanyaan Umum - Harga Pasar**

**Input User:**

```
"harga pasar hari ini"
atau
"info harga komoditas"
```

**Output Bot:** ✅

```
📊 INFORMASI HARGA PASAR KOMODITAS PERTANIAN

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🌾 TANAMAN PANGAN

Padi & Beras:
• Gabah Kering Panen (GKP): Rp 7.200 - 7.800/kg
• Beras Premium IR64: Rp 12.500 - 13.500/kg
...

🌶️ HORTIKULTURA - SAYURAN

Cabai & Tomat:
• Cabai Merah Keriting: Rp 45.000 - 65.000/kg ↗️
• Tomat Buah: Rp 8.000 - 12.000/kg →
...

[SEMUA komoditas ditampilkan karena pertanyaan umum]
```

**Perbedaan:**

- Pertanyaan spesifik "harga cabai" → Hanya cabai
- Pertanyaan umum "harga pasar" → Semua komoditas

---

## 📊 Perbandingan Sebelum vs Sesudah

| Aspek                | Sebelum                   | Sesudah                                      |
| -------------------- | ------------------------- | -------------------------------------------- |
| **Deteksi Spesifik** | Kurang akurat             | Sangat akurat (keyword matching)             |
| **Penomoran**        | Minimal (bullet saja)     | Lengkap (1, 2, 3 + a, b, c)                  |
| **Responsivitas**    | Jawab semua → user scroll | Jawab yang ditanya → langsung paham          |
| **Struktur**         | Linear                    | Hierarkis dengan heading jelas               |
| **Action Items**     | Tidak jelas               | Selalu ada "📌 Langkah Selanjutnya" bernomor |
| **Readability**      | Sedang                    | Sangat tinggi (paragraf terpisah)            |

---

## 🎯 Keyword yang Terdeteksi

### **Harga Spesifik:**

- `harga cabai` / `harga cabe` → Harga 5 jenis cabai
- `harga padi` → Harga gabah & beras
- `harga jagung` → Harga jagung pipilan
- `harga tomat` → Harga tomat 3 jenis
- `harga bawang` → Harga 4 jenis bawang

### **Jenis/Varietas:**

- `jenis cabai` / `macam cabai` / `varietas cabai` → 6 klasifikasi cabai
- `jenis padi` / `varietas padi` → 15+ varietas padi

### **Budidaya:**

- `budidaya cabai` / `tanam cabai` / `cara cabai` → Panduan cabai
- (Bisa ditambah untuk komoditas lain)

### **Umum (Fallback):**

- `harga pasar` (tanpa komoditas spesifik) → Semua harga
- `budidaya` (tanpa tanaman spesifik) → Overview

---

## 💡 Tips Bertanya yang Efektif

### **✅ BAIK (Spesifik):**

```
"harga cabai"
"jenis cabai"
"budidaya cabai"
"varietas padi"
"harga tomat"
```

→ Mendapat jawaban fokus, to-the-point

### **✅ BAIK (Umum untuk Overview):**

```
"harga pasar"
"info komoditas"
```

→ Mendapat overview lengkap

### **❌ KURANG OPTIMAL:**

```
"harga" (terlalu umum, kurang konteks)
```

→ Tetap dapat jawaban tapi bisa lebih spesifik

---

## 🔧 Struktur Penomoran Standar

Semua respons mengikuti hierarki:

```
🌶️ **JUDUL UTAMA**

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**📊 HEADING 1:**

**1. POIN UTAMA PERTAMA**
   • Sub-poin bullet
   • Sub-poin bullet

   a) Sub-nomor pertama
   b) Sub-nomor kedua
   c) Sub-nomor ketiga

**2. POIN UTAMA KEDUA**
   • Sub-poin

   a) Detail a
   b) Detail b

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**📌 Langkah Selanjutnya:**

1. **Action item pertama** dengan penjelasan
2. **Action item kedua** dengan penjelasan
3. **Action item ketiga** dengan penjelasan
```

**Keuntungan:**

- ✅ Mudah di-scan (visual hierarchy)
- ✅ Mudah dipahami (logical flow)
- ✅ Actionable (langkah konkret di akhir)

---

## 🚀 Dampak Peningkatan

### **Untuk User/Petani:**

1. ✅ Tidak bingung - Info langsung fokus pada yang ditanya
2. ✅ Mudah dipahami - Penomoran jelas, paragraf terpisah
3. ✅ Cepat action - Langkah selanjutnya selalu tersedia
4. ✅ Tidak perlu scroll panjang - Respons to-the-point

### **Untuk Chatbot:**

1. ✅ Lebih intelligent - Deteksi keyword multi-layer
2. ✅ Lebih professional - Struktur konsisten
3. ✅ Lebih helpful - Respons sesuai kebutuhan
4. ✅ Lebih efficient - Token usage lebih optimal (tidak kirim info yang tidak relevan)

---

## 📝 Technical Implementation

### **File Modified:**

- `lib/services/gemini_chat_service.dart`

### **Perubahan Utama:**

**1. Enhanced Prompt (Line ~230):**

```dart
ANALISIS PERTANYAAN USER:
- Jika user tanya tentang SATU komoditas spesifik → Jawab HANYA komoditas tersebut
- Jika user tanya umum → Berikan overview beberapa komoditas
- Fokus pada keywords penting: harga, budidaya, hama, pupuk, varietas

GAYA KOMUNIKASI:
- Struktur jawaban dengan PENOMORAN & HEADING yang jelas
- Gunakan format: 1., 2., 3. untuk poin utama dan a), b), c) untuk sub-poin
- Pisahkan paragraf dengan line break untuk readability
- Akhiri dengan action items bernomor yang konkret
```

**2. Smart Keyword Detection (Line ~300):**

```dart
// DETEKSI PERTANYAAN TENTANG JENIS/VARIETAS
if ((lowerMessage.contains('jenis') || lowerMessage.contains('varietas')) &&
    lowerMessage.contains('cabai')) {
  return _getJenisCabai();
}

// DETEKSI PERTANYAAN TENTANG HARGA SPESIFIK
if (lowerMessage.contains('harga') && lowerMessage.contains('cabai')) {
  return [Harga cabai spesifik SAJA];
}

// DETEKSI UMUM (fallback)
if (lowerMessage.contains('harga')) {
  return [Semua harga komoditas];
}
```

**3. Helper Functions (NEW):**

- `_getJenisCabai()` - Klasifikasi 6 jenis cabai lengkap
- `_getJenisPadi()` - 15+ varietas padi dengan detail
- `_getHargaPadi()` - Harga spesifik padi & beras
- `_getHargaJagung()` - Harga spesifik jagung
- `_getHargaTomat()` - Harga spesifik tomat
- `_getHargaBawang()` - Harga spesifik 4 jenis bawang
- `_getBudidayaCabaiLengkap()` - Panduan budidaya cabai

---

## ✅ Testing Checklist

Sebelum deploy, test dengan pertanyaan:

- [ ] "harga cabai" → Harus return harga cabai SAJA (5 jenis)
- [ ] "jenis cabai" → Harus return klasifikasi 6 jenis cabai
- [ ] "varietas padi" → Harus return 15+ varietas padi
- [ ] "harga padi" → Harus return harga padi & beras SAJA
- [ ] "harga pasar" → Return semua komoditas (karena umum)
- [ ] "budidaya cabai" → Return panduan cabai
- [ ] Cek penomoran: Ada 1, 2, 3 dan a, b, c?
- [ ] Cek paragraf: Ada line break pemisah?
- [ ] Cek action items: Ada "📌 Langkah Selanjutnya" bernomor?

---

## 🎉 Kesimpulan

Chatbot Agrigo sekarang:

1. ✅ **Lebih Responsif** - Menangkap pertanyaan spesifik dengan akurat
2. ✅ **Lebih Fokus** - Jawab hanya yang ditanya, tidak melebar
3. ✅ **Lebih Terstruktur** - Penomoran jelas, paragraf rapi
4. ✅ **Lebih Actionable** - Selalu ada langkah konkret di akhir
5. ✅ **Lebih User-Friendly** - Mudah dipahami, tidak bikin bingung

**Tanpa mengubah tampilan UI sama sekali!** 🎨✨
