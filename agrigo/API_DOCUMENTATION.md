<!-- @format -->

# Agrigo API Documentation

## Base URL

```
http://127.0.0.1:8000/api
```

## Authentication

Semua endpoint (kecuali login/register) memerlukan token authentication:

```
Authorization: Bearer {token}
```

Token disimpan otomatis di SharedPreferences setelah login/register berhasil.

---

## 📱 Integrasi Mobile App → Web Admin

Data yang dibuat di aplikasi mobile akan **OTOMATIS** muncul di web admin dalam waktu real-time.

### Flow Data Sync:

1. User membuat transaksi di mobile app
2. ApiService.createTransaction() mengirim data ke Laravel API
3. Data tersimpan di database MySQL
4. Web admin langsung menampilkan data terbaru (refresh halaman)

---

## 🔐 Authentication Endpoints

### 1. Register

**POST** `/register`

**Body:**

```json
{
  "name": "Budi Santoso",
  "email": "budi@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "phone": "081234567890",
  "address": "Jl. Merdeka No. 123"
}
```

**Response:**

```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": 1,
      "name": "Budi Santoso",
      "email": "budi@example.com",
      "role": "farmer"
    },
    "token": "1|xxxxxxxxxxxxxxxxxxxxx"
  }
}
```

### 2. Login

**POST** `/login`

**Body:**

```json
{
  "email": "budi@example.com",
  "password": "password123"
}
```

**Response:**

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "name": "Budi Santoso",
      "email": "budi@example.com"
    },
    "token": "1|xxxxxxxxxxxxxxxxxxxxx"
  }
}
```

### 3. Logout

**POST** `/logout`

**Headers:** `Authorization: Bearer {token}`

**Response:**

```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

### 4. Get Profile

**GET** `/profile`

