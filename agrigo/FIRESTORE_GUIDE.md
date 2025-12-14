# 🚀 Flutter Firebase Firestore Integration - Complete Guide

## ✅ Setup Complete!

Anda sekarang memiliki **Firestore Service** yang lengkap untuk mobile app Flutter dengan fitur:

- ✅ **User Management** - Profile, updates, real-time sync
- ✅ **Transactions** - Income/Expense tracking dengan statistik
- ✅ **Schedules** - Planting & harvest schedules
- ✅ **Commodities** - Real-time price monitoring
- ✅ **Weather** - Weather data integration
- ✅ **Notifications** - Push notifications & in-app alerts
- ✅ **Real-time Streams** - Live data updates tanpa refresh

---

## 📁 File Structure

```
lib/
├── models/
│   └── app_models.dart           ✅ Complete models (User, Transaction, Schedule, etc.)
├── services/
│   ├── firestore_service.dart    ✅ NEW! Complete Firestore CRUD operations
│   ├── firebase_service.dart     ✅ Authentication service
│   └── ...
├── pages/
│   ├── transactions_page.dart    ✅ NEW! Example transaction page
│   └── ...
```

---

## 🎯 How To Use Firestore Service

### 1. **Initialize Service**

```dart
import 'package:agrigo/services/firestore_service.dart';

class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final FirestoreService _firestore = FirestoreService();
  
  // Your code here
}
```

---

### 2. **User Operations**

#### Get Current User Profile
```dart
UserModel? user = await _firestore.getCurrentUser();
if (user != null) {
  print('Name: ${user.name}');
  print('Email: ${user.email}');
  print('Region: ${user.region}');
}
```

#### Update Profile
```dart
bool success = await _firestore.updateUserProfile(
  name: 'John Doe',
  phone: '+6281234567890',
  region: 'Jakarta',
  crops: ['padi', 'jagung'],
);
```

#### Stream User Data (Real-time)
```dart
StreamBuilder<UserModel?>(
  stream: _firestore.streamCurrentUser(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final user = snapshot.data!;
      return Text('Hello, ${user.name}!');
    }
    return CircularProgressIndicator();
  },
)
```

---

### 3. **Transaction Operations**

#### Add Transaction
```dart
final transaction = TransactionModel(
  id: '',
  userId: _firestore.currentUserId!,
  type: 'expense', // or 'income'
  category: 'fertilizer',
  amount: 500000,
  description: 'Pupuk NPK 50kg',
  date: DateTime.now(),
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

String? id = await _firestore.addTransaction(transaction);
if (id != null) {
  print('✅ Transaction added: $id');
}
```

#### Get Transactions
```dart
List<TransactionModel> transactions = await _firestore.getUserTransactions(
  limit: 50,
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime.now(),
);
```

#### Stream Transactions (Real-time)
```dart
StreamBuilder<List<TransactionModel>>(
  stream: _firestore.streamUserTransactions(limit: 50),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final transactions = snapshot.data!;
      return ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final tx = transactions[index];
          return ListTile(
            title: Text(tx.description),
            subtitle: Text(tx.category),
            trailing: Text('Rp ${tx.amount}'),
          );
        },
      );
    }
    return CircularProgressIndicator();
  },
)
```

#### Get Transaction Statistics
```dart
Map<String, double> stats = await _firestore.getTransactionStats(
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime.now(),
);

print('Income: Rp ${stats['income']}');
print('Expense: Rp ${stats['expense']}');
print('Balance: Rp ${stats['balance']}');
```

#### Update Transaction
```dart
await _firestore.updateTransaction(transactionId, {
  'amount': 600000,
  'description': 'Pupuk NPK 60kg',
  'updatedAt': FieldValue.serverTimestamp(),
});
```

#### Delete Transaction
```dart
bool success = await _firestore.deleteTransaction(transactionId);
```

---

### 4. **Schedule Operations**

#### Add Schedule
```dart
final schedule = ScheduleModel(
  id: '',
  userId: _firestore.currentUserId!,
  title: 'Tanam Padi',
  description: 'Masa tanam padi varietas IR64',
  startDate: DateTime(2024, 2, 1),
  endDate: DateTime(2024, 5, 1),
  status: 'planned',
  crop: 'padi',
  area: 2.5,
  unit: 'hektar',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

String? id = await _firestore.addSchedule(schedule);
```

