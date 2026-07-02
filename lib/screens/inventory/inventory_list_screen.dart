import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/inventory_item.dart';
import '../../providers/clinic_context_provider.dart';
import '../../services/inventory_service.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/empty_state.dart';
import 'inventory_form_screen.dart';

class InventoryListScreen extends StatelessWidget {
  const InventoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clinic = context.watch<ClinicContextProvider>().selectedClinic;
    final service = InventoryService();

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      drawer: const AppDrawer(currentRoute: '/inventory'),
      floatingActionButton: clinic == null ? null : FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => InventoryFormScreen(clinicId: clinic.id))),
        child: const Icon(Icons.add),
      ),
      body: clinic == null
          ? const EmptyState(icon: Icons.local_hospital_outlined, message: 'Select a clinic first.')
          : StreamBuilder<List<InventoryItem>>(
              stream: service.streamForClinic(clinic.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final items = snapshot.data!;
                if (items.isEmpty) {
                  return const EmptyState(icon: Icons.inventory_2_outlined, message: 'No inventory items yet.');
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return Card(
                      color: item.isLowStock ? Colors.red.shade50 : null,
                      child: ListTile(
                        leading: Icon(Icons.inventory_2_outlined, color: item.isLowStock ? Colors.red : Colors.teal),
                        title: Text(item.name),
                        subtitle: Text('${item.quantity} ${item.unit} • Reorder at ${item.reorderLevel} • ${item.supplier}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => service.adjustQuantity(item.id, -1)),
                            IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => service.adjustQuantity(item.id, 1)),
                          ],
                        ),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => InventoryFormScreen(clinicId: clinic.id, existing: item))),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
