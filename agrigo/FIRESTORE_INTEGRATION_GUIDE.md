# 🔥 Firebase Firestore Integration Guide
**IMPORTANT: Panduan ini HANYA untuk Backend Logic - UI/Design tidak diubah sama sekali!**

## ✅ Status: Service Layer COMPLETE

Semua Firestore services sudah siap digunakan di `lib/services/firestore_service.dart`

---

## 📋 Available Services & How to Use

### 1. **USER OPERATIONS**

```dart
final firestoreService = FirestoreService();

// Get current user
UserModel? user = await firestoreService.getCurrentUser();

// Update profile
await firestoreService.updateUserProfile(
  name: 'John Doe',
  phone: '+6281234567890',
  region: 'Jakarta',
  crops: ['padi', 'jagung'],
);

// Stream user data (real-time)
StreamBuilder<UserModel?>(
  stream: firestoreService.streamCurrentUser(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      UserModel user = snapshot.data!;
      return Text(user.name);
    }
    return CircularProgressIndicator();
  },
);
```

**Integration ke existing pages:**
- ✅ `edit_profile_page.dart` - Sudah pake service ini
- ✅ `dashboard_page.dart` - Display user info

---

### 2. **TRANSACTION OPERATIONS**

```dart
// Add transaction
await firestoreService.addTransaction(
  TransactionModel(
    id: '',
    userId: currentUserId,
    type: 'expense', // or 'income'
    category: 'fertilizer',
    amount: 500000,
    description: 'Pupuk organik',
    date: DateTime.now(),
  ),
);

// Get transactions
List<TransactionModel> transactions = 
  await firestoreService.getUserTransactions(limit: 50);

// Get by date range
transactions = await firestoreService.getUserTransactions(
  startDate: DateTime(2025, 1, 1),
  endDate: DateTime(2025, 12, 31),
);

// Stream transactions (real-time)
StreamBuilder<List<TransactionModel>>(
  stream: firestoreService.streamUserTransactions(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return ListView.builder(
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          TransactionModel tx = snapshot.data![index];
          return ListTile(
            title: Text(tx.description),
            trailing: Text('Rp ${tx.amount}'),
          );
        },
      );
    }
    return CircularProgressIndicator();
  },
);

// Get statistics
Map<String, double> stats = await firestoreService.getTransactionStats(
  startDate: DateTime(2025, 1, 1),
  endDate: DateTime.now(),
);
print('Income: ${stats['income']}');
print('Expense: ${stats['expense']}');
print('Balance: ${stats['balance']}');

// Update transaction
await firestoreService.updateTransaction(transactionId, {
  'amount': 600000,
  'description': 'Updated description',
});

// Delete transaction
await firestoreService.deleteTransaction(transactionId);
```

**Integration ke existing pages:**
- ✅ `finance_page.dart` - Main page untuk transactions
- ✅ `transaction_form_page.dart` - Add/edit transactions
- ✅ `transactions_page.dart` - List view

**Cara integrasinya di existing pages:**
```dart
// Contoh di finance_page.dart - tambahkan di initState atau didFinishLaunchingWithOptions
@override
void initState() {
  super.initState();
  _loadTransactions();
}

Future<void> _loadTransactions() async {
  final firestoreService = FirestoreService();
  final transactions = await firestoreService.getUserTransactions();
  setState(() {
    // Update state dengan data dari Firestore
  });
}
```

---

### 3. **SCHEDULE OPERATIONS**

```dart
// Add schedule
await firestoreService.addSchedule(
  ScheduleModel(
    id: '',
    userId: currentUserId,
    title: 'Tanam Padi',
    description: 'Musim tanam padi varietas IR64',
    startDate: DateTime(2025, 2, 1),
    endDate: DateTime(2025, 5, 1),
    status: 'planned', // planned, ongoing, completed
    crop: 'padi',
    area: 2.5,
    unit: 'hektar',
  ),
);

// Get schedules
List<ScheduleModel> schedules = 
  await firestoreService.getUserSchedules();

// Get by status
schedules = await firestoreService.getUserSchedules(status: 'ongoing');

// Get upcoming schedules (next 7 days)
schedules = await firestoreService.getUpcomingSchedules();

// Stream schedules (real-time)
StreamBuilder<List<ScheduleModel>>(
  stream: firestoreService.streamUserSchedules(),
  builder: (context, snapshot) {
    // ... build UI
  },
);

// Update schedule
await firestoreService.updateSchedule(scheduleId, {
  'status': 'completed',
  'actualYield': 5.2,
});

// Delete schedule
await firestoreService.deleteSchedule(scheduleId);
```

