import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/clinic.dart';
import '../../providers/auth_provider.dart';
import '../../providers/clinic_context_provider.dart';
import '../../services/clinic_service.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/empty_state.dart';
import 'clinic_form_screen.dart';

class ClinicListScreen extends StatelessWidget {
  const ClinicListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final service = ClinicService();
    final stream = auth.isSuperAdmin
        ? service.streamAllClinics()
        : service.streamClinicsByIds(auth.accessibleClinicIds);

    return Scaffold(
      appBar: AppBar(title: const Text('Clinics')),
      drawer: const AppDrawer(currentRoute: '/clinics'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClinicFormScreen())),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Clinic>>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final clinics = snapshot.data!;
          if (clinics.isEmpty) {
            return const EmptyState(icon: Icons.local_hospital_outlined, message: 'No clinics yet. Tap + to add one.');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: clinics.length,
            itemBuilder: (context, i) {
              final c = clinics[i];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.local_hospital)),
                  title: Text(c.name),
                  subtitle: Text(c.address),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.read<ClinicContextProvider>().selectClinic(c);
                    Navigator.pushNamed(context, '/dashboard');
                  },
                  onLongPress: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ClinicFormScreen(existing: c)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
