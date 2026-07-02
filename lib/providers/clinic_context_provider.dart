import 'package:flutter/foundation.dart';
import '../models/clinic.dart';

/// Tracks which clinic the user is currently "inside" (relevant for admins
/// who manage multiple clinics and switch between them via a picker in the
/// dashboard app bar). Doctors/staff scoped to one clinic just get it
/// auto-selected.
class ClinicContextProvider extends ChangeNotifier {
  Clinic? selectedClinic;

  void selectClinic(Clinic clinic) {
    selectedClinic = clinic;
    notifyListeners();
  }

  void clear() {
    selectedClinic = null;
    notifyListeners();
  }
}
