import 'package:flutter/material.dart';
import '../../models/inventory_item.dart';
import '../../services/inventory_service.dart';
import '../../utils/validators.dart';

class InventoryFormScreen extends StatefulWidget {
  final String clinicId;
  final InventoryItem? existing;
  const InventoryFormScreen({super.key, required this.clinicId, this.existing});

  @override
  State<InventoryFormScreen> createState() => _InventoryFormScreenState();
}

class _InventoryFormScreenState extends State<InventoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _quantity = TextEditingController(text: widget.existing?.quantity.toString());
  late final _unit = TextEditingController(text: widget.existing?.unit);
  late final _reorder = TextEditingController(text: widget.existing?.reorderLevel.toString());
  late final _supplier = TextEditingController(text: widget.existing?.supplier);
  bool _saving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final service = InventoryService();
    final item = InventoryItem(
      id: widget.existing?.id ?? '',
      clinicId: widget.clinicId,
      name: _name.text.trim(),
      quantity: int.tryParse(_quantity.text) ?? 0,
      unit: _unit.text.trim(),
      reorderLevel: int.tryParse(_reorder.text) ?? 0,
      supplier: _supplier.text.trim(),
    );
    if (widget.existing == null) {
      await service.addItem(item);
    } else {
      await service.updateItem(widget.existing!.id, item.toMap());
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Add Inventory Item' : 'Edit Item'),
        actions: [
          if (widget.existing != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                await InventoryService().deleteItem(widget.existing!.id);
                if (mounted) Navigator.pop(context);
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Item name'),
                validator: (v) => Validators.required(v, 'Name'),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantity,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    validator: (v) => Validators.positiveNumber(v, 'Quantity'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _unit,
                    decoration: const InputDecoration(labelText: 'Unit (e.g. tablets)'),
                    validator: (v) => Validators.required(v, 'Unit'),
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              TextFormField(
                controller: _reorder,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Reorder level (alert threshold)'),
                validator: (v) => Validators.positiveNumber(v, 'Reorder level'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _supplier,
                decoration: const InputDecoration(labelText: 'Supplier'),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
