import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/auth_wrapper.dart';
import 'constants/app_colors.dart';
import 'config/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const SafeStrideApp());
}

class SafeStrideApp extends StatelessWidget {
  const SafeStrideApp({super.key});

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
      // No initialRoute — AuthWrapper at home decides what to show based on
      // Firebase auth state. This avoids the double-route bug and the
      // loading-spinner-after-login issue caused by navigating back to '/'.
      onGenerateRoute: RouteGenerator.generateRoute,
      home: const AuthWrapper(),
    );
  }
}
