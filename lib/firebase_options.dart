// lib/firebase_options.dart
// ─────────────────────────────────────────────────────────────────────────────
// FIREBASE OPTIONS — Multi-platform configuration
//
// This file is the SINGLE source of truth for Firebase SDK initialization on
// every platform (Android, iOS, macOS, Web, Windows, Linux).
//
// HOW TO POPULATE THIS FILE (for the project maintainer):
//   Run the FlutterFire CLI from the project root:
//       dart pub global activate flutterfire_cli
//       flutterfire configure \
//         --project=<YOUR_FIREBASE_PROJECT_ID> \
//         --out=lib/firebase_options.dart
//
//   The CLI will overwrite every field below with REAL values from Firebase
//   Console: apiKey, appId, messagingSenderId, authDomain, databaseURL,
//   storageBucket, measurementId — exactly as required by changes.txt §0.2
//   ("Validate firebase_options.dart has web options").
//
// The values below are SAFE PLACEHOLDERS so the project compiles / the web
// build can proceed. When the real values are supplied (via flutterfire CLI
// or manual paste), `Firebase.initializeApp(options: DefaultFirebaseOptions.
// currentPlatform)` in main.dart will connect to the live project.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

/// Default [FirebaseOptions] for all supported Flutter target platforms.
///
/// Usage (in main.dart):
/// ```dart
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  // ── Web (Flutter Web / WASM / JS) ───────────────────────────────────────
  // §0.2 of changes.txt requires these fields be populated from Firebase
  // Console > Add Web App: apiKey, appId, messagingSenderId, authDomain,
  // databaseURL (if RTDB used), storageBucket, measurementId.
  static FirebaseOptions get webPlatform => const FirebaseOptions(
    apiKey: 'PASTE_FIREBASE_WEB_API_KEY_HERE',
    appId: 'PASTE_FIREBASE_WEB_APP_ID_HERE',
    messagingSenderId: 'PASTE_FIREBASE_SENDER_ID_HERE',
    projectId: 'PASTE_FIREBASE_PROJECT_ID_HERE',
    authDomain: 'PASTE_FIREBASE_AUTH_DOMAIN_HERE',
    databaseURL: 'PASTE_FIREBASE_DATABASE_URL_HERE',
    storageBucket: 'PASTE_FIREBASE_STORAGE_BUCKET_HERE',
    measurementId: 'PASTE_FIREBASE_MEASUREMENT_ID_HERE',
  );

  // ── Android (Google Play) ──────────────────────────────────────────────
  // Values come from android/app/google-services.json
  static FirebaseOptions get androidPlatform => const FirebaseOptions(
    apiKey: 'PASTE_ANDROID_API_KEY_HERE',
    appId: 'PASTE_ANDROID_APP_ID_HERE',
    messagingSenderId: 'PASTE_SENDER_ID_HERE',
    projectId: 'PASTE_PROJECT_ID_HERE',
    storageBucket: 'PASTE_STORAGE_BUCKET_HERE',
  );

  // ── iOS / macOS (Apple platforms) ──────────────────────────────────────
  // Values come from ios/Runner/GoogleService-Info.plist and
  // macos/Runner/GoogleService-Info.plist respectively.
  static FirebaseOptions get iosPlatform => const FirebaseOptions(
    apiKey: 'PASTE_IOS_API_KEY_HERE',
    appId: 'PASTE_IOS_APP_ID_HERE',
    messagingSenderId: 'PASTE_SENDER_ID_HERE',
    projectId: 'PASTE_PROJECT_ID_HERE',
    storageBucket: 'PASTE_STORAGE_BUCKET_HERE',
    iosBundleId: 'PASTE_IOS_BUNDLE_ID_HERE',
  );

  static FirebaseOptions get macosPlatform => const FirebaseOptions(
    apiKey: 'PASTE_MACOS_API_KEY_HERE',
    appId: 'PASTE_MACOS_APP_ID_HERE',
    messagingSenderId: 'PASTE_SENDER_ID_HERE',
    projectId: 'PASTE_PROJECT_ID_HERE',
    storageBucket: 'PASTE_STORAGE_BUCKET_HERE',
    iosBundleId: 'PASTE_MACOS_BUNDLE_ID_HERE',
  );

  // ── Windows / Linux (Desktop, no native Firebase SDK support) ──────────
  // Uses the Web API key / REST endpoint path; for now fallback to the
  // shared placeholder values below and override only when Windows/Linux
  // client SDKs are required.
  static FirebaseOptions get windowsPlatform => webPlatform;
  static FirebaseOptions get linuxPlatform   => webPlatform;

  /// Returns the correct [FirebaseOptions] for the currently-compiling
  /// target platform.
  ///
  /// On Web the choice is unambiguous. For native platforms we switch on
  /// [defaultTargetPlatform]. Unknown platforms fall back to [webPlatform]
  /// as the broadest-compatible configuration (REST-based APIs work across
  /// all targets).
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return webPlatform;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return androidPlatform;
      case TargetPlatform.iOS:     return iosPlatform;
      case TargetPlatform.macOS:   return macosPlatform;
      case TargetPlatform.windows: return windowsPlatform;
      case TargetPlatform.linux:   return linuxPlatform;
      case TargetPlatform.fuchsia:
        return webPlatform;
    }
  }
}
