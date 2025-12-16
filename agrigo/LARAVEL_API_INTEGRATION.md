# Laravel API Integration - Quick Setup

## ✅ Status Sekarang:

1. **Laravel API Server:** ✅ RUNNING di http://127.0.0.1:8000
2. **ApiService:** ✅ READY dengan endpoints lengkap
3. **Test Screen:** ✅ TERSEDIA di Login Page

---

## 🚀 Cara Test API dari Mobile:

### **Step 1: Jalankan App di Emulator**

```powershell
cd E:\basedproject\agrigo\agrigo
flutter run
```

### **Step 2: Di Login Page, klik tombol:**

```
"Test Laravel API Connection"
```

### **Step 3: Klik "Test Connection"**

Jika berhasil, akan muncul:
```
✅ Connection SUCCESS!
X komoditas ditemukan
```

Jika gagal, akan muncul error + tips troubleshooting.

---

## 📡 Base URL Configuration:

File: `lib/services/api_service.dart`

```dart
// ACTIVE BASE URL - Ganti sesuai kebutuhan
static const String baseUrl = baseUrlLocalhost; // Default: emulator
```

### Pilihan Base URL:

**1. Emulator Android (Default):**
```dart
static const String baseUrl = 'http://10.0.2.2:8000/api';
```
- `10.0.2.2` = alias untuk `127.0.0.1` dari emulator
- Gunakan ini saat testing di emulator

**2. Physical Device (WiFi sama):**
```dart
static const String baseUrl = 'http://YOUR_PC_IP:8000/api';
```
- Cek IP PC: `ipconfig` → cari IPv4 Address (misal: 192.168.1.14)
- PC dan HP harus di WiFi yang sama
- Ganti `YOUR_PC_IP` dengan IP PC Anda

**3. Ngrok (Testing dari mana saja):**
```dart
static const String baseUrl = 'https://YOUR_NGROK_URL/api';
```
- Install ngrok: https://ngrok.com
- Run: `ngrok http 8000`
- Copy HTTPS URL ke base URL
- Bisa test dari device manapun

---

## 🔧 API Endpoints Available:

### Authentication:
- `POST /api/register` - Register user baru
- `POST /api/login` - Login user
- `POST /api/logout` - Logout
- `GET /api/user` - Get user profile

### Commodities (Komoditas):
- `GET /api/commodities` - List semua komoditas
- `GET /api/commodities/{id}` - Detail komoditas
- `GET /api/commodities/type/{type}` - Filter by type
- `GET /api/commodity-types` - List semua types

### Transactions (Keuangan Petani):
- `GET /api/transactions` - List transaksi user
- `POST /api/transactions` - Buat transaksi baru
- `GET /api/transactions/summary` - Ringkasan income/expense
- `DELETE /api/transactions/{id}` - Hapus transaksi

### Schedules (Jadwal Tanam):
- `GET /api/schedules` - List jadwal tanam
- `POST /api/schedules` - Buat jadwal baru
- `PUT /api/schedules/{id}` - Update jadwal
- `DELETE /api/schedules/{id}` - Hapus jadwal

### Weather:
- `GET /api/weather` - Data cuaca sesuai lokasi user

---

## 🗄️ Database Setup (Jika Belum):

### **Check Database:**

```powershell
cd E:\basedproject\agrigo\agrigo\web\agrigo-admin
php artisan migrate:status
```

### **Setup Fresh Database:**

```powershell
php artisan migrate:fresh
php artisan db:seed --class=AgrigoSeeder
```

**Data yang akan terisi:**
- 3 users (admin, Budi, Siti)
- 12 komoditas (Padi, Jagung, Cabai, dll)
- Sample transactions
- Sample schedules

---

## 🔐 Authentication Flow:

### **Opsi 1: Pakai Firebase Auth (Current)**

User login dengan Firebase → data disimpan di Firestore:
```
✅ Google Sign-In
✅ Email/Password
⚠️ Facebook (Development Mode)
```

**Tidak perlu Laravel API token** untuk ini.

---

### **Opsi 2: Laravel API Auth (Optional)**

Jika mau pakai Laravel API untuk authentication:

```dart
// Di login page
final result = await ApiService.login(email, password);
final token = result['token'];
await ApiService.saveToken(token); // Save to SharedPreferences

// Sekarang bisa hit endpoint yang perlu auth:
final transactions = await ApiService.getTransactions(); // Auto include token
```

