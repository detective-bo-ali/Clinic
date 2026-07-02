import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';

class AppointmentService {
  final _db = FirebaseFirestore.instance;
  CollectionReference get _appts => _db.collection('appointments');

  Future<DocumentReference> addAppointment(Appointment appt) {
    return _appts.add(appt.toMap());
  }

  Future<void> updateAppointment(String id, Map<String, dynamic> data) {
    return _appts.doc(id).update(data);
  }

  Future<void> deleteAppointment(String id) {
    return _appts.doc(id).delete();
  }

  Stream<List<Appointment>> streamForClinic(String clinicId) {
    return _appts
        .where('clinicId', isEqualTo: clinicId)
        .orderBy('dateTime')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Appointment.fromDoc(d)).toList());
  }

  /// Doctor's own schedule across whichever clinic(s) they work at.
  Stream<List<Appointment>> streamForDoctor(String doctorId) {
    return _appts
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('dateTime')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Appointment.fromDoc(d)).toList());
  }

  Stream<List<Appointment>> streamForDay(String clinicId, DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return _appts
        .where('clinicId', isEqualTo: clinicId)
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('dateTime', isLessThan: Timestamp.fromDate(end))
        .orderBy('dateTime')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Appointment.fromDoc(d)).toList());
  }
}
