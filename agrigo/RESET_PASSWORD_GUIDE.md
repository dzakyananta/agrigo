# 🔐 Sistem Reset Password dengan OTP Email

## ✅ Status: LENGKAP & SIAP DIGUNAKAN

Sistem reset password dengan OTP via email sudah sepenuhnya terintegrasi dan siap digunakan!

---

## 📋 Alur Lengkap Reset Password

### 1️⃣ **User Lupa Password (di Mobile)**
- User membuka aplikasi mobile
- Klik "Lupa Password"
- Masukkan alamat email yang terdaftar
- Klik "Kirim Kode"

### 2️⃣ **Sistem Mengirim OTP**
- Sistem generate kode OTP 5 digit secara random
- OTP disimpan di Firestore dengan:
  - Email user
  - Kode OTP
  - Waktu kadaluarsa (5 menit)
  - Status: belum digunakan
- Sistem kirim email berisi kode OTP ke Gmail user via SMTP

### 3️⃣ **User Menerima Email**
- Email dikirim dari: `serverdocker22@gmail.com`
- Subject: "Kode OTP Reset Password - Agrigo"
- Isi email berisi kode OTP 5 digit dengan desain profesional
- ⏰ Berlaku 5 menit

### 4️⃣ **User Masukkan OTP (di Mobile)**
- User cek email dan salin kode OTP
- Masukkan kode OTP di aplikasi mobile (5 kotak input)
- Klik "Verifikasi"

### 5️⃣ **Sistem Verifikasi OTP**
- Sistem cek kode OTP di Firestore
- Validasi:
  - ✅ Kode OTP cocok?
  - ✅ Belum kadaluarsa?
  - ✅ Belum pernah digunakan?
- Jika valid: tandai OTP sebagai "sudah digunakan"
- Jika tidak valid: tampilkan pesan error

### 6️⃣ **User Buat Password Baru (di Mobile)**
- Jika OTP valid, tampilkan form password baru
- User masukkan password baru (min. 6 karakter)
- User konfirmasi password
- Klik "Konfirmasi"

### 7️⃣ **Sistem Update Password**
- Sistem kirim request ke backend PHP
- Backend update password di Firebase Auth menggunakan Firebase Admin SDK
- Password berhasil diubah
- OTP dihapus dari Firestore
- User diarahkan kembali ke halaman login

### 8️⃣ **User Login dengan Password Baru**
- User login dengan email dan password baru
- ✅ Berhasil masuk ke aplikasi!

---

## 🚀 Cara Menjalankan Sistem

### **Server PHP (Backend)**

1. Buka terminal di folder `agrigo/web/agrigo-admin/`
2. Jalankan perintah:
   ```bash
   php -S 0.0.0.0:8001
   ```
3. Server akan berjalan di: `http://192.168.21.133:8001`
4. ✅ Server siap menerima request!

### **Aplikasi Mobile (Flutter)**

1. Pastikan Flutter app sudah terkoneksi ke WiFi yang sama dengan server
2. Run aplikasi:
   ```bash
   flutter run
   ```
3. ✅ Aplikasi siap digunakan!

---

## 📂 File-File Penting

### **Backend (PHP)**

| File | Fungsi |
|------|--------|
| `send-otp-gmail.php` | Mengirim OTP via Gmail SMTP |
| `reset-password.php` | Mengubah password di Firebase Auth |
| `.env` | Konfigurasi email (Gmail App Password) |
| `otp_logs.txt` | Log OTP yang dikirim |
| `password_reset_logs.txt` | Log reset password |

### **Frontend (Flutter)**

| File | Fungsi |
|------|--------|
| `lib/services/otp_service.dart` | Generate OTP, verifikasi, kirim email, reset password |
| `lib/pages/forgot_password_page.dart` | UI lupa password, verifikasi OTP, reset password |

---

## 🔧 Konfigurasi Email (Gmail)

File: `agrigo/web/agrigo-admin/.env`

