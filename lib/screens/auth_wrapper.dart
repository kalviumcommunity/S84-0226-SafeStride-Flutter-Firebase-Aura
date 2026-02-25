import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'login/login_screen.dart';
import 'main_screen.dart';

class AuthWrapper extends StatelessWidget {
  final Stream<User?>? authStream;

  const AuthWrapper({super.key, this.authStream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authStream ?? AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const MainScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
