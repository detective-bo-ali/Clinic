import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../services/staff_service.dart';
import '../../utils/validators.dart';

/// NOTE: Creating a brand-new Auth account for a doctor/staff member from
/// inside the admin's logged-in app session requires a Cloud Function
/// (Admin SDK) because the client SDK's createUser call signs in as that
/// new user, kicking the admin out. The recommended flow:
///   1. Admin fills this form -> calls a callable Cloud Function `inviteStaff`
///   2. Function creates the Auth user + /users/{uid} doc + emails a temp password
/// This screen calls `StaffService.createStaffProfileDoc` directly for local
/// testing/demo purposes — wire it to your Cloud Function before shipping.
class StaffFormScreen extends StatefulWidget {
  final String clinicId;
  const StaffFormScreen({super.key, required this.clinicId});

  @override
  State<StaffFormScreen> createState() => _StaffFormScreenState();
}

class _StaffFormScreenState extends State<StaffFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _specialty = TextEditingController();
  final _phone = TextEditingController();
  UserRole _role = UserRole.doctor;
  bool _saving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    // In production: replace this with a call to your `inviteStaff` Cloud
    // Function, passing name/email/role/clinicId, and show the returned
    // temporary password or trigger a password-reset email.
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Hook this up to your inviteStaff Cloud Function (see comment in source).'),
    ));
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invite Staff / Doctor')),
      body: Padding(
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
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: Validators.email,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<UserRole>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(value: UserRole.doctor, child: Text('Doctor')),
                  DropdownMenuItem(value: UserRole.staff, child: Text('Staff / Receptionist')),
                  DropdownMenuItem(value: UserRole.clinicAdmin, child: Text('Clinic Admin')),
                ],
                onChanged: (v) => setState(() => _role = v!),
              ),
              if (_role == UserRole.doctor) ...[
                const SizedBox(height: 14),
                TextFormField(
                  controller: _specialty,
                  decoration: const InputDecoration(labelText: 'Specialty (e.g. Pediatrics)'),
                ),
              ],
              const SizedBox(height: 14),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Phone (optional)'),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Send Invite'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
