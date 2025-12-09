<!-- @format -->

# 🚀 QUICK START - Chatbot Management

## ✅ Setup Database (Satu Kali Saja)

### 1. Stop Server

Jika server sedang running, tekan `Ctrl+C` di terminal

### 2. Fresh Migration + Seed

```powershell
cd "e:\SEMESTER 5\agrigo\agrigo\web\agrigo-admin"
php artisan migrate:fresh --seed
```

Output yang benar:

```
✅ Database seeded successfully!
📧 Admin Login: admin@agrigo.com
🔑 Password: admin123
```

### 3. Start Server

```powershell
php artisan serve
```

Server running di: **http://127.0.0.1:8000**

---

## 🎯 Akses Chatbot Management

### 1. Login Web Admin

- URL: **http://127.0.0.1:8000/admin/login**
- Email: **admin@agrigo.com**
- Password: **admin123**

### 2. Menu Chatbot FAQs

Setelah login, klik menu **"Chatbot FAQs"** di sidebar (icon robot 🤖)

Atau langsung ke: **http://127.0.0.1:8000/admin/chatbot-faqs**

---

## 📊 Fitur Chatbot Management

### Dashboard Statistics

- **Total FAQs:** Jumlah semua FAQ
- **Active FAQs:** FAQ yang visible ke user
- **Inactive FAQs:** FAQ yang di-hide
- **Total Usage:** Berapa kali FAQ digunakan

### Filter & Search

- **Search:** Cari berdasarkan question, answer, atau keywords
- **Category:** Filter by Pertanian, Cuaca, Komoditas, dll
- **Status:** Filter Active/Inactive

### Actions

- ✏️ **Edit** - Update FAQ
- 🔄 **Toggle Status** - Active/Inactive
- 🔃 **Reset Usage** - Reset counter ke 0
- 🗑️ **Delete** - Hapus FAQ

---

## ➕ Tambah FAQ Baru

### 1. Klik "Add New FAQ"

### 2. Isi Form:

**Category** (Required)

```
Pilih atau ketik: Pertanian, Cuaca, Komoditas, Keuangan, Jadwal, Umum
```

**Question** (Required)

```
Contoh: "Bagaimana cara menanam jagung?"
```

**Answer** (Required)

```
Contoh: "Jagung ditanam dengan jarak 70-75 cm antar baris dan 20-25 cm antar tanaman. Gunakan benih berkualitas, berikan pupuk dasar saat tanam, dan lakukan penyiangan rutin. Panen setelah 90-110 hari."
```

**Keywords** (Required - pisah dengan koma)

```
Contoh: jagung, corn, tanaman jagung, menanam jagung
```

**Active**

```
✅ Checked = Visible ke user mobile app
☐ Unchecked = Hidden dari user
```

### 3. Klik "Save FAQ"

FAQ baru **langsung tersedia** di mobile app!

---

## 📱 Test di Mobile App

### 1. Smart Search API

```dart
import 'package:agrigo/services/api_service.dart';

// Di chatbot page
Future<void> handleUserQuestion(String question) async {
  // Smart search - auto-find best answer
  final results = await ApiService.smartSearchChatbot(question);

  if (results.isNotEmpty) {
    // Get best match (highest score)
    final bestAnswer = results.first;

    // Show to user
    showBotMessage(bestAnswer['answer']);

    // Usage count otomatis bertambah!
  } else {
    showBotMessage('Maaf, belum ada jawaban untuk pertanyaan ini.');
  }
}
```

### 2. Get All FAQs

```dart
final faqs = await ApiService.getChatbotFaqs();
print('Total FAQs: ${faqs.length}');

for (var faq in faqs) {
  print('Q: ${faq['question']}');
  print('A: ${faq['answer']}');
}
```

### 3. Get by Category

```dart
// Tampilkan FAQ per kategori
final pertanianFaqs = await ApiService.getChatbotFaqsByCategory('Pertanian');
```

---

## 📋 Sample Data (14 FAQs)

Setelah migrate:fresh --seed, otomatis ada 14 FAQs:

### 📗 Pertanian (3 FAQs)

1. Apa itu tanaman padi?
2. Bagaimana cara menanam jagung?
3. Kapan waktu terbaik untuk memberi pupuk?

### 🌤️ Cuaca (2 FAQs)

4. Bagaimana cara cek cuaca?
5. Apa yang harus dilakukan saat musim hujan?

### 🌾 Komoditas (2 FAQs)

6. Komoditas apa saja yang tersedia?
7. Bagaimana merawat tanaman cabai?

### 💰 Keuangan (2 FAQs)

