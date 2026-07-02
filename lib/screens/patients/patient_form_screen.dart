import 'package:flutter/material.dart';
import '../../models/patient.dart';
import '../../services/patient_service.dart';
import '../../utils/validators.dart';

class PatientFormScreen extends StatefulWidget {
  final String clinicId;
  final Patient? existing;
  const PatientFormScreen({super.key, required this.clinicId, this.existing});

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _age = TextEditingController(text: widget.existing?.age.toString());
  String _gender = 'Female';
  late final _phone = TextEditingController(text: widget.existing?.phone);
  late final _address = TextEditingController(text: widget.existing?.address);
  late final _history = TextEditingController(text: widget.existing?.medicalHistory);
  late final _bloodGroup = TextEditingController(text: widget.existing?.bloodGroup);
  late final _allergies = TextEditingController(text: widget.existing?.allergies);
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) _gender = widget.existing!.gender;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final service = PatientService();
    if (widget.existing == null) {
      await service.addPatient(Patient(
        id: '',
        clinicId: widget.clinicId,
        name: _name.text.trim(),
        age: int.tryParse(_age.text) ?? 0,
        gender: _gender,
        phone: _phone.text.trim(),
        address: _address.text.trim(),
        medicalHistory: _history.text.trim(),
        bloodGroup: _bloodGroup.text.trim().isEmpty ? null : _bloodGroup.text.trim(),
        allergies: _allergies.text.trim().isEmpty ? null : _allergies.text.trim(),
      ));
    } else {
      await service.updatePatient(widget.existing!.id, {
        'name': _name.text.trim(),
        'age': int.tryParse(_age.text) ?? 0,
        'gender': _gender,
        'phone': _phone.text.trim(),
        'address': _address.text.trim(),
        'medicalHistory': _history.text.trim(),
        'bloodGroup': _bloodGroup.text.trim(),
        'allergies': _allergies.text.trim(),
      });
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? 'Add Patient' : 'Edit Patient')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) => Validators.required(v, 'Name'),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _age,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Age'),
                    validator: (v) => Validators.positiveNumber(v, 'Age'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: ['Female', 'Male', 'Other']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => setState(() => _gender = v!),
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: Validators.phone,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _address,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _bloodGroup,
                    decoration: const InputDecoration(labelText: 'Blood group (optional)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _allergies,
                    decoration: const InputDecoration(labelText: 'Allergies (optional)'),
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              TextFormField(
                controller: _history,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Medical history / notes'),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Patient'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
