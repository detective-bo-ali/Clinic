import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

/// Wraps Firebase Auth + the corresponding /users/{uid} profile doc
/// which stores role + clinic membership (used for all access control).
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentFirebaseUser => _auth.currentUser;

  Future<AppUser?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(uid, doc.data()!);
  }

  Stream<AppUser?> userProfileStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map(
          (doc) => doc.exists ? AppUser.fromMap(uid, doc.data()!) : null,
        );
  }

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Registers a brand-new account. By default new self-signups become
  /// `clinicAdmin` (they then create their own clinic). Staff/doctor accounts
  /// are normally created BY a clinicAdmin via `createStaffAccount` instead,
  /// so they're scoped into an existing clinic from the start.
  Future<UserCredential> registerClinicAdmin({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _db.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email,
      'role': UserRole.clinicAdmin.name,
      'clinicIds': <String>[],
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return cred;
  }

  /// Used by a clinicAdmin to add a doctor/staff member to their clinic.
  /// NOTE: creating another user's Auth account from a logged-in client
  /// requires either Firebase Admin SDK (Cloud Function) or a secondary
  /// FirebaseApp instance, since `createUserWithEmailAndPassword` signs in
  /// as the new user. For production, move this into a Cloud Function
  /// (e.g. `createStaffAccount` callable) — stubbed here for the client call.
  Future<void> createStaffProfileDoc({
    required String uid,
    required String name,
    required String email,
    required UserRole role,
    required List<String> clinicIds,
    String? specialty,
    String? phone,
  }) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'role': role.name,
      'clinicIds': clinicIds,
      'specialty': specialty,
      'phone': phone,
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);
}
