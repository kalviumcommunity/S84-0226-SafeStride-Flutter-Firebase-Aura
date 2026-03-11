import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';

class AuthFailure implements Exception {
  final String message;
  final String? code;
  AuthFailure(this.message, {this.code});
  @override
  String toString() => message;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── OTP helpers ───────────────────────────────────────────────────────────

  /// Generates a 6-digit code, persists it in Firestore, and returns the code.
  /// In production you would email the code; here we return it so the screen
  /// can display it for demo purposes.
  Future<String> generateAndStoreOtp(String email, String name) async {
    final code = (100000 + Random().nextInt(900000))
        .toString(); // 100000–999999
    final expiry = DateTime.now().add(const Duration(minutes: 10));

    await _db.collection('pending_verifications').doc(_emailKey(email)).set({
      'code': code,
      'name': name,
      'expiry': Timestamp.fromDate(expiry),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return code;
  }

  /// Verifies the entered code and deletes the Firestore record on success.
  /// Throws [AuthFailure] on any mismatch/expiry.
  Future<void> verifyOtp(String email, String enteredCode) async {
    final doc = await _db
        .collection('pending_verifications')
        .doc(_emailKey(email))
        .get();

    if (!doc.exists) {
      throw AuthFailure('Session expired. Please go back and sign up again.');
    }

    final data = doc.data()!;
    final storedCode = data['code'] as String;
    final expiry = (data['expiry'] as Timestamp).toDate();

    if (DateTime.now().isAfter(expiry)) {
      await doc.reference.delete();
      throw AuthFailure('Code expired. Tap "Resend" to get a new one.');
    }

    if (enteredCode.trim() != storedCode) {
      throw AuthFailure('Incorrect code. Please try again.');
    }

    // Code is valid — clean up
    await doc.reference.delete();
  }

  String _emailKey(String email) =>
      email.toLowerCase().replaceAll('.', '_dot_').replaceAll('@', '_at_');

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<UserCredential> signUp(
    String email,
    String password, {
    String? displayName,
    String activityType = 'runner',
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (displayName != null && displayName.isNotEmpty) {
        await cred.user?.updateDisplayName(displayName);
      }
      // Persist user profile to Firestore `users` collection
      if (cred.user != null) {
        await FirestoreService().addUserData(cred.user!.uid, {
          'uid': cred.user!.uid,
          'email': email,
          'displayName': displayName ?? '',
          'activityType': activityType,
          'bio': '',
          'darkMode': false,
          'notificationsEnabled': true,
          'preferredDistance': 10.0,
          'savedRoutesCount': 0,
          'reviewsCount': 0,
          'favoritesCount': 0,
          'totalDistanceKm': 0.0,
        });
      }
      return cred;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseErrorCode(e.code), code: e.code);
    }
  }

  Future<UserCredential> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseErrorCode(e.code), code: e.code);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseErrorCode(e.code), code: e.code);
    }
  }

  Future<void> logout() => _auth.signOut();

  String _mapFirebaseErrorCode(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
