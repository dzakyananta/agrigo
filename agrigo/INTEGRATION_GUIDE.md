<!-- @format -->

# 🚀 Cara Integrasi Mobile App dengan Web Admin

## Overview

Aplikasi Agrigo mobile (Flutter) sekarang sudah terintegrasi dengan Web Admin (Laravel). Setiap data yang dibuat di mobile app akan **otomatis tersimpan ke database** dan **langsung muncul di web admin**.

---

## ⚡ Quick Start

### 1. Jalankan Laravel Server

```bash
cd web/agrigo-admin
php artisan serve
```

Server akan running di: `http://127.0.0.1:8000`

### 2. Login Web Admin

Buka browser: http://127.0.0.1:8000

- Email: `admin@agrigo.com`
- Password: `admin123`

### 3. Update Base URL di Mobile App

Edit file `lib/services/api_service.dart` line 7:

```dart
// Pilih sesuai environment Anda:

// Untuk testing di Emulator Android
static const String baseUrl = 'http://10.0.2.2:8000/api';

// Untuk testing di device fisik (same network)
static const String baseUrl = 'http://192.168.x.x:8000/api';

// Untuk production
static const String baseUrl = 'https://your-domain.com/api';
```

### 4. Import Service di File Flutter

```dart
import 'package:agrigo/services/api_service.dart';
```

---

## 📱 Implementasi di Aplikasi Mobile

### Example 1: Create Transaction (Finance Page)

```dart
import 'package:agrigo/services/api_service.dart';

// Dalam StatefulWidget atau StatelessWidget
Future<void> saveTransaction() async {
  // Ambil data dari form
  final type = 'income'; // atau 'expense'
  final amount = 5000000.0;
  final description = 'Penjualan padi hasil panen';
  final date = '2024-12-01';
  final commodityId = 1; // ID komoditas padi

  // Kirim ke API (auto-sync ke web admin)
  final result = await ApiService.createTransaction(
    type: type,
    amount: amount,
    description: description,
    date: date,
    commodityId: commodityId,
  );

  if (result != null) {
    // Sukses! Data sudah tersimpan di database
    print('✅ Transaction created with ID: ${result['id']}');

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaksi berhasil disimpan!'),
        backgroundColor: Colors.green,
      ),
    );
  } else {
    // Gagal
    print('❌ Failed to create transaction');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gagal menyimpan transaksi'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

### Example 2: Get Commodities (Commodity Selection Page)

```dart
import 'package:agrigo/services/api_service.dart';

class CommoditySelectionPage extends StatefulWidget {
  @override
  _CommoditySelectionPageState createState() => _CommoditySelectionPageState();
}

