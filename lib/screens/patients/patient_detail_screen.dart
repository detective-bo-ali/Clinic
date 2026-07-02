import 'package:flutter/material.dart';
import '../../models/patient.dart';
import '../../models/prescription.dart';
import '../../models/invoice.dart';
import '../../services/prescription_service.dart';
import '../../services/billing_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_chip.dart';
import 'patient_form_screen.dart';

class PatientDetailScreen extends StatelessWidget {
  final Patient patient;
  const PatientDetailScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(patient.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => PatientFormScreen(clinicId: patient.clinicId, existing: patient))),
            ),
          ],
          bottom: const TabBar(tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Prescriptions'),
            Tab(text: 'Billing'),
          ]),
        ),
        body: TabBarView(children: [
          _OverviewTab(patient: patient),
          _PrescriptionsTab(patientId: patient.id),
          _BillingTab(patientId: patient.id),
        ]),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final Patient patient;
  const _OverviewTab({required this.patient});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _infoRow('Age', '${patient.age}'),
        _infoRow('Gender', patient.gender),
        _infoRow('Phone', patient.phone),
        _infoRow('Address', patient.address),
        if (patient.bloodGroup != null) _infoRow('Blood group', patient.bloodGroup!),
        if (patient.allergies != null) _infoRow('Allergies', patient.allergies!),
        const SizedBox(height: 12),
        const Text('Medical history', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(patient.medicalHistory.isEmpty ? 'No history recorded.' : patient.medicalHistory),
      ],
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value)),
        ]),
      );
}

class _PrescriptionsTab extends StatelessWidget {
  final String patientId;
  const _PrescriptionsTab({required this.patientId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Prescription>>(
      stream: PrescriptionService().streamForPatient(patientId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final list = snapshot.data!;
        if (list.isEmpty) return const EmptyState(icon: Icons.medication_outlined, message: 'No prescriptions yet.');
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: list.length,
          itemBuilder: (context, i) {
            final rx = list[i];
            return Card(
              child: ExpansionTile(
                title: Text('Dr. ${rx.doctorName} • ${rx.date?.toLocal().toString().split(' ').first ?? ''}'),
                children: rx.medicines.map((m) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.medication_outlined, size: 20),
                  title: Text(m.name),
                  subtitle: Text('${m.dosage} • ${m.frequency} • ${m.duration}'),
                )).toList(),
              ),
            );
          },
        );
      },
    );
  }
}

class _BillingTab extends StatelessWidget {
  final String patientId;
  const _BillingTab({required this.patientId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Invoice>>(
      stream: BillingService().streamForPatient(patientId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final list = snapshot.data!;
        if (list.isEmpty) return const EmptyState(icon: Icons.receipt_long_outlined, message: 'No invoices yet.');
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: list.length,
          itemBuilder: (context, i) {
            final inv = list[i];
            final color = inv.status == InvoiceStatus.paid ? Colors.green
                : inv.status == InvoiceStatus.partial ? Colors.orange : Colors.red;
            return Card(
              child: ListTile(
                title: Text('Total: \$${inv.total.toStringAsFixed(2)}'),
                subtitle: Text('Balance: \$${inv.balance.toStringAsFixed(2)}'),
                trailing: StatusChip(label: inv.status.name, color: color),
              ),
            );
          },
        );
      },
    );
  }
}
