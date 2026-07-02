import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_user.dart';
import '../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;
  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.appUser;

    final items = <_NavItem>[
      _NavItem('Dashboard', Icons.dashboard_outlined, '/dashboard'),
      if (auth.isSuperAdmin) _NavItem('Clinics', Icons.local_hospital_outlined, '/clinics'),
      _NavItem('Patients', Icons.people_outline, '/patients'),
      _NavItem('Appointments', Icons.calendar_month_outlined, '/appointments'),
      _NavItem('Billing', Icons.receipt_long_outlined, '/billing'),
      _NavItem('Inventory', Icons.inventory_2_outlined, '/inventory'),
      if (auth.isSuperAdmin || auth.isClinicAdmin)
        _NavItem('Staff', Icons.badge_outlined, '/staff'),
    ];

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Theme.of(context).colorScheme.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.teal, size: 28),
                  ),
                  const SizedBox(height: 10),
                  Text(user?.name ?? '', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(_roleLabel(user?.role), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: items
                    .map((item) => ListTile(
                          leading: Icon(item.icon),
                          title: Text(item.label),
                          selected: currentRoute == item.route,
                          onTap: () {
                            Navigator.pop(context);
                            if (currentRoute != item.route) {
                              Navigator.pushReplacementNamed(context, item.route);
                            }
                          },
                        ))
                    .toList(),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sign out', style: TextStyle(color: Colors.red)),
              onTap: () => context.read<AuthProvider>().signOut(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _roleLabel(UserRole? role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'Platform Admin';
      case UserRole.clinicAdmin:
        return 'Clinic Admin';
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.staff:
        return 'Staff';
      default:
        return '';
    }
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  _NavItem(this.label, this.icon, this.route);
}
