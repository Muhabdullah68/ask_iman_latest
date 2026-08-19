// lib/web/pages/quran/web_quran_tab.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — QURAN EXPLORER TABS (5 tabs per spec)
//
// Each tab maps to a real URL under /quran so deep links, back/forward and
// the top pill navigation all stay in sync. Spec icons match the Figma
// design: hearing (Talawat), translate (Tarjuma), menu_book (Tafseer),
// text_fields (Settings), share (Share).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

enum WebQuranTab {
  talawat('Talawat', Icons.hearing_rounded, '/talawat'),
  tarjuma('Tarjuma', Icons.translate_rounded, '/tarjuma'),
  tafseer('Tafseer', Icons.menu_book_rounded, '/tafseer'),
  settings('Settings', Icons.text_fields_rounded, '/settings'),
  share('Share', Icons.share_rounded, '/share');

  final String label;
  final IconData icon;
  final String path;

  const WebQuranTab(this.label, this.icon, this.path);

  /// Maps a URL path segment (e.g. "talawat", "tarjuma") back to a tab.
  static WebQuranTab fromPath(String? segment) {
    return WebQuranTab.values.firstWhere(
      (t) => t.path == '/$segment',
      orElse: () => WebQuranTab.talawat,
    );
  }
}