**Response:**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Budi Santoso",
    "email": "budi@example.com",
    "profile": {
      "phone": "081234567890",
      "address": "Jl. Merdeka No. 123",
      "location": null
    }
  }
}
```

### 5. Update Profile

**PUT** `/profile`

**Body:**

```json
{
  "name": "Budi Santoso Updated",
  "phone": "081234567890",
  "address": "Jl. Baru No. 456",
  "location": "-6.200000,106.816666"
}
```

---

## 🌾 Commodities Endpoints

### 1. Get All Commodities

**GET** `/commodities`

**Response:**

```json
{
  "success": true,
  "message": "Commodities retrieved successfully",
  "data": [
    {
      "id": 1,
      "name": "Padi",
      "type": "Padi-padian",
      "description": "Tanaman padi untuk bahan makanan pokok",
      "is_active": true
    }
  ]
}
```

### 2. Get Commodity by ID

**GET** `/commodities/{id}`

**Response:**

```json
{
  "success": true,
  "message": "Commodity retrieved successfully",
  "data": {
    "id": 1,
    "name": "Padi",
    "type": "Padi-padian",
    "description": "Tanaman padi untuk bahan makanan pokok",
    "is_active": true
  }
}
```

### 3. Get Commodities by Type

**GET** `/commodities/type/{type}`

**Example:** `/commodities/type/Sayuran`

**Response:**

```json
{
  "success": true,
  "message": "Commodities retrieved successfully",
  "data": [
    {
      "id": 5,
      "name": "Cabai",
      "type": "Sayuran",
      "description": "Cabai untuk bumbu masakan"
    }
  ]
}
```

### 4. Get All Commodity Types

**GET** `/commodity-types`

**Response:**

```json
{
  "success": true,
  "message": "Commodity types retrieved successfully",
  "data": [
    "Padi-padian",
    "Palawija",
    "Sayuran",
    "Buah-buahan",
    "Umbi-umbian",
    "Rempah-rempah"
  ]
}
```

---

## 💰 Transactions Endpoints

### 1. Get All Transactions

**GET** `/transactions`

**Response:**

```json
{
  "success": true,
  "message": "Transactions retrieved successfully",
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "commodity_id": 1,
      "type": "income",
      "amount": 5000000,
      "description": "Penjualan padi hasil panen",
      "date": "2024-12-01",
      "commodity": {
        "id": 1,
        "name": "Padi"
      },
      "user": {
        "id": 1,
        "name": "Budi Santoso"
      }
    }
  ]
}
```

### 2. Create Transaction (AUTO-SYNC KE WEB ADMIN)

**POST** `/transactions`

**Body:**

```json
{
  "type": "income",
  "amount": 5000000,
  "description": "Penjualan padi hasil panen",
  "date": "2024-12-01",
  "commodity_id": 1
}
```

**ATAU dengan commodity_name (auto-create jika belum ada):**

```json
{
  "type": "expense",
  "amount": 500000,
  "description": "Pembelian pupuk organik",
  "date": "2024-12-01",
  "commodity_name": "Pupuk Organik"
}
```

**Response:**

```json
{
  "success": true,
  "message": "Transaction created successfully",
  "data": {
    "id": 1,
    "user_id": 1,
    "commodity_id": 1,
    "type": "income",
    "amount": 5000000,
    "description": "Penjualan padi hasil panen",
    "date": "2024-12-01"
  }
}
```

### 3. Update Transaction

**PUT** `/transactions/{id}`

**Body:**

```json
{
  "type": "income",
  "amount": 6000000,
  "description": "Penjualan padi hasil panen (updated)",
  "date": "2024-12-01",
  "commodity_id": 1
}
```

### 4. Delete Transaction

**DELETE** `/transactions/{id}`

**Response:**

```json
{
  "success": true,
  "message": "Transaction deleted successfully"
}
```

### 5. Get Financial Summary

**GET** `/transactions/summary`

**Response:**

```json
{
  "success": true,
  "message": "Financial summary retrieved successfully",
  "data": {
    "total_transactions": 10,
    "income": 15000000,
    "expense": 5000000,
    "balance": 10000000,
    "income_count": 6,
    "expense_count": 4
  }
}
```

---

## 📅 Schedules Endpoints

### 1. Get All Schedules

**GET** `/schedules`

**Response:**

```json
{
  "success": true,
  "message": "Schedules retrieved successfully",
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "commodity_id": 1,
      "start_date": "2024-12-01",
      "end_date": "2024-12-31",
      "status": "active",
      "notes": "Jadwal tanam padi musim ini",
      "commodity": {
        "id": 1,
        "name": "Padi"
      }
    }
  ]
}
```

### 2. Create Schedule

**POST** `/schedules`

**Body:**

```json
{
  "commodity_id": 1,
  "start_date": "2024-12-01",
  "end_date": "2024-12-31",
  "status": "active",
  "notes": "Jadwal tanam padi musim ini"
}
```

### 3. Update Schedule

**PUT** `/schedules/{id}`

**Body:**

```json
{
  "commodity_id": 1,
  "start_date": "2024-12-01",
  "end_date": "2024-12-31",
  "status": "completed",
  "notes": "Jadwal tanam padi selesai"
}
```

### 4. Delete Schedule

**DELETE** `/schedules/{id}`

---

## 📲 Cara Menggunakan di Flutter

### 1. Import Service

```dart
import 'package:agrigo/services/api_service.dart';
```

### 2. Create Transaction (Auto-sync ke Web Admin)

```dart
// Di dalam fungsi async
final result = await ApiService.createTransaction(
  type: 'income', // atau 'expense'
  amount: 5000000,
  description: 'Penjualan padi hasil panen',
  date: '2024-12-01',
  commodityId: 1, // ID dari commodity
  // ATAU gunakan commodityName jika belum ada di database
  // commodityName: 'Padi Baru',
);

if (result != null) {
  print('Transaction berhasil dibuat dan tersimpan di web admin!');
  print('ID: ${result['id']}');
} else {
  print('Gagal membuat transaction');
}
```

### 3. Get Commodities

```dart
final commodities = await ApiService.getCommodities();
print('Total commodities: ${commodities.length}');

