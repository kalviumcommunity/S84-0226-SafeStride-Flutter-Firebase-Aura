import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/auth_wrapper.dart';
import 'constants/app_colors.dart';
import 'config/routes.dart';
import 'config/maps_loader.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load Google Maps JS API on web (no-op on mobile)
  await MapsLoader.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const SafeStrideApp(),
    ),
  );
}

class SafeStrideApp extends StatelessWidget {
  const SafeStrideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SafeStride',
          themeMode: themeProvider.themeMode,
          theme: AppColors.lightTheme,
          darkTheme: AppColors.darkTheme,
          // No initialRoute — AuthWrapper at home decides what to show based on
          // Firebase auth state. This avoids the double-route bug and the
          // loading-spinner-after-login issue caused by navigating back to '/'.
          onGenerateRoute: RouteGenerator.generateRoute,
          home: const AuthWrapper(),
        );
      },
    );
  }
}