8. Bagaimana cara mencatat transaksi?
9. Dimana melihat laporan keuangan?

### 📅 Jadwal (2 FAQs)

10. Bagaimana membuat jadwal tanam?
11. Bagaimana cara kerja notifikasi?

### ℹ️ Umum (3 FAQs)

12. Apa itu Agrigo?
13. Bagaimana cara mendapat bantuan?
14. Bagaimana cara membuat akun?

---

## 🔄 Flow Update FAQ

```
1. Admin login web admin
   ↓
2. Klik menu "Chatbot FAQs"
   ↓
3. Edit FAQ atau Add New
   ↓
4. Save changes
   ↓
5. Data langsung tersimpan di database
   ↓
6. Mobile app auto-update (tidak perlu restart)
   ↓
7. User dapat jawaban terbaru
   ↓
8. Usage count bertambah otomatis
```

---

## 🎯 Use Cases

### Use Case 1: Tambah FAQ Baru

**Scenario:** User sering tanya tentang hama wereng

**Action:**

1. Login web admin
2. Chatbot FAQs → Add New FAQ
3. Category: **Pertanian**
4. Question: **Bagaimana mengatasi hama wereng?**
5. Answer: **Wereng dapat diatasi dengan: 1) Tanam varietas tahan wereng, 2) Jaga kebersihan sawah, 3) Kurangi pemupukan nitrogen berlebih, 4) Semprot insektisida jika populasi tinggi.**
6. Keywords: **wereng, hama wereng, pest control, hama padi**
7. Save

**Result:** User mobile app langsung bisa tanya dan dapat jawaban!

### Use Case 2: Update FAQ Lama

**Scenario:** Info pupuk sudah outdated

**Action:**

1. Chatbot FAQs → Search "pupuk"
2. Klik Edit
3. Update answer dengan info terbaru
4. Save

**Result:** User dapat info terbaru!

### Use Case 3: Disable FAQ Sementara

**Scenario:** Info sedang diverifikasi

**Action:**

1. Chatbot FAQs → Cari FAQ
2. Klik toggle status → Inactive
3. Verify info
4. Toggle kembali → Active

**Result:** FAQ hidden sementara, then visible lagi

---

## 📊 Analytics

### Monitor Usage Count

Lihat FAQ mana yang paling sering diakses:

- FAQ dengan usage tinggi = topik penting
- FAQ dengan usage rendah = mungkin perlu edit keyword
- FAQ tidak pernah diakses = mungkin tidak relevan

### Action Based on Data

- **High usage:** Expand jawaban, tambah related FAQs
- **Low usage:** Update keywords, improve question phrasing
- **Zero usage:** Consider delete atau merge dengan FAQ lain

---

## 🐛 Troubleshooting

### FAQ tidak muncul di mobile app

✅ **Check:**

1. Status FAQ = Active?
2. Server running?
3. Mobile app online?
4. Keywords match dengan user query?

### Usage count tidak naik

✅ **Pastikan:**

- Mobile app use `getChatbotFaq(id)` atau `smartSearchChatbot()`
- Bukan `getChatbotFaqs()` yang tidak increment counter

### Search tidak akurat

✅ **Fix:**

- Tambah lebih banyak keywords
- Gunakan variasi kata (padi, rice, beras)
- Test dengan `smart-search` endpoint

---

## ✅ Checklist Setup

- [ ] Database migrated fresh
- [ ] Seeder running successfully
- [ ] Server running (php artisan serve)
- [ ] Login web admin berhasil
- [ ] Menu "Chatbot FAQs" ada di sidebar
- [ ] 14 sample FAQs muncul
- [ ] Bisa add new FAQ
- [ ] Bisa edit FAQ
- [ ] Bisa toggle status
- [ ] Mobile app bisa akses API

---

## 🎉 Done!

Sekarang chatbot Agrigo bisa **dikontrol penuh dari web admin**!

**Admin bisa:**
✅ Tambah FAQ kapan saja
✅ Edit jawaban FAQ
✅ Monitor usage statistics
✅ Control visibility (active/inactive)
✅ Organize by category
✅ Track popular topics

**User mobile app dapat:**
✅ Jawaban real-time
✅ FAQ selalu update
✅ Smart search dengan scoring
✅ Category-based browsing
✅ Keyword matching

---

## 📞 Support

Jika ada masalah:

1. Check error di terminal Laravel
2. Check response API di browser/Postman
3. Lihat file CHATBOT_FAQ_GUIDE.md untuk detail implementasi
4. Lihat file INTEGRATION_GUIDE.md untuk API documentation
