import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_planner/models/app_user.dart';
import 'package:travel_planner/models/destination.dart';

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<AppUser>> getUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => AppUser.fromMap(doc.data())).toList();
    });
  }

  // --- Profile Management ---
  Future<void> createUser(AppUser user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<void> updateUser(AppUser user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toMap());
  }

  Future<void> deleteUser(String uid) async {
    // Note: This only deletes the Firestore doc. 
    // Authenticaton deletion requires Admin SDK/Cloud Functions.
    await _firestore.collection('users').doc(uid).delete();
  }

  // --- Sub-collection Management (Favorites) ---
  Stream<List<Destination>> getUserFavoritesStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Destination.fromMap(doc.data())).toList();
    });
  }

  Future<void> removeUserFavorite(String uid, String destinationId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(destinationId)
        .delete();
  }

  // --- Sub-collection Management (Bookings) ---
  Stream<List<Destination>> getUserBookingsStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('bookings')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Destination.fromMap(doc.data())).toList();
    });
  }

  Future<void> removeUserBooking(String uid, String destinationId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('bookings')
        .doc(destinationId)
        .delete();
  }
}
