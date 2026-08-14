import 'package:flutter/material.dart';
import '../../core/theme/figma_tokens.dart';

/// A decorative hero panel at the top of screens that provides INSTANT
/// visual proof that the light/dark theme change has taken effect.
///
/// Light theme: Gold-warm cream surface with mint gradient border, "Bismillah"
/// Dark theme:  Deep forest green gradient with gold accent calligraphy
///
/// Used as the first widget on Home Screen top; also inserted at the top of
/// Profile and About pages.
class ThemeHeroBanner extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final double height;
  final Widget? trailing;

  const ThemeHeroBanner({
    super.key,
    this.title,
    this.subtitle,
    this.height = 240,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final figma = context.figma;

    return Semantics(
      container: true,
      label: 'Spiritual greeting banner',
      child: Container(
        width: double.infinity,
        height: height,
        padding: const EdgeInsets.symmetric(
          horizontal: FigmaTokens.spacing5,
          vertical: FigmaTokens.spacing6,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(figma.cardRadius),
          border: Border.all(
            color: isDark
                ? FigmaTokens.accentGoldAmber.withValues(alpha: 0.5)
                : FigmaTokens.brandAccentSageStart.withValues(alpha: 0.15),
            width: isDark ? 1.5 : 1,
          ),
          boxShadow: isDark ? const [] : FigmaTokens.cardShadow,
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    FigmaTokens.brandDeepGreen,
                    FigmaTokens.brandMidGreen,
                    const Color(0xFF1B4332),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    FigmaTokens.accentGoldSurface,
                    FigmaTokens.surfacePanelMint,
                    const Color(0xFFFFF8E7),
                  ],
                ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Decorative ornamental 8-point star corner (always visible)
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Opacity(
                opacity: isDark ? 0.15 : 0.08,
                child: _StarOrnament(
                  color: isDark
                      ? FigmaTokens.accentGoldAmber
                      : FigmaTokens.brandDeepGreen,
                  size: 140,
                ),
              ),
            ),
            // Left content column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bismillah / Greeting — Arabic serif, prominent
                Text(
                  isDark
                      ? 'بِسْمِ ٱللَّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ'
                      : 'بِسْمِ ٱللَّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyArabicSerif,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? FigmaTokens.accentGoldAmber
                        : FigmaTokens.brandDeepGreen,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title ??
                      (isDark
                          ? 'ASK IMAN · Your Divine Companion'
                          : 'Welcome · ASK IMAN'),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? FigmaTokens.textCreamLight
                        : FigmaTokens.textHeading,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle ??
                      (isDark
                          ? 'Quran · Prayers · Tasbeeh · Community — in the shade of Barakah'
                          : 'Quran · Prayers · Tasbeeh · Community — blessed journey'),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? FigmaTokens.darkTextSecondary
                        : FigmaTokens.textBody,
                    height: 1.4,
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(height: 18),
                  trailing!,
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Small ornamental 8-point star rendered via CustomPaint
// (matches IslamicBackground pattern style but larger, for corners)
// ────────────────────────────────────────────────────────────────
class _StarOrnament extends StatelessWidget {
  final Color color;
  final double size;
  const _StarOrnament({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _StarPainter(color),
    );
  }
}

class _StarPainter extends CustomPainter {
  final Color color;
  _StarPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final outerR = size.width * 0.48;
    final innerR = size.width * 0.22;
    final center = Offset(size.width / 2, size.height / 2);
    const points = 8;

    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final a = (i * 3.14159) / points - 3.14159 / 2;
      final x = center.dx + r * _cos(a);
      final y = center.dy + r * _sin(a);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Inner circle ornament
    canvas.drawCircle(
      center,
      size.width * 0.1,
      paint..style = PaintingStyle.stroke,
    );
  }

  double _cos(double a) => a >= 0 && a <= 6.2832
      ? _approxCos(a)
      : _approxCos(a % (6.28318));
  double _sin(double a) => _approxCos(1.5707963 - (a % 6.28318));
  double _approxCos(double x) {
    // Quick taylor cos (accurate enough for ornament)
    final x2 = x * x;
    final x4 = x2 * x2;
    return 1 - x2 / 2 + x4 / 24;
  }

  @override
  bool shouldRepaint(covariant _StarPainter old) => old.color != color;
}
