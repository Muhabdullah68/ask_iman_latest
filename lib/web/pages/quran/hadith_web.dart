// lib/web/pages/quran/hadith_web.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — QURAN · AHADITH LIBRARY
//
// Six-book authentic hadith library. /quran/hadith shows elegant stylized book
// covers; each cover opens /quran/hadith/:slug with the book's hadiths backed
// by AhadeesData (Bukhari, Muslim, Tirmidhi, Abu Dawud, Nasai, Ibn Majah).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/figma_tokens.dart';
import '../../../core/utils/seo_meta.dart';
import '../../../features/quran/data/ahadees_data.dart';
import '../../widgets/web_footer.dart';
import '../../widgets/web_ornaments.dart';
import '../../widgets/web_tilt3d.dart';
import '../../widgets/web_widgets.dart';

const List<String> kHadithBookSlugs = [
  'bukhari',
  'muslim',
  'tirmidhi',
  'abu-dawud',
  'nasai',
  'ibn-majah',
];

const Map<String, String> _bookArabic = {
  'bukhari':
      '\u0635\u062d\u064a\u062d \u0627\u0644\u0628\u062e\u0627\u0631\u064a',
  'muslim': '\u0635\u062d\u064a\u062d \u0645\u0633\u0644\u0645',
  'tirmidhi':
      '\u062c\u0627\u0645\u0639 \u0627\u0644\u062a\u0631\u0645\u0630\u064a',
  'abu-dawud': '\u0633\u0646\u0646 \u0623\u0628\u064a \u062f\u0627\u0648\u062f',
  'nasai': '\u0633\u0646\u0646 \u0627\u0644\u0646\u0633\u0627\u0626\u064a',
  'ibn-majah': '\u0633\u0646\u0646 \u0627\u0628\u0646 \u0645\u0627\u062c\u0647',
};

const List<List<Color>> _coverPalettes = [
  [Color(0xFF14532D), Color(0xFF0B3D22)],
  [Color(0xFF0F3A5F), Color(0xFF0A2540)],
  [Color(0xFF7A4A12), Color(0xFF54310A)],
  [Color(0xFF5B1E3A), Color(0xFF3A1225)],
  [Color(0xFF374151), Color(0xFF1F2937)],
  [Color(0xFF275E3F), Color(0xFF17402A)],
];

String _bookName(String slug) {
  switch (slug) {
    case 'bukhari':
      return 'Sahih al-Bukhari';
    case 'muslim':
      return 'Sahih Muslim';
    case 'tirmidhi':
      return 'Jami at-Tirmidhi';
    case 'abu-dawud':
      return 'Sunan Abu Dawud';
    case 'nasai':
      return 'Sunan an-Nasai';
    case 'ibn-majah':
      return 'Sunan Ibn Majah';
    default:
      return 'Sahih al-Bukhari';
  }
}

String _bookBlurb(String slug) {
  switch (slug) {
    case 'bukhari':
      return 'The most authentic book after the Quran';
    case 'muslim':
      return 'Second of the six canonical collections';
    case 'tirmidhi':
      return 'Compiled by Abu Isa at-Tirmidhi';
    case 'abu-dawud':
      return 'Focused on jurisprudence and rulings';
    case 'nasai':
      return 'Known for precise chains of narration';
    case 'ibn-majah':
      return 'The final of the six sunan collections';
    default:
      return 'Authentic hadith collection';
  }
}

// ── Library ──────────────────────────────────────────────────────────────────
class HadithLibraryPage extends StatelessWidget {
  const HadithLibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    setPageTitle('Authentic Hadith Library \u00b7 Ask Iman');
    return Container(
      color: figma.surfaceBackground,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 480),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 48,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const WebSectionHeader(
                      eyebrow: 'Ahadith',
                      title: 'Authentic Hadith Library',
                      subtitle:
                          'Six canonical collections of the Prophet\'s '
                          'traditions \u2014 Sahih al-Bukhari, Sahih Muslim, '
                          'Jami at-Tirmidhi, Sunan Abu Dawud, Sunan an-Nasai '
                          'and Sunan Ibn Majah.',
                    ),
                    const SizedBox(height: 36),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cols = constraints.maxWidth >= 1020
                            ? 3
                            : constraints.maxWidth >= 720
                            ? 2
                            : 1;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: kHadithBookSlugs.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cols,
                                mainAxisSpacing: 28,
                                crossAxisSpacing: 28,
                                childAspectRatio: 1.55,
                              ),
                          itemBuilder: (context, i) => _BookCover(
                            slug: kHadithBookSlugs[i],
                            index: i,
                            onTap: () => context.go(
                              '/quran/hadith/${kHadithBookSlugs[i]}',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 56),
                    const WebFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  final String slug;
  final int index;
  final VoidCallback onTap;
  const _BookCover({
    required this.slug,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    final palette = _coverPalettes[index % _coverPalettes.length];
    return Tilt3D(
      borderRadius: BorderRadius.circular(18),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: palette,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: figma.accentGoldAmber.withValues(alpha: 0.55),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(child: _BookSpine()),
                    const Spacer(),
                    const CrescentOrnament(size: 16),
                  ],
                ),
                const Spacer(),
                Text(
                  _bookArabic[slug] ?? '',
                  textDirection: TextDirection.rtl,
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                  ),
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyArabicSerif,
                    fontSize: 19,
                    height: 1.35,
                    color: figma.accentGoldLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _bookName(slug),
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: FigmaTokens.textOnDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _bookBlurb(slug),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 12.5,
                    height: 1.45,
                    color: FigmaTokens.textOnDark.withValues(alpha: 0.78),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      'READ \u2022 100 HADITHS',
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyUiSans,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                        color: figma.accentGoldAmber,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: figma.accentGoldAmber,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BookSpine extends StatelessWidget {
  const _BookSpine();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                FigmaTokens.ornamentGold.withValues(alpha: 0.1),
                FigmaTokens.ornamentGold.withValues(alpha: 0.55),
                FigmaTokens.ornamentGold.withValues(alpha: 0.1),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 28,
          height: 2,
          color: FigmaTokens.ornamentGold.withValues(alpha: 0.5),
        ),
      ],
    );
  }
}

