<!-- @format -->

# Smart Notification System - Agrigo

## Fitur Utama

### 1. Notifikasi Otomatis Berdasarkan Jadwal

Sistem secara otomatis menghasilkan notifikasi pintar berdasarkan jadwal tanam yang aktif:

- **Hari 1 (Penanaman)**: Reminder penanaman komoditas
- **Hari ke-7**: Notifikasi pemupukan awal
- **Hari ke-14**: Reminder pemeriksaan hama
- **Setiap 3 hari**: Reminder penyiraman rutin
- **Setiap 14 hari**: Reminder pemupukan berkala
- **7 hari sebelum panen**: Persiapan alat panen
- **Hari panen**: Notifikasi hari panen

### 2. Dashboard Integration

#### Notification Bell dengan Badge

- Menampilkan jumlah notifikasi yang belum dibaca
- Badge merah dengan counter (max: 9+)
- Tap untuk membuka halaman notifikasi lengkap

#### Notifikasi Preview

- Menampilkan 3 notifikasi terbaru di dashboard
- Tombol "Lihat Semua" untuk membuka halaman lengkap
- Pull-to-refresh untuk update notifikasi

### 3. Halaman Notifikasi Lengkap

#### Fitur:

- **Mark as Read**: Tap notifikasi untuk menandai sebagai dibaca
- **Mark All as Read**: Tandai semua notifikasi dibaca sekaligus
- **Swipe to Delete**: Geser kiri untuk menghapus notifikasi
- **Konfirmasi Hapus**: Dialog konfirmasi sebelum menghapus

#### Visual Indicators:

- Border warna untuk notifikasi belum dibaca
- Dot indikator unread
- Icon berdasarkan tipe (penyiraman, pemupukan, hama, panen, tanam)
- Warna berdasarkan prioritas (merah, hijau, orange, biru)

### 4. Smart Generation

#### Otomatis:

- Generate notifikasi 1x per hari
- Tidak duplikasi notifikasi pada hari yang sama
- Hanya untuk jadwal yang sedang berlangsung
- Maximum 50 notifikasi tersimpan (auto-cleanup)

#### Manual:

- API untuk create custom notification
- Cocok untuk reminder manual atau event khusus

## Tipe Notifikasi

### Icon Types:

- `water`: Penyiraman (💧)
- `fertilizer`: Pemupukan (🌱)
- `pest`: Pemeriksaan Hama (🐛)
- `harvest`: Panen (🌾)
- `plant`: Penanaman (🌿)

### Color Types:

- `red`: Urgent/Important
- `green`: Normal/Success
- `orange`: Warning/Reminder
- `blue`: Info

## Data Persistence

Menggunakan **SharedPreferences** untuk menyimpan:

- List notifikasi (JSON)
- Status read/unread
- Last check timestamp (untuk prevent duplicate generation)

## API Methods

### NotificationService

```dart
// Get all notifications
await NotificationService.getNotifications()

// Save notification
await NotificationService.saveNotification(notification)

// Mark as read
await NotificationService.markAsRead(id)

// Mark all as read
await NotificationService.markAllAsRead()

// Delete notification
await NotificationService.deleteNotification(id)

// Get unread count
await NotificationService.getUnreadCount()

// Generate smart notifications (auto called)
await NotificationService.generateSmartNotifications()

// Create manual notification
await NotificationService.createManualNotification(
  title: 'Custom Title',
  description: 'Custom Description',
  time: 'Hari ini',
  iconType: 'water',
  colorType: 'blue',
)
```

## Cara Penggunaan

### Automatic (Sudah Terintegrasi)

Sistem otomatis berjalan saat:

1. Dashboard page di-load
2. User melakukan pull-to-refresh
3. Setiap hari saat app dibuka (auto-check)

### Manual Trigger

Jika ingin manual refresh:

```dart
await NotificationService.generateSmartNotifications();
await _loadNotifications();
```

## Maintenance

### Clear Old Notifications

Otomatis menjaga max 50 notifikasi terbaru.

### Reset Notifications

```dart
final prefs = await SharedPreferences.getInstance();
await prefs.remove('notifications');
await prefs.remove('last_notification_check');
```

## Future Enhancements

Potensial fitur yang bisa ditambahkan:

- [ ] Push notification (Firebase Cloud Messaging)
- [ ] Sound/vibration untuk notifikasi baru
- [ ] Filter notifikasi by type/schedule
- [ ] Search dalam notifikasi
- [ ] Archive notifikasi
- [ ] Schedule custom reminder
- [ ] Notification preferences/settings
- [ ] Priority levels
- [ ] Notification categories
