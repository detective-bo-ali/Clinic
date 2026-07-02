import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine {
  final String name;
  final String dosage;   // e.g. "500mg"
  final String frequency; // e.g. "1-0-1"
  final String duration;  // e.g. "5 days"

  Medicine({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
  });

  factory Medicine.fromMap(Map<String, dynamic> map) => Medicine(
        name: map['name'] ?? '',
        dosage: map['dosage'] ?? '',
        frequency: map['frequency'] ?? '',
        duration: map['duration'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'duration': duration,
      };
}

class Prescription {
  final String id;
  final String clinicId;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String? appointmentId;
  final List<Medicine> medicines;
  final String notes;
  final DateTime? date;

  Prescription({
    required this.id,
    required this.clinicId,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    this.appointmentId,
    required this.medicines,
    required this.notes,
    this.date,
  });

  factory Prescription.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Prescription(
      id: doc.id,
      clinicId: data['clinicId'] ?? '',
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      appointmentId: data['appointmentId'],
      medicines: (data['medicines'] as List<dynamic>? ?? [])
          .map((m) => Medicine.fromMap(m as Map<String, dynamic>))
          .toList(),
      notes: data['notes'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clinicId': clinicId,
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'appointmentId': appointmentId,
      'medicines': medicines.map((m) => m.toMap()).toList(),
      'notes': notes,
      'date': FieldValue.serverTimestamp(),
    };
  }
}
