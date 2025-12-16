<!-- @format -->

# Development Workflow untuk Agrigo

## Masalah

`flutter run` gagal menemukan APK karena incompatibility antara Flutter tooling dan AGP 8.7.0+. Ini adalah **known issue** - build berhasil tapi Flutter tidak bisa locate APK.

## Solusi: Manual Build & Hot Reload Workflow

### Method 1: Build + Install + Attach (RECOMMENDED)

```powershell
# 1. Build APK
cd "e:\SEMESTER 5\agrigo\agrigo"
flutter build apk --debug

# 2. Install ke device (accept permission di device jika muncul dialog)
adb install -r "android\app\build\outputs\flutter-apk\app-debug.apk"

# 3. Buka app di device, lalu attach untuk hot reload
flutter attach
```

Setelah `flutter attach` connect, kamu bisa:

- Press `r` untuk hot reload
- Press `R` untuk hot restart
- Edit code dan save → otomatis hot reload

### Method 2: Quick Install Only

```powershell
# Build & install dalam 1 step
cd "e:\SEMESTER 5\agrigo\agrigo"
flutter build apk --debug
adb install -r "android\app\build\outputs\flutter-apk\app-debug.apk"
```

## Root Cause Analysis

### Masalah Version Conflict:

1. **AGP 8.9.1**: Flutter tooling belum fully support (APK output path berubah)
2. **AGP 8.7.2**: `androidx.activity:1.11.0` requires AGP 8.9.1+
3. **AGP 8.7.0**: Masih ada dependency conflict + Flutter locator issue

### Kenapa Gradle Build Berhasil tapi Flutter Run Gagal?

- Gradle: ✅ Build berhasil, APK ada di `android/app/build/outputs/flutter-apk/app-debug.apk`
- Flutter tooling: ❌ Mencari APK di lokasi lama atau dengan naming convention berbeda
- Result: "Gradle build failed to produce an .apk file" (misleading error)

## Fixes yang Sudah Dicoba

### ✅ Yang Berhasil:

- Manual `adb install` → App installed & running
- `flutter attach` → Hot reload working
- Resolution strategy untuk force androidx.activity:1.9.3

### ❌ Yang Tidak Berhasil:

- Downgrade AGP → dependency conflict
- Upgrade AGP → Flutter locator issue
- Output configuration workaround → Kotlin syntax error

## Rekomendasi ke Depan

**Untuk saat ini**: Gunakan workflow manual (build + install + attach)

**Untuk jangka panjang**:

1. Wait for Flutter SDK update yang support AGP 8.9+
2. Atau wait for dependency updates yang support AGP 8.7.0
3. Monitor Flutter GitHub issues terkait AGP compatibility

## Current Configuration

**Working Setup:**

- AGP: 8.7.0
- Kotlin: 2.1.0
- Gradle: 8.13
- Firebase BOM: 32.7.0
- Resolution Strategy: Force androidx.activity:1.9.3

**File: android/settings.gradle.kts**

```kotlin
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}
```

**File: android/app/build.gradle.kts**

```kotlin
configurations.all {
    resolutionStrategy {
        force("androidx.activity:activity:1.9.3")
        force("androidx.activity:activity-ktx:1.9.3")
    }
}
```

## Tips

1. **Selalu cek APK exists**: `Test-Path "android\app\build\outputs\flutter-apk\app-debug.apk"`
2. **Permission dialog**: Accept "Install unknown apps" di device saat install
3. **Hot reload**: Lebih cepat dari rebuild full, gunakan `flutter attach`
4. **Cache issues**: Clean dengan `flutter clean` + hapus `.gradle/caches`

## Firebase Integration Status

✅ **SELESAI & WORKING:**

- Firebase packages installed
- google-services.json configured
- Firebase initialized in main.dart
- Transaction CRUD with Firestore
- Real-time sync in finance_page.dart
- Migration utilities created
- Security rules defined

📝 **TODO:**

- Deploy firestore.rules ke Firebase Console
- Create Firestore indexes (auto-generate dari error atau manual)
- Replace 'demo_user' dengan Firebase Authentication
- Test offline mode functionality
