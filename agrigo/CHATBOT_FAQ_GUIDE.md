<!-- @format -->

# 🤖 Chatbot FAQ Management - Update Guide

## ✨ Fitur Baru: Chatbot FAQ dari Web Admin

Sekarang admin bisa **mengelola FAQ chatbot** langsung dari web admin! Data FAQ akan **otomatis tersedia di mobile app** via API.

---

## 📱 Cara Kerja Data Sync

```
Web Admin (Add/Edit FAQ)
    ↓
MySQL Database
    ↓
API Endpoint (/api/chatbot/faqs)
    ↓
Mobile App Chatbot (Auto-update)
```

**Setiap perubahan di web admin langsung tersedia di mobile app!**

---

## 🎯 Fitur Web Admin

### 1. Halaman Management

**URL:** http://127.0.0.1:8000/admin/chatbot-faqs

**Fitur:**

- ✅ View semua FAQs dengan pagination
- ✅ Filter by category (Pertanian, Cuaca, Komoditas, dll)
- ✅ Filter by status (Active/Inactive)
- ✅ Search by question, answer, atau keywords
- ✅ Toggle Active/Inactive status
- ✅ Reset usage count
- ✅ Statistics dashboard

### 2. Add New FAQ

**Formulir:**

- **Category:** Pertanian, Cuaca, Komoditas, Keuangan, Jadwal, Umum
- **Question:** Pertanyaan yang akan muncul
- **Answer:** Jawaban lengkap
- **Keywords:** Kata kunci untuk pencarian (pisah dengan koma)
- **Status:** Active/Inactive

### 3. Edit FAQ

- Update question, answer, keywords
- Lihat usage statistics
- Toggle active status

### 4. Auto-tracking

- **Usage Count:** Berapa kali FAQ diakses user
- **Created/Updated timestamps:** Track perubahan

---

## 🔌 API Endpoints untuk Mobile App

### 1. Get All Active FAQs

```
GET /api/chatbot/faqs
```

**Response:**

```json
{
  "success": true,
  "message": "FAQs retrieved successfully",
  "data": [
    {
      "id": 1,
      "category": "Pertanian",
      "question": "Apa itu tanaman padi?",
      "answer": "Padi adalah tanaman makanan pokok...",
      "keywords": ["padi", "rice", "beras"],
      "is_active": true,
      "usage_count": 15
    }
  ]
}
```

### 2. Get FAQs by Category

```
GET /api/chatbot/faqs/category/{category}
```

**Example:**

```
GET /api/chatbot/faqs/category/Pertanian
```

### 3. Get All Categories

```
GET /api/chatbot/faqs/categories
```

**Response:**

```json
{
  "success": true,
  "data": ["Pertanian", "Cuaca", "Komoditas", "Keuangan", "Jadwal", "Umum"]
}
```

### 4. Search FAQs

```
GET /api/chatbot/faqs/search?q={query}
```

**Example:**

```
GET /api/chatbot/faqs/search?q=padi
```

### 5. Smart Search (Recommended!)

```
GET /api/chatbot/faqs/smart-search?q={query}
```

**Fitur:**

- Scoring system berdasarkan keyword match
- Auto-increment usage count untuk best match
- Sorted by relevance

**Example:**

```
GET /api/chatbot/faqs/smart-search?q=cara tanam padi
```

**Response:**

```json
{
  "success": true,
  "message": "Smart search completed",
  "data": [
    {
      "id": 1,
      "category": "Pertanian",
      "question": "Apa itu tanaman padi?",
      "answer": "...",
      "match_score": 15,
      "usage_count": 16
    }
  ]
}
```

### 6. Get FAQ by ID

```
GET /api/chatbot/faqs/{id}
```

**Note:** Automatically increments usage_count!

---

## 📱 Implementasi di Flutter

### 1. Import Service

```dart
import 'package:agrigo/services/api_service.dart';
```

### 2. Get All FAQs

