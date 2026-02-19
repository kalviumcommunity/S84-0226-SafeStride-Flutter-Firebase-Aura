import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/responsive_home.dart';

/// Main entry point - Firebase initialized before app starts
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase Core initialization (DO NOT REMOVE)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

/// Root widget with Material3 theme
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeStride',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Sprint #2: Route to ResponsiveHome for responsive UI demonstration
      home: const ResponsiveHome(),
    );
  }
}
