import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentStatus { scheduled, completed, cancelled, noShow }

AppointmentStatus statusFromString(String value) {
  return AppointmentStatus.values.firstWhere(
    (s) => s.name == value,
    orElse: () => AppointmentStatus.scheduled,
  );
}

class Appointment {
  final String id;
  final String clinicId;
  final String patientId;
  final String patientName; // denormalized for fast list rendering
  final String doctorId;
  final String doctorName; // denormalized
  final DateTime dateTime;
  final AppointmentStatus status;
  final String reason;
  final String notes;

  Appointment({
    required this.id,
    required this.clinicId,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.dateTime,
    required this.status,
    required this.reason,
    required this.notes,
  });

  factory Appointment.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id,
      clinicId: data['clinicId'] ?? '',
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      status: statusFromString(data['status'] ?? 'scheduled'),
      reason: data['reason'] ?? '',
      notes: data['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clinicId': clinicId,
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'dateTime': Timestamp.fromDate(dateTime),
      'status': status.name,
      'reason': reason,
      'notes': notes,
    };
  }
}
