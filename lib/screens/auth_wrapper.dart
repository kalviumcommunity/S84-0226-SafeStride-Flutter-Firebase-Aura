import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import 'landing_page.dart';
import 'main_screen.dart';

class AuthWrapper extends StatefulWidget {
  final Stream<User?>? authStream;

  const AuthWrapper({super.key, this.authStream});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    final stream = widget.authStream ?? AuthService().authStateChanges;
    _authSub = stream.listen((user) {
      if (!mounted) return;
      if (user != null) {
        context.read<ThemeProvider>().loadFromFirestore(user.uid);
        context.read<UserProvider>().subscribe(user.uid);
      } else {
        context.read<ThemeProvider>().reset();
        context.read<UserProvider>().clear();
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: widget.authStream ?? AuthService().authStateChanges,
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
