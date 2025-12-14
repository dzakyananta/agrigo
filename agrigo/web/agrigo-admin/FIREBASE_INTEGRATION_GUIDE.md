# Firebase Integration dengan Laravel Admin - Setup Guide

## ✅ Yang Sudah Selesai

1. **PHP Sodium Extension** - Sudah diaktifkan
2. **Firebase PHP SDK** - Sudah terinstall (kreait/firebase-php v7.9.0)
3. **FirebaseService.php** - Sudah dibuat di `app/Services/FirebaseService.php`
4. **Test Route** - Sudah dibuat di `/test-firebase`
5. **Environment Config** - Sudah ditambahkan ke `.env`

## 📋 Langkah Selanjutnya

### 1. Download Firebase Service Account Credentials

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Pilih project **agrigo**
3. Klik ⚙️ (Settings) → **Project Settings**
4. Tab **Service Accounts**
5. Klik **Generate New Private Key**
6. Download file JSON
7. **PENTING**: Simpan file dengan nama `firebase-credentials.json` di folder:
   ```
   e:\basedproject\agrigo\agrigo\web\agrigo-admin\storage\firebase-credentials.json
   ```

### 2. Update Firebase Project ID di .env

Edit file `.env` dan update `FIREBASE_PROJECT_ID` dengan project ID yang benar dari Firebase Console:

```env
FIREBASE_PROJECT_ID=your-actual-firebase-project-id
```

### 3. Test Koneksi Firebase

Setelah credentials sudah tersimpan, test koneksi dengan:

```bash
php artisan serve
```

Kemudian buka browser ke:
```
http://localhost:8000/test-firebase
```

**Expected Response (Success):**
```json
{
  "success": true,
  "message": "Firebase connected successfully",
  "users_count": 5,
  "users": [
    {
      "id": "user123",
      "name": "John Doe",
      "email": "john@example.com",
      ...
    }
  ]
}
```
**Jika Error:**
```json
{
  "success": false,
  "error": "Credentials file not found or invalid"
}
```
→ Pastikan file `firebase-credentials.json` sudah ada di folder `storage/`

## 🏗️ Struktur Database yang Direkomendasikan

### Hybrid Approach: Firebase + MySQL

**Firebase Firestore** (Shared Data - Real-time sync antara Mobile & Web):
- ✅ `users` - Data pengguna (farmers)
- ✅ `transactions` - Transaksi keuangan
- ✅ `schedules` - Jadwal tanam/panen
- ✅ `commodities` - Data komoditas (harga, stok)
- ✅ `weather` - Data cuaca
- ✅ `notifications` - Notifikasi push

**MySQL** (Laravel Admin Only - Data administratif):
- ✅ `admins` - Akun admin (login web admin)
- ✅ `activity_logs` - Log aktivitas admin
- ✅ `sessions` - Session Laravel
- ✅ `cache` - Cache Laravel
- ✅ `queue_jobs` - Background jobs

### Keuntungan Hybrid Approach:

1. **Real-time Sync**: Mobile app dan web admin melihat data yang sama secara real-time
2. **Offline Support**: Firebase Firestore support offline mode di mobile
3. **Scalability**: Firebase auto-scale tanpa perlu manage server
4. **Security**: Firebase Security Rules melindungi data
5. **Performance**: MySQL untuk data administratif yang tidak perlu real-time

## 🔧 Cara Menggunakan Firebase Service

### Contoh 1: Get All Users

```php
use App\Services\FirebaseService;

class DashboardController extends Controller
{
    public function index(FirebaseService $firebase)
    {
        $users = $firebase->getAllUsers();
        $totalUsers = count($users);
        
        return view('admin.dashboard', compact('users', 'totalUsers'));
    }
}
```

### Contoh 2: Get User Detail

```php
public function show($id, FirebaseService $firebase)
{
    $user = $firebase->getUser($id);
    
    if (!$user) {
        return redirect()->back()->with('error', 'User tidak ditemukan');
    }
    
    $transactions = $firebase->getUserTransactions($id);
    
    return view('admin.users.show', compact('user', 'transactions'));
}
```

### Contoh 3: Update User

```php
public function update(Request $request, $id, FirebaseService $firebase)
{
    $data = $request->validate([
        'name' => 'required|string',
        'phone' => 'nullable|string',
        'region' => 'nullable|string',
        'isActive' => 'boolean',
    ]);
    
    $firebase->updateUser($id, $data);
    
    return redirect()->route('admin.users.show', $id)
        ->with('success', 'User berhasil diupdate');
}
```

### Contoh 4: Query Collection (Advanced)

```php
// Get active users only
$activeUsers = $firebase->queryCollection('users', 'isActive', '=', true);

// Get transactions by status
$pendingTransactions = $firebase->queryCollection(
    'transactions', 
    'status', 
    '=', 
    'pending'
);

// Get users by region
$jakartaUsers = $firebase->queryCollection('users', 'region', '=', 'Jakarta');
```

## 📊 Firestore Collection Structure

