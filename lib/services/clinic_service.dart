import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/clinic.dart';

class ClinicService {
  final _db = FirebaseFirestore.instance;
  CollectionReference get _clinics => _db.collection('clinics');

  Future<DocumentReference> createClinic(Clinic clinic) {
    return _clinics.add(clinic.toMap());
  }

  Future<void> updateClinic(String id, Map<String, dynamic> data) {
    return _clinics.doc(id).update(data);
  }

  Future<void> deleteClinic(String id) {
    return _clinics.doc(id).delete();
  }

  /// Super admin: stream of ALL clinics.
  Stream<List<Clinic>> streamAllClinics() {
    return _clinics.orderBy('name').snapshots().map(
          (snap) => snap.docs.map((d) => Clinic.fromDoc(d)).toList(),
        );
  }

  /// Clinic admin/doctor/staff: only the clinics they belong to.
  Stream<List<Clinic>> streamClinicsByIds(List<String> ids) {
    if (ids.isEmpty) return const Stream.empty();
    return _clinics.where(FieldPath.documentId, whereIn: ids).snapshots().map(
          (snap) => snap.docs.map((d) => Clinic.fromDoc(d)).toList(),
        );
  }

  Future<Clinic?> getClinic(String id) async {
    final doc = await _clinics.doc(id).get();
    if (!doc.exists) return null;
    return Clinic.fromDoc(doc);
  }
}
