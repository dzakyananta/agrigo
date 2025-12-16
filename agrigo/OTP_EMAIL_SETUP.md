# Setup Email OTP untuk Laravel

## 📧 Konfigurasi Email SMTP

### Opsi 1: Gmail (Recommended untuk Testing)

1. **Edit `.env` di folder `web/agrigo-admin`:**

```env
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=your-email@gmail.com
MAIL_FROM_NAME="Agrigo"
```

2. **Generate App Password Gmail:**
   - Buka: https://myaccount.google.com/apppasswords
   - Login dengan akun Gmail
   - Generate "App Password" untuk Laravel
   - Copy password 16 karakter
   - Paste ke `MAIL_PASSWORD`

### Opsi 2: Mailtrap (Recommended untuk Development)

1. **Daftar di Mailtrap:** https://mailtrap.io (gratis)

2. **Edit `.env`:**

```env
MAIL_MAILER=smtp
MAIL_HOST=sandbox.smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=your-mailtrap-username
MAIL_PASSWORD=your-mailtrap-password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@agrigo.com
MAIL_FROM_NAME="Agrigo"
```

3. **Copy credentials dari Mailtrap dashboard**

### Opsi 3: SendGrid (Production)

```env
MAIL_MAILER=smtp
MAIL_HOST=smtp.sendgrid.net
MAIL_PORT=587
MAIL_USERNAME=apikey
MAIL_PASSWORD=your-sendgrid-api-key
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@agrigo.com
MAIL_FROM_NAME="Agrigo"
```

## 🚀 Testing Email

1. **Start Laravel server:**

```bash
cd web/agrigo-admin
php artisan serve --host=0.0.0.0 --port=8001
```

2. **Test API endpoint menggunakan Postman/cURL:**

```bash
curl -X POST http://localhost:8001/api/send-otp \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","otp":"123456"}'
```

3. **Response sukses:**

```json
{
  "success": true,
  "message": "OTP berhasil dikirim ke email"
}
```

## 📱 Update Flutter untuk Call Laravel

Di file `lib/services/otp_service.dart`, ganti URL dengan IP komputer Anda:

```dart
// Ganti localhost dengan IP komputer (cek dengan ipconfig di CMD)
final url = Uri.parse('http://192.168.1.100:8001/api/send-otp');
```

**Cara cek IP:**

Windows:
```bash
ipconfig
# Cari "IPv4 Address" di WiFi/Ethernet adapter
```

## 🔥 Update Firestore Security Rules

Tambahkan rules untuk koleksi `otp_codes`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // ... existing rules ...
    
    // Allow anyone to read/write OTP codes (temporary, for forgot password)
    match /otp_codes/{email} {
      allow read, write: if true;
      // In production, add more restrictive rules:
      // - Check expiry time
      // - Rate limiting
      // - IP validation
    }
  }
}
```

## ✅ Testing Complete Flow

1. **Buka app Flutter** → Login page
2. **Tap "Lupa Password"**
3. **Masukkan email** (gunakan email testing Anda)
4. **Tap "Dapatkan kode OTP"**
5. **Cek email** (inbox atau spam)
6. **Copy kode OTP 6 digit**
7. **Masukkan di app** → VerificationCodePage
8. **Tap "Verifikasi"**
9. **Jika valid** → Navigate ke ResetPasswordPage
10. **Masukkan password baru** → Submit

## 🐛 Troubleshooting

### Email tidak terkirim:

1. Cek Laravel logs: `storage/logs/laravel.log`
2. Cek email credentials di `.env`
3. Test SMTP connection:

```bash
php artisan tinker
Mail::raw('Test', function($msg) { $msg->to('your@email.com')->subject('Test'); });
```

### Flutter tidak bisa connect ke Laravel:

1. Cek Laravel server running: `http://localhost:8001`
2. Ganti `localhost` dengan IP komputer di `otp_service.dart`
3. Test dengan curl dari terminal
4. Disable firewall Windows (sementara)

### OTP expired atau invalid:

1. Cek Firestore collection `otp_codes`
2. Verify `expiryTime` masih valid (5 menit)
3. Verify `isUsed` = false
4. Cek OTP match dengan yang dikirim email

## 🎯 Production Checklist

- [ ] Ganti SendGrid/SES untuk email production
- [ ] Update Firestore rules (tambah rate limiting)
- [ ] Enable CORS di Laravel untuk domain production
- [ ] Ganti URL hardcode dengan environment variable
- [ ] Add email delivery tracking
- [ ] Add logging untuk OTP generation/verification
- [ ] Implement OTP brute force protection
- [ ] Add email templates professional
- [ ] Test dengan berbagai email provider (Gmail, Yahoo, Outlook)
- [ ] Setup SPF, DKIM, DMARC untuk domain

## 📚 References

- Laravel Mail: https://laravel.com/docs/10.x/mail
- Gmail App Password: https://support.google.com/accounts/answer/185833
- Mailtrap: https://mailtrap.io/
- SendGrid: https://sendgrid.com/
