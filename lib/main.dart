import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'screens/auth_wrapper.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.neonGreen),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.home,
      onGenerateRoute: RouteGenerator.generateRoute,
      home: AuthWrapper(
        authStream: authStream,
      ),
    );
  }
}

// MainScreen is defined in screens/main_screen.dart