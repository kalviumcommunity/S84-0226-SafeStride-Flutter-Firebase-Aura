import 'package:firebase_auth/firebase_auth.dart';

class AuthFailure implements Exception {
  final String message;
  AuthFailure(this.message);
  @override
  String toString() => message;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseErrorCode(e.code));
    }
  }

  Future<UserCredential> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseErrorCode(e.code));
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

