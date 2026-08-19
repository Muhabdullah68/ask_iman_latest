// lib/web/web_firebase.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — Firebase availability helpers
//
// The website runs even before real Firebase web keys are supplied. These
// helpers let widgets degrade gracefully instead of throwing the dreaded
// "No Firebase App '[DEFAULT]' has been created" error mid-frame.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// True when a default Firebase app object exists (initializeApp succeeded).
bool get webFirebaseReady => Firebase.apps.isNotEmpty;

/// Safe [FirebaseAuth] accessor — returns null when Firebase is not set up.
FirebaseAuth? get webAuth {
  if (!webFirebaseReady) return null;
  try {
    return FirebaseAuth.instance;
  } catch (_) {
    return null;
  }
}

/// Auth state stream that never throws. When Firebase is unavailable it
/// emits a single `null` (signed-out) so the UI falls back to guest mode.
Stream<User?> webAuthStateChanges() async* {
  final auth = webAuth;
  if (auth == null) {
    yield null;
    return;
  }
  try {
    yield* auth.authStateChanges();
  } catch (_) {
    yield null;
  }
}

/// Reads the current user without throwing when Firebase is unavailable.
User? webCurrentUser() {
  final auth = webAuth;
  if (auth == null) return null;
  try {
    return auth.currentUser;
  } catch (_) {
    return null;
  }
}
