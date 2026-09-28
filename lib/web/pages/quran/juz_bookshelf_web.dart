// lib/web/pages/quran/juz_bookshelf_web.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — JUZ BOOKSHELF (30 SUPARA "3D" BOOKS)
//
// The 30 juz of the Qur'an presented as a shelf of stylised book covers with a
// genuine 3D presence (perspective tilt toward the cursor via Tilt3D). Each
// book carries the juz's Arabic ordinal, the Arabic name of the surah where it
// begins, and its start reference so Talawat / Tarjuma both open the right
// spot. A play affordance drives shared Juz audio when supplied.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../core/theme/figma_tokens.dart';
import '../../../features/quran/data/surahs_data.dart';
import '../../widgets/web_ornaments.dart';
import '../../widgets/web_tilt3d.dart';
import 'juz_data.dart';

/// Responsive bookshelf of the 30 juz. [onSelectJuz] is required; [onPlayJuz]
/// adds a per-book play button that starts the recitation of that juz.
class JuzBookshelf extends StatelessWidget {
  final void Function(int juzNum, int surah, int ayah) onSelectJuz;
  final void Function(int juzNum)? onPlayJuz;

  const JuzBookshelf({super.key, required this.onSelectJuz, this.onPlayJuz});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 1080
            ? 5
            : constraints.maxWidth >= 820
            ? 4
            : constraints.maxWidth >= 560
            ? 3
            : 2;
        const spacing = 18.0;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 0.58,
          ),
          itemCount: 30,
          itemBuilder: (context, i) {
            final n = i + 1;
            return _JuzBook(
              juzNum: n,
              onTap: () => onSelectJuz(n, juzStartSurah(n), juzStartAyah(n)),
              onPlay: onPlayJuz == null ? null : () => onPlayJuz!(n),
            );
          },
        );
      },
    );
  }
}

class _JuzBook extends StatelessWidget {
  final int juzNum;
  final VoidCallback onTap;
  final VoidCallback? onPlay;

  const _JuzBook({required this.juzNum, required this.onTap, this.onPlay});

  static const _covers = [
    [Color(0xFF14532D), Color(0xFF0F3D23)],
    [Color(0xFF0F3D4C), Color(0xFF0B2B34)],
    [Color(0xFF3D2B0F), Color(0xFF2A1E0A)],
    [Color(0xFF1B2A4A), Color(0xFF121F38)],
    [Color(0xFF431F24), Color(0xFF31161C)],
  ];

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    final meta = SurahsData.surahs[juzStartSurah(juzNum) - 1];
    final nameEn = meta['name'] as String;
    final nameAr = meta['arabic'] as String;
    final cover = _covers[(juzNum - 1) % _covers.length];
    final radius = BorderRadius.circular(12);

    return Tilt3D(
      maxAngle: 10,
      perspective: 0.0012,
      glow: 0.22,
      borderRadius: radius,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: cover,
              ),
              border: Border.all(
                color: figma.accentGoldAmber.withValues(alpha: 0.55),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(3, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.14,
                    child: CustomPaint(painter: _KhatamWatermark()),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: FigmaTokens.ornamentGold.withValues(
                            alpha: 0.5,
                          ),
                          width: 0.8,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CrescentOrnament(size: 16, alpha: 0.95),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: FigmaTokens.ornamentGold.withValues(
                                alpha: 0.16,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'الجزء ${arabicNumeral(juzNum)}',
                              style: const TextStyle(
                                fontFamily: FigmaTokens.fontFamilyArabicSerif,
                                fontSize: 11,
                                height: 1.2,
                                color: FigmaTokens.accentGoldLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Center(
                        child: Text(
                          nameAr,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: FigmaTokens.fontFamilyArabicSerif,
                            fontSize: 23,
                            height: 1.35,
                            color: FigmaTokens.textOnDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          nameEn,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: FigmaTokens.fontFamilyUiSans,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: figma.accentGoldLight,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Center(
                        child: Text(
                          'Juz ${arabicNumeral(juzNum)}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: FigmaTokens.fontFamilyUiSans,
                            fontSize: 10.5,
                            color: Colors.white.withValues(alpha: 0.62),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${juzStartSurah(juzNum)}:${juzStartAyah(juzNum)}',
                              style: TextStyle(
                                fontFamily: FigmaTokens.fontFamilyUiSans,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (onPlay != null)
                            _PlayBadge(juzNum: juzNum, onPlay: onPlay!)
                          else
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayBadge extends StatelessWidget {
  final int juzNum;
  final VoidCallback onPlay;
  const _PlayBadge({required this.juzNum, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FigmaTokens.brandMidGreen,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPlay,
        child: Tooltip(
          message: 'Play Juz $juzNum',
          child: const Padding(
            padding: EdgeInsets.all(7),
            child: Icon(
              Icons.play_arrow_rounded,
              size: 18,
              color: FigmaTokens.textOnDark,
            ),
          ),
        ),
      ),
    );
  }
}

/// Faint 8-point khatam lattice watermark on each spine.
class _KhatamWatermark extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = FigmaTokens.ornamentGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide * 0.34;
    for (var k = 0; k < 8; k++) {
      final start =
          center + Offset.fromDirection(k * 0.7853981633974483, r * 0.55);
      final end = center + Offset.fromDirection(k * 0.7853981633974483, r);
      canvas.drawLine(start, end, stroke);
    }
    final squarePath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: r));
    canvas.drawPath(squarePath, stroke);
  }

  @override
  bool shouldRepaint(covariant _KhatamWatermark oldDelegate) => false;
}
