// lib/features/quran/tabs/ayah_tab.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════════════════════
// AYAH TAB — matches Ayah_page.png exactly
// ══════════════════════════════════════════════════════════════════════════════
class AyahTab extends StatefulWidget {
  const AyahTab({super.key});
  @override
  State<AyahTab> createState() => _AyahTabState();
}

class _AyahTabState extends State<AyahTab> {
  int _topicIndex = 0;
  final _topics = ['Mercy', 'Patience', 'Tawbah'];

  // All ayahs with topic tagging
  static const List<Map<String, String>> _allAyahs = [
    {
      'ref':         'SURAH AL-BAQARAH 2:286',
      'arabic':      'لَا يُكَلِّفُ اللَّهُ نَفۡسًا إِلَّا وُسۡعَهَا',
      'translation': '"Allah does not charge a soul except [with that within] its capacity."',
      'topic':       'Patience',
    },
    {
      'ref':         'SURAH ASH-SHARH 94:5',
      'arabic':      'فَإِنَّ مَعَ الۡعُسۡرِ يُسۡرًا',
      'translation': '"For indeed, with hardship [will be] ease."',
      'topic':       'Patience',
    },
    {
      'ref':         'SURAH AZ-ZUMAR 39:53',
      'arabic':      'قُلۡ يَٰعِبَادِيَ الَّذِينَ أَسۡرَفُواْ عَلَىٰٓ أَنفُسِهِمۡ لَا تَقۡنَطُواْ مِن رَّحۡمَةِ اللَّهِ إِنَّ اللَّهَ يَغۡفِرُ الذُّنُوبَ جَمِيعًا إِنَّهُۥ هُوَ الۡغَفُورُ الرَّحِيمُ',
      'translation': '"Say, \'O My servants who have transgressed against themselves [by sinning], do not despair of the mercy of Allah. Indeed, Allah forgives all sins. Indeed, it is He who is the Forgiving, the Merciful.\'"',
      'topic':       'Tawbah',
    },
    {
      'ref':         'SURAH AR-RAHMAN 55:13',
      'arabic':      'فَبِأَيِّ ءَالَآءِ رَبِّكُمَا تُكَذِّبَانِ',
      'translation': '"So which of the favors of your Lord would you deny?"',
      'topic':       'Mercy',
    },
    {
      'ref':         'SURAH AL-ANBIYA 21:107',
      'arabic':      'وَمَآ أَرۡسَلۡنَٰكَ إِلَّا رَحۡمَةً لِّلۡعَٰلَمِينَ',
      'translation': '"And We have not sent you, [O Muhammad], except as a mercy to the worlds."',
      'topic':       'Mercy',
    },
    {
      'ref':         'SURAH AL-BAQARAH 2:153',
      'arabic':      'يَٰٓأَيُّهَا الَّذِينَ ءَامَنُواْ اسۡتَعِينُواْ بِالصَّبۡرِ وَالصَّلَوٰةِ إِنَّ اللَّهَ مَعَ الصَّٰبِرِينَ',
      'translation': '"O you who have believed, seek help through patience and prayer. Indeed, Allah is with the patient."',
      'topic':       'Patience',
    },
    {
      'ref':         'SURAH AL-BAQARAH 2:222',
      'arabic':      'إِنَّ اللَّهَ يُحِبُّ التَّوَّٰبِينَ وَيُحِبُّ الۡمُتَطَهِّرِينَ',
      'translation': '"Indeed, Allah loves those who are constantly repentant and loves those who purify themselves."',
      'topic':       'Tawbah',
    },
  ];

  List<Map<String, String>> get _filtered {
    final t = _topics[_topicIndex];
    return _allAyahs.where((a) => a['topic'] == t).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroBanner(),
          _buildTopicFilter(),
          ..._filtered.map(_buildAyahCard),
          _buildDeepDiveBanner(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── "Words of Allah" dark hero banner ─────────────────────────────────────
  Widget _buildHeroBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image with warm light
              Image.asset(
                'assets/images/mosque.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2D5A3D), Color(0xFF0D2818)],
                    ),
                  ),
                ),
              ),
              // Dark overlay
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x44000000), Color(0xBB0D2818)],
                  ),
                ),
              ),
              // Text content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Words of Allah',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Find solace and guidance in the\ndivine revelations of the Noble\nQuran.',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppColors.textCream,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── "Explore by Topic" chips ───────────────────────────────────────────────
  Widget _buildTopicFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explore by Topic',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(_topics.length, (i) {
              final active = _topicIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _topicIndex = i),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 9),
                  decoration: BoxDecoration(
                    color: active ? AppColors.gold : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color:
                      active ? AppColors.gold : AppColors.borderLight,
                    ),
                  ),
                  child: Text(
                    _topics[i],
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: active
                          ? AppColors.primaryDarkest
                          : AppColors.textGrey,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Individual Ayah card — white card matching design ─────────────────────
  Widget _buildAyahCard(Map<String, String> a) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Reference badge + action icons row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    a['ref']!,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.goldDark,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.bookmark_outline,
                    size: 18, color: AppColors.textGrey),
                const SizedBox(width: 10),
                const Icon(Icons.share_outlined,
                    size: 18, color: AppColors.textGrey),
              ],
            ),
          ),
          // Arabic text
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
            child: Text(
              a['arabic']!,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 26,
                color: AppColors.textDark,
                height: 2.0,
              ),
            ),
          ),
          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(height: 1, color: AppColors.borderLight),
          ),
          // Translation
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
            child: Text(
              a['translation']!,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: AppColors.textGrey,
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── "Deepen Your Connection" dark CTA banner ──────────────────────────────
  Widget _buildDeepDiveBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primaryDarkest],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Deepen Your\nConnection',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.gold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Access our full library of tafsir, word-by-word translations, and high-quality recitations.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppColors.textCream,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Text(
              'Explore Full Quran',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDarkest,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
