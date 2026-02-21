import 'package:firebase_auth/firebase_auth.dart';

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
      throw Exception('Signup Failed: ${e.code}');
    }
  }

  Future<UserCredential> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception('Login Failed: ${e.code}');
    }
  }

  Future<void> logout() => _auth.signOut();
}
