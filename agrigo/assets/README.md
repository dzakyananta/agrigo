<!-- @format -->

Tambahkan file gambar berikut ke folder `assets/`:

1. logo.png -> gunakan gambar ke-2 dari lampiran (logo berwarna hijau). Ini akan ditampilkan di dalam lingkaran pada layar utama.
2. placeholder.png (opsional) -> gunakan gambar ke-1 dari lampiran jika Anda ingin mengganti placeholder.

Langkah:

- Buka folder project `e:\SEMESTER 5\agrigo\agrigo\assets` (buat folder `assets` jika belum ada).
- Salin file gambar dari lampiran ke folder tersebut.
- Pastikan nama file tepat: `logo.png` (dan `placeholder.png` jika diperlukan).
- Jalankan di terminal (PowerShell):

```powershell
cd "e:\SEMESTER 5\agrigo\agrigo"
flutter pub get
flutter run -d <device>
```

Jika muncul error bahwa asset tidak ditemukan, periksa nama file dan pastikan sudah tercantum di `pubspec.yaml` pada bagian `flutter -> assets:`.
