import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // ==================== USER OPERATIONS ====================

  /// Get user profile by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('🔴 Error getting user: $e');
      return null;
    }
  }

  /// Get current logged-in user profile
  Future<UserModel?> getCurrentUser() async {
    if (currentUserId == null) return null;
    return await getUser(currentUserId!);
  }

  /// Create or update user profile
  Future<bool> saveUser(UserModel user) async {
    try {
      await _db.collection('users').doc(user.id).set(
        user.toMap(),
        SetOptions(merge: true),
      );
      print('✅ User saved successfully');
      return true;
    } catch (e) {
      print('🔴 Error saving user: $e');
      return false;
    }
  }

  /// Update user profile fields
  Future<bool> updateUserProfile({
    String? name,
    String? phone,
    String? region,
    String? profileImage,
    List<String>? crops,
  }) async {
    if (currentUserId == null) return false;

    try {
      Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (region != null) updates['region'] = region;
      if (profileImage != null) updates['profileImage'] = profileImage;
      if (crops != null) updates['crops'] = crops;

      await _db.collection('users').doc(currentUserId).update(updates);
      print('✅ Profile updated successfully');
      return true;
    } catch (e) {
      print('🔴 Error updating profile: $e');
      return false;
    }
  }

  /// Stream current user data (real-time updates)
  Stream<UserModel?> streamCurrentUser() {
    if (currentUserId == null) {
      return Stream.value(null);
    }

    return _db.collection('users').doc(currentUserId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  // ==================== TRANSACTION OPERATIONS ====================

  /// Add new transaction
  Future<String?> addTransaction(TransactionModel transaction) async {
    try {
      DocumentReference doc = await _db.collection('transactions').add(
        transaction.toMap(),
      );
      print('✅ Transaction added: ${doc.id}');
      return doc.id;
    } catch (e) {
      print('🔴 Error adding transaction: $e');
      return null;
    }
  }

  /// Get transactions for current user
  Future<List<TransactionModel>> getUserTransactions({
    int limit = 50,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (currentUserId == null) return [];

    try {
      Query query = _db
          .collection('transactions')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('date', descending: true)
          .limit(limit);

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: startDate);
      }
      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: endDate);
      }

      QuerySnapshot snapshot = await query.get();
      return snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('🔴 Error getting transactions: $e');
      return [];
    }
  }

  /// Stream transactions (real-time)
  Stream<List<TransactionModel>> streamUserTransactions({int limit = 50}) {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _db
        .collection('transactions')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc))
            .toList());
  }

  /// Update transaction
  Future<bool> updateTransaction(
      String transactionId, Map<String, dynamic> updates) async {
    try {
      await _db.collection('transactions').doc(transactionId).update(updates);
      print('✅ Transaction updated');
      return true;
    } catch (e) {
      print('🔴 Error updating transaction: $e');
      return false;
    }
  }

  /// Delete transaction
  Future<bool> deleteTransaction(String transactionId) async {
    try {
      await _db.collection('transactions').doc(transactionId).delete();
      print('✅ Transaction deleted');
      return true;
    } catch (e) {
      print('🔴 Error deleting transaction: $e');
      return false;
    }
  }

  /// Get transaction statistics
  Future<Map<String, double>> getTransactionStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (currentUserId == null) {
      return {'income': 0, 'expense': 0, 'balance': 0};
    }

    try {
      Query query = _db
          .collection('transactions')
          .where('userId', isEqualTo: currentUserId);

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: startDate);
      }
      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: endDate);
      }

      QuerySnapshot snapshot = await query.get();

      double income = 0;
      double expense = 0;

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        double amount = (data['amount'] ?? 0).toDouble();
        String type = data['type'] ?? 'expense';

        if (type == 'income') {
          income += amount;
        } else {
          expense += amount;
        }
      }

      return {
        'income': income,
        'expense': expense,
        'balance': income - expense,
      };
    } catch (e) {
      print('🔴 Error getting transaction stats: $e');
      return {'income': 0, 'expense': 0, 'balance': 0};
    }
  }

  // ==================== SCHEDULE OPERATIONS ====================

  /// Add new schedule
  Future<String?> addSchedule(ScheduleModel schedule) async {
    try {
      DocumentReference doc = await _db.collection('schedules').add(
        schedule.toMap(),
      );
      print('✅ Schedule added: ${doc.id}');
      return doc.id;
    } catch (e) {
      print('🔴 Error adding schedule: $e');
      return null;
    }
  }

  /// Get schedules for current user
  Future<List<ScheduleModel>> getUserSchedules({
    String? status,
    int limit = 50,
  }) async {
    if (currentUserId == null) return [];

    try {
      Query query = _db
          .collection('schedules')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('startDate', descending: false)
          .limit(limit);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      QuerySnapshot snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ScheduleModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('🔴 Error getting schedules: $e');
      return [];
    }
  }

  /// Stream schedules (real-time)
  Stream<List<ScheduleModel>> streamUserSchedules({String? status}) {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    Query query = _db
        .collection('schedules')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('startDate', descending: false);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ScheduleModel.fromFirestore(doc)).toList());
  }

  /// Update schedule
  Future<bool> updateSchedule(
      String scheduleId, Map<String, dynamic> updates) async {
    try {
      await _db.collection('schedules').doc(scheduleId).update(updates);
      print('✅ Schedule updated');
      return true;
    } catch (e) {
      print('🔴 Error updating schedule: $e');
      return false;
    }
  }

  /// Delete schedule
  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      await _db.collection('schedules').doc(scheduleId).delete();
      print('✅ Schedule deleted');
      return true;
    } catch (e) {
      print('🔴 Error deleting schedule: $e');
      return false;
    }
  }

  /// Get upcoming schedules (next 7 days)
  Future<List<ScheduleModel>> getUpcomingSchedules() async {
    if (currentUserId == null) return [];

    try {
      DateTime now = DateTime.now();
      DateTime nextWeek = now.add(Duration(days: 7));

      QuerySnapshot snapshot = await _db
          .collection('schedules')
          .where('userId', isEqualTo: currentUserId)
          .where('startDate', isGreaterThanOrEqualTo: now)
          .where('startDate', isLessThanOrEqualTo: nextWeek)
          .where('status', whereIn: ['planned', 'ongoing'])
          .orderBy('startDate')
          .get();

      return snapshot.docs
          .map((doc) => ScheduleModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('🔴 Error getting upcoming schedules: $e');
      return [];
    }
  }

  // ==================== COMMODITY OPERATIONS ====================

  /// Get all commodities (public data)
  Future<List<CommodityModel>> getCommodities({
    String? category,
    String? region,
  }) async {
    try {
      Query query = _db.collection('commodities').orderBy('name');

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      if (region != null) {
        query = query.where('region', isEqualTo: region);
      }

      QuerySnapshot snapshot = await query.get();
      return snapshot.docs
          .map((doc) => CommodityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('🔴 Error getting commodities: $e');
      return [];
    }
  }

  /// Stream commodities (real-time price updates)
  Stream<List<CommodityModel>> streamCommodities({String? region}) {
    Query query = _db.collection('commodities').orderBy('name');

    if (region != null) {
      query = query.where('region', isEqualTo: region);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => CommodityModel.fromFirestore(doc))
        .toList());
  }

  // ==================== WEATHER OPERATIONS ====================

  /// Get weather data for region
  Future<WeatherModel?> getWeather(String region) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('weather')
          .where('region', isEqualTo: region)
          .orderBy('updatedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return WeatherModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('🔴 Error getting weather: $e');
      return null;
    }
  }

  /// Stream weather (real-time updates)
  Stream<WeatherModel?> streamWeather(String region) {
    return _db
        .collection('weather')
        .where('region', isEqualTo: region)
        .orderBy('updatedAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return WeatherModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    });
  }

  // ==================== NOTIFICATION OPERATIONS ====================

  /// Save FCM token for push notifications
  Future<bool> saveFCMToken(String token) async {
    if (currentUserId == null) return false;

    try {
      await _db.collection('users').doc(currentUserId).update({
        'fcmToken': token,
        'fcmUpdatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ FCM token saved');
      return true;
    } catch (e) {
      print('🔴 Error saving FCM token: $e');
      return false;
    }
  }

  /// Get notifications for current user
  Future<List<NotificationModel>> getUserNotifications({
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    if (currentUserId == null) return [];

    try {
      Query query = _db
          .collection('notifications')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (unreadOnly) {
        query = query.where('isRead', isEqualTo: false);
      }

      QuerySnapshot snapshot = await query.get();
      return snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('🔴 Error getting notifications: $e');
      return [];
    }
  }

  /// Stream notifications (real-time)
  Stream<List<NotificationModel>> streamUserNotifications({int limit = 20}) {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _db
        .collection('notifications')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  /// Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _db
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
      print('✅ Notification marked as read');
      return true;
    } catch (e) {
      print('🔴 Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllNotificationsAsRead() async {
    if (currentUserId == null) return false;

    try {
      QuerySnapshot snapshot = await _db
          .collection('notifications')
          .where('userId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      WriteBatch batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      print('✅ All notifications marked as read');
      return true;
    } catch (e) {
      print('🔴 Error marking all notifications as read: $e');
      return false;
    }
  }

  // ==================== BATCH OPERATIONS ====================

  /// Delete user account and all related data
  Future<bool> deleteUserAccount() async {
    if (currentUserId == null) return false;

    try {
      WriteBatch batch = _db.batch();

      // Delete transactions
      QuerySnapshot transactions = await _db
          .collection('transactions')
          .where('userId', isEqualTo: currentUserId)
          .get();
      for (var doc in transactions.docs) {
        batch.delete(doc.reference);
      }

      // Delete schedules
      QuerySnapshot schedules = await _db
          .collection('schedules')
          .where('userId', isEqualTo: currentUserId)
          .get();
      for (var doc in schedules.docs) {
        batch.delete(doc.reference);
      }

      // Delete notifications
      QuerySnapshot notifications = await _db
          .collection('notifications')
          .where('userId', isEqualTo: currentUserId)
          .get();
      for (var doc in notifications.docs) {
        batch.delete(doc.reference);
      }

      // Delete user profile
      batch.delete(_db.collection('users').doc(currentUserId));

      await batch.commit();
      print('✅ User account deleted');
      return true;
    } catch (e) {
      print('🔴 Error deleting user account: $e');
      return false;
    }
  }
}
