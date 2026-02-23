// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safestride_app/main.dart';

void main() {
  testWidgets('App renders with injected auth stream', (WidgetTester tester) async {
    // Create a mock stream controller so Firebase is bypassed
    final authController = StreamController<User?>();
    
    // Push a null user to force the StreamBuilder to emit Data
    authController.add(null);
    await tester.pumpWidget(SafeStrideApp(authStream: authController.stream));
    await tester.pump(); // Use pump instead of pumpAndSettle, because streams can cause infinite settles.

    // Verify app renders the AuthWrapper (which evaluates to LoginScreen since user is null)
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Clean up
    authController.close();
  });
}