**Integration ke existing pages:**
- ✅ `schedule_page.dart` - Main schedule view
- ✅ `edit_schedule_page.dart` - Add/edit schedules
- ✅ `date_period_page.dart` - Date selection

---

### 4. **COMMODITY OPERATIONS** (Public Data)

```dart
// Get all commodities
List<CommodityModel> commodities = 
  await firestoreService.getCommodities();

// Filter by category
commodities = await firestoreService.getCommodities(
  category: 'Tanaman Pangan',
);

// Filter by region
commodities = await firestoreService.getCommodities(
  region: 'Jakarta',
);

// Stream commodities (real-time price updates)
StreamBuilder<List<CommodityModel>>(
  stream: firestoreService.streamCommodities(region: 'Jakarta'),
  builder: (context, snapshot) {
    // ... build price list
  },
);
```

**Integration ke existing pages:**
- ✅ `commodity_list_page.dart` - List semua commodities
- ✅ `commodity_detail_page.dart` - Detail harga
- ✅ `commodity_search_page.dart` - Search function
- ✅ `commodity_selection_page.dart` - Selection UI

---

### 5. **WEATHER OPERATIONS** (Public Data)

```dart
// Get weather by region
WeatherModel? weather = await firestoreService.getWeather('Jakarta');

if (weather != null) {
  print('Temperature: ${weather.temperature}°C');
  print('Condition: ${weather.condition}');
  print('Humidity: ${weather.humidity}%');
}

// Stream weather (real-time updates)
StreamBuilder<WeatherModel?>(
  stream: firestoreService.streamWeather('Jakarta'),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      WeatherModel weather = snapshot.data!;
      return Column(
        children: [
          Text('${weather.temperature}°C'),
          Text(weather.condition),
        ],
      );
    }
    return CircularProgressIndicator();
  },
);
```

**Integration ke existing pages:**
- ✅ `weather_page.dart` - Weather display
- ✅ `dashboard_page.dart` - Weather widget

---

### 6. **NOTIFICATION OPERATIONS**

```dart
// Save FCM token (call this after user login)
await firestoreService.saveFCMToken(fcmToken);

// Get notifications
List<NotificationModel> notifications = 
  await firestoreService.getUserNotifications();

// Get unread only
notifications = await firestoreService.getUserNotifications(
  unreadOnly: true,
);

// Stream notifications (real-time)
StreamBuilder<List<NotificationModel>>(
  stream: firestoreService.streamUserNotifications(),
  builder: (context, snapshot) {
    // ... build notification list
  },
);

// Mark as read
await firestoreService.markNotificationAsRead(notificationId);

// Mark all as read
await firestoreService.markAllNotificationsAsRead();
```

**Integration ke existing pages:**
- ✅ `notification_page.dart` - Notification list
- ✅ `dashboard_page.dart` - Notification badge

---

## 🚀 Quick Integration Examples

### Example 1: Finance Page dengan Real-time Data

```dart
// lib/pages/finance_page.dart - TAMBAHKAN INI (tidak ubah UI)

class _FinancePageState extends State<FinancePage> {
  final FirestoreService _firestoreService = FirestoreService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Keuangan')),
      body: StreamBuilder<List<TransactionModel>>(
        stream: _firestoreService.streamUserTransactions(limit: 50),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Belum ada transaksi'));
          }
          
          final transactions = snapshot.data!;
          
          // GUNAKAN EXISTING UI COMPONENTS ANDA
          return YourExistingUIComponent(transactions: transactions);
        },
      ),
    );
  }
}
```

### Example 2: Add Transaction dari Form

