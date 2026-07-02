import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/prescription.dart';

class PrescriptionService {
  final _db = FirebaseFirestore.instance;
  CollectionReference get _rx => _db.collection('prescriptions');

  Future<DocumentReference> addPrescription(Prescription rx) {
    return _rx.add(rx.toMap());
  }

  Stream<List<Prescription>> streamForPatient(String patientId) {
    return _rx
        .where('patientId', isEqualTo: patientId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Prescription.fromDoc(d)).toList());
  }

  Stream<List<Prescription>> streamForClinic(String clinicId) {
    return _rx
        .where('clinicId', isEqualTo: clinicId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Prescription.fromDoc(d)).toList());
  }
}
