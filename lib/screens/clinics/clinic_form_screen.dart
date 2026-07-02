import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/clinic.dart';
import '../../providers/auth_provider.dart';
import '../../services/clinic_service.dart';
import '../../services/staff_service.dart';
import '../../utils/validators.dart';

class ClinicFormScreen extends StatefulWidget {
  final Clinic? existing;
  const ClinicFormScreen({super.key, this.existing});

  @override
  State<ClinicFormScreen> createState() => _ClinicFormScreenState();
}

class _ClinicFormScreenState extends State<ClinicFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _address = TextEditingController(text: widget.existing?.address);
  late final _phone = TextEditingController(text: widget.existing?.phone);
  bool _saving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final auth = context.read<AuthProvider>();
    final service = ClinicService();
    if (widget.existing == null) {
      final clinic = Clinic(
        id: '',
        name: _name.text.trim(),
        address: _address.text.trim(),
        phone: _phone.text.trim(),
        ownerId: auth.firebaseUser!.uid,
      );
      final ref = await service.createClinic(clinic);
      // Attach this clinic to the creating admin's clinicIds so it shows up
      // immediately in their clinic picker / drawer without a manual step.
      await StaffService().assignToClinic(auth.firebaseUser!.uid, ref.id);
    } else {
      await service.updateClinic(widget.existing!.id, {
        'name': _name.text.trim(),
        'address': _address.text.trim(),
        'phone': _phone.text.trim(),
      });
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? 'New Clinic' : 'Edit Clinic')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Clinic name'),
                validator: (v) => Validators.required(v, 'Clinic name'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _address,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (v) => Validators.required(v, 'Address'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: Validators.phone,
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Clinic'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
