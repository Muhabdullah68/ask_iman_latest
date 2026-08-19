// lib/core/utils/seo_meta_web.dart
// ─────────────────────────────────────────────────────────────────────────────
// SEO — Flutter Web implementation. Writes a descriptive per-route <title>
// into `document.title` so browser tabs, history and search engines see a
// meaningful title for each page (changes.txt Phase 3.4).
// ─────────────────────────────────────────────────────────────────────────────

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

void setTitle(String title) {
  try {
    if (html.document.title != title) {
      html.document.title = title;
    }
  } catch (_) {
    // Silently swallow — failing to set a title is non-critical.
  }
}
