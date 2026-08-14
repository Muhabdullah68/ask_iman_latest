// lib/admin_meta_stub.dart
// ─────────────────────────────────────────────────────────────────────────────
// META TAG GUARD — Mobile / non-Web stub (no-op implementation)
//
// This file is imported on platforms WITHOUT dart:html (Android, iOS, macOS,
// Windows, Linux). Since these platforms have no web crawlers or meta tags to
// manipulate, every method is an intentional no-op.
//
// The conditional import in main.dart swaps this file with `admin_meta_web.dart`
// automatically when the app is compiled for Flutter Web.
// ─────────────────────────────────────────────────────────────────────────────

/// Stub guard — does nothing on non-web platforms.
///
/// Exists only to satisfy the shared interface contract used by the
/// `_AdminGateWidgetState` lifecycle in `main.dart`.
class AdminMetaWebGuard {
  /// No-op on mobile: no meta tags to manipulate.
  static void applyNoIndex() {}

  /// No-op on mobile: nothing was changed so nothing to restore.
  static void restoreIndex() {}
}
