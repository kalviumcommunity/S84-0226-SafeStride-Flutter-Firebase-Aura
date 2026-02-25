import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'screens/landing_page.dart';
import 'screens/main_screen.dart';
import 'constants/app_colors.dart';
import 'config/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    SafeStrideApp(
      authStream: FirebaseAuth.instance.authStateChanges(),
    ),
  );
}

class SafeStrideApp extends StatelessWidget {
  final Stream<User?>? authStream;

  const SafeStrideApp({super.key, this.authStream});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeStride',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      initialRoute: AppRoutes.landing,
      onGenerateRoute: RouteGenerator.generateRoute,
      home: StreamBuilder<User?>(
        stream: authStream,
        builder: (context, snapshot) {
          // Still loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          // User is logged in
          if (snapshot.hasData) {
            return const MainScreen();
          }
          
          // User is not logged in - show landing page
          return const LandingPage();
        },
      ),
    );
  }
}