for (var commodity in commodities) {
  print('${commodity['name']} - ${commodity['type']}');
}
```

### 4. Get Financial Summary

```dart
final summary = await ApiService.getFinancialSummary();
if (summary != null) {
  print('Income: Rp ${summary['income']}');
  print('Expense: Rp ${summary['expense']}');
  print('Balance: Rp ${summary['balance']}');
}
```

### 5. Login

```dart
final result = await ApiService.login(
  email: 'budi@example.com',
  password: 'password123',
);

if (result != null) {
  print('Login berhasil!');
  print('Name: ${result['user']['name']}');
  // Token sudah tersimpan otomatis di SharedPreferences
}
```

---

## ⚙️ Setup Laravel API

### 1. Update Base URL

Edit file `lib/services/api_service.dart`:

```dart
// Untuk development (localhost)
static const String baseUrl = 'http://127.0.0.1:8000/api';

// Untuk production (server online)
static const String baseUrl = 'https://your-domain.com/api';

// Untuk testing dari Android Emulator
static const String baseUrl = 'http://10.0.2.2:8000/api';

// Untuk testing dari device fisik di network yang sama
static const String baseUrl = 'http://192.168.x.x:8000/api';
```

### 2. Jalankan Laravel Server

```bash
cd web/agrigo-admin
php artisan serve
```

### 3. Test API

Login ke web admin: http://127.0.0.1:8000

- Email: admin@agrigo.com
- Password: admin123

---

## 🔄 Data Sync Flow

```
Mobile App (Flutter)
    ↓
    └─→ ApiService.createTransaction()
        ↓
        └─→ HTTP POST /api/transactions
            ↓
            └─→ Laravel API (TransactionApiController)
                ↓
                └─→ MySQL Database
                    ↓
                    └─→ Web Admin (Auto-refresh untuk melihat data baru)
```

**PENTING:**

- Setiap data yang dibuat di mobile app akan LANGSUNG tersimpan di database
- Data langsung muncul di web admin (cukup refresh halaman)
- Tidak perlu sinkronisasi manual
- Cocok untuk multi-user (setiap user hanya melihat data mereka sendiri)

---

## 🧪 Testing

### Test Transaction Creation:

```dart
// Contoh di transaction_form_page.dart
Future<void> _saveTransaction() async {
  if (_formKey.currentState!.validate()) {
    final result = await ApiService.createTransaction(
      type: widget.type, // 'income' or 'expense'
      amount: double.parse(_totalHargaController.text),
      description: _deskripsiController.text,
      date: DateFormat('yyyy-MM-dd').format(selectedDate!),
      commodityId: selectedCommodityId,
    );

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaksi berhasil disimpan!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan transaksi')),
      );
    }
  }
}
```

---

## 📊 Data yang Tersedia di Web Admin

Setelah mobile app mengirim data via API, web admin akan menampilkan:

1. **Dashboard** - Total transactions, income, expense, balance
2. **Transactions** - Per-user financial summary
3. **Commodities** - 36 komoditas yang bisa dipilih
4. **Schedules** - Jadwal tanam dari mobile app
5. **Users** - List semua petani yang register

---

## 🔒 Security

- Token authentication menggunakan Laravel Sanctum
- Password di-hash menggunakan bcrypt
- API hanya bisa diakses oleh user yang terautentikasi
- Setiap user hanya bisa melihat/edit data miliknya sendiri
- Admin bisa melihat semua data

---

## ❓ Troubleshooting

### 1. Connection Refused

- Pastikan Laravel server running: `php artisan serve`
- Cek baseUrl di ApiService sesuai environment

### 2. 401 Unauthorized

- Token expired atau invalid
- Login ulang untuk mendapatkan token baru

### 3. Data tidak muncul di web admin

- Refresh halaman web admin
- Cek di terminal Laravel apakah ada error
- Cek response API di Flutter console

### 4. Network Error

- Cek koneksi internet
- Pastikan baseUrl correct
- Untuk emulator gunakan 10.0.2.2 bukan 127.0.0.1
