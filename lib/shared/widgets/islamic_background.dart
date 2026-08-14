import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class IslamicBackground extends StatelessWidget {
  final Widget? child;
  final bool showPattern;
  final double patternOpacity;
  const IslamicBackground({
    super.key,
    this.child,
    this.showPattern = true,
    this.patternOpacity = 0.06,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        AppColors.primaryDarkest,
                        AppColors.darkBg,
                        const Color(0xFF0A1A10),
                      ]
                    : [
                        AppColors.bgCream,
                        AppColors.bgCream,
                        const Color(0xFFFBF7F0),
                      ],
              ),
            ),
          ),
        ),
        if (showPattern) ...[
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _IslamicPatternPainter(
                  color: isDark ? AppColors.gold : AppColors.primaryDark,
                  opacity: patternOpacity,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ],
        if (child != null) Positioned.fill(child: child!),
      ],
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;
  const _IslamicPatternPainter({
    required this.color,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const tileW = 140.0;
    const tileH = 120.0;
    final cols = (size.width / tileW).ceil() + 1;
    final rows = (size.height / tileH).ceil() + 1;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final ox = c * tileW + (r.isOdd ? tileW / 2 : 0);
        final oy = r * tileH;
        _drawStarPattern(canvas, paint, Offset(ox + tileW / 2, oy + tileH / 2));
      }
    }
  }

  void _drawStarPattern(Canvas canvas, Paint paint, Offset center) {
    const double outerRadius = 38;
    const double innerRadius = 18;
    const int points = 8;
    final path = Path();

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * math.pi) / points - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _IslamicPatternPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.opacity != opacity;
}
