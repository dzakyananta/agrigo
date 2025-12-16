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
  static Future<void> signInWithGoogle() async {
    try {
      print('🔵 Starting Google Sign-In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('❌ Google Sign-In cancelled by user');
        return;
      }

      print('🟢 Got Google account: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🔵 Signing in with Firebase...');
      await _auth.signInWithCredential(credential);
      
      // Wait a bit for auth to settle
      await Future.delayed(Duration(milliseconds: 500));

      final user = _auth.currentUser;
      if (user != null) {
        print('🟢 Firebase auth successful: ${user.uid}');
        final userDoc = await getUser(user.uid);

        if (!userDoc.exists) {
          print('🔵 Creating Firestore user document...');
          await createUser(
            userId: user.uid,
            name: user.displayName ?? 'Google User',
            email: user.email ?? '',
            phone: '',
            region: '',
          );
          print('✅ Firestore user created!');
        } else {
          print('✅ User already exists in Firestore');
        }
      }
    } catch (e) {
      print('🔴 Google sign in error: $e');
      rethrow;
    }
  }

  // ---------------- FACEBOOK SIGN IN ----------------
  static Future<void> signInWithFacebook() async {
    try {
      print('🔵 Starting Facebook Sign-In...');
      print('🔵 Requesting Facebook permissions...');
      
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
        loginBehavior: LoginBehavior.nativeWithFallback, // Try native app first, fallback to web
      );

      print('🔵 Facebook login result status: ${result.status}');
      print('🔵 Facebook login message: ${result.message}');

      if (result.status == LoginStatus.success) {
        print('🟢 Facebook login successful!');
        print('🔵 Access Token: ${result.accessToken?.token.substring(0, 20)}...');
        
        print('🔵 Fetching Facebook user data...');
        final userData = await FacebookAuth.instance.getUserData();
        print('🟢 Facebook user data retrieved:');
        print('   - Name: ${userData['name']}');
        print('   - Email: ${userData['email']}');
        print('   - ID: ${userData['id']}');

        final OAuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.token);

        print('🔵 Signing in with Firebase using Facebook credential...');
        
        try {
          await _auth.signInWithCredential(credential);
        } catch (e) {
          // Check if error is due to email already in use
          if (e.toString().contains('account-exists-with-different-credential') ||
              e.toString().contains('email-already-in-use')) {
            print('⚠️ Email already exists with different provider');
            print('🔵 Attempting to link Facebook with existing account...');
            
            // Get the email from Facebook data
            final email = userData['email'] as String?;
            if (email != null && email.isNotEmpty) {
              // Fetch sign-in methods for this email
              final methods = await _auth.fetchSignInMethodsForEmail(email);
              print('🔵 Existing sign-in methods: $methods');
              
              if (methods.contains('google.com')) {
                print('⚠️ Account exists with Google. User needs to link accounts.');
                throw Exception(
                  'Email $email sudah terdaftar dengan Google. '
                  'Silakan login dengan Google terlebih dahulu, '
                  'lalu link akun Facebook dari Profile Settings.'
                );
              }
            }
            
            rethrow;
          }
          rethrow;
        }
        
        // Wait a bit for auth to settle
        await Future.delayed(Duration(milliseconds: 500));

        final user = _auth.currentUser;
        if (user != null) {
          print('🟢 Firebase auth successful: ${user.uid}');
          print('🔵 Checking if user exists in Firestore...');
          final userDoc = await getUser(user.uid);

          if (!userDoc.exists) {
            print('🔵 Creating Firestore user document...');
            await createUser(
              userId: user.uid,
              name: userData['name'] ?? 'Facebook User',
              email: userData['email'] ?? '',
              phone: '',
              region: '',
            );
            print('✅ Firestore user created!');
          } else {
            print('✅ User already exists in Firestore');
          }
        }
      } else if (result.status == LoginStatus.cancelled) {
        print('⚠️ Facebook login cancelled by user');
        throw Exception('Login dibatalkan');
      } else if (result.status == LoginStatus.failed) {
        print('🔴 Facebook login failed: ${result.message}');
        throw Exception('Facebook login gagal: ${result.message}');
      } else {
        print('❌ Facebook login status unknown: ${result.status}');
        throw Exception('Status login tidak diketahui');
      }
    } catch (e) {
      print('🔴 Facebook sign in error: $e');
      print('🔴 Error type: ${e.runtimeType}');
      rethrow;
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
