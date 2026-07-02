import 'package:cloud_firestore/cloud_firestore.dart';

enum InvoiceStatus { paid, unpaid, partial }

InvoiceStatus invoiceStatusFromString(String value) {
  return InvoiceStatus.values.firstWhere(
    (s) => s.name == value,
    orElse: () => InvoiceStatus.unpaid,
  );
}

class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;

  InvoiceItem({required this.description, required this.quantity, required this.unitPrice});

  double get total => quantity * unitPrice;

  factory InvoiceItem.fromMap(Map<String, dynamic> map) => InvoiceItem(
        description: map['description'] ?? '',
        quantity: map['quantity'] ?? 1,
        unitPrice: (map['unitPrice'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'description': description,
        'quantity': quantity,
        'unitPrice': unitPrice,
      };
}

class Invoice {
  final String id;
  final String clinicId;
  final String patientId;
  final String patientName;
  final List<InvoiceItem> items;
  final double amountPaid;
  final InvoiceStatus status;
  final DateTime? date;

  Invoice({
    required this.id,
    required this.clinicId,
    required this.patientId,
    required this.patientName,
    required this.items,
    required this.amountPaid,
    required this.status,
    this.date,
  });

  double get total => items.fold(0, (sum, item) => sum + item.total);
  double get balance => total - amountPaid;

  factory Invoice.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Invoice(
      id: doc.id,
      clinicId: data['clinicId'] ?? '',
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      items: (data['items'] as List<dynamic>? ?? [])
          .map((i) => InvoiceItem.fromMap(i as Map<String, dynamic>))
          .toList(),
      amountPaid: (data['amountPaid'] ?? 0).toDouble(),
      status: invoiceStatusFromString(data['status'] ?? 'unpaid'),
      date: (data['date'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clinicId': clinicId,
      'patientId': patientId,
      'patientName': patientName,
      'items': items.map((i) => i.toMap()).toList(),
      'amountPaid': amountPaid,
      'status': status.name,
      'date': FieldValue.serverTimestamp(),
    };
  }
}
