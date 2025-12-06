import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email and password
  static Future<UserCredential?> registerWithEmailPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String region,
    List<String>? crops,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // Create user profile in Firestore
        await FirebaseService.createUser(
          userId: user.uid,
          name: name,
          email: email,
          phone: phone,
          region: region,
          crops: crops,
        );

        // Update display name
        await user.updateDisplayName(name);
      }

      return result;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Sign in with email and password
  static Future<UserCredential?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  // Update password
  static Future<void> updatePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      } else {
        throw Exception('No user is currently signed in');
      }
    } catch (e) {
      throw Exception('Password update failed: ${e.toString()}');
    }
  }

  // Update email
  static Future<void> updateEmail(String newEmail) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updateEmail(newEmail);

        // Update email in Firestore as well
        await FirebaseService.updateUserProfile(userId: user.uid);
      } else {
        throw Exception('No user is currently signed in');
      }
    } catch (e) {
      throw Exception('Email update failed: ${e.toString()}');
    }
  }

  // Verify email
  static Future<void> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('Email verification failed: ${e.toString()}');
    }
  }

  // Check if email is verified
  static bool get isEmailVerified {
    User? user = _auth.currentUser;
    return user?.emailVerified ?? false;
  }

  // Delete account
  static Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Delete user data from Firestore first
        await _db.collection('users').doc(user.uid).delete();

        // Delete user account
        await user.delete();
      }
    } catch (e) {
      throw Exception('Account deletion failed: ${e.toString()}');
    }
  }

  // Reauthenticate user (required for sensitive operations)
  static Future<void> reauthenticateWithPassword(String password) async {
    try {
      User? user = _auth.currentUser;
      if (user != null && user.email != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }
    } catch (e) {
      throw Exception('Reauthentication failed: ${e.toString()}');
    }
  }

  // Get user profile data
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseService.getUser(user.uid);
        if (doc.exists) {
          return doc.data() as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }

  // Update user profile
  static Future<void> updateUserProfile({
    String? name,
    String? phone,
    String? region,
    String? profileImage,
    List<String>? crops,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Update display name in Auth if name is provided
        if (name != null) {
          await user.updateDisplayName(name);
        }

        // Update profile image in Auth if provided
        if (profileImage != null) {
          await user.updatePhotoURL(profileImage);
        }

        // Update user data in Firestore
        await FirebaseService.updateUserProfile(
          userId: user.uid,
          name: name,
          phone: phone,
          region: region,
          profileImage: profileImage,
          crops: crops,
        );
      }
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }

  // Check if user is admin
  static Future<bool> isAdmin() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseService.getUser(user.uid);
        if (doc.exists) {
          Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
          return userData['role'] == 'admin';
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get error message in Indonesian
  static String getErrorMessage(String errorCode) {
    switch (errorCode) {
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
      case 'operation-not-allowed':
        return 'Operasi tidak diizinkan';
      default:
        return 'Terjadi kesalahan: $errorCode';
    }
  }
}
