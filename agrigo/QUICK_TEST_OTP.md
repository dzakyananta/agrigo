# 🎯 QUICK TEST GUIDE - OTP System

## ✅ Setup Complete! (Updated: 5 Digit OTP)

**Yang sudah jalan:**
- ✅ Flutter app running di emulator
- ✅ PHP server running di `http://192.168.21.133:8001`
- ✅ Gmail SMTP configured (App Password ready)
- ✅ Firestore rules deployed (otp_codes accessible)
- ✅ OTP system: **5 DIGIT** (bukan 6)
- ✅ OTP service sudah connect ke server

---

## 📱 Test OTP Flow (5 Langkah)

### **1. Buka Forgot Password**
- Di app, tap **"Lupa Password"** di login page
- Pastikan method **"E-mail"** selected

### **2. Masukkan Email Testing**
- Gunakan: `alvindenobahari@gmail.com` (email Anda)
- Atau email lain yang Anda punya akses
- Tap **"Dapatkan kode OTP"**

### **3. Cek Console Log**
**Di VS Code Output/Terminal, cari:**
```
🔑 Generated OTP: 12345 for alvindenobahari@gmail.com
✅ OTP saved to Firestore
📧 Email API Response: 200
```

**Di terminal PHP server:**
```
[Mon Dec 15 02:XX:XX 2025] 192.168.21.133:54321 Accepted
📧 SMTP Config: Host=smtp.gmail.com, Port=587, User=alvindenobahari@gmail.com
📧 Attempting to send OTP: 12345 to: alvindenobahari@gmail.com
```

### **4. Cek Email Gmail Anda**
- Buka Gmail di browser/phone
- **Cek Inbox** (atau folder **Spam**)
- Subject: **"Kode OTP Reset Password - Agrigo"**
- Body: Design hijau dengan **OTP 5 DIGIT** besar

**Jika email tidak masuk dalam 30 detik:**
- Buka: `web/agrigo-admin/otp_logs.txt`
- Copy OTP dari file log
```
[2025-12-15 02:XX:XX] Email: alvindenobahari@gmail.com | OTP: 12345
```

### **5. Masukkan OTP di App**
- Copy OTP **5 digit** dari email/log
- Paste di VerificationCodePage (**5 boxes** sekarang)
- Tap **"Verifikasi"**

**Expected Result:**
- ✅ OTP valid → Navigate ke ResetPasswordPage
- ❌ OTP salah → Error "Kode OTP salah"
- ❌ OTP expired (>5 menit) → Error "Kode OTP sudah kadaluarsa"
- ❌ OTP sudah dipakai → Error "Kode OTP sudah digunakan"

---

## 🔍 Debug Checklist

### **App tidak bisa connect ke PHP server?**

1. **Verify PHP server running:**
```bash
# Cek terminal harus ada:
[Mon Dec 15 XX:XX:XX 2025] PHP 8.3.25 Development Server (http://0.0.0.0:8001) started
```

2. **Test server dari browser:**
```
http://localhost:8001
```
Should show: "Method not allowed" (normal - server only accept POST)

3. **Test dengan curl:**
```bash
curl -X POST http://192.168.21.133:8001 ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"test@example.com\",\"otp\":\"123456\"}"
```

Expected response:
```json
{
  "success": true,
  "message": "OTP berhasil dikirim ke email",
  "debug": {...}
}
```

### **OTP tidak masuk Firestore?**

1. **Cek Firebase Console:**
   - Buka: https://console.firebase.google.com/project/agrigo-bddde/firestore
   - Collection: `otp_codes`
   - Document: `test@example.com`

2. **Verify structure:**
```
otp_codes/test@example.com/
  ├── otp: "123456"
  ├── email: "test@example.com"
  ├── expiryTime: December 15, 2025 at 1:50:30 AM UTC+7
  ├── createdAt: December 15, 2025 at 1:45:30 AM UTC+7
  └── isUsed: false
```

