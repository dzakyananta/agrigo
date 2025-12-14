import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ================= REGISTER =================
  static Future<UserCredential?> registerWithEmailPassword({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String region,
    List<String>? crops,
    File? profileImage,
  }) async {
    try {
      print('🔵 [1/3] Creating Auth user...');
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user == null) throw Exception("User is null after registration");

      print('🟢 [1/3] Auth user created: ${user.uid}');

      String? imageUrl;
      if (profileImage != null) {
        print('🔵 [2/3] Uploading profile image...');
        final ref = _storage.ref().child("profile_images/${user.uid}.jpg");
        await ref.putFile(profileImage);
        imageUrl = await ref.getDownloadURL();
        print('🟢 [2/3] Image uploaded!');
      }

      print('🔵 [3/3] Saving to Firestore...');
      await FirebaseService.createUser(
        userId: user.uid,
        name: name,
        email: email,
        phone: phone,
        region: region,
        profileImage: imageUrl,
        crops: crops,
      );
      print('🟢 [3/3] Firestore saved!');

      // SKIP updateDisplayName to avoid Pigeon bug
      print('✅ Registration completed successfully!');

      return result;
    } catch (e) {
      print("❌ Registration Error: $e");
      rethrow;
    }
  }

  // ================= LOGIN =================
  static Future<UserCredential?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // ================= GOOGLE LOGIN =================
  static Future<UserCredential?> signInWithGoogle() async {
    return await FirebaseService.signInWithGoogle();
  }

  // ================= FACEBOOK LOGIN =================
  static Future<UserCredential?> signInWithFacebook() async {
    return await FirebaseService.signInWithFacebook();
  }

  // ================= LOGOUT =================
  static Future<void> signOut() async {
    await FirebaseService.logout();
  }

  // ================= PASSWORD RESET =================
  static Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ================= UPDATE PASSWORD =================
  static Future<void> updatePassword(String newPassword) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    } else {
      throw Exception('No user is currently signed in');
    }
  }

  // ================= UPDATE EMAIL =================
  static Future<void> updateEmail(String newEmail) async {
    User? user = _auth.currentUser;

    if (user != null) {
      await user.updateEmail(newEmail);

      await FirebaseService.updateUserProfile(
        userId: user.uid,
        email: newEmail,
      );
    } else {
      throw Exception('No user is currently signed in');
    }
  }

  // ================= VERIFY EMAIL =================
  static Future<void> sendEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  static bool get isEmailVerified =>
      _auth.currentUser?.emailVerified ?? false;

  // ================= DELETE ACCOUNT =================
  static Future<void> deleteAccount() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).delete();
      await user.delete();
    }
  }

  // ================= REAUTHENTICATE =================
  static Future<void> reauthenticateWithPassword(String password) async {
    User? user = _auth.currentUser;

    if (user != null && user.email != null) {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    }
  }

  // ================= GET USER PROFILE =================
  static Future<Map<String, dynamic>?> getUserProfile() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot doc = await FirebaseService.getUser(user.uid);
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    }

    return null;
  }

  // ================= UPDATE PROFILE =================
  static Future<void> updateUserProfile({
    String? name,
    String? phone,
    String? region,
    String? profileImage,
    List<String>? crops,
  }) async {
    User? user = _auth.currentUser;

    if (user != null) {
      if (name != null) await user.updateDisplayName(name);
      if (profileImage != null) await user.updatePhotoURL(profileImage);

      await FirebaseService.updateUserProfile(
        userId: user.uid,
        name: name,
        phone: phone,
        region: region,
        profileImage: profileImage,
        crops: crops,
      );
    }
  }

  // ================= CHECK ADMIN =================
  static Future<bool> isAdmin() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot doc = await FirebaseService.getUser(user.uid);
      if (!doc.exists) return false;

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return data['role'] == 'admin';
    }

    return false;
  }

  // ================= ERROR MESSAGE =================
  static String getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Password terlalu lemah';
      case 'email-already-in-use':
        return 'Email sudah digunakan';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'user-not-found':
        return 'Pengguna tidak ditemukan';
      case 'wrong-password':
        return 'Password salah';
      case 'user-disabled':
        return 'Akun telah dinonaktifkan';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan, coba lagi nanti';
      default:
        return 'Terjadi kesalahan: $code';
    }
  }
}
