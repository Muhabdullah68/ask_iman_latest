// lib/web/pages/quran/surah_reading_page.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — QURAN · SURAH READING (DEDICATED)
//
// Full-page surah reader for deep links like /quran/surah/2. Includes a slim
// back-nav bar, the reading pane, and a sticky audio bar at the bottom.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/figma_tokens.dart';
import '../../../core/utils/seo_meta.dart';
import '../../../features/quran/data/surahs_data.dart';
import 'audio_bar_web.dart';
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
      child: Column(
        children: [
          Container(
            color: FigmaTokens.brandDeepGreen,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => context.go('/quran'),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_back_rounded,
                              size: 17,
                              color: FigmaTokens.accentGoldLight,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Back to Quran',
                              style: TextStyle(
                                fontFamily: FigmaTokens.fontFamilyUiSans,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: FigmaTokens.accentGoldLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${meta['name']}  ${meta['arabic']}',
                        style: const TextStyle(
                          fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: FigmaTokens.textOnDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SurahReadingPane(surahNum: n),
          ),
          const QuranAudioBar(),
        ],
      ),
    );
  }
}