// ── Book reader ──────────────────────────────────────────────────────────────
class HadithBookPage extends StatelessWidget {
  final String slug;
  const HadithBookPage({super.key, required this.slug});

  String get _resolved => kHadithBookSlugs.contains(slug) ? slug : 'bukhari';
  String get _name => _bookName(_resolved);

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    final hadiths = AhadeesData.getBookHadiths(_resolved);
    setPageTitle('$_name \u00b7 Ask Iman');
    return Container(
      color: figma.surfaceBackground,
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
                        onTap: () => context.go('/quran/hadith'),
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
                              'Library',
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
                        _bookArabic[_resolved] ?? '',
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontFamily: FigmaTokens.fontFamilyArabicSerif,
                          fontSize: 15,
                          color: FigmaTokens.textOnDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _name,
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 22,
                          ),
                          decoration: BoxDecoration(
                            gradient: FigmaTokens.heroGradientLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: figma.borderHairline),
                          ),
                          child: Row(
                            children: [
                              GoldIconBadge(
                                icon: Icons.menu_book_rounded,
                                size: 54,
                                iconSize: 26,
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _name,
                                      style: TextStyle(
                                        fontFamily:
                                            FigmaTokens.fontFamilyDisplaySerif,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: figma.textHeading,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${hadiths.length} hadiths \u00b7 '
                                      '${_bookBlurb(_resolved)}',
                                      style: TextStyle(
                                        fontFamily:
                                            FigmaTokens.fontFamilyUiSans,
                                        fontSize: 13,
                                        color: figma.textBody,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                _bookArabic[_resolved] ?? '',
                                textDirection: TextDirection.rtl,
                                textHeightBehavior: const TextHeightBehavior(
                                  applyHeightToFirstAscent: false,
                                  applyHeightToLastDescent: false,
                                ),
                                style: TextStyle(
                                  fontFamily: FigmaTokens.fontFamilyArabicSerif,
                                  fontSize: 20,
                                  height: 1.4,
                                  color: FigmaTokens.brandDeepGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        ...List.generate(hadiths.length, (i) {
                          final h = hadiths[i];
                          final isLast = i == hadiths.length - 1;
                          return _HadithCard(
                            number: h['number'] ?? '${i + 1}',
                            arabic: h['arabic'] ?? '',
                            english: h['id'] ?? '',
                            last: isLast,
                          );
                        }),
                        const SizedBox(height: 56),
                        const WebFooter(),
                        const SizedBox(height: 72),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HadithCard extends StatelessWidget {
  final String number;
  final String arabic;
  final String english;
  final bool last;
  const _HadithCard({
    required this.number,
    required this.arabic,
    required this.english,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      decoration: BoxDecoration(
        color: figma.surfaceBackground,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCardSm),
        border: Border.all(color: figma.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: figma.accentGoldSurface,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Hadith $number',
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: figma.accentGoldAmber,
                  ),
                ),
              ),
              const Spacer(),
              const CrescentOrnament(size: 16),
            ],
          ),
          const SizedBox(height: 14),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              arabic,
              textAlign: TextAlign.right,
              softWrap: true,
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
              style: TextStyle(
                fontFamily: FigmaTokens.fontFamilyArabicMushaf,
                fontSize: 21,
                height: 1.9,
                color: figma.textHeading,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(
              height: 1,
              thickness: 1,
              color: figma.borderHairline,
            ),
          ),
          Text(
            english,
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 14.5,
              height: 1.65,
              color: figma.textBody,
            ),
          ),
        ],
      ),
    );
  }
}
