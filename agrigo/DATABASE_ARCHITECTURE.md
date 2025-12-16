# Database Architecture - Agrigo

## 🗄️ **2 Database Berbeda!**

Aplikasi Agrigo menggunakan **2 sistem database terpisah**:

---

## 📱 **1. MOBILE APP (Flutter) → Firebase Firestore**

### **Database:** Firebase Firestore (NoSQL Cloud Database)
- **Type:** NoSQL Document Database
- **Location:** Cloud (Google Firebase)
- **Access:** Real-time, Offline-capable
- **Management:** Firebase Console (https://console.firebase.google.com)

### **Struktur Collections:**

```
firestore/
├── users/                    # User profiles
│   ├── {userId}/
│   │   ├── name
│   │   ├── email
│   │   ├── phone
│   │   ├── region
│   │   ├── profileImage
│   │   ├── crops[]
│   │   ├── role
│   │   └── createdAt
│
├── transactions/             # Financial transactions (Optional)
│   ├── {transactionId}/
│   │   ├── userId
│   │   ├── type (income/expense)
│   │   ├── amount
│   │   ├── commodity
│   │   ├── description
│   │   └── date
│
├── schedules/                # Planting schedules (Optional)
│   ├── {scheduleId}/
│   │   ├── userId
│   │   ├── commodity
│   │   ├── startDate
│   │   ├── endDate
│   │   └── status
│
└── notifications/            # Push notifications
    ├── {notificationId}/
        ├── userId
        ├── title
        ├── message
        └── timestamp
```

### **Kenapa Firestore?**
- ✅ **Real-time sync** - Data update langsung tanpa refresh
- ✅ **Offline mode** - App tetap jalan tanpa internet
- ✅ **Scalable** - Auto-scale untuk jutaan user
- ✅ **Firebase Auth** - Terintegrasi dengan Google/Facebook login
- ✅ **Free tier** - Generous free quota
- ✅ **No server setup** - Fully managed cloud

### **Current Usage:**
```dart
// Di mobile app
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .get();
```

---

## 🌐 **2. WEB ADMIN (Laravel) → MySQL**

### **Database:** MySQL (SQL Relational Database)
- **Type:** SQL Relational Database
- **Location:** Local (XAMPP/Laragon) atau Server
- **Access:** HTTP API (Laravel)
- **Management:** phpMyAdmin / HeidiSQL

### **Struktur Tables:**

```sql
agrigo_database/
├── users                     # Admin & petani accounts
│   ├── id
│   ├── name
│   ├── email
│   ├── password (hashed)
│   ├── role (admin/farmer)
│   └── created_at
│
├── user_profiles             # Extended profile data
│   ├── id
│   ├── user_id (FK)
│   ├── phone
│   ├── address
│   └── location
│
├── commodities               # Master data komoditas
│   ├── id
│   ├── name (Padi, Jagung, Cabai)
│   ├── type (Padi-padian, Sayuran)
│   ├── description
│   └── is_active
│
├── transactions              # Financial records
│   ├── id
│   ├── user_id (FK)
│   ├── commodity_id (FK)
│   ├── type (income/expense)
│   ├── amount
│   ├── description
│   └── date
│
├── schedules                 # Planting schedules
│   ├── id
│   ├── user_id (FK)
│   ├── commodity_id (FK)
│   ├── start_date
│   ├── end_date
│   ├── status (active/completed/cancelled)
│   └── notes
│
├── articles                  # Tips & articles
│   ├── id
│   ├── title
│   ├── content
│   └── category
│
├── notifications             # System notifications
│   ├── id
│   ├── user_id (FK)
│   ├── title
│   ├── message
│   └── is_read
│
├── chatbot_faqs              # Chatbot responses
│   ├── id
│   ├── question
│   ├── answer
│   └── category
│
├── app_settings              # App configuration
│   ├── id
│   ├── key
│   └── value
│
├── activity_logs             # User activity tracking
│   ├── id
│   ├── user_id (FK)
│   ├── action
│   ├── description
│   └── timestamp
│
└── weather_data              # Weather cache (optional)
    ├── id
    ├── location
    ├── temperature
    ├── condition
    └── updated_at
```

### **Kenapa MySQL?**
- ✅ **Relational** - Complex queries, joins, reporting
- ✅ **Web Admin** - Dashboard untuk monitoring
- ✅ **Mature** - Proven, stable, well-documented
- ✅ **Analytics** - Advanced reporting & statistics
- ✅ **Backup** - Easy backup & restore
- ✅ **Integration** - Works with Laravel perfectly

### **Current Usage:**
```php
// Di Laravel API
use App\Models\Transaction;

$transactions = Transaction::where('user_id', $userId)
    ->with('commodity')
    ->orderBy('date', 'desc')
    ->get();
```

---

## 🔄 **Perbandingan:**

| Feature | Firebase Firestore | MySQL (Laravel) |
|---------|-------------------|-----------------|
| **Type** | NoSQL Document | SQL Relational |
| **Location** | Cloud (Google) | Local/Server |
| **Access** | Direct from mobile | Via HTTP API |
| **Real-time** | ✅ Yes (built-in) | ❌ No (polling/websocket) |
| **Offline** | ✅ Yes | ❌ No |
| **Complex Queries** | ❌ Limited | ✅ Excellent |
| **Authentication** | ✅ Built-in (Firebase Auth) | ⚠️ Manual (Laravel Sanctum) |
| **Cost** | Pay-as-you-go | One-time (server) |
| **Setup** | Zero setup | Requires server |
| **Best For** | Mobile real-time data | Web admin, analytics |

---

## 🎯 **Strategi Arsitektur Saat Ini:**

### **HYBRID APPROACH** (Best of Both Worlds)

```
┌─────────────────────────────────────────────────────────┐
│                    MOBILE APP (Flutter)                 │
└───────────────┬─────────────────────────┬───────────────┘
                │                         │
                ▼                         ▼
    ┌───────────────────────┐ ┌──────────────────────────┐
    │   Firebase Firestore  │ │    Laravel API (MySQL)   │
    │   (Primary Mobile)    │ │    (Optional Backend)    │
    ├───────────────────────┤ ├──────────────────────────┤
    │ • User Profiles       │ │ • Transactions           │
    │ • Google/FB Auth      │ │ • Schedules              │
    │ • Real-time Sync      │ │ • Commodities            │
    │ • Notifications       │ │ • Articles               │
    │ • Offline Support     │ │ • Analytics              │
    └───────────────────────┘ └──────────┬───────────────┘
                                         │
                                         ▼
                              ┌──────────────────────┐
                              │   Web Admin Panel    │
                              │   (Laravel Blade)    │
                              │ • Monitoring         │
                              │ • Reports            │
                              │ • User Management    │
                              └──────────────────────┘
```

### **Current Implementation:**

**✅ AKTIF: Firebase Firestore (Mobile)**
- User authentication (Google, Email/Password)
- User profiles
- Real-time notifications

**⏸️ OPTIONAL: Laravel API (MySQL)**
- Tersedia tapi belum fully integrated ke mobile
- Bisa digunakan untuk:
  - Transactions management
  - Advanced reporting
  - Web admin dashboard
  - Analytics

---

## 📊 **3 Opsi Integrasi:**

### **Opsi 1: Firebase Only (CURRENT - SIMPLEST)**

```
Mobile App → Firebase Firestore
           → Firebase Auth
```

**Pros:**
- ✅ Paling simple, zero backend setup
- ✅ Real-time sync out of the box
- ✅ Offline-capable
- ✅ No server maintenance

**Cons:**
- ❌ Limited complex queries
- ❌ No built-in web admin (harus buat sendiri)
- ❌ Pay-as-you-go pricing

**Best for:** MVP, small-medium scale

---

### **Opsi 2: Firebase + Laravel API (HYBRID)**

```
Mobile App → Firebase (Auth, Profiles)
           ↓
           → Laravel API (Transactions, Schedules)
           ↓
           → MySQL (Analytics, Reports)
           
Web Admin → Laravel Dashboard → MySQL
```

**Pros:**
- ✅ Best of both worlds
- ✅ Real-time auth via Firebase
- ✅ Complex queries via MySQL
- ✅ Web admin dashboard ready
- ✅ Advanced analytics

**Cons:**
- ⚠️ More complex architecture
- ⚠️ Need to maintain 2 databases
- ⚠️ Sync issues possible

**Best for:** Growing app, need web dashboard

---

### **Opsi 3: Laravel Only (FULL BACKEND)**

```
Mobile App → Laravel API → MySQL
           
Web Admin → Laravel Dashboard → MySQL
```

**Pros:**
- ✅ Single source of truth
- ✅ Full control over data
- ✅ No vendor lock-in
- ✅ Complex queries easy

**Cons:**
- ❌ No real-time (need websockets)
- ❌ No offline mode
- ❌ Must implement auth from scratch
- ❌ More backend work

**Best for:** Enterprise apps, full control needed

---

## ✅ **REKOMENDASI SAYA:**

### **Untuk Project Agrigo (Petani Target):**

**Gunakan OPSI 1: Firebase Only (Current Setup)**

**Alasan:**
1. ✅ **Sudah jalan** - Google login, email auth working
2. ✅ **Zero maintenance** - No server setup needed
3. ✅ **Offline mode** - Petani bisa tetap input data tanpa internet
4. ✅ **Real-time** - Data sync instant
5. ✅ **Scalable** - Bisa handle ribuan petani
6. ✅ **Free tier** - Cukup untuk development & small scale

**Yang Sudah Working:**
- ✅ User authentication (Google + Email/Password)
- ✅ User profiles di Firestore
- ✅ Firebase Storage (gambar)
- ✅ Firebase Messaging (notifikasi)

**Yang Bisa Ditambah (Tetap Firestore):**
- 📊 Transactions di Firestore (bukan MySQL)
- 📅 Schedules di Firestore
- 📰 Articles di Firestore
- 💬 Chatbot FAQ di Firestore

**Kapan Pakai Laravel?**
- Jika butuh **web dashboard** untuk admin
- Jika butuh **advanced analytics**
- Jika butuh **complex reporting**
- Jika user base > 10,000

---

## 🚀 **Action Plan:**

### **Phase 1: Stick with Firebase (DONE)**
- ✅ Authentication working
- ✅ User profiles working
- ✅ Real-time notifications

### **Phase 2: Add Features to Firestore (NEXT)**
```dart
// Add transactions to Firestore
await FirebaseFirestore.instance
  .collection('transactions')
  .add({
    'userId': userId,
    'type': 'income',
    'amount': 500000,
    'description': 'Penjualan padi',
    'date': Timestamp.now(),
  });
```

### **Phase 3: Optional Web Admin (FUTURE)**
- Build simple Firebase web admin
- Or integrate Laravel API later if needed

---

## 🔧 **Database Management:**

### **Firebase Firestore:**

**View Data:**
1. Buka https://console.firebase.google.com
2. Pilih project: `agrigo-bddde`
3. Klik "Firestore Database"
4. Browse collections

**Backup:**
```bash
# Export Firestore
firebase firestore:export gs://agrigo-bddde.appspot.com/backups
```

### **MySQL (Laravel):**

**View Data:**
1. Buka phpMyAdmin (http://localhost/phpmyadmin)
2. Pilih database: `agrigo_database`
3. Browse tables

**Backup:**
```bash
# Export MySQL
mysqldump -u root agrigo_database > backup.sql
```

---

## 📝 **Summary:**

**Mobile App Database:**
- 📱 **Firebase Firestore** (NoSQL Cloud)
- 🔥 Real-time, offline-capable
- ✅ Currently ACTIVE & WORKING

**Web Admin Database:**
- 🌐 **MySQL** (SQL Local)
- 📊 For complex queries, analytics
- ⏸️ Available but NOT connected to mobile yet

**Recommendation:**
- 👍 **Stick with Firebase** for mobile
- 🎯 Add transactions/schedules to **Firestore** (not MySQL)
- 🔮 Use Laravel API **only if** you need web admin dashboard

**Current Status:**
- ✅ Firebase: 100% working (auth, profiles)
- ⏸️ Laravel API: Ready but optional
- 🎯 Next: Add features to Firestore, not MySQL

---

**Kesimpulan:** Anda **TIDAK PERLU** Laravel/MySQL untuk mobile app. Firebase sudah cukup dan lebih baik untuk use case Anda! 🚀
