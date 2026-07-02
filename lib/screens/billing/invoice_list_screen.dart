import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/invoice.dart';
import '../../providers/clinic_context_provider.dart';
import '../../services/billing_service.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_chip.dart';
import 'invoice_form_screen.dart';

class InvoiceListScreen extends StatelessWidget {
  const InvoiceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clinic = context.watch<ClinicContextProvider>().selectedClinic;

    return Scaffold(
      appBar: AppBar(title: const Text('Billing')),
      drawer: const AppDrawer(currentRoute: '/billing'),
      floatingActionButton: clinic == null ? null : FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => InvoiceFormScreen(clinicId: clinic.id))),
        child: const Icon(Icons.add),
      ),
      body: clinic == null
          ? const EmptyState(icon: Icons.local_hospital_outlined, message: 'Select a clinic first.')
          : StreamBuilder<List<Invoice>>(
              stream: BillingService().streamForClinic(clinic.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final invoices = snapshot.data!;
                if (invoices.isEmpty) {
                  return const EmptyState(icon: Icons.receipt_long_outlined, message: 'No invoices yet. Tap + to create one.');
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: invoices.length,
                  itemBuilder: (context, i) {
                    final inv = invoices[i];
                    final color = inv.status == InvoiceStatus.paid ? Colors.green
                        : inv.status == InvoiceStatus.partial ? Colors.orange : Colors.red;
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.receipt_long_outlined),
                        title: Text(inv.patientName),
                        subtitle: Text('Total \$${inv.total.toStringAsFixed(2)} • Balance \$${inv.balance.toStringAsFixed(2)}'),
                        trailing: StatusChip(label: inv.status.name, color: color),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => InvoiceFormScreen(clinicId: clinic.id, existing: inv))),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
