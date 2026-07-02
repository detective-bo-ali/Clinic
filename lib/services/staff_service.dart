import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class StaffService {
  final _db = FirebaseFirestore.instance;
  CollectionReference get _users => _db.collection('users');

  Stream<List<AppUser>> streamStaffForClinic(String clinicId) {
    return _users
        .where('clinicIds', arrayContains: clinicId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => AppUser.fromMap(d.id, d.data() as Map<String, dynamic>)).toList());
  }

  Stream<List<AppUser>> streamAllUsers() {
    return _users.snapshots().map((snap) =>
        snap.docs.map((d) => AppUser.fromMap(d.id, d.data() as Map<String, dynamic>)).toList());
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) {
    return _users.doc(uid).update(data);
  }

  Future<void> deactivateUser(String uid) {
    return _users.doc(uid).update({'active': false});
  }

  Future<void> assignToClinic(String uid, String clinicId) {
    return _users.doc(uid).update({
      'clinicIds': FieldValue.arrayUnion([clinicId]),
    });
  }

  Future<void> removeFromClinic(String uid, String clinicId) {
    return _users.doc(uid).update({
      'clinicIds': FieldValue.arrayRemove([clinicId]),
    });
  }
}