class _CommoditySelectionPageState extends State<CommoditySelectionPage> {
  List<dynamic> commodities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCommodities();
  }

  Future<void> loadCommodities() async {
    setState(() => isLoading = true);

    final data = await ApiService.getCommodities();

    setState(() {
      commodities = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: commodities.length,
      itemBuilder: (context, index) {
        final commodity = commodities[index];
        return ListTile(
          title: Text(commodity['name']),
          subtitle: Text(commodity['type']),
          onTap: () {
            // Pilih komoditas
            Navigator.pop(context, commodity);
          },
        );
      },
    );
  }
}
```

### Example 3: Login & Register

```dart
// Login
Future<void> handleLogin(String email, String password) async {
  final result = await ApiService.login(
    email: email,
    password: password,
  );

  if (result != null) {
    // Login berhasil, token sudah tersimpan otomatis
    print('Welcome ${result['user']['name']}!');

    // Navigate to dashboard
    Navigator.pushReplacementNamed(context, '/dashboard');
  } else {
    // Login gagal
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login Gagal'),
        content: Text('Email atau password salah'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Register
Future<void> handleRegister(
  String name,
  String email,
  String password,
  String phone,
  String address,
) async {
  final result = await ApiService.register(
    name: name,
    email: email,
    password: password,
    phone: phone,
    address: address,
  );

  if (result != null) {
    // Register berhasil, langsung login
    print('Account created for ${result['user']['name']}!');
    Navigator.pushReplacementNamed(context, '/dashboard');
  } else {
    // Register gagal
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Registrasi Gagal'),
        content: Text('Email sudah terdaftar'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

### Example 4: Get Financial Summary

```dart
import 'package:agrigo/services/api_service.dart';

class FinancePage extends StatefulWidget {
  @override
  _FinancePageState createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  Map<String, dynamic>? summary;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSummary();
  }

  Future<void> loadSummary() async {
    setState(() => isLoading = true);

    final data = await ApiService.getFinancialSummary();

    setState(() {
      summary = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (summary == null) {
      return Center(child: Text('Gagal memuat data'));
    }

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSummaryCard(
            'Total Pemasukan',
            'Rp ${_formatCurrency(summary!['income'])}',
            Colors.green,
          ),
          SizedBox(height: 16),
          _buildSummaryCard(
            'Total Pengeluaran',
            'Rp ${_formatCurrency(summary!['expense'])}',
            Colors.red,
          ),
          SizedBox(height: 16),
          _buildSummaryCard(
            'Saldo',
            'Rp ${_formatCurrency(summary!['balance'])}',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 16)),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(num value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
```

---

## 🔄 Data Sync Flow

```
┌─────────────────────┐
│   Mobile App        │
│   (Flutter)         │
└──────────┬──────────┘
           │
           │ 1. User input data
           ↓
┌─────────────────────┐
│   ApiService        │
│   HTTP Request      │
└──────────┬──────────┘
           │
           │ 2. POST /api/transactions
           ↓
┌─────────────────────┐
│   Laravel API       │
│   (Controller)      │
└──────────┬──────────┘
           │
           │ 3. Save to database
           ↓
┌─────────────────────┐
│   MySQL Database    │
└──────────┬──────────┘
           │
           │ 4. Data tersimpan
           ↓
┌─────────────────────┐
│   Web Admin         │
│   (Auto-refresh)    │
└─────────────────────┘
```

---

## 📊 Fitur yang Sudah Terintegrasi

### ✅ Commodities

- Get all commodities (36 items)
- Get by ID
- Get by type (Padi-padian, Sayuran, dll)
- Get types list

### ✅ Transactions

- **Create** (mobile → database → web admin)
- **Read** (get all user's transactions)
- **Update** (edit transaction)
- **Delete** (hapus transaction)
- **Summary** (income, expense, balance)

### ✅ Schedules

- Create schedule
- Get all schedules
- Update schedule
- Delete schedule

### ✅ Authentication

- Register (create account)
- Login (get token)
- Logout (clear token)
- Get profile
- Update profile

---

## 🎯 Contoh Penggunaan Lengkap

### Update Transaction Form Page

Edit file: `lib/pages/transaction_form_page.dart`

Tambahkan di bagian atas:

```dart
import 'package:agrigo/services/api_service.dart';
```

Ganti method `_simpanData()` dengan:

```dart
Future<void> _simpanData() async {
  if (_formKey.currentState!.validate()) {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    // Format date
    final dateStr = selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(selectedDate!)
        : DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Get amount
    final amount = double.tryParse(
      _totalHargaController.text.replaceAll('.', '').replaceAll(',', '')
    ) ?? 0.0;

    // Create transaction via API
    final result = await ApiService.createTransaction(
      type: widget.type, // 'income' or 'expense'
      amount: amount,
      description: _deskripsiController.text,
      date: dateStr,
      commodityName: selectedKomoditas, // Auto-create if not exists
    );

    // Hide loading
    Navigator.pop(context);

    if (result != null) {
      // Success!
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Transaksi berhasil disimpan!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Go back
      Navigator.pop(context);
    } else {
      // Failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Gagal menyimpan transaksi'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
```

---

## 🧪 Testing

### 1. Test di Emulator Android

```dart
// api_service.dart
static const String baseUrl = 'http://10.0.2.2:8000/api';
```

### 2. Test di Device Fisik

- Pastikan laptop dan device di network yang sama (WiFi sama)
- Cek IP laptop: `ipconfig` (Windows) atau `ifconfig` (Mac/Linux)
- Gunakan IP tersebut:

```dart
static const String baseUrl = 'http://192.168.1.100:8000/api';
```

### 3. Test API Response

```dart
// Test get commodities
final commodities = await ApiService.getCommodities();
print('Commodities count: ${commodities.length}');

// Test create transaction
final result = await ApiService.createTransaction(
  type: 'income',
  amount: 1000000,
  description: 'Test transaction',
  date: '2024-12-08',
  commodityName: 'Padi',
);
print('Transaction created: ${result != null}');
```

---

## 🔐 User Account untuk Testing

### Admin

- Email: `admin@agrigo.com`
- Password: `admin123`

### Farmer 1

- Email: `budi@example.com`
- Password: `password123`

### Farmer 2

- Email: `siti@example.com`
- Password: `password123`

---

## 📝 Catatan Penting

1. **Token Authentication**: Token disimpan otomatis di SharedPreferences setelah login
2. **Auto-Create Commodity**: Jika kirim `commodityName` dan belum ada di database, akan dibuat otomatis
3. **Per-User Data**: Setiap user hanya bisa melihat data miliknya sendiri
4. **Admin Access**: Admin bisa melihat semua data di web admin
5. **Real-time Sync**: Data langsung muncul di web admin setelah dibuat di mobile app

---

## ❓ Troubleshooting

### Connection Error

```
✅ Solusi:
1. Pastikan Laravel server running (php artisan serve)
2. Cek baseUrl di ApiService
3. Untuk emulator gunakan 10.0.2.2 bukan 127.0.0.1
4. Untuk device fisik gunakan IP laptop (192.168.x.x)
```

### 401 Unauthorized

```
✅ Solusi:
1. Token expired, login ulang
2. Pastikan sudah login sebelum akses protected endpoints
3. Cek SharedPreferences punya token atau tidak
```

### Data Tidak Muncul

```
✅ Solusi:
1. Refresh halaman web admin
2. Cek console Flutter untuk error
3. Cek terminal Laravel untuk error log
4. Pastikan data terkirim dengan benar (cek response)
```

### CORS Error

```
✅ Solusi:
Laravel sudah support CORS by default untuk Sanctum API.
Jika tetap ada error, install package fruitcake/laravel-cors
```

---

## 📚 Resources

- API Documentation: `API_DOCUMENTATION.md`
- Laravel Docs: https://laravel.com/docs
- Flutter HTTP: https://pub.dev/packages/http
- Laravel Sanctum: https://laravel.com/docs/sanctum

---

## 🎉 Selesai!

Sekarang aplikasi Agrigo mobile sudah terintegrasi penuh dengan web admin. Setiap data yang dibuat di mobile app akan otomatis tersimpan dan muncul di web admin!

**Next Steps:**

1. Update baseUrl sesuai environment
2. Test login/register
3. Test create transaction
4. Cek data di web admin
5. Deploy ke production jika sudah OK
