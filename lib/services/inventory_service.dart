import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory_item.dart';

class InventoryService {
  final _db = FirebaseFirestore.instance;
  CollectionReference get _items => _db.collection('inventory');

  Future<DocumentReference> addItem(InventoryItem item) {
    return _items.add(item.toMap());
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) {
    return _items.doc(id).update(data);
  }

  Future<void> adjustQuantity(String id, int delta) {
    return _items.doc(id).update({'quantity': FieldValue.increment(delta)});
  }

  Future<void> deleteItem(String id) {
    return _items.doc(id).delete();
  }

  Stream<List<InventoryItem>> streamForClinic(String clinicId) {
    return _items
        .where('clinicId', isEqualTo: clinicId)
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs.map((d) => InventoryItem.fromDoc(d)).toList());
  }

  Stream<List<InventoryItem>> streamLowStock(String clinicId) {
    return streamForClinic(clinicId)
        .map((items) => items.where((i) => i.isLowStock).toList());
  }
}
