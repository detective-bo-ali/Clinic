import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/clinic.dart';
import '../providers/auth_provider.dart';
import '../providers/clinic_context_provider.dart';
import '../services/clinic_service.dart';

/// Dropdown shown in the dashboard app bar so admins/staff who belong to
/// multiple clinics can switch which clinic's data they're viewing.
class ClinicPicker extends StatelessWidget {
  const ClinicPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final clinicCtx = context.watch<ClinicContextProvider>();
    final service = ClinicService();

    final stream = auth.isSuperAdmin
        ? service.streamAllClinics()
        : service.streamClinicsByIds(auth.accessibleClinicIds);

    return StreamBuilder<List<Clinic>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final clinics = snapshot.data!;
        if (clinics.isEmpty) return const SizedBox.shrink();

        // Auto-select first clinic if none chosen yet.
        if (clinicCtx.selectedClinic == null ||
            !clinics.any((c) => c.id == clinicCtx.selectedClinic!.id)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<ClinicContextProvider>().selectClinic(clinics.first);
          });
        }

        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: clinicCtx.selectedClinic?.id,
            dropdownColor: Theme.of(context).colorScheme.primary,
            iconEnabledColor: Colors.white,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            items: clinics
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: (id) {
              final clinic = clinics.firstWhere((c) => c.id == id);
              context.read<ClinicContextProvider>().selectClinic(clinic);
            },
          ),
        );
      },
    );
  }
}
