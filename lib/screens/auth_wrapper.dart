import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'landing_page.dart';
import 'main_screen.dart';

class AuthWrapper extends StatelessWidget {
  final Stream<User?>? authStream;

  const AuthWrapper({super.key, this.authStream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authStream ?? AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Show a brief loading indicator only on first connection.
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Use currentUser as a fast-path to avoid flicker on warm restarts.
          if (FirebaseAuth.instance.currentUser != null) {
            return const MainScreen();
          }
          return const Scaffold(
            backgroundColor: Color(0xFFECF0F8),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Logged in — also check currentUser as a fallback for web auth delay.
        if (snapshot.hasData || FirebaseAuth.instance.currentUser != null) {
          return const MainScreen();
        }

        // Not logged in — show the landing / onboarding page.
        return const LandingPage();
      },
    );
  }
}
