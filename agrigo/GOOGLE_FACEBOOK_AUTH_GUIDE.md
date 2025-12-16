# 🔐 Panduan Google & Facebook Authentication

## ✅ Status Implementasi

### Yang Sudah Dikonfigurasi:
- ✅ **Google Sign-In** - Implementasi lengkap dengan Pigeon bug fix
- ✅ **Facebook Login** - Implementasi lengkap dengan Pigeon bug fix  
- ✅ **Firebase Authentication** - Terintegrasi penuh
- ✅ **Firestore Auto-Create** - User baru otomatis tersimpan
- ✅ **Android Configuration** - Sudah lengkap di AndroidManifest.xml
- ✅ **Dependencies** - Semua package sudah terinstall

---

## 📱 Cara Kerja Sistem

### 1. **Google Sign-In Flow**
```
User tap Google button
    ↓
Google Sign-In dialog muncul
    ↓
User pilih akun Google
    ↓
Firebase Auth login
    ↓
Cek Firestore - user sudah ada?
    ├─ Ya: Ambil data user
    └─ Tidak: Auto-create user document
    ↓
Navigate ke Dashboard
```

### 2. **Facebook Login Flow**
```
User tap Facebook button
    ↓
Facebook WebView login muncul
    ↓
User masukkan kredensial Facebook
    ↓
Firebase Auth login
    ↓
Cek Firestore - user sudah ada?
    ├─ Ya: Ambil data user
    └─ Tidak: Auto-create user document
    ↓
Navigate ke Dashboard
```

---

## 🔧 Konfigurasi Saat Ini

### **Android Configuration**

#### **1. Facebook App ID & Token**
Location: `android/app/src/main/res/values/strings.xml`
```xml
<string name="facebook_app_id">897444219611448</string>
<string name="facebook_client_token">0fb8ca40163b0a8ef097e17b7ae77466</string>
<string name="fb_login_protocol_scheme">fb897444219611448</string>
```

#### **2. AndroidManifest.xml**
- ✅ Facebook SDK configuration
- ✅ Facebook Activity & CustomTabActivity
- ✅ Internet permission
- ✅ Facebook queries for Android 11+

#### **3. build.gradle**
```gradle
dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
    implementation 'com.facebook.android:facebook-android-sdk:16.0.0'
}
```

#### **4. google-services.json**
Location: `android/app/google-services.json`
- ✅ File sudah ada dan terkonfigurasi

---

## 🚀 Cara Testing

### **Test Google Sign-In:**
1. Buka aplikasi di emulator atau device fisik
2. Klik tombol **Google (G)** di halaman login
3. Pilih akun Google dari list
4. Sistem akan otomatis:
   - Login via Firebase Auth
   - Buat user document di Firestore (jika belum ada)
   - Navigate ke Dashboard

### **Test Facebook Login:**
1. Buka aplikasi di emulator atau device fisik
2. Klik tombol **Facebook (f)** di halaman login
3. Masukkan kredensial Facebook di WebView
4. Sistem akan otomatis:
   - Login via Firebase Auth
   - Ambil nama & email dari Facebook
   - Buat user document di Firestore (jika belum ada)
   - Navigate ke Dashboard

---

## 🐛 Troubleshooting

### **Problem: Pigeon Serialization Error**
**Solusi:** Sudah di-handle otomatis di code!
```dart
catch (e) {
  if (e.toString().contains('PigeonUserDetails') || 
      e.toString().contains('is not a subtype')) {
    // Ignore Pigeon bug - auth masih berhasil
    if (FirebaseService.currentUser != null) {
      return; // Success!
    }
  }
  rethrow;
}
```

### **Problem: Google Sign-In tidak muncul**
**Kemungkinan Penyebab:**
1. SHA-1 fingerprint belum ditambahkan di Firebase Console
2. `google-services.json` tidak sesuai

**Solusi:**
1. Generate SHA-1:
   ```bash
   cd android
   ./gradlew signingReport
   ```
2. Copy SHA-1 ke Firebase Console → Project Settings → Add Fingerprint
3. Download ulang `google-services.json`
4. Rebuild app

