import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

/// Holds the current Firebase auth user + their app profile (role, clinics).
/// Wrap the app with this provider so every screen can read role/clinic
/// access without re-fetching.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? firebaseUser;
  AppUser? appUser;
  bool loading = true;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? user) async {
    firebaseUser = user;
    if (user == null) {
      appUser = null;
      loading = false;
      notifyListeners();
      return;
    }
    _authService.userProfileStream(user.uid).listen((profile) {
      appUser = profile;
      loading = false;
      notifyListeners();
    });
  }

  bool get isSignedIn => firebaseUser != null;

  bool get isSuperAdmin => appUser?.role == UserRole.superAdmin;
  bool get isClinicAdmin => appUser?.role == UserRole.clinicAdmin;
  bool get isDoctor => appUser?.role == UserRole.doctor;
  bool get isStaff => appUser?.role == UserRole.staff;

  /// Clinics this user is allowed to act within. Super admin sees everything
  /// (handled at the query layer via streamAllClinics instead of this list).
  List<String> get accessibleClinicIds => appUser?.clinicIds ?? [];

  Future<void> signIn(String email, String password) =>
      _authService.signIn(email, password);

  Future<void> registerClinicAdmin(String name, String email, String password) =>
      _authService.registerClinicAdmin(name: name, email: email, password: password);

  Future<void> signOut() => _authService.signOut();
}
