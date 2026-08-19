// lib/core/utils/seo_meta.dart
// ─────────────────────────────────────────────────────────────────────────────
// SEO — per-route <title> helper (changes.txt Phase 3.4)
//
// On Flutter Web this swaps to `seo_meta_web.dart` which writes a descriptive
// page title into `document.title`, so each screen shows a meaningful browser
// tab title / history entry (Home · Quran · Ibadah · Community · Profile …).
// On native platforms the stub is a no-op.
// ─────────────────────────────────────────────────────────────────────────────

import 'seo_meta_stub.dart'
    if (dart.library.html) 'seo_meta_web.dart';

/// Set the browser tab title for the current route.
///
/// Safe to call from any screen's `initState`. No-op on mobile builds.
void setPageTitle(String title) => setTitle(title);
