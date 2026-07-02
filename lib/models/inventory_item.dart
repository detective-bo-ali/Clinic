import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  final String id;
  final String clinicId;
  final String name;
  final int quantity;
  final String unit; // e.g. "tablets", "boxes", "vials"
  final int reorderLevel;
  final DateTime? expiryDate;
  final String supplier;

  InventoryItem({
    required this.id,
    required this.clinicId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.reorderLevel,
    this.expiryDate,
    required this.supplier,
  });

  bool get isLowStock => quantity <= reorderLevel;

  factory InventoryItem.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InventoryItem(
      id: doc.id,
      clinicId: data['clinicId'] ?? '',
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? 0,
      unit: data['unit'] ?? '',
      reorderLevel: data['reorderLevel'] ?? 0,
      expiryDate: (data['expiryDate'] as Timestamp?)?.toDate(),
      supplier: data['supplier'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clinicId': clinicId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'reorderLevel': reorderLevel,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'supplier': supplier,
    };
  }
}