3. **Cek console Flutter:**
```
🔑 Generated OTP: 123456 for test@example.com
✅ OTP saved to Firestore
```

### **OTP verification failed?**

1. **Check expiry time:**
   - OTP valid 5 menit dari `createdAt`
   - Generate OTP baru jika expired

2. **Check `isUsed` flag:**
   - Setelah verify sukses, `isUsed` = true
   - OTP tidak bisa dipakai lagi
   - Generate OTP baru via "Kirim ulang OTP"

3. **Verify OTP match:**
   - Copy exact OTP dari console/log
   - Jangan manual ketik (typo risk)

---

## 📊 Server Logs

### **PHP Server Logs** (`web/agrigo-admin/otp_logs.txt`):
```
[2025-12-15 01:45:30] Email: test@example.com | OTP: 123456
[2025-12-15 01:46:15] Email: user@test.com | OTP: 789012
[2025-12-15 01:47:00] Email: demo@agrigo.com | OTP: 345678
```

### **Flutter Console Output:**
```
🔑 Generated OTP: 123456 for test@example.com
✅ OTP saved to Firestore
📧 Sending OTP 123456 to test@example.com via Laravel backend...
📧 Email API Response: 200
📧 Response body: {"success":true,"message":"OTP berhasil dikirim ke email",...}
```

### **Firestore Console:**
- URL: https://console.firebase.google.com/project/agrigo-bddde/firestore/data/~2Fotp_codes
- Verify OTP documents created/updated

---

## 🚀 Production Checklist (Setelah Testing)

### **1. Enable Real Email Sending**

Edit `web/agrigo-admin/send-otp.php` line 71-96:
```php
// PRODUCTION: Uncomment dan setup SMTP
$to = $email;
$subject = "Kode OTP Reset Password - Agrigo";
// ... email HTML template ...
mail($to, $subject, $message, $headers);
```

**Setup PHP mail() atau gunakan Laravel Mailtrap/SendGrid**

### **2. Disable Testing Fallback**

Edit `lib/services/otp_service.dart` line 97:
```dart
// HAPUS line ini untuk production:
// return true; // TEMPORARY: Allow testing without Laravel backend

// Ganti dengan:
return false; // Email sending failed
```

### **3. Add Rate Limiting**

Update Firestore rules untuk prevent abuse:
```javascript
match /otp_codes/{email} {
  allow read: if true;
  allow write: if request.time < resource.data.createdAt + duration.minutes(5) 
               || !exists(/databases/$(database)/documents/otp_codes/$(email));
  // Maximum 1 request per 60 seconds per email
}
```

### **4. Add Production URL**

Edit `lib/services/otp_service.dart`:
```dart
// Development
final url = Uri.parse('http://192.168.21.133:8001/api/send-otp');

// Production (ganti dengan domain Laravel production)
final url = Uri.parse('https://api.agrigo.com/api/send-otp');
```

### **5. Security Enhancements**

- ✅ Enable HTTPS untuk Laravel backend
- ✅ Add API key/token untuk auth
- ✅ Implement CORS properly
- ✅ Add IP rate limiting
- ✅ Log failed OTP attempts
- ✅ Add captcha untuk prevent bot

---

## 📞 Support

**Jika ada error:**
1. Cek console Flutter (VS Code Output)
2. Cek terminal PHP server
3. Cek `web/agrigo-admin/otp_logs.txt`
4. Cek Firestore Console
5. Share screenshot error ke team

**Test berhasil jika:**
- ✅ OTP generated dan logged
- ✅ OTP tersimpan di Firestore
- ✅ OTP verification sukses
- ✅ Navigate ke ResetPasswordPage
- ✅ Password reset link sent (backup)

---

## 🎉 Siap Testing!

**Current Status:**
- 🟢 PHP Server: Running at http://192.168.21.133:8001
- 🟢 Flutter App: Running on emulator-5554
- 🟢 Firestore Rules: Deployed successfully
- 🟢 OTP System: Ready to test

**Next:** Test forgot password flow di app! 🚀
