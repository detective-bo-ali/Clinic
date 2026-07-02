import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/invoice.dart';

class BillingService {
  final _db = FirebaseFirestore.instance;
  CollectionReference get _invoices => _db.collection('invoices');

  Future<DocumentReference> createInvoice(Invoice invoice) {
    return _invoices.add(invoice.toMap());
  }

  Future<void> updateInvoice(String id, Map<String, dynamic> data) {
    return _invoices.doc(id).update(data);
  }

  Future<void> recordPayment(String id, double newAmountPaid, InvoiceStatus status) {
    return _invoices.doc(id).update({
      'amountPaid': newAmountPaid,
      'status': status.name,
    });
  }

  Stream<List<Invoice>> streamForClinic(String clinicId) {
    return _invoices
        .where('clinicId', isEqualTo: clinicId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Invoice.fromDoc(d)).toList());
  }

  Stream<List<Invoice>> streamForPatient(String patientId) {
    return _invoices
        .where('patientId', isEqualTo: patientId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Invoice.fromDoc(d)).toList());
  }

  /// Quick revenue rollup for the dashboard — for heavy reporting move this
  /// to a scheduled Cloud Function that writes aggregates to /clinics/{id}/stats.
  Future<double> totalCollectedThisMonth(String clinicId) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final snap = await _invoices
        .where('clinicId', isEqualTo: clinicId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .get();
    double sum = 0;
    for (final doc in snap.docs) {
      final inv = Invoice.fromDoc(doc);
      sum += inv.amountPaid;
    }
    return sum;
  }
}
