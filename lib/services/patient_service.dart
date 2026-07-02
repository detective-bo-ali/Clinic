import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient.dart';

/// Patients are stored in a top-level collection (not nested under clinics)
/// so cross-clinic queries (e.g. super admin search) stay simple, while
/// every document carries `clinicId` for scoping + Firestore security rules.
class PatientService {
  final _db = FirebaseFirestore.instance;
  CollectionReference get _patients => _db.collection('patients');

  Future<DocumentReference> addPatient(Patient patient) {
    return _patients.add(patient.toMap());
  }

  Future<void> updatePatient(String id, Map<String, dynamic> data) {
    return _patients.doc(id).update(data);
  }

  Future<void> deletePatient(String id) {
    return _patients.doc(id).delete();
  }

  Stream<List<Patient>> streamPatientsForClinic(String clinicId) {
    return _patients
        .where('clinicId', isEqualTo: clinicId)
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Patient.fromDoc(d)).toList());
  }

  Future<Patient?> getPatient(String id) async {
    final doc = await _patients.doc(id).get();
    if (!doc.exists) return null;
    return Patient.fromDoc(doc);
  }

  /// Simple client-side-filtered search by name prefix. For larger datasets,
  /// swap this for Algolia/Typesense via a Cloud Function trigger.
  Stream<List<Patient>> searchPatients(String clinicId, String query) {
    return streamPatientsForClinic(clinicId).map((patients) => patients
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList());
  }
}
