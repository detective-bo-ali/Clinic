import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../../services/appointment_service.dart';
import '../../utils/validators.dart';

/// Minimal patient/doctor selection: in production swap the plain
/// TextFormFields for typeahead pickers backed by PatientService /
/// StaffService (filtered to doctors). Kept simple here to stay focused.
class AppointmentFormScreen extends StatefulWidget {
  final String clinicId;
  final Appointment? existing;
  final DateTime? initialDate;
  const AppointmentFormScreen({super.key, required this.clinicId, this.existing, this.initialDate});

  @override
  State<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _patientName = TextEditingController(text: widget.existing?.patientName);
  late final _patientId = TextEditingController(text: widget.existing?.patientId);
  late final _doctorName = TextEditingController(text: widget.existing?.doctorName);
  late final _doctorId = TextEditingController(text: widget.existing?.doctorId);
  late final _reason = TextEditingController(text: widget.existing?.reason);
  late final _notes = TextEditingController(text: widget.existing?.notes);
  late DateTime _date = widget.existing?.dateTime ?? widget.initialDate ?? DateTime.now();
  late TimeOfDay _time = TimeOfDay.fromDateTime(widget.existing?.dateTime ?? DateTime.now());
  AppointmentStatus _status = AppointmentStatus.scheduled;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) _status = widget.existing!.status;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context, initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final dateTime = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    final service = AppointmentService();
    final appt = Appointment(
      id: widget.existing?.id ?? '',
      clinicId: widget.clinicId,
      patientId: _patientId.text.trim(),
      patientName: _patientName.text.trim(),
      doctorId: _doctorId.text.trim(),
      doctorName: _doctorName.text.trim(),
      dateTime: dateTime,
      status: _status,
      reason: _reason.text.trim(),
      notes: _notes.text.trim(),
    );
    if (widget.existing == null) {
      await service.addAppointment(appt);
    } else {
      await service.updateAppointment(widget.existing!.id, appt.toMap());
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'New Appointment' : 'Edit Appointment'),
        actions: [
          if (widget.existing != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                await AppointmentService().deleteAppointment(widget.existing!.id);
                if (mounted) Navigator.pop(context);
              },
            ),
        ],
      ),
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
                decoration: const InputDecoration(labelText: 'Patient ID (paste from Patients screen)'),
                validator: (v) => Validators.required(v, 'Patient ID'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _doctorName,
                decoration: const InputDecoration(labelText: 'Doctor name'),
                validator: (v) => Validators.required(v, 'Doctor name'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _doctorId,
                decoration: const InputDecoration(labelText: 'Doctor ID (uid)'),
                validator: (v) => Validators.required(v, 'Doctor ID'),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text('${_date.year}-${_date.month.toString().padLeft(2,'0')}-${_date.day.toString().padLeft(2,'0')}'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time, size: 18),
                    label: Text(_time.format(context)),
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              TextFormField(
                controller: _reason,
                decoration: const InputDecoration(labelText: 'Reason for visit'),
                validator: (v) => Validators.required(v, 'Reason'),
              ),
              const SizedBox(height: 14),
              if (widget.existing != null)
                DropdownButtonFormField<AppointmentStatus>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: AppointmentStatus.values
                      .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _status = v!),
                ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _notes,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
