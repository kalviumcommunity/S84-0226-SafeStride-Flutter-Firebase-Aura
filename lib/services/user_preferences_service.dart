import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Service that manages user preferences and personalization data in Firestore.
///
/// Collections used:
///   • `users/{uid}`   – profile + preferences
///   • `users/{uid}/saved_routes/{routeId}` – bookmarked routes
class UserPreferencesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Profile ──────────────────────────────────────────────────────────────

  /// Real-time stream of the full [UserModel] for [uid].
  Stream<UserModel?> userStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserModel.fromMap(snap.data()!);
    });
  }

  /// Fetch the user profile once (non-streaming).
  Future<UserModel?> getUser(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return UserModel.fromMap(snap.data()!);
  }

  // ── Preferences ──────────────────────────────────────────────────────────

  /// Update one or more preference fields.  Only the supplied keys are
  /// written; everything else is left untouched.
  Future<void> updatePreferences(
      String uid, Map<String, dynamic> prefs) async {
    await _db.collection('users').doc(uid).set(
      {...prefs, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  /// Toggle dark-mode preference.
  Future<void> toggleDarkMode(String uid, bool value) async {
    await updatePreferences(uid, {'darkMode': value});
  }

  /// Set the user's activity type (`runner` / `cyclist`).
  Future<void> setActivityType(String uid, String type) async {
    await updatePreferences(uid, {'activityType': type});
  }

  /// Toggle notification preference.
  Future<void> toggleNotifications(String uid, bool value) async {
    await updatePreferences(uid, {'notificationsEnabled': value});
  }

  /// Update the display name.
  Future<void> updateDisplayName(String uid, String name) async {
    await updatePreferences(uid, {'displayName': name});
  }

  /// Update the bio / tagline.
  Future<void> updateBio(String uid, String bio) async {
    await updatePreferences(uid, {'bio': bio});
  }

  /// Set preferred route distance (km).
  Future<void> setPreferredDistance(String uid, double km) async {
    await updatePreferences(uid, {'preferredDistance': km});
  }

  // ── Saved Routes ─────────────────────────────────────────────────────────

  /// Save (bookmark) a route for the user.
  Future<void> saveRoute(String uid, String routeId,
      Map<String, dynamic> routeData) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('saved_routes')
        .doc(routeId)
        .set({...routeData, 'savedAt': FieldValue.serverTimestamp()});

    // Increment counter on the profile document
    await _db.collection('users').doc(uid).set(
      {'savedRoutesCount': FieldValue.increment(1)},
      SetOptions(merge: true),
    );
  }

  /// Remove a saved route.
  Future<void> unsaveRoute(String uid, String routeId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('saved_routes')
        .doc(routeId)
        .delete();

    await _db.collection('users').doc(uid).set(
      {'savedRoutesCount': FieldValue.increment(-1)},
      SetOptions(merge: true),
    );
  }

  /// Stream all saved routes for the user.
  Stream<QuerySnapshot> savedRoutesStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('saved_routes')
        .orderBy('savedAt', descending: true)
        .snapshots();
  }
}
