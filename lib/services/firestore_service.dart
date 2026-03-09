import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Users ─────────────────────────────────────────────────────────────────

  /// Create or overwrite a user profile document in the `users` collection.
  Future<void> addUserData(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Real-time stream of a single user's profile document.
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  // ── Routes ────────────────────────────────────────────────────────────────

  /// Create a new route document. Uses [routeId] as the document ID.
  Future<void> addRoute(String routeId, Map<String, dynamic> data) async {
    await _db.collection('routes').doc(routeId).set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update specific fields of an existing route document.
  Future<void> updateRoute(String routeId, Map<String, dynamic> data) async {
    await _db.collection('routes').doc(routeId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Real-time stream of all routes, newest first.
  Stream<QuerySnapshot> getRoutesStream() {
    return _db
        .collection('routes')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Delete a route by its document ID.
  Future<void> deleteRoute(String routeId) async {
    await _db.collection('routes').doc(routeId).delete();
  }
}