```dart
Future<void> loadFaqs() async {
  final faqs = await ApiService.getChatbotFaqs();

  for (var faq in faqs) {
    print('Q: ${faq['question']}');
    print('A: ${faq['answer']}');
    print('Category: ${faq['category']}');
    print('Keywords: ${faq['keywords']}');
    print('---');
  }
}
```

### 3. Get FAQs by Category

```dart
// Load FAQs untuk kategori tertentu
Future<void> loadPertanianFaqs() async {
  final faqs = await ApiService.getChatbotFaqsByCategory('Pertanian');
  print('Found ${faqs.length} FAQs in Pertanian category');
}
```

### 4. Search FAQs

```dart
// Search berdasarkan keyword user
Future<void> searchFaqs(String query) async {
  final results = await ApiService.searchChatbotFaqs(query);

  if (results.isNotEmpty) {
    print('Found ${results.length} matching FAQs');
    // Display results to user
  } else {
    print('No FAQs found for: $query');
  }
}
```

### 5. Smart Search (Recommended!)

```dart
// Smart search dengan scoring
Future<Map<String, dynamic>?> getBestAnswer(String userQuestion) async {
  final results = await ApiService.smartSearchChatbot(userQuestion);

  if (results.isNotEmpty) {
    // Get best match (highest score)
    final bestMatch = results.first;

    print('Best Answer:');
    print('Q: ${bestMatch['question']}');
    print('A: ${bestMatch['answer']}');
    print('Score: ${bestMatch['match_score']}');

    return bestMatch;
  }

  return null;
}
```

### 6. Complete Chatbot Implementation

