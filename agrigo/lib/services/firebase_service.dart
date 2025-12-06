import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collections
  static const String usersCollection = 'users';
  static const String commoditiesCollection = 'commodities';
  static const String transactionsCollection = 'transactions';
  static const String weatherCollection = 'weather_data';
  static const String regionsCollection = 'regions';
  static const String notificationsCollection = 'notifications';

  // User Management
  static Future<void> createUser({
    required String userId,
    required String name,
    required String email,
    required String phone,
    required String region,
    String? profileImage,
    List<String>? crops,
    String role = 'farmer',
  }) async {
    await _db.collection(usersCollection).doc(userId).set({
      'name': name,
      'email': email,
      'phone': phone,
      'region': region,
      'profileImage': profileImage ?? '',
      'crops': crops ?? [],
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
    });
  }

  static Future<DocumentSnapshot> getUser(String userId) async {
    return await _db.collection(usersCollection).doc(userId).get();
  }

  static Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? region,
    String? profileImage,
    List<String>? crops,
  }) async {
    Map<String, dynamic> updateData = {
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (name != null) updateData['name'] = name;
    if (phone != null) updateData['phone'] = phone;
    if (region != null) updateData['region'] = region;
    if (profileImage != null) updateData['profileImage'] = profileImage;
    if (crops != null) updateData['crops'] = crops;

    await _db.collection(usersCollection).doc(userId).update(updateData);
  }

  // Commodity Management
  static Future<void> addCommodity({
    required String name,
    required String category,
    required double currentPrice,
    required String region,
    required String unit,
    String? imageUrl,
    String? description,
  }) async {
    await _db.collection(commoditiesCollection).add({
      'name': name,
      'category': category,
      'currentPrice': currentPrice,
      'region': region,
      'unit': unit,
      'imageUrl': imageUrl ?? '',
      'description': description ?? '',
      'priceHistory': [],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isActive': true,
    });
  }

  static Future<QuerySnapshot> getCommodities({String? region}) async {
    Query query = _db
        .collection(commoditiesCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('name');

    if (region != null) {
      query = query.where('region', isEqualTo: region);
    }

    return await query.get();
  }

  static Future<void> updateCommodityPrice({
    required String commodityId,
    required double newPrice,
  }) async {
    DocumentReference doc = _db
        .collection(commoditiesCollection)
        .doc(commodityId);

    await doc.update({
      'currentPrice': newPrice,
      'updatedAt': FieldValue.serverTimestamp(),
      'priceHistory': FieldValue.arrayUnion([
        {'price': newPrice, 'timestamp': FieldValue.serverTimestamp()},
      ]),
    });
  }

  // Transaction Management
  static Future<String> createTransaction({
    required String buyerId,
    required String sellerId,
    required String commodityId,
    required String commodityName,
    required double quantity,
    required double pricePerUnit,
    required double totalAmount,
    String? notes,
  }) async {
    DocumentReference doc = await _db.collection(transactionsCollection).add({
      'buyerId': buyerId,
      'sellerId': sellerId,
      'commodityId': commodityId,
      'commodityName': commodityName,
      'quantity': quantity,
      'pricePerUnit': pricePerUnit,
      'totalAmount': totalAmount,
      'notes': notes ?? '',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  static Future<QuerySnapshot> getUserTransactions(String userId) async {
    return await _db
        .collection(transactionsCollection)
        .where('buyerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
  }

  static Future<void> updateTransactionStatus({
    required String transactionId,
    required String status,
  }) async {
    await _db.collection(transactionsCollection).doc(transactionId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Weather Data Management
  static Future<void> saveWeatherData({
    required String region,
    required Map<String, dynamic> weatherData,
  }) async {
    await _db.collection(weatherCollection).add({
      'region': region,
      'temperature': weatherData['temperature'],
      'humidity': weatherData['humidity'],
      'description': weatherData['description'],
      'icon': weatherData['icon'],
      'windSpeed': weatherData['windSpeed'],
      'pressure': weatherData['pressure'],
      'coordinates': weatherData['coordinates'],
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Future<QuerySnapshot> getLatestWeather(String region) async {
    return await _db
        .collection(weatherCollection)
        .where('region', isEqualTo: region)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();
  }

  // Region Management
  static Future<void> addRegion({
    required String name,
    required String province,
    required Map<String, double> coordinates,
  }) async {
    await _db.collection(regionsCollection).add({
      'name': name,
      'province': province,
      'coordinates': coordinates,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<QuerySnapshot> getRegions() async {
    return await _db
        .collection(regionsCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .get();
  }

  // Notifications
  static Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    await _db.collection(notificationsCollection).add({
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'data': data ?? {},
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<QuerySnapshot> getUserNotifications(String userId) async {
    return await _db
        .collection(notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    await _db.collection(notificationsCollection).doc(notificationId).update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  // Real-time streams
  static Stream<QuerySnapshot> commoditiesStream({String? region}) {
    Query query = _db
        .collection(commoditiesCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('updatedAt', descending: true);

    if (region != null) {
      query = query.where('region', isEqualTo: region);
    }

    return query.snapshots();
  }

  static Stream<QuerySnapshot> userTransactionsStream(String userId) {
    return _db
        .collection(transactionsCollection)
        .where('buyerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> userNotificationsStream(String userId) {
    return _db
        .collection(notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
