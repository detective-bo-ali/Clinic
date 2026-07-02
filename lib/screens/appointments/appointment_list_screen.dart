import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/appointment.dart';
import '../../providers/clinic_context_provider.dart';
import '../../services/appointment_service.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_chip.dart';
import 'appointment_form_screen.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});
  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final clinic = context.watch<ClinicContextProvider>().selectedClinic;

    return Scaffold(
      appBar: AppBar(title: const Text('Appointments')),
      drawer: const AppDrawer(currentRoute: '/appointments'),
      floatingActionButton: clinic == null ? null : FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => AppointmentFormScreen(clinicId: clinic.id, initialDate: _selectedDay))),
        child: const Icon(Icons.add),
      ),
      body: clinic == null
          ? const EmptyState(icon: Icons.local_hospital_outlined, message: 'Select a clinic first.')
          : Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: CalendarFormat.week,
                  onDaySelected: (selected, focused) {
                    setState(() { _selectedDay = selected; _focusedDay = focused; });
                  },
                  headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                ),
                const Divider(height: 1),
                Expanded(
                  child: StreamBuilder<List<Appointment>>(
                    stream: AppointmentService().streamForDay(clinic.id, _selectedDay),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final appts = snapshot.data!;
                      if (appts.isEmpty) {
                        return const EmptyState(icon: Icons.event_busy, message: 'No appointments on this day.');
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: appts.length,
                        itemBuilder: (context, i) {
                          final a = appts[i];
                          final color = a.status == AppointmentStatus.completed ? Colors.green
                              : a.status == AppointmentStatus.cancelled ? Colors.red
                              : a.status == AppointmentStatus.noShow ? Colors.grey : Colors.blue;
                          return Card(
                            child: ListTile(
                              leading: Text(
                                '${a.dateTime.hour.toString().padLeft(2, '0')}:${a.dateTime.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              title: Text(a.patientName),
                              subtitle: Text('Dr. ${a.doctorName} • ${a.reason}'),
                              trailing: StatusChip(label: a.status.name, color: color),
                              onTap: () => Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => AppointmentFormScreen(clinicId: clinic.id, existing: a))),
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
