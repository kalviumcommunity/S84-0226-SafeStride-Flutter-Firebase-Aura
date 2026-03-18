import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_preferences_service.dart';

/// Centralized user profile state streamed from Firestore.
/// Eliminates independent StreamBuilders across screens.
class UserProvider extends ChangeNotifier {
  final _prefsSvc = UserPreferencesService();

  UserModel? _user;
  StreamSubscription<UserModel?>? _sub;

  UserModel? get user => _user;
  bool get isLoaded => _user != null;
  String get displayName => _user?.displayName ?? '';
  String get activityType => _user?.activityType ?? 'runner';

  /// Subscribe to live Firestore stream for [uid].
  void subscribe(String uid) {
    _sub?.cancel();
    _sub = _prefsSvc.userStream(uid).listen((u) {
      _user = u;
      notifyListeners();
    });
  }

  /// Update local state optimistically after an edit.
  void updateLocally(UserModel updated) {
    _user = updated;
    notifyListeners();
  }

  /// Clear state on sign-out.
  void clear() {
    _sub?.cancel();
    _sub = null;
    _user = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