### Collection: `users`
```json
{
  "id": "auto-generated-uid",
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+62812345678",
  "region": "Jakarta",
  "profileImage": "https://storage.googleapis.com/...",
  "crops": ["padi", "jagung"],
  "role": "farmer",
  "isActive": true,
  "createdAt": "2025-01-01T00:00:00Z"
}
```

### Collection: `transactions`
```json
{
  "id": "auto-generated-id",
  "userId": "user-uid",
  "type": "income|expense",
  "category": "fertilizer|seed|harvest",
  "amount": 500000,
  "description": "Pembelian pupuk",
  "date": "2025-01-15T00:00:00Z",
  "createdAt": "2025-01-15T10:30:00Z"
}
```

### Collection: `schedules`
```json
{
  "id": "auto-generated-id",
  "userId": "user-uid",
  "title": "Tanam Padi",
  "description": "Masa tanam padi varietas IR64",
  "startDate": "2025-02-01T00:00:00Z",
  "endDate": "2025-05-01T00:00:00Z",
  "status": "planned|ongoing|completed",
  "crop": "padi",
  "area": 2.5,
  "unit": "hektar"
}
```

### Collection: `commodities`
```json
{
  "id": "auto-generated-id",
  "name": "Padi",
  "category": "Tanaman Pangan",
  "price": 5000,
  "unit": "kg",
  "region": "Jakarta",
  "lastUpdated": "2025-01-15T00:00:00Z"
}
```

## 🔒 Firebase Security Rules

Deploy rules ini ke Firebase Console → Firestore Database → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection
    match /users/{userId} {
      // Farmers can only read/write their own data
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Allow read for authenticated users (for listings)
      allow read: if request.auth != null;
    }
    
    // Transactions collection
    match /transactions/{transactionId} {
      // Users can only access their own transactions
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Schedules collection
    match /schedules/{scheduleId} {
      // Users can only access their own schedules
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Commodities - read only for all authenticated users
    match /commodities/{commodityId} {
      allow read: if request.auth != null;
      allow write: if false; // Only via admin/functions
    }
    
    // Weather - read only for all authenticated users
    match /weather/{weatherId} {
      allow read: if request.auth != null;
      allow write: if false; // Only via admin/functions
    }
    
    // Notifications
    match /notifications/{notificationId} {
      allow read: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      allow write: if false; // Only via admin/functions
    }
  }
}
```

## 💡 Tips & Best Practices

### 1. Error Handling
```php
try {
    $users = $firebase->getAllUsers();
} catch (\Exception $e) {
    Log::error('Firebase Error: ' . $e->getMessage());
    return response()->json(['error' => 'Failed to fetch data'], 500);
}
```

### 2. Caching Results
```php
use Illuminate\Support\Facades\Cache;

$users = Cache::remember('firebase_users', 300, function () use ($firebase) {
    return $firebase->getAllUsers();
});
```

### 3. Background Jobs untuk Data Sync
```php
// app/Jobs/SyncFirebaseData.php
class SyncFirebaseData implements ShouldQueue
{
    public function handle(FirebaseService $firebase)
    {
        $users = $firebase->getAllUsers();
        // Process data...
    }
}
```

## 🚀 Next Steps

1. ✅ **Test koneksi** - Jalankan `/test-firebase`
2. **Update UserController** - Integrasikan Firebase ke existing controllers
3. **Update Views** - Sesuaikan tampilan untuk data Firebase
4. **Deploy Security Rules** - Copy paste rules di atas ke Firebase Console
5. **Testing** - Test CRUD operations dari web admin

## 📞 Troubleshooting

### Error: "Credentials file not found"
- Pastikan file `firebase-credentials.json` ada di folder `storage/`
- Check permissions file (harus readable)

### Error: "Unauthorized"
- Pastikan service account memiliki role **Firebase Admin SDK Administrator**
- Re-download credentials file

### Error: "Collection not found"
- Collection akan auto-create saat first write
- Atau buat manual di Firebase Console

## 📖 Resources

- [Firebase PHP SDK Documentation](https://firebase-php.readthedocs.io/)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)

---

**Database Strategy Summary:**

✅ **Firebase Firestore** → Shared data (mobile + web) - Real-time sync  
✅ **MySQL** → Admin-only data (sessions, logs, cache)  
✅ **Hybrid approach** → Best of both worlds  

**Kenapa bukan MySQL untuk semua?**
- Mobile app butuh offline support → Firebase punya built-in
- Real-time updates → Firebase auto-sync, MySQL butuh polling
- Scalability → Firebase auto-scale, MySQL butuh manage server
- Push notifications → Firebase Cloud Messaging terintegrasi

**Kenapa bukan Firebase untuk semua?**
- Laravel authentication → Sudah punya sistem di MySQL
- Admin activity logs → Tidak perlu real-time, lebih efisien di MySQL
- Session/Cache → Laravel native support untuk MySQL
- Cost → MySQL lokal gratis, Firebase bayar per usage
