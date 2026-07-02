import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_user.dart';
import '../../providers/clinic_context_provider.dart';
import '../../services/staff_service.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/empty_state.dart';
import 'staff_form_screen.dart';

class StaffListScreen extends StatelessWidget {
  const StaffListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clinic = context.watch<ClinicContextProvider>().selectedClinic;
    final service = StaffService();

    return Scaffold(
      appBar: AppBar(title: const Text('Staff & Doctors')),
      drawer: const AppDrawer(currentRoute: '/staff'),
      floatingActionButton: clinic == null ? null : FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => StaffFormScreen(clinicId: clinic.id))),
        child: const Icon(Icons.person_add),
      ),
      body: clinic == null
          ? const EmptyState(icon: Icons.local_hospital_outlined, message: 'Select a clinic first.')
          : StreamBuilder<List<AppUser>>(
              stream: service.streamStaffForClinic(clinic.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final staff = snapshot.data!;
                if (staff.isEmpty) {
                  return const EmptyState(icon: Icons.badge_outlined, message: 'No staff assigned to this clinic yet.');
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: staff.length,
                  itemBuilder: (context, i) {
                    final u = staff[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text(u.name.isNotEmpty ? u.name[0].toUpperCase() : '?')),
                        title: Text(u.name),
                        subtitle: Text('${_roleLabel(u.role)}${u.specialty != null ? ' • ${u.specialty}' : ''}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (action) {
                            if (action == 'remove') {
                              service.removeFromClinic(u.uid, clinic.id);
                            } else if (action == 'deactivate') {
                              service.deactivateUser(u.uid);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'remove', child: Text('Remove from clinic')),
                            PopupMenuItem(value: 'deactivate', child: Text('Deactivate account')),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.superAdmin: return 'Platform Admin';
      case UserRole.clinicAdmin: return 'Clinic Admin';
      case UserRole.doctor: return 'Doctor';
      case UserRole.staff: return 'Staff';
    }
  }
}