#### Get Schedules
```dart
// Get all schedules
List<ScheduleModel> schedules = await _firestore.getUserSchedules();

// Get by status
List<ScheduleModel> activeSchedules = await _firestore.getUserSchedules(
  status: 'ongoing',
);

// Get upcoming schedules (next 7 days)
List<ScheduleModel> upcoming = await _firestore.getUpcomingSchedules();
```

#### Stream Schedules (Real-time)
```dart
StreamBuilder<List<ScheduleModel>>(
  stream: _firestore.streamUserSchedules(status: 'ongoing'),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final schedules = snapshot.data!;
      return ListView.builder(
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final schedule = schedules[index];
          return Card(
            child: ListTile(
              title: Text(schedule.title),
              subtitle: Text('${schedule.crop} - ${schedule.area} ${schedule.unit}'),
              trailing: Text(schedule.status),
            ),
          );
        },
      );
    }
    return CircularProgressIndicator();
  },
)
```

#### Update Schedule Status
```dart
await _firestore.updateSchedule(scheduleId, {
  'status': 'completed',
  'updatedAt': FieldValue.serverTimestamp(),
});
```

---

### 5. **Commodity Operations**

#### Get Commodities
```dart
// Get all
List<CommodityModel> commodities = await _firestore.getCommodities();

// Filter by category
List<CommodityModel> grains = await _firestore.getCommodities(
  category: 'Tanaman Pangan',
);

// Filter by region
List<CommodityModel> jakartaCommodities = await _firestore.getCommodities(
  region: 'Jakarta',
);
```

#### Stream Commodities (Real-time Prices)
```dart
StreamBuilder<List<CommodityModel>>(
  stream: _firestore.streamCommodities(region: 'Jakarta'),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final commodities = snapshot.data!;
      return ListView.builder(
        itemCount: commodities.length,
        itemBuilder: (context, index) {
          final commodity = commodities[index];
          return ListTile(
            title: Text(commodity.name),
            subtitle: Text(commodity.category),
            trailing: Text('Rp ${commodity.currentPrice}/${commodity.unit}'),
          );
        },
      );
    }
    return CircularProgressIndicator();
  },
)
```

---

### 6. **Weather Operations**

#### Get Weather
```dart
WeatherModel? weather = await _firestore.getWeather('Jakarta');
if (weather != null) {
  print('Temperature: ${weather.temperature}°C');
  print('Humidity: ${weather.humidity}%');
  print('Description: ${weather.description}');
}
```

#### Stream Weather (Real-time)
```dart
StreamBuilder<WeatherModel?>(
  stream: _firestore.streamWeather('Jakarta'),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final weather = snapshot.data!;
      return Card(
        child: Column(
          children: [
            Text('${weather.temperature}°C'),
            Text(weather.description),
            Text('Humidity: ${weather.humidity}%'),
          ],
        ),
      );
    }
    return CircularProgressIndicator();
  },
)
```

---

### 7. **Notification Operations**

#### Save FCM Token (for Push Notifications)
```dart
// Get FCM token from Firebase Messaging
String token = await FirebaseMessaging.instance.getToken();

// Save to Firestore
await _firestore.saveFCMToken(token);
```

#### Get Notifications
```dart
// Get all notifications
List<NotificationModel> notifications = await _firestore.getUserNotifications();

// Get unread only
List<NotificationModel> unread = await _firestore.getUserNotifications(
  unreadOnly: true,
);
```

#### Stream Notifications (Real-time)
```dart
StreamBuilder<List<NotificationModel>>(
  stream: _firestore.streamUserNotifications(limit: 20),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final notifications = snapshot.data!;
      return ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return ListTile(
            leading: Icon(
              notif.isRead ? Icons.drafts : Icons.mark_email_unread,
              color: notif.isRead ? Colors.grey : Colors.blue,
            ),
            title: Text(notif.title),
            subtitle: Text(notif.message),
            onTap: () async {
              // Mark as read when tapped
              await _firestore.markNotificationAsRead(notif.id);
            },
          );
        },
      );
    }
    return CircularProgressIndicator();
  },
)
```

#### Mark Notification as Read
```dart
await _firestore.markNotificationAsRead(notificationId);
```

#### Mark All as Read
```dart
await _firestore.markAllNotificationsAsRead();
```

---

## 💡 Best Practices

