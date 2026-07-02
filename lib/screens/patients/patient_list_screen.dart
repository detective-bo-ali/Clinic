import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/patient.dart';
import '../../providers/clinic_context_provider.dart';
import '../../services/patient_service.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/empty_state.dart';
import 'patient_form_screen.dart';
import 'patient_detail_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});
  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final clinic = context.watch<ClinicContextProvider>().selectedClinic;
    final service = PatientService();

    return Scaffold(
      appBar: AppBar(title: const Text('Patients')),
      drawer: const AppDrawer(currentRoute: '/patients'),
      floatingActionButton: clinic == null ? null : FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => PatientFormScreen(clinicId: clinic.id))),
        child: const Icon(Icons.person_add_alt_1),
      ),
      body: clinic == null
          ? const EmptyState(icon: Icons.local_hospital_outlined, message: 'Select a clinic first.')
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText: 'Search patients by name…',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<Patient>>(
                    stream: _query.isEmpty
                        ? service.streamPatientsForClinic(clinic.id)
                        : service.searchPatients(clinic.id, _query),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final patients = snapshot.data!;
                      if (patients.isEmpty) {
                        return const EmptyState(icon: Icons.people_outline, message: 'No patients found.');
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: patients.length,
                        itemBuilder: (context, i) {
                          final p = patients[i];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(child: Text(p.name.isNotEmpty ? p.name[0].toUpperCase() : '?')),
                              title: Text(p.name),
                              subtitle: Text('${p.age} yrs • ${p.gender} • ${p.phone}'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => PatientDetailScreen(patient: p))),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
