import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String id;
  final String clinicId;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String address;
  final String medicalHistory;
  final String? bloodGroup;
  final String? allergies;
  final DateTime? createdAt;

  Patient({
    required this.id,
    required this.clinicId,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.address,
    required this.medicalHistory,
    this.bloodGroup,
    this.allergies,
    this.createdAt,
  });

  factory Patient.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Patient(
      id: doc.id,
      clinicId: data['clinicId'] ?? '',
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      medicalHistory: data['medicalHistory'] ?? '',
      bloodGroup: data['bloodGroup'],
      allergies: data['allergies'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clinicId': clinicId,
      'name': name,
      'age': age,
      'gender': gender,
      'phone': phone,
      'address': address,
      'medicalHistory': medicalHistory,
      'bloodGroup': bloodGroup,
      'allergies': allergies,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
