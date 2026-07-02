import 'package:cloud_firestore/cloud_firestore.dart';

/// Roles available in the system.
/// superAdmin   -> can see/manage all clinics (you / platform owner)
/// clinicAdmin  -> manages one or more specific clinics (clinic owner/manager)
/// doctor       -> sees patients/appointments assigned to them
/// staff        -> front-desk/receptionist: appointments, billing, patients
enum UserRole { superAdmin, clinicAdmin, doctor, staff }

UserRole roleFromString(String value) {
  return UserRole.values.firstWhere(
    (r) => r.name == value,
    orElse: () => UserRole.staff,
  );
}

class AppUser {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final List<String> clinicIds; // clinics this user belongs to
  final String? specialty; // for doctors
  final String? phone;
  final bool active;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.clinicIds,
    this.specialty,
    this.phone,
    this.active = true,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: roleFromString(map['role'] ?? 'staff'),
      clinicIds: List<String>.from(map['clinicIds'] ?? []),
      specialty: map['specialty'],
      phone: map['phone'],
      active: map['active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
      'clinicIds': clinicIds,
      'specialty': specialty,
      'phone': phone,
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
