# Setup Web Admin Agrigo - LENGKAP

## 📋 Struktur Database yang Sudah Diperbaiki

### Tabel Utama:

1. **users** - Data pengguna (admin & petani)
2. **user_profiles** - Profil petani (phone, address, location)
3. **commodities** - Master komoditas (nama & jenis saja, tanpa harga)
4. **transactions** - Transaksi income/expense (amount, description, date)
5. **schedules** - Jadwal tanam (commodity_id, start_date, end_date, status)
6. **articles** - Artikel dashboard
7. **notifications** - Notifikasi untuk user
8. **chatbot_faqs** - FAQ untuk chatbot
9. **app_settings** - Pengaturan aplikasi
10. **activity_logs** - Log aktivitas user
11. **weather_data** - Data cuaca (optional cache)

## 🚀 Cara Setup (MUDAH)

### Langkah 1: Jalankan Setup Otomatis

Buka PowerShell/CMD di folder `agrigo-admin` dan jalankan:

```powershell
cd "e:\SEMESTER 5\agrigo\agrigo\web\agrigo-admin"
php artisan migrate:fresh
php artisan db:seed --class=AgrigoSeeder
php artisan serve
```

### Langkah 2: Login

Buka browser: **http://127.0.0.1:8000/admin/login**

**Kredensial:**

-   Email: `admin@agrigo.com`
-   Password: `admin123`

## ✅ Yang Sudah Diperbaiki

### 1. Commodities - DISEDERHANAKAN

**SEBELUM:** Memiliki harga, unit, harvest_season, storage, quality_standards  
**SESUDAH:** Hanya nama dan jenis

```
Contoh:
- Nama: Padi
- Jenis: Padi-padian
- Deskripsi: Tanaman padi untuk beras
```

### 2. Transactions - SESUAI MOBILE

**SEBELUM:** category, quantity, price_per_unit, status, transaction_date  
**SESUDAH:** type, amount, description, date

```
Contoh:
- Type: income / expense
- Amount: 5000000
- Commodity: Padi (optional)
- Description: Penjualan padi 500 kg
- Date: 2024-12-01
```

### 3. Schedules - SESUAI MOBILE

**SEBELUM:** Punya kolom komoditas (string) dan commodity_id (redundant)  
**SESUDAH:** Hanya commodity_id (foreign key)

```
Contoh:
- Commodity: Padi (dari table commodities)
- Start Date: 2024-12-05
- End Date: 2025-04-05
- Status: active / completed / cancelled
- Notes: Tanam padi varietas IR64
```

### 4. User Profiles - SIMPEL

**SEBELUM:** farm_size, crops_grown, experience_years  
**SESUDAH:** phone, address, location

```
Contoh:
- Phone: 08123456789
- Address: Subang, Jawa Barat
- Location: Subang (untuk cuaca)
```

## 📊 Data Sample yang Terisi

### Users (3 users)

1. Admin Agrigo (admin@agrigo.com)
2. Budi Santoso (budi@farmer.com) - Petani dari Subang
3. Siti Rahayu (siti@farmer.com) - Petani dari Karawang

### Commodities (10 items)

| Nama         | Jenis       |
| ------------ | ----------- |
| Padi         | Padi-padian |
| Jagung       | Padi-padian |
| Kedelai      | Palawija    |
| Kacang Tanah | Palawija    |
| Cabai        | Sayuran     |
| Tomat        | Sayuran     |
| Bayam        | Sayuran     |
| Kangkung     | Sayuran     |
| Singkong     | Umbi-umbian |
| Ubi Jalar    | Umbi-umbian |

### Schedules (3 jadwal)

1. Budi - Padi (active, 5 hari lagi mulai)
2. Budi - Cabai (active, sedang berjalan)
3. Siti - Jagung (completed, sudah selesai)

### Transactions (3 transaksi)

1. Budi - Income 5.000.000 (Penjualan padi)
2. Budi - Expense 1.500.000 (Pembelian pupuk)
3. Siti - Income 3.500.000 (Penjualan jagung)

### Articles (2 artikel)

1. Tips Menanam Padi di Musim Hujan
2. Cara Efektif Mengelola Keuangan Pertanian

### Notifications (2 notifikasi)

1. Jadwal Tanam Padi Dimulai (untuk Budi)
2. Tips Pertanian - Broadcast ke semua

### Chatbot FAQs (2 FAQ)

1. Bagaimana cara membuat jadwal tanam?
2. Bagaimana cara mencatat transaksi?

### App Settings (5 pengaturan)

-   app_name, app_version, maintenance_mode, enable_notifications, enable_chatbot

## 🎯 Fitur Web Admin

### Menu Utama:

1. **Dashboard** - Statistik & overview
2. **Users** - Kelola petani
3. **Commodities** - Master komoditas (nama & jenis)
4. **Schedules** - Jadwal tanam semua petani
5. **Transactions** - Transaksi income/expense
6. **Articles** - Artikel edukatif
7. **Notifications** - Kirim notifikasi
8. **Chatbot FAQs** - Kelola FAQ
9. **App Settings** - Pengaturan app
10. **Activity Logs** - Monitor aktivitas

## 🔄 Sinkronisasi dengan Mobile App

Data di web admin = Data di mobile app Agrigo

### Alur Data:

```
Mobile App → API → Database ← Web Admin
```

### API Endpoints (Ready):

-   POST /api/register - Daftar user baru
-   POST /api/login - Login user
-   GET /api/schedules - List jadwal user
-   POST /api/schedules - Tambah jadwal
-   GET /api/transactions - List transaksi user
-   POST /api/transactions - Tambah transaksi
-   GET /api/commodities - List komoditas
-   GET /api/articles - List artikel
-   GET /api/notifications - Notifikasi user

## 🛠️ Troubleshooting

### Error: Table not found

```bash
php artisan migrate:fresh
php artisan db:seed --class=AgrigoSeeder
```

### Loading lama

-   Pastikan MySQL service running
-   Check koneksi database di `.env`

### Error 500

```bash
php artisan cache:clear
php artisan config:clear
php artisan view:clear
```

## 📝 Perbedaan dengan Versi Lama

### ❌ DIHAPUS dari Commodities:

-   unit (kg, ton, ikat)
-   current_price, min_price, max_price
-   harvest_season
-   storage_requirements
-   quality_standards

### ❌ DIHAPUS dari Transactions:

-   category
-   quantity
-   price_per_unit
-   status

### ❌ DIHAPUS dari Schedules:

-   komoditas (string) - Diganti dengan commodity_id (foreign key)

### ❌ DIHAPUS dari User Profiles:

-   farm_size
-   crops_grown
-   experience_years

### ✅ DITAMBAHKAN:

-   Articles Management
-   Notifications Management
-   Chatbot FAQs
-   App Settings
-   Activity Logs

## ✨ Kesimpulan

Web admin sekarang **100% sesuai dengan aplikasi mobile Agrigo**:

✅ Komoditas: Hanya nama & jenis  
✅ Transaksi: Income/expense simpel  
✅ Jadwal: Link ke commodity (foreign key)  
✅ Profile: Phone, address, location  
✅ Fitur baru: Articles, Notifications, Chatbot, Settings, Logs

**Siap digunakan!** 🎉