### 1. **Always Check Current User**
```dart
if (_firestore.currentUserId == null) {
  // User not logged in, redirect to login
  Navigator.pushReplacementNamed(context, '/login');
  return;
}
```

### 2. **Use Streams for Real-time Updates**
```dart
// ✅ GOOD - Real-time updates
StreamBuilder<List<TransactionModel>>(
  stream: _firestore.streamUserTransactions(),
  builder: (context, snapshot) {
    // UI updates automatically
  },
)

// ❌ BAD - Need to manually refresh
Future<void> loadTransactions() async {
  final transactions = await _firestore.getUserTransactions();
  setState(() {
    _transactions = transactions;
  });
}
```

### 3. **Handle Errors Gracefully**
```dart
try {
  await _firestore.addTransaction(transaction);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('✅ Success!')),
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('❌ Error: $e')),
  );
}
```

### 4. **Use Pagination for Large Lists**
```dart
// Limit results
List<TransactionModel> recent = await _firestore.getUserTransactions(
  limit: 20, // Only get latest 20
);

// Load more when scrolling
ScrollController _scrollController = ScrollController();

@override
void initState() {
  super.initState();
  _scrollController.addListener(() {
    if (_scrollController.position.pixels == 
        _scrollController.position.maxScrollExtent) {
      // Load more
      _loadMoreTransactions();
    }
  });
}
```

### 5. **Cache Data Locally**
```dart
import 'package:shared_preferences/shared_preferences.dart';

// Save to local cache
Future<void> cacheUser(UserModel user) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_name', user.name);
  await prefs.setString('user_email', user.email);
}

// Load from cache first, then sync with Firestore
Future<UserModel?> getUserWithCache() async {
  final prefs = await SharedPreferences.getInstance();
  final cachedName = prefs.getString('user_name');
  
  if (cachedName != null) {
    // Show cached data immediately
    // Then fetch fresh data from Firestore in background
  }
  
  return await _firestore.getCurrentUser();
}
```

---

## 🎨 Example: Complete Transaction Page

Lihat contoh lengkap di: `lib/pages/transactions_page.dart`

Features:
- ✅ Add transaction dengan form validation
- ✅ Real-time transaction list (StreamBuilder)
- ✅ Income/Expense statistics
- ✅ Delete transaction with confirmation
- ✅ Beautiful UI dengan color coding

---

## 🔧 Troubleshooting

### Error: "User not logged in"
```dart
// Make sure user is logged in before using Firestore
User? user = FirebaseAuth.instance.currentUser;
if (user == null) {
  // Redirect to login
}
```

### Error: "Permission denied"
```dart
// Check Firestore Security Rules
// Make sure rules allow authenticated users to read/write their own data

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /transactions/{transactionId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

### Slow Performance
```dart
// 1. Use indexes for queries
// Go to Firebase Console → Firestore → Indexes → Create Index

// 2. Limit query results
List<TransactionModel> transactions = await _firestore.getUserTransactions(
  limit: 20, // Don't fetch all at once
);

// 3. Use pagination
// 4. Enable offline persistence (enabled by default)
```

---

## 📚 Next Steps

### Option 1: Build More Features
- [ ] Dashboard with charts (income/expense trends)
- [ ] Export transactions to PDF/Excel
- [ ] Schedule notifications/reminders
- [ ] Commodity price alerts
- [ ] Weather-based recommendations

### Option 2: Optimize Performance
- [ ] Implement pagination for all lists
- [ ] Add local caching with Hive/SharedPreferences
- [ ] Optimize images (compress, lazy load)
- [ ] Add loading skeletons

### Option 3: Add Advanced Features
- [ ] Offline mode dengan sync
- [ ] Multi-language support (i18n)
- [ ] Dark mode
- [ ] Search & filters
- [ ] Data export/import

---

## 🚀 Ready to Build!

Your Firebase Firestore integration is now complete and ready to use. Start building amazing features for your farmers! 🌾

**Files Created:**
- ✅ `lib/services/firestore_service.dart` - Complete Firestore CRUD operations
- ✅ `lib/pages/transactions_page.dart` - Example implementation
- ✅ `lib/models/app_models.dart` - Updated with all models

**Documentation:**
- ✅ This guide with all examples
- ✅ Best practices
- ✅ Troubleshooting tips

Need help? Refer to this guide or check:
- [Firebase Firestore Documentation](https://firebase.google.com/docs/firestore)
- [FlutterFire Documentation](https://firebase.flutter.dev)
