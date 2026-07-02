# ClinicOS — Multi-Clinic Management System (Flutter + Firebase)

A full-suite clinic management app: patients, appointments, prescriptions,
billing/invoices, inventory, and staff — scoped across multiple clinics with
role-based access (Super Admin / Clinic Admin / Doctor / Staff).

## 1. Setup

```bash
flutter create --org com.yourcompany clinic_app_tmp   # only if you need a fresh shell
# then copy this lib/, pubspec.yaml, firestore.rules into your project, OR
# just `flutter pub get` directly inside this folder if it already has
# android/ios platform folders (run `flutter create .` here once to add them).

flutter pub get

# Connect to YOUR Firebase project (replaces lib/firebase_options.dart):
dart pub global activate flutterfire_cli
flutterfire configure
```

In the Firebase console, enable:
- **Authentication** → Email/Password sign-in method
- **Firestore Database** → start in production mode
- **Storage** (optional, for patient documents/photos later)

Deploy security rules:
```bash
firebase deploy --only firestore:rules
```

Run the app:
```bash
flutter run
```

## 2. First-run flow

1. Open the app → tap **"New clinic? Create an admin account"** → register.
   This creates a `clinicAdmin` user.
2. You'll land on the Dashboard with no clinic yet → go to **Clinics** (drawer)
   → tap **+** → create your first clinic. It's auto-attached to your account.
3. Go to **Staff** → invite doctors/receptionists (see note below on wiring
   this to a Cloud Function before production use).
4. Use **Patients**, **Appointments**, **Billing**, **Inventory** as normal.

## 3. Architecture

- **State management:** `provider`. `AuthProvider` exposes the signed-in
  Firebase user + their `/users/{uid}` profile (role, clinicIds).
  `ClinicContextProvider` tracks which clinic is "active" in the UI (the
  dropdown in the dashboard app bar) — relevant for admins managing several
  clinics.
- **Data model:** Firestore, mostly top-level collections (`patients`,
  `appointments`, `prescriptions`, `invoices`, `inventory`, `clinics`,
  `users`), each clinical doc carrying a `clinicId` field. This keeps
  cross-clinic queries (super admin dashboards/reporting) simple while
  `firestore.rules` enforces that non-super-admins only touch documents
  whose `clinicId` is in their own `clinicIds` array.
- **Roles:** `superAdmin` (you, sees all clinics), `clinicAdmin` (owns/manages
  one or more clinics — full CRUD + staff management), `doctor` (their own
  appointments/patients/prescriptions), `staff` (front-desk: patients,
  appointments, billing).

## 4. Important production TODOs

- **Staff invites:** `StaffFormScreen` currently just shows a placeholder
  snackbar. Creating another user's Auth account from a logged-in client
  isn't possible with the client SDK (it would sign the admin out and into
  the new account). Implement an `inviteStaff` **Cloud Function** using the
  Admin SDK that: creates the Auth user, writes their `/users/{uid}` doc with
  role + clinicIds, and emails them a temp password or reset link. Call it
  via `cloud_functions` from the form instead.
- **Patient/Doctor pickers:** `AppointmentFormScreen` and `InvoiceFormScreen`
  take patient/doctor IDs as plain text for simplicity. Swap in a search
  picker backed by `PatientService` / `StaffService` (filtered to role ==
  doctor) before shipping.
- **PDF export:** `pdf` + `printing` packages are already in `pubspec.yaml`
  for generating/printing prescriptions and invoices — add a "Print" button
  that builds a `pw.Document` from the `Prescription`/`Invoice` models.
- **Reporting at scale:** `BillingService.totalCollectedThisMonth` queries
  live; once you have meaningful volume, move rollups to a scheduled Cloud
  Function that writes aggregates to `/clinics/{id}/stats`.
- **Search at scale:** `PatientService.searchPatients` filters client-side.
  Fine for hundreds of patients; swap for Algolia/Typesense (synced via a
  Firestore trigger) once clinics have thousands.

## 5. Folder structure

```
lib/
  models/        Plain Dart classes mirroring Firestore docs (toMap/fromDoc)
  services/      One class per collection — all Firestore reads/writes live here
  providers/     AuthProvider, ClinicContextProvider (provider package)
  screens/       auth/ dashboard/ clinics/ patients/ appointments/ billing/ inventory/ staff/
  widgets/       Shared UI: AppDrawer, ClinicPicker, StatusChip, EmptyState
  utils/         Theme, form validators
firestore.rules  Role + clinic-scoped security rules
```