```dart
import 'package:flutter/material.dart';
import 'package:agrigo/services/api_service.dart';

class ChatbotPage extends StatefulWidget {
  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool isLoading = false;

  // Load categories saat init
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    loadCategories();
    addBotMessage('👋 Halo! Saya Agrigo Bot. Ada yang bisa saya bantu?');
  }

  Future<void> loadCategories() async {
    final cats = await ApiService.getChatbotCategories();
    setState(() => categories = cats);
  }

  void addUserMessage(String text) {
    setState(() {
      messages.add({'type': 'user', 'text': text, 'time': DateTime.now()});
    });
  }

  void addBotMessage(String text) {
    setState(() {
      messages.add({'type': 'bot', 'text': text, 'time': DateTime.now()});
    });
  }

  Future<void> handleUserMessage(String message) async {
    addUserMessage(message);
    _messageController.clear();

    setState(() => isLoading = true);

    // Smart search untuk best answer
    final results = await ApiService.smartSearchChatbot(message);

    setState(() => isLoading = false);

    if (results.isNotEmpty) {
      final bestMatch = results.first;
      addBotMessage(bestMatch['answer']);

      // Jika ada multiple matches, suggest alternatives
      if (results.length > 1) {
        addBotMessage('📚 Topik terkait lainnya:');
        for (var i = 1; i < results.length && i < 3; i++) {
          addBotMessage('• ${results[i]['question']}');
        }
      }
    } else {
      addBotMessage('Maaf, saya tidak menemukan jawaban untuk pertanyaan Anda. Coba kata kunci lain atau hubungi admin.');

      // Show available categories
      if (categories.isNotEmpty) {
        addBotMessage('💡 Kategori yang tersedia: ${categories.join(', ')}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🤖 Agrigo Chatbot'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message['type'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message['text'],
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Loading indicator
          if (isLoading)
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  SizedBox(width: 16),
                  CircularProgressIndicator(strokeWidth: 2),
                  SizedBox(width: 12),
                  Text('Bot sedang mengetik...'),
                ],
              ),
            ),

          // Input field
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ketik pertanyaan...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        handleUserMessage(value.trim());
                      }
                    },
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    final message = _messageController.text.trim();
                    if (message.isNotEmpty) {
                      handleUserMessage(message);
                    }
                  },
                  icon: Icon(Icons.send),
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 📊 Sample Data

Seeder sudah include **14 FAQs** dalam 6 kategori:

### 📗 Pertanian (3 FAQs)

- Apa itu tanaman padi?
- Bagaimana cara menanam jagung?
- Kapan waktu terbaik untuk memberi pupuk?

### 🌤️ Cuaca (2 FAQs)

- Bagaimana cara cek cuaca?
- Apa yang harus dilakukan saat musim hujan?

### 🌾 Komoditas (2 FAQs)

- Komoditas apa saja yang tersedia?
- Bagaimana merawat tanaman cabai?

### 💰 Keuangan (2 FAQs)

- Bagaimana cara mencatat transaksi?
- Dimana melihat laporan keuangan?

### 📅 Jadwal (2 FAQs)

- Bagaimana membuat jadwal tanam?
- Bagaimana cara kerja notifikasi?

### ℹ️ Umum (3 FAQs)

- Apa itu Agrigo?
- Bagaimana cara mendapat bantuan?
- Bagaimana cara membuat akun?

---

## 🎯 Best Practices

### 1. **Gunakan Smart Search**

Smart search lebih baik karena:

- Scoring system untuk relevance
- Auto-increment usage count
- Sorted by best match

### 2. **Cache FAQs Locally**

```dart
// Load once, cache for offline use
Future<void> cacheFaqs() async {
  final faqs = await ApiService.getChatbotFaqs();
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('cached_faqs', json.encode(faqs));
}
```

### 3. **Show Quick Replies**

```dart
// Show popular categories as quick replies
Widget buildQuickReplies() {
  return Wrap(
    spacing: 8,
    children: categories.map((cat) {
      return ActionChip(
        label: Text(cat),
        onPressed: () {
          handleUserMessage('Tentang $cat');
        },
      );
    }).toList(),
  );
}
```

### 4. **Fallback to Admin Contact**

```dart
// If no answer found
if (results.isEmpty) {
  addBotMessage(
    'Maaf, saya belum bisa menjawab. '
    'Hubungi admin di support@agrigo.com atau '
    'klik tombol Contact Support di menu Profile.'
  );
}
```

---

## 🔄 Update Workflow

1. **Admin menambah FAQ baru di web admin**

   - Login ke http://127.0.0.1:8000/admin/chatbot-faqs
   - Klik "Add New FAQ"
   - Isi category, question, answer, keywords
   - Save

2. **FAQ langsung tersedia di API**

   - Tidak perlu restart server
   - Tidak perlu clear cache

3. **Mobile app auto-update**
   - User mengetik pertanyaan
   - App call smart-search API
   - Dapat jawaban terbaru dari database

---

## 🧪 Testing

### Test di API Tester:

http://127.0.0.1:8000/api-tester.html

### Test Manual di Browser:

```
# Get all FAQs
http://127.0.0.1:8000/api/chatbot/faqs

# Get categories
http://127.0.0.1:8000/api/chatbot/faqs/categories

# Search
http://127.0.0.1:8000/api/chatbot/faqs/search?q=padi

# Smart search
http://127.0.0.1:8000/api/chatbot/faqs/smart-search?q=cara tanam
```

---

## ✨ Features Summary

✅ **CRUD lengkap** di web admin  
✅ **14 sample FAQs** sudah ter-seed  
✅ **6 categories** (Pertanian, Cuaca, Komoditas, Keuangan, Jadwal, Umum)  
✅ **Smart search** dengan scoring  
✅ **Usage tracking** otomatis  
✅ **Real-time sync** mobile ↔ web  
✅ **Filter & pagination** di web admin  
✅ **Active/Inactive toggle**  
✅ **Keywords matching**

---

## 🎉 Ready to Use!

Chatbot FAQ system sudah siap digunakan! Admin bisa manage FAQ via web admin, dan semua perubahan langsung tersedia di mobile app.

**Next Steps:**

1. Migrate database: `php artisan migrate:fresh --seed`
2. Login web admin: admin@agrigo.com / admin123
3. Akses: http://127.0.0.1:8000/admin/chatbot-faqs
4. Test add/edit FAQ
5. Implement chatbot UI di mobile app
6. Test smart search functionality