### **Problem: Facebook Login gagal**
**Kemungkinan Penyebab:**
1. Facebook App ID salah
2. App belum di-approve di Facebook Developer Console
3. Test user belum ditambahkan

**Solusi:**
1. Cek Facebook App ID di `strings.xml`
2. Pastikan app dalam mode Development
3. Tambahkan test users di Facebook Developer Console

---

## 📝 Cara Mengganti Facebook App

### **Step 1: Buat Facebook App Baru**
1. Buka https://developers.facebook.com
2. My Apps → Create App
3. Pilih **Consumer** type
4. Isi nama app

### **Step 2: Setup Facebook Login**
1. Dashboard → Add Product → **Facebook Login**
2. Settings → Valid OAuth Redirect URIs:
   ```
   https://agrigo-bddde.firebaseapp.com/__/auth/handler
   ```

### **Step 3: Get App ID & Client Token**
1. Settings → Basic
2. Copy **App ID**
3. Copy **Client Token** (klik Show)

### **Step 4: Update Android**
Edit `android/app/src/main/res/values/strings.xml`:
```xml
<string name="facebook_app_id">YOUR_NEW_APP_ID</string>
<string name="facebook_client_token">YOUR_NEW_CLIENT_TOKEN</string>
<string name="fb_login_protocol_scheme">fbYOUR_NEW_APP_ID</string>
```

### **Step 5: Update Firebase Console**
1. Firebase Console → Authentication → Sign-in method
2. Facebook → Edit
3. Paste App ID & App Secret dari Facebook Dashboard

### **Step 6: Rebuild**
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

---

## 📝 Cara Mengganti Google Project

### **Step 1: Enable Google Sign-In di Firebase**
1. Firebase Console → Authentication → Sign-in method
2. Enable **Google** provider
3. Pilih support email

### **Step 2: Generate SHA-1 Fingerprint**
```bash
cd android
./gradlew signingReport
```

Copy SHA-1 dan SHA-256 dari output

### **Step 3: Add Fingerprints**
1. Firebase Console → Project Settings
2. Your Apps → Android app
3. Add fingerprint → Paste SHA-1 dan SHA-256

### **Step 4: Download google-services.json**
1. Firebase Console → Project Settings
2. Your Apps → Android app  
3. Download `google-services.json`
4. Replace file di `android/app/google-services.json`

### **Step 5: Rebuild**
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

---

## 🎯 Best Practices

### **1. Security**
- ✅ Jangan hardcode API keys di code
- ✅ Gunakan `google-services.json` dari Firebase
- ✅ Tambahkan SHA-1 untuk production & debug builds

### **2. User Experience**
- ✅ Tampilkan loading indicator saat proses login
- ✅ Berikan feedback jelas jika login gagal
- ✅ Auto-navigate ke dashboard jika berhasil

### **3. Error Handling**
- ✅ Catch semua Firebase exceptions
- ✅ Handle Pigeon serialization bug
- ✅ Display user-friendly error messages

---

## 📚 File-File Penting

### **Flutter Code:**
- `lib/services/firebase_service.dart` - Service untuk semua auth methods
- `lib/pages/login_page.dart` - UI dan flow login

### **Android Config:**
- `android/app/build.gradle` - Dependencies
- `android/app/google-services.json` - Firebase config
- `android/app/src/main/AndroidManifest.xml` - Permissions & activities
- `android/app/src/main/res/values/strings.xml` - Facebook keys

---

## 🎉 Status Akhir

✅ **Google Sign-In** - Ready to use  
✅ **Facebook Login** - Ready to use  
✅ **Email/Password** - Already working  
✅ **OTP Reset Password** - Already working  

**Sistem authentication lengkap sudah siap untuk production! 🚀**

---

## 📞 Support

Jika ada masalah:
1. Cek Firebase Console → Authentication → Users
2. Cek Firestore → users collection
3. Lihat Flutter console logs untuk error details
4. Rebuild app dengan `flutter clean && flutter pub get`
