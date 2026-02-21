import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addRoute(String routeId, Map<String, dynamic> data) async {
    await _db.collection('routes').doc(routeId).set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<QuerySnapshot> getRoutesStream() {
    return _db.collection('routes')
              .orderBy('updatedAt', descending: true)
              .snapshots();
  }

  Future<void> deleteRoute(String routeId) async {
    await _db.collection('routes').doc(routeId).delete();
  }
}
