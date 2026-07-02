import 'package:cloud_firestore/cloud_firestore.dart';

class Clinic {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String ownerId; // uid of clinicAdmin who created it
  final DateTime? createdAt;

  Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.ownerId,
    this.createdAt,
  });

  factory Clinic.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Clinic(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      ownerId: data['ownerId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'ownerId': ownerId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
