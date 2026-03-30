import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  // Lazy initialize GoogleSignIn only when needed
  GoogleSignIn? _googleSignIn;
  GoogleSignIn get _getGoogleSignIn => _googleSignIn ??= GoogleSignIn();

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

  /// Sign in with Google and create/update user profile in Firestore.
  /// Returns the UserCredential on success.
  /// Throws [AuthFailure] on any error during Google authentication or Firestore operations.
  Future<UserCredential> signInWithGoogle({
    String activityType = 'runner',
  }) async {
    try {
      final UserCredential userCredential;

      if (kIsWeb) {
        // Web: use Firebase popup flow directly to avoid plugin token/profile
        // fetch issues that can fail with browser policy/API restrictions.
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        provider.addScope('profile');
        userCredential = await _auth.signInWithPopup(provider);
      } else {
        // Mobile: use google_sign_in plugin then exchange for Firebase credential.
        final GoogleSignInAccount? googleUser = await _getGoogleSignIn.signIn();

        if (googleUser == null) {
          throw AuthFailure('Google sign-in was cancelled.');
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      final User? user = userCredential.user;
      if (user == null) {
        throw AuthFailure('Failed to retrieve user information from Google.');
      }

      // Check if this is a new user
      final userDoc = await _db.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        // New user — create their profile in Firestore
        await FirestoreService().addUserData(user.uid, {
          'uid': user.uid,
          'email': user.email ?? '',
          'displayName': user.displayName ?? '',
          'photoURL': user.photoURL ?? '',
          'activityType': activityType,
          'bio': '',
          'darkMode': false,
          'notificationsEnabled': true,
          'preferredDistance': 10.0,
          'savedRoutesCount': 0,
          'reviewsCount': 0,
          'favoritesCount': 0,
          'totalDistanceKm': 0.0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Existing user — update their photoURL if they don't have one
        final userData = userDoc.data();
        if ((userData?['photoURL'] as String?)?.isEmpty ?? true) {
          await _db.collection('users').doc(user.uid).update({
            'photoURL': user.photoURL ?? '',
            'lastLoginAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Just update the last login timestamp
          await _db.collection('users').doc(user.uid).update({
            'lastLoginAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return userCredential;
    } on AuthFailure {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseErrorCode(e.code), code: e.code);
    } on FirebaseException catch (e) {
      throw AuthFailure(
        e.message ?? 'Google sign-in failed (${e.code}).',
        code: e.code,
      );
    } catch (e) {
      final rawError = e.toString();
      if (kIsWeb &&
          rawError.toLowerCase().contains('content-people.googleapis.com')) {
        throw AuthFailure(
          'Google People API is blocked/disabled for this OAuth app. '
          'Enable People API in Google Cloud or use Firebase popup-only flow settings.',
        );
      }
      throw AuthFailure('Google sign-in failed. $rawError');
    }
  }

  /// Sign out from both Firebase and Google
  Future<void> signOutGoogle() async {
    try {
      await _auth.signOut();
      if (_googleSignIn != null) {
        await _googleSignIn!.signOut();
      }
    } catch (e) {
      throw AuthFailure('Failed to sign out: ${e.toString()}');
    }
  }

  String _mapFirebaseErrorCode(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'operation-not-allowed':
        return 'Google sign-in is not enabled in Firebase Authentication.';
      case 'unauthorized-domain':
        return 'This domain is not authorized for Google sign-in. Add localhost in Firebase Auth authorized domains.';
      case 'popup-blocked':
        return 'Popup was blocked by the browser. Please allow popups and try again.';
      case 'popup-closed-by-user':
        return 'Google sign-in popup was closed before completion.';
      case 'cancelled-popup-request':
        return 'Another sign-in popup is already open. Please finish that one first.';
      case 'web-context-canceled':
        return 'Sign-in flow was interrupted. Please retry and keep the popup open.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email using a different sign-in method.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed ($code). Please try again.';
    }
  }
}