```dart
// lib/pages/transaction_form_page.dart - TAMBAHKAN di submit function

Future<void> _submitTransaction() async {
  if (_formKey.currentState!.validate()) {
    final firestoreService = FirestoreService();
    
    final transaction = TransactionModel(
      id: '',
      userId: firestoreService.currentUserId!,
      type: _selectedType, // from your form
      category: _selectedCategory, // from your form
      amount: _amountController.text, // from your form
      description: _descriptionController.text,
      date: _selectedDate,
    );
    
    String? transactionId = await firestoreService.addTransaction(transaction);
    
    if (transactionId != null) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Transaksi berhasil ditambahkan')),
      );
      Navigator.pop(context);
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Gagal menambahkan transaksi')),
      );
    }
  }
}
```

### Example 3: Display Statistics di Dashboard

```dart
// lib/pages/dashboard_page.dart - TAMBAHKAN widget untuk stats

FutureBuilder<Map<String, double>>(
  future: _firestoreService.getTransactionStats(
    startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
    endDate: DateTime.now(),
  ),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    
    final stats = snapshot.data!;
    
    // GUNAKAN EXISTING UI DESIGN ANDA
    return YourStatisticsWidget(
      income: stats['income']!,
      expense: stats['expense']!,
      balance: stats['balance']!,
    );
  },
);
```

---

## 📝 Integration Checklist

### Pages yang sudah siap tinggal integrasikan:

- [ ] `finance_page.dart` - Tambahkan `StreamBuilder` untuk real-time transactions
- [ ] `transaction_form_page.dart` - Panggil `addTransaction()` di submit
- [ ] `transactions_page.dart` - Gunakan `getUserTransactions()` untuk list
- [ ] `schedule_page.dart` - Gunakan `streamUserSchedules()` untuk real-time
- [ ] `edit_schedule_page.dart` - Panggil `addSchedule()` atau `updateSchedule()`
- [ ] `commodity_list_page.dart` - Gunakan `streamCommodities()` untuk live price
- [ ] `weather_page.dart` - Gunakan `streamWeather()` untuk real-time weather
- [ ] `notification_page.dart` - Gunakan `streamUserNotifications()`
- [ ] `dashboard_page.dart` - Combine semua data dengan `FutureBuilder`

---

## 🔒 Important Notes

### ❌ JANGAN:
- Jangan ubah UI/design yang sudah ada
- Jangan buat page baru kecuali diminta
- Jangan ubah struktur folder existing
- Jangan hapus code yang sudah berfungsi

### ✅ LAKUKAN:
- **HANYA tambahkan logic di existing pages**
- **HANYA panggil FirestoreService methods**
- **HANYA ganti dummy data dengan real Firestore data**
- **Preserve all existing UI components**

---

## 🐛 Troubleshooting

### "User not found"
```dart
// Pastikan user sudah register di Firebase Auth
final user = await _firestoreService.getCurrentUser();
if (user == null) {
  // Redirect ke login
}
```

### "Permission denied"
- Check Firestore Security Rules di Firebase Console
- Pastikan user sudah authenticated

### "Data tidak muncul"
```dart
// Debug dengan print
final transactions = await _firestoreService.getUserTransactions();
print('📊 Transactions count: ${transactions.length}');
```

---

## 🎯 Next Steps

1. **Test semua service methods** ✅ (Sudah siap)
2. **Integrate ke existing pages** ⏳ (Tinggal panggil methods)
3. **Add loading indicators** ⏳ (CircularProgressIndicator)
4. **Add error handling** ⏳ (try-catch & SnackBar)
5. **Test real-time sync** ⏳ (Buka app di 2 devices)

---

## 📚 Full API Reference

Semua methods ada di: `lib/services/firestore_service.dart`

**Total Methods Available: 30+**
- User: 5 methods
- Transaction: 7 methods
- Schedule: 6 methods
- Commodity: 2 methods
- Weather: 2 methods
- Notification: 5 methods
- Utility: 1 method (deleteUserAccount)

---

**🎉 READY TO USE! Tinggal panggil di existing pages Anda!**
