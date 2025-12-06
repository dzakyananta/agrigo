# Konfigurasi Database MySQL untuk Agrigo Admin Panel

# Update file .env dengan konfigurasi berikut:

# Database Configuration

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=agrigo_admin
DB_USERNAME=root
DB_PASSWORD=

# Atau sesuaikan dengan konfigurasi MySQL Anda:

# DB_USERNAME=your_mysql_username

# DB_PASSWORD=your_mysql_password

# Langkah-langkah Import Database:

1. Buka phpMyAdmin di browser (biasanya http://localhost/phpmyadmin)

2. Buat database baru bernama 'agrigo_admin':

    - Klik "New" di sidebar kiri
    - Masukkan nama database: agrigo_admin
    - Klik "Create"

3. Import file SQL:

    - Pilih database 'agrigo_admin' yang baru dibuat
    - Klik tab "Import"
    - Klik "Choose File" dan pilih file 'agrigo_database.sql'
    - Klik "Go" untuk mengimport

4. Update file .env di Laravel:

    - Buka file .env di folder agrigo-admin
    - Update konfigurasi database seperti di atas
    - Simpan file .env

5. Test koneksi database:
    - Jalankan: php artisan migrate:status
    - Jika berhasil, akan melihat daftar migration yang sudah dijalankan

# Kredensial Login Admin Panel:

Email: admin@agrigo.com
Password: password

# Kredensial Login Farmer:

Email: budi@farmer.com
Password: password

Email: siti@farmer.com  
Password: password

Email: ahmad@farmer.com
Password: password

# Data yang sudah tersedia:

-   6 Users (1 Admin, 4 Farmers, 2 Buyers)
-   6 Commodities (Beras, Jagung, Cabai, Tomat, Kentang, Wortel)
-   8 Transactions dengan berbagai status
-   3 Weather Data untuk lokasi berbeda
-   User Profiles untuk farmers dengan detail pertanian
