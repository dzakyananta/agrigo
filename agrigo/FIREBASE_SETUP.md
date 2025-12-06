<!-- @format -->

# Panduan Setup Firebase untuk AgriGo

## 1. Konfigurasi Firebase Project

### Langkah 1: Buat Project Firebase

1. Buka [Firebase Console](https://console.firebase.google.com)
2. Klik "Add project" atau "Create a project"
3. Nama project: `agrigo-app`
4. Aktifkan Google Analytics (opsional)
5. Pilih location: Asia-Southeast1 (Singapore)

### Langkah 2: Setup Authentication

1. Di Firebase Console, pilih "Authentication"
2. Klik tab "Sign-in method"
3. Aktifkan:
   - Email/Password
   - Phone (opsional untuk SMS verification)
   - Google (opsional)

### Langkah 3: Setup Firestore Database

1. Di Firebase Console, pilih "Firestore Database"
2. Klik "Create database"
3. Pilih "Start in test mode" (untuk development)
4. Pilih location: asia-southeast1

### Langkah 4: Setup Storage

1. Di Firebase Console, pilih "Storage"
2. Klik "Get started"
3. Gunakan default security rules

### Langkah 5: Setup Cloud Messaging (untuk notifikasi push)

1. Di Firebase Console, pilih "Cloud Messaging"
2. Setup akan otomatis ketika menambahkan Android/iOS app

## 2. Konfigurasi Flutter App

### Langkah 1: Install Firebase CLI

```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
```

### Langkah 2: Login dan Setup

```bash
firebase login
flutterfire configure
```

### Langkah 3: Install Dependencies

Jalankan di terminal VS Code:

```bash
cd "e:\SEMESTER 5\agrigo\agrigo"
flutter pub get
```

### Langkah 4: Android Configuration

1. Download `google-services.json` dari Firebase Console
2. Letakkan di `android/app/google-services.json`
3. Edit `android/build.gradle` (project level):

```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
}
```

4. Edit `android/app/build.gradle`:

```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.3.1')
}
```

## 3. Setup API Cuaca OpenWeatherMap

### Langkah 1: Daftar API Key

1. Buka [OpenWeatherMap](https://openweathermap.org/api)
2. Daftar akun gratis
3. Dapatkan API Key dari dashboard

### Langkah 2: Update Weather Service

Edit file `lib/services/weather_service.dart`, ganti:

```dart
static const String _apiKey = 'YOUR_OPENWEATHER_API_KEY';
```

dengan API key yang didapat.

## 4. Firestore Database Schema

### Collections yang akan dibuat:

#### users

```json
{
  "userId": "user_123",
  "name": "Nama Petani",
  "email": "petani@example.com",
  "phone": "+62812345678",
  "region": "Bandar Lampung",
  "profileImage": "https://...",
  "crops": ["padi", "jagung", "cabai"],
  "role": "farmer", // atau "admin"
  "createdAt": "2025-01-01T00:00:00Z",
  "isActive": true
}
```

#### commodities

```json
{
  "commodityId": "commodity_123",
  "name": "Padi IR64",
  "category": "pangan",
  "currentPrice": 5500,
  "region": "Bandar Lampung",
  "unit": "kg",
  "imageUrl": "https://...",
  "description": "Padi berkualitas tinggi",
  "priceHistory": [
    {
      "price": 5500,
      "timestamp": "2025-01-01T00:00:00Z"
    }
  ],
  "createdAt": "2025-01-01T00:00:00Z",
  "updatedAt": "2025-01-01T00:00:00Z",
  "isActive": true
}
```

#### transactions

```json
{
  "transactionId": "trans_123",
  "buyerId": "user_123",
  "sellerId": "user_456",
  "commodityId": "commodity_123",
  "commodityName": "Padi IR64",
  "quantity": 100,
  "pricePerUnit": 5500,
  "totalAmount": 550000,
  "notes": "Kualitas bagus",
  "status": "pending", // pending, confirmed, completed, cancelled
  "createdAt": "2025-01-01T00:00:00Z",
  "updatedAt": "2025-01-01T00:00:00Z"
}
```

#### weather_data

```json
{
  "weatherId": "weather_123",
  "region": "Bandar Lampung",
  "temperature": 28.5,
  "feelsLike": 32.1,
  "humidity": 75,
  "pressure": 1013,
  "description": "cerah berawan",
  "main": "Clouds",
  "icon": "02d",
  "windSpeed": 3.2,
  "windDegree": 180,
  "visibility": 10000,
  "cloudiness": 40,
  "sunrise": "2025-01-01T23:30:00Z",
  "sunset": "2025-01-01T11:45:00Z",
  "cityName": "Bandar Lampung",
  "country": "ID",
  "coordinates": {
    "lat": -5.4292,
    "lon": 105.2611
  },
  "timestamp": "2025-01-01T00:00:00Z"
}
```

#### notifications

```json
{
  "notificationId": "notif_123",
  "userId": "user_123",
  "title": "Harga Padi Naik",
  "message": "Harga padi di Bandar Lampung naik menjadi Rp 5.500/kg",
  "type": "priceAlert", // general, priceAlert, weather, transaction, system
  "data": {
    "commodityId": "commodity_123",
    "newPrice": 5500
  },
  "isRead": false,
  "createdAt": "2025-01-01T00:00:00Z",
  "readAt": null
}
```

#### regions

```json
{
  "regionId": "region_123",
  "name": "Bandar Lampung",
  "province": "Lampung",
  "coordinates": {
    "lat": -5.4292,
    "lon": 105.2611
  },
  "isActive": true,
  "createdAt": "2025-01-01T00:00:00Z"
}
```

## 5. Security Rules Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null &&
        resource.data.role == 'admin' ||
        request.auth.token.admin == true;
    }

    // Commodities collection
    match /commodities/{commodityId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
        request.auth.token.admin == true;
    }

    // Transactions collection
    match /transactions/{transactionId} {
      allow read, write: if request.auth != null &&
        (resource.data.buyerId == request.auth.uid ||
         resource.data.sellerId == request.auth.uid);
      allow read: if request.auth != null &&
        request.auth.token.admin == true;
    }

    // Weather data - public read
    match /weather_data/{weatherId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }

    // Notifications
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null &&
        resource.data.userId == request.auth.uid;
    }

    // Regions - public read
    match /regions/{regionId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
        request.auth.token.admin == true;
    }
  }
}
```

## 6. Cara Menjalankan Aplikasi

### Development Mode:

```bash
# Di terminal VS Code
cd "e:\SEMESTER 5\agrigo\agrigo"

