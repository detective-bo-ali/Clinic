import 'package:flutter/material.dart';
import '../../models/invoice.dart';
import '../../services/billing_service.dart';
import '../../utils/validators.dart';

class InvoiceFormScreen extends StatefulWidget {
  final String clinicId;
  final Invoice? existing;
  const InvoiceFormScreen({super.key, required this.clinicId, this.existing});

  @override
  State<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _patientName = TextEditingController(text: widget.existing?.patientName);
  late final _patientId = TextEditingController(text: widget.existing?.patientId);
  late List<InvoiceItem> _items = widget.existing?.items.toList() ?? [];
  late final _amountPaid = TextEditingController(text: widget.existing?.amountPaid.toString() ?? '0');
  bool _saving = false;

  final _descCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  final _priceCtrl = TextEditingController();

  void _addLineItem() {
    if (_descCtrl.text.trim().isEmpty || _priceCtrl.text.trim().isEmpty) return;
    setState(() {
      _items.add(InvoiceItem(
        description: _descCtrl.text.trim(),
        quantity: int.tryParse(_qtyCtrl.text) ?? 1,
        unitPrice: double.tryParse(_priceCtrl.text) ?? 0,
      ));
      _descCtrl.clear();
      _qtyCtrl.text = '1';
      _priceCtrl.clear();
    });
  }

  double get _total => _items.fold(0, (sum, i) => sum + i.total);

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _items.isEmpty) return;
    setState(() => _saving = true);
    final paid = double.tryParse(_amountPaid.text) ?? 0;
    final status = paid >= _total ? InvoiceStatus.paid : paid > 0 ? InvoiceStatus.partial : InvoiceStatus.unpaid;
    final service = BillingService();
    final invoice = Invoice(
      id: widget.existing?.id ?? '',
      clinicId: widget.clinicId,
      patientId: _patientId.text.trim(),
      patientName: _patientName.text.trim(),
      items: _items,
      amountPaid: paid,
      status: status,
    );
    if (widget.existing == null) {
      await service.createInvoice(invoice);
    } else {
      await service.updateInvoice(widget.existing!.id, invoice.toMap());
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? 'New Invoice' : 'Edit Invoice')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _patientName,
                decoration: const InputDecoration(labelText: 'Patient name'),
                validator: (v) => Validators.required(v, 'Patient name'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _patientId,
                decoration: const InputDecoration(labelText: 'Patient ID'),
                validator: (v) => Validators.required(v, 'Patient ID'),
              ),
              const SizedBox(height: 18),
              const Text('Line items', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._items.asMap().entries.map((e) => Card(
                    child: ListTile(
                      title: Text(e.value.description),
                      subtitle: Text('${e.value.quantity} x \$${e.value.unitPrice.toStringAsFixed(2)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _items.removeAt(e.key)),
                      ),
                    ),
                  )),
              Row(children: [
                Expanded(flex: 3, child: TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description'))),
                const SizedBox(width: 8),
                Expanded(flex: 1, child: TextField(controller: _qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Qty'))),
                const SizedBox(width: 8),
                Expanded(flex: 2, child: TextField(controller: _priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price'))),
                IconButton(icon: const Icon(Icons.add_circle, color: Colors.teal), onPressed: _addLineItem),
              ]),
              const SizedBox(height: 14),
              Text('Total: \$${_total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 14),
              TextFormField(
                controller: _amountPaid,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount paid so far'),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Invoice'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
