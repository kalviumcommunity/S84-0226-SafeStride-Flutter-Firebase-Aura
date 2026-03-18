import 'package:flutter/material.dart';
import '../services/user_preferences_service.dart';

/// Centralized theme state — eliminates `isDarkMode` prop-drilling.
/// Wraps MaterialApp so every widget reads theme from context.
class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  final _prefsSvc = UserPreferencesService();

  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  /// Called from initState of AuthWrapper when a user signs in.
  Future<void> loadFromFirestore(String uid) async {
    final user = await _prefsSvc.getUser(uid);
    if (user != null && user.darkMode != _isDark) {
      _isDark = user.darkMode;
      notifyListeners();
    }
  }

  /// Toggle and persist to Firestore.
  Future<void> toggle(String uid) async {
    _isDark = !_isDark;
    notifyListeners();
    await _prefsSvc.toggleDarkMode(uid, _isDark);
  }

  /// Reset when user signs out.
  void reset() {
    _isDark = false;
    notifyListeners();
  }
}