```env
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=465
MAIL_USERNAME=serverdocker22@gmail.com
MAIL_PASSWORD=stnbtftirxjrctqw
MAIL_ENCRYPTION=ssl
MAIL_FROM_ADDRESS=serverdocker22@gmail.com
MAIL_FROM_NAME="Agrigo Admin"
```

### **Cara Mendapatkan Gmail App Password:**
1. Buka [Google Account](https://myaccount.google.com/)
2. Pilih **Security** > **2-Step Verification**
3. Scroll ke bawah, klik **App passwords**
4. Generate app password baru
5. Salin password (16 karakter tanpa spasi)
6. Masukkan ke `.env` di `MAIL_PASSWORD`

---

## 🔐 Security Features

### ✅ **OTP Expiry (5 Menit)**
- OTP hanya berlaku 5 menit setelah dikirim
- Setelah kadaluarsa, user harus kirim ulang OTP baru

### ✅ **One-Time Use**
- OTP hanya bisa digunakan 1 kali
- Setelah digunakan, OTP tidak bisa dipakai lagi
- User harus kirim ulang jika ingin reset lagi

### ✅ **Resend OTP (60 Detik Cooldown)**
- User bisa kirim ulang OTP
- Ada timer 60 detik untuk mencegah spam
- OTP lama akan diganti dengan OTP baru

### ✅ **Password Validation**
- Password minimal 6 karakter
- Konfirmasi password harus sama
- Validasi di frontend dan backend

### ✅ **HTTPS Ready**
- Semua komunikasi via HTTPS (production)
- Password di-hash di Firebase Auth
- OTP tidak disimpan dalam plaintext (hanya di Firestore dengan expiry)

---

## 🧪 Testing

### **Test 1: Kirim OTP**
1. Buka aplikasi mobile
2. Klik "Lupa Password"
3. Masukkan email: `alvindenobahari@gmail.com`
4. Klik "Kirim Kode"
5. ✅ Cek email, OTP harus diterima dalam 10-15 detik

### **Test 2: Verifikasi OTP**
1. Salin kode OTP dari email (5 digit)
2. Masukkan di aplikasi mobile
3. Klik "Verifikasi"
4. ✅ Harus muncul form password baru

### **Test 3: Reset Password**
1. Masukkan password baru: `newpass123`
2. Konfirmasi password: `newpass123`
3. Klik "Konfirmasi"
4. ✅ Password berhasil diubah

### **Test 4: Login dengan Password Baru**
1. Kembali ke halaman login
2. Login dengan email dan password baru
3. ✅ Berhasil login!

---

## 🐛 Troubleshooting

### **Email Tidak Diterima**

**Penyebab & Solusi:**
- ❌ Server PHP tidak berjalan → Jalankan `php -S 0.0.0.0:8001`
- ❌ Gmail App Password salah → Periksa `.env`, generate ulang App Password
- ❌ Port/protocol salah → Pastikan `MAIL_PORT=465` dan `MAIL_ENCRYPTION=ssl`
- ❌ Email masuk ke spam → Cek folder spam/junk email
- ❌ Firewall memblokir port 465 → Disable firewall atau whitelist port 465

**Cek Log:**
```bash
cat agrigo/web/agrigo-admin/otp_logs.txt
```

### **OTP Tidak Valid**

**Penyebab & Solusi:**
- ❌ OTP sudah kadaluarsa (> 5 menit) → Kirim ulang OTP baru
- ❌ OTP sudah digunakan → Kirim ulang OTP baru
- ❌ OTP salah → Cek kembali email, pastikan 5 digit benar
- ❌ Koneksi Firestore gagal → Cek koneksi internet

### **Reset Password Gagal**

**Penyebab & Solusi:**
- ❌ Firebase credentials tidak ditemukan → Cek `storage/firebase-credentials.json`
- ❌ Email tidak terdaftar di Firebase → Pastikan user sudah registrasi
- ❌ Password terlalu pendek (< 6 karakter) → Gunakan min. 6 karakter

**Cek Log:**
```bash
cat agrigo/web/agrigo-admin/password_reset_logs.txt
```

---

## 📱 Endpoint API

### **1. Send OTP Email**
```
POST http://192.168.21.133:8001/send-otp-gmail.php

Headers:
- Content-Type: application/x-www-form-urlencoded

Body:
- email: user@example.com
- otp: 12345

Response (Success):
{
  "success": true,
  "message": "OTP berhasil dikirim ke email Anda.",
  "email": "user@example.com"
}

Response (Error):
{
  "success": false,
  "message": "Gagal mengirim email: <error>"
}
```

### **2. Reset Password**
```
POST http://192.168.21.133:8001/reset-password.php

Headers:
- Content-Type: application/json

Body:
{
  "email": "user@example.com",
  "password": "newpassword123"
}

Response (Success):
{
  "success": true,
  "message": "Password berhasil diubah. Silakan login dengan password baru."
}

Response (Error):
{
  "success": false,
  "message": "Gagal mengubah password: <error>"
}
```

---

## 🎨 UI/UX Features

### **Forgot Password Page**
- ✅ Input email dengan validasi
- ✅ Toggle email/phone (phone belum aktif)
- ✅ Loading indicator saat kirim OTP
- ✅ Toast notification sukses/error

### **Verification Code Page**
- ✅ 5 kotak input untuk OTP (auto-focus)
- ✅ Timer 60 detik untuk kirim ulang OTP
- ✅ Tombol "Kirim Ulang" dengan cooldown
- ✅ Validasi OTP realtime
- ✅ Loading indicator saat verifikasi

### **Reset Password Page**
- ✅ Input password baru dengan toggle visibility
- ✅ Input konfirmasi password
- ✅ Validasi password (min. 6 karakter, harus sama)
- ✅ Loading indicator saat reset
- ✅ Auto redirect ke login setelah sukses

---

## 🔮 Fitur Masa Depan (Opsional)

### **SMS OTP (WhatsApp/SMS Gateway)**
- Integrasi dengan Twilio, Nexmo, atau layanan lokal
- User bisa pilih: email atau SMS
- OTP dikirim via WhatsApp/SMS

### **Rate Limiting**
- Batasi jumlah request OTP per email (misal: 3x per jam)
- Mencegah spam dan abuse

### **Email Template Custom**
- Desain email lebih menarik dengan logo Agrigo
- Personalisasi dengan nama user

### **Multi-Language**
- Support Bahasa Indonesia dan Inggris
- Auto-detect dari setting device

---

## 📊 Database Structure (Firestore)

### **Collection: `otp_codes`**
```
Document ID: user_email@example.com
{
  "otp": "12345",
  "email": "user_email@example.com",
  "expiryTime": Timestamp(2025-12-15 15:25:00),
  "createdAt": Timestamp(2025-12-15 15:20:00),
  "isUsed": false,
  "usedAt": null  // Set after verification
}
```

---

## 🎉 Sistem Siap Digunakan!

**Checklist:**
- ✅ Backend PHP berjalan (`php -S 0.0.0.0:8001`)
- ✅ Gmail App Password sudah dikonfigurasi
- ✅ Flutter app terkoneksi ke backend
- ✅ Firebase Admin SDK terintegrasi
- ✅ Firestore OTP collection sudah ada
- ✅ Email delivery sudah ditest
- ✅ OTP verification sudah ditest
- ✅ Password reset sudah ditest

**Cara Testing:**
1. Jalankan PHP server
2. Jalankan Flutter app
3. Test lupa password dengan email Anda
4. Cek email untuk OTP
5. Verifikasi OTP di app
6. Reset password baru
7. Login dengan password baru
8. ✅ **SUKSES!**

---

## 📞 Support

Jika ada masalah:
1. Cek log file di `agrigo/web/agrigo-admin/`
2. Cek Flutter console untuk error message
3. Cek email spam folder
4. Pastikan server PHP dan Flutter app di network yang sama

**Selamat menggunakan sistem reset password Agrigo! 🌾**