# Install dependencies
flutter pub get

# Run aplikasi
flutter run
```

### Build untuk Release:

```bash
# Android APK
flutter build apk --release

# Android App Bundle (untuk Play Store)
flutter build appbundle --release
```

## 7. Fitur Real-time yang Sudah Diimplementasi

✅ **Cuaca Real-time**: Menggunakan OpenWeatherMap API
✅ **Harga Komoditas**: Update real-time via Firestore
✅ **Notifikasi Push**: Firebase Cloud Messaging  
✅ **Lokasi Otomatis**: Geolocator untuk cuaca berdasarkan lokasi
✅ **Saran Pertanian**: Berdasarkan kondisi cuaca real
✅ **Forecast 5 Hari**: Prakiraan cuaca untuk perencanaan
✅ **Database Terintegrasi**: Semua data tersimpan di Firebase

## 8. Testing Database

Setelah setup, Anda dapat test dengan:

1. Buat akun user baru via app
2. Lihat data di Firebase Console > Firestore
3. Test fitur cuaca dengan GPS enabled
4. Test transaksi dan notifikasi

## 9. Monitoring & Analytics

Firebase menyediakan:

- **Analytics**: User behavior dan app usage
- **Crashlytics**: Error monitoring
- **Performance**: App performance monitoring
- **Remote Config**: Update app tanpa release baru

Database Firebase ini siap untuk produksi dan dapat menangani ribuan user petani secara bersamaan dengan real-time updates!
