import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'providers/auth_provider.dart';
import 'providers/clinic_context_provider.dart';
import 'utils/theme.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/clinics/clinic_list_screen.dart';
import 'screens/patients/patient_list_screen.dart';
import 'screens/appointments/appointment_list_screen.dart';
import 'screens/billing/invoice_list_screen.dart';
import 'screens/inventory/inventory_list_screen.dart';
import 'screens/staff/staff_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ClinicApp());
}

class ClinicApp extends StatelessWidget {
  const ClinicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ClinicContextProvider()),
      ],
      child: MaterialApp(
        title: 'ClinicOS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _RootGate(),
        routes: {
          '/register': (_) => const RegisterScreen(),
          '/dashboard': (_) => const DashboardScreen(),
          '/clinics': (_) => const ClinicListScreen(),
          '/patients': (_) => const PatientListScreen(),
          '/appointments': (_) => const AppointmentListScreen(),
          '/billing': (_) => const InvoiceListScreen(),
          '/inventory': (_) => const InventoryListScreen(),
          '/staff': (_) => const StaffListScreen(),
        },
      ),
    );
  }
}

/// Decides Login vs Dashboard based on auth state, and shows a spinner
/// while the user's role/profile doc is loading (needed for the drawer
/// to know which menu items to show).
class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!auth.isSignedIn) {
      return const LoginScreen();
    }
    return const DashboardScreen();
  }
}