---

## 📊 Integration Strategy:

### **Current Setup (Firebase + Laravel):**

**Firebase (SUDAH JALAN):**
- ✅ User Authentication
- ✅ User Profiles
- ✅ Real-time sync

**Laravel API (BARU):**
- 📊 Transactions (income/expense)
- 🌾 Commodities (master data)
- 📅 Schedules (planting schedule)
- 📰 Articles/Tips
- 🌤️ Weather data

**Workflow:**
1. User login via Firebase (Google/Email)
2. Setelah login, app fetch data dari Laravel API
3. Transaksi/jadwal disimpan ke Laravel MySQL
4. User profile tetap di Firebase Firestore

---

## 🧪 Testing Checklist:

- [ ] Laravel server running (`php artisan serve`)
- [ ] Database sudah di-migrate & seed
- [ ] Base URL sesuai (emulator vs physical device)
- [ ] App running di device/emulator
- [ ] Klik "Test Laravel API Connection" di Login Page
- [ ] "Test Connection" button → Should show commodities
- [ ] "Test Transactions" → Will fail (need token) → Expected behavior

---

## 🎯 Next Integration Steps:

### **1. Connect Transactions Page to API**

Update `lib/screens/transactions_screen.dart`:
```dart
// Replace Firestore fetch with API
final transactions = await ApiService.getTransactions();
```

### **2. Connect Schedules Page to API**

Update `lib/screens/schedules_screen.dart`:
```dart
final schedules = await ApiService.getSchedules();
```

### **3. Hybrid Strategy (Best of Both):**

- **Firebase:** Authentication, user profiles, real-time
- **Laravel API:** Transactions, schedules, master data, analytics

Benefit:
- Firebase = fast, real-time, offline-capable
- Laravel API = complex queries, reporting, web admin integration

---

## 📞 Troubleshooting:

### **Error: Connection refused**

**Solution:**
1. Pastikan Laravel server running:
   ```powershell
   php artisan serve
   ```

2. Cek base URL:
   - Emulator: `http://10.0.2.2:8000/api`
   - Physical: `http://YOUR_PC_IP:8000/api`

### **Error: No application encryption key**

**Solution:**
```powershell
cd E:\basedproject\agrigo\agrigo\web\agrigo-admin
php artisan key:generate
```

### **Error: Database connection failed**

**Solution:**
1. Check `.env` file:
   ```
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=agrigo_db
   DB_USERNAME=root
   DB_PASSWORD=
   ```

2. Start MySQL (XAMPP/Laragon)

3. Run migrations:
   ```powershell
   php artisan migrate:fresh
   ```

---

## 🌐 For Physical Device Testing:

### **Option 1: WiFi Network (Recommended)**

1. PC dan HP connect ke WiFi yang sama
2. Cek IP PC:
   ```powershell
   ipconfig
   ```
3. Update base URL:
   ```dart
   static const String baseUrl = 'http://192.168.1.XX:8000/api';
   ```
4. Rebuild app & test

### **Option 2: Ngrok (Easiest)**

1. Install ngrok: https://ngrok.com/download
2. Run:
   ```powershell
   ngrok http 8000
   ```
3. Copy HTTPS URL (e.g., https://abc123.ngrok.io)
4. Update base URL:
   ```dart
   static const String baseUrl = 'https://abc123.ngrok.io/api';
   ```
5. Rebuild & test (works anywhere!)

---

## ✅ Summary:

**What's Working:**
- ✅ Laravel API Server (port 8000)
- ✅ ApiService with all endpoints
- ✅ Test screen integrated
- ✅ Firebase Authentication (Google + Email)

**Next Steps:**
1. Test API connection dari emulator
2. Fix database jika ada error
3. Connect existing screens ke API
4. Deploy (optional): Ngrok atau server cloud

**Files Modified:**
- `lib/services/api_service.dart` - Updated base URLs
- `lib/screens/api_test_screen.dart` - Created test screen
- `lib/pages/login_page.dart` - Added test button

**Laravel Status:**
- Server: http://127.0.0.1:8000
- Admin: http://127.0.0.1:8000/admin/login
- API: http://127.0.0.1:8000/api/*

---

Good luck! 🚀
