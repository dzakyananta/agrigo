import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Collections
  static const String usersCollection = 'users';

  // ===================== USER MANAGEMENT =====================

  static Future<DocumentSnapshot> getUser(String userId) async {
    return await _db.collection(usersCollection).doc(userId).get();
  }

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

  // UPDATE USER PROFILE
  static Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? region,
    String? profileImage,
    List<String>? crops,
    String? email, // TAMBAHKAN INI
  }) async {
    Map<String, dynamic> data = {};

    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (region != null) data['region'] = region;
    if (profileImage != null) data['profileImage'] = profileImage;
    if (crops != null) data['crops'] = crops;
    if (email != null) data['email'] = email; // TAMBAHKAN INI

    await _db.collection('users').doc(userId).update(data);
  }

  // Get current logged-in user
  static User? get currentUser => _auth.currentUser;
  static String? get userId => _auth.currentUser?.uid;

  // Listen login/logout realtime
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ===================== AUTHENTICATION =====================

  // FIX: Don't return UserCredential to avoid Pigeon bug
  // Use try-catch to suppress Pigeon serialization error - auth still works!
  static Future<void> loginWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      // Check if it's just Pigeon serialization error (auth actually succeeded)
      if (e.toString().contains('PigeonUserDetails') ||
          e.toString().contains('is not a subtype')) {
        // Ignore Pigeon bug - check if user is actually logged in
        await Future.delayed(Duration(milliseconds: 100));
        if (_auth.currentUser != null) {
          print('✅ Login succeeded despite Pigeon error');
          return; // Auth actually worked!
        }
      }
      // If it's real auth error, rethrow
      rethrow;
    }
  }

  // FIX: ULTIMATE Register - NO updateDisplayName, NO reload, ONLY Auth + Firestore
  // FIX: Don't return UserCredential to avoid Pigeon bug
  static Future<void> registerWithEmail({
    required String email,
    required String password,
    required String name,
    String phone = '',
    String location = '',
  }) async {
    print('🔵 Registration START for: $email');

    String? uid;

    // Step 1: Create Auth user with Pigeon error suppression
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      uid = credential.user!.uid;
    } catch (e) {
      // Check if it's just Pigeon serialization error (registration actually succeeded)
      if (e.toString().contains('PigeonUserDetails') ||
          e.toString().contains('is not a subtype')) {
        // Ignore Pigeon bug - get user from currentUser
        await Future.delayed(Duration(milliseconds: 100));
        uid = _auth.currentUser?.uid;
        if (uid == null) {
          // If still no user, it's real error
          rethrow;
        }
        print('✅ Auth created despite Pigeon error: $uid');
      } else {
        // If it's real registration error, rethrow
        rethrow;
      }
    }

    print('🟢 Auth created: $uid');

    // Step 2: Save to Firestore
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'phone': phone,
      'region': location,
      'profileImage': '',
      'crops': [],
      'role': 'farmer',
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
    });

    print('🟢 Firestore saved!');
    print('✅ Registration DONE!');

    // Don't return credential - avoid Pigeon bug
  }

  // ---------------- GOOGLE SIGN IN ----------------
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final user = userCredential.user!;
        final userDoc = await getUser(user.uid);

        if (!userDoc.exists) {
          await createUser(
            userId: user.uid,
            name: user.displayName ?? 'Google User',
            email: user.email ?? '',
            phone: '',
            region: '',
          );
        }
      }

      return userCredential;
    } catch (e) {
      print('Google sign in error: $e');
      return null;
    }
  }

  // ---------------- FACEBOOK SIGN IN ----------------
  static Future<UserCredential?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
        loginBehavior: LoginBehavior.webOnly,
      );

      if (result.status == LoginStatus.success) {
        final userData = await FacebookAuth.instance.getUserData();

        final OAuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.token);

        final userCredential = await _auth.signInWithCredential(credential);

        if (userCredential.user != null) {
          final user = userCredential.user!;
          final userDoc = await getUser(user.uid);

          if (!userDoc.exists) {
            await createUser(
              userId: user.uid,
              name: userData['name'] ?? 'Facebook User',
              email: userData['email'] ?? '',
              phone: '',
              region: '',
            );
          }
        }

        return userCredential;
      }

      return null;
    } catch (e) {
      print('Facebook sign in error: $e');
      return null;
    }
  }

  // LOGOUT
  static Future<void> logout() async {
    await _googleSignIn.signOut();
    await FacebookAuth.instance.logOut();
    await _auth.signOut();
  }

  // RESET PASSWORD
  static Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ===================== SCHEDULES =====================

  static Stream<QuerySnapshot> getSchedulesStream() {
    return _db
        .collection(usersCollection)
        .doc(userId)
        .collection('schedules')
        .orderBy('start_date', descending: true)
        .snapshots();
  }

  static Future<DocumentReference> createSchedule({
    required String commodityName,
    required String commodityType,
    required DateTime startDate,
    required DateTime endDate,
    String? notes,
  }) async {
    return await _db
        .collection(usersCollection)
        .doc(userId)
        .collection('schedules')
        .add({
      'commodity_name': commodityName,
      'commodity_type': commodityType,
      'start_date': Timestamp.fromDate(startDate),
      'end_date': Timestamp.fromDate(endDate),
      'notes': notes,
      'status': 'active',
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateSchedule(
      String scheduleId, Map<String, dynamic> data) async {
    data['updated_at'] = FieldValue.serverTimestamp();

    await _db
        .collection(usersCollection)
        .doc(userId)
        .collection('schedules')
        .doc(scheduleId)
        .update(data);
  }

  static Future<void> deleteSchedule(String scheduleId) async {
    await _db
        .collection(usersCollection)
        .doc(userId)
        .collection('schedules')
        .doc(scheduleId)
        .delete();
  }

  // ===================== TRANSACTIONS =====================

  static Stream<QuerySnapshot> getTransactionsStream() {
    return _db
        .collection(usersCollection)
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots();
  }

  static Future<DocumentReference> createTransaction({
    required String type,
    required double amount,
    String? commodityName,
    String? description,
    required DateTime date,
  }) async {
    return await _db
        .collection(usersCollection)
        .doc(userId)
        .collection('transactions')
        .add({
      'type': type,
      'amount': amount,
      'commodity_name': commodityName,
      'description': description,
      'date': Timestamp.fromDate(date),
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  static Future<Map<String, double>> getTransactionSummary() async {
    final snapshot = await _db
        .collection(usersCollection)
        .doc(userId)
        .collection('transactions')
        .get();

    double income = 0;
    double expense = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final amount = (data['amount'] as num).toDouble();

      if (data['type'] == 'income') {
        income += amount;
      } else if (data['type'] == 'expense') {
        expense += amount;
      }
    }

    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
    };
  }

  static Future<void> deleteTransaction(String transactionId) async {
    await _db
        .collection(usersCollection)
        .doc(userId)
        .collection('transactions')
        .doc(transactionId)
        .delete();
  }

  // ===================== GLOBAL COMMODITIES =====================

  static Stream<QuerySnapshot> getCommoditiesStream() {
    return _db
        .collection('commodities')
        .where('is_active', isEqualTo: true)
        .orderBy('name')
        .snapshots();
  }
}
