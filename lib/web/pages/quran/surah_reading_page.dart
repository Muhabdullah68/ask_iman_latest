// lib/web/pages/quran/surah_reading_page.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — QURAN · SURAH READING (DEDICATED)
//
// Full-page surah reader for deep links like /quran/surah/2. Reuses the same
// bounded reading pane as the explorer so layout and audio stay consistent.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../core/theme/figma_tokens.dart';
import '../../../core/utils/seo_meta.dart';
import '../../../features/quran/data/surahs_data.dart';
import 'surah_explorer_web.dart';

class SurahReadingPage extends StatelessWidget {
  final int surahNum;
  const SurahReadingPage({super.key, required this.surahNum});

  @override
  Widget build(BuildContext context) {
    final n = surahNum.clamp(1, SurahsData.surahs.length);
    final meta = SurahsData.surahs[n - 1];
    setPageTitle(
      'Surah ${meta['name']} — ${meta['arabic']} · Ask Iman',
    );
    return Container(
      color: FigmaTokens.surfaceBackground,
      child: SurahReadingPane(surahNum: n),
    );
  }
}
