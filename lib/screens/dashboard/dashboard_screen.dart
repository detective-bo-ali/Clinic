import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/clinic_context_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/clinic_picker.dart';
import '../../widgets/empty_state.dart';
import '../../services/patient_service.dart';
import '../../services/appointment_service.dart';
import '../../services/billing_service.dart';
import '../../services/inventory_service.dart';
import '../../models/appointment.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final clinic = context.watch<ClinicContextProvider>().selectedClinic;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: const [Padding(padding: EdgeInsets.only(right: 12), child: ClinicPicker())],
      ),
      drawer: const AppDrawer(currentRoute: '/dashboard'),
      body: clinic == null
          ? const EmptyState(icon: Icons.local_hospital_outlined, message: 'No clinic selected yet.\nCreate or pick a clinic to get started.')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back, ${auth.appUser?.name ?? ''}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(clinic.name, style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 18),
                  _StatsRow(clinicId: clinic.id),
                  const SizedBox(height: 24),
                  const Text("Today's appointments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  _TodayAppointments(clinicId: clinic.id),
                ],
              ),
            ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final String clinicId;
  const _StatsRow({required this.clinicId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StreamBuilder(
            stream: PatientService().streamPatientsForClinic(clinicId),
            builder: (context, snap) => _StatCard(
              icon: Icons.people_outline,
              label: 'Patients',
              value: snap.hasData ? '${snap.data!.length}' : '—',
              color: Colors.blue,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StreamBuilder(
            stream: AppointmentService().streamForDay(clinicId, DateTime.now()),
            builder: (context, snap) => _StatCard(
              icon: Icons.calendar_today_outlined,
              label: "Today's Visits",
              value: snap.hasData ? '${snap.data!.length}' : '—',
              color: Colors.teal,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StreamBuilder(
            stream: InventoryService().streamLowStock(clinicId),
            builder: (context, snap) => _StatCard(
              icon: Icons.warning_amber_outlined,
              label: 'Low Stock',
              value: snap.hasData ? '${snap.data!.length}' : '—',
              color: Colors.orange,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _TodayAppointments extends StatelessWidget {
  final String clinicId;
  const _TodayAppointments({required this.clinicId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Appointment>>(
      stream: AppointmentService().streamForDay(clinicId, DateTime.now()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final appts = snapshot.data!;
        if (appts.isEmpty) {
          return const EmptyState(icon: Icons.event_available, message: 'No appointments scheduled for today.');
        }
        return Column(
          children: appts.map((a) => Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(a.patientName),
              subtitle: Text('Dr. ${a.doctorName} • ${a.reason}'),
              trailing: Text('${a.dateTime.hour.toString().padLeft(2,'0')}:${a.dateTime.minute.toString().padLeft(2,'0')}'),
            ),
          )).toList(),
        );
      },
    );
  }
}
