// lib/web/pages/quran/quran_tabs_web.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — QURAN · TALAWAT / TARJUMA SUB-TABS
//
// Talawat and Tarjuma share one concept: the 30 supara (juz) presented as a
// shelf of 3D-styled books. Talawat opens the Arabic reader at the juz start;
// Tarjuma opens the translation reader at the same spot. Both can kick off
// juz-wide recitation directly from the book's play badge.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/quran_audio_service.dart';
import '../../widgets/web_widgets.dart';
import 'juz_bookshelf_web.dart';
import 'juz_data.dart';

void _playJuzz(int juzNum) {
  final audio = QuranAudioService();
  audio.playJuzz(juzNum, 'Juz $juzNum', surahsInJuz(juzNum));
}

/// Talawat sub-tab — pick a supara to recite.
class TalawatTabWeb extends StatelessWidget {
  const TalawatTabWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const WebSectionHeader(
          eyebrow: 'Talawat',
          title: 'Recitation — Choose a Supara',
          subtitle:
              'Thirty juz, presented as a sacred shelf. Tap a book to recite '
              'from its opening verse.',
        ),
        const SizedBox(height: 26),
        JuzBookshelf(
          onSelectJuz: (juzNum, surah, ayah) =>
              context.go('/quran/surah/$surah?ayah=$ayah'),
          onPlayJuz: _playJuzz,
        ),
      ],
    );
  }
}

/// Tarjuma sub-tab — pick a supara to read with translation.
class TarjumaTabWeb extends StatelessWidget {
  const TarjumaTabWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const WebSectionHeader(
          eyebrow: 'Tarjuma',
          title: 'Translation — Choose a Supara',
          subtitle:
              'Read any juz with English and Urdu meaning, starting exactly '
              'where that supara begins.',
        ),
        const SizedBox(height: 26),
        JuzBookshelf(
          onSelectJuz: (juzNum, surah, ayah) =>
              context.go('/quran/surah/$surah?ayah=$ayah&mode=tarjuma'),
          onPlayJuz: _playJuzz,
        ),
      ],
    );
  }
}
