import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/figma_tokens.dart';

class KhatamOrnament extends StatelessWidget {
  const KhatamOrnament({
    super.key,
    required this.size,
    this.color = FigmaTokens.ornamentGold,
    this.alpha = 1.0,
    this.strokeWidth = 1.4,
    this.filled = false,
    this.crescent = false,
    this.crescentColor,
  });

  final double size;
  final Color color;
  final double alpha;
  final double strokeWidth;
  final bool filled;
  final bool crescent;
  final Color? crescentColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _KhatamPainter(
        color: color,
        alpha: alpha,
        strokeWidth: strokeWidth,
        filled: filled,
        crescent: crescent,
        crescentColor: crescentColor ?? color,
      ),
    );
  }
}

class _KhatamPainter extends CustomPainter {
  _KhatamPainter({
    required this.color,
    required this.alpha,
    required this.strokeWidth,
    required this.filled,
    required this.crescent,
    required this.crescentColor,
  });

  final Color color;
  final double alpha;
  final double strokeWidth;
  final bool filled;
  final bool crescent;
  final Color crescentColor;

  Path _rotatedSquare(Size size, double radius, double rotation) {
    final center = size.center(Offset.zero);
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = rotation + i * math.pi / 2;
      final pt = center +
          Offset(math.cos(angle), math.sin(angle)) * radius;
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.shortestSide / 2;
    final base = color.withValues(alpha: alpha);
    final paint = Paint();
    if (filled) {
      paint.style = PaintingStyle.fill;
      paint.color = base;
      canvas.drawPath(_rotatedSquare(size, radius, -math.pi / 2), paint);
      canvas.drawPath(
        _rotatedSquare(size, radius, -math.pi / 2 + math.pi / 4),
        paint,
      );
    } else {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = strokeWidth;
      paint.strokeJoin = StrokeJoin.round;
      paint.color = base;
      canvas.drawPath(_rotatedSquare(size, radius, -math.pi / 2), paint);
      canvas.drawPath(
        _rotatedSquare(size, radius, -math.pi / 2 + math.pi / 4),
        paint,
      );
    }
    if (crescent) {
      final c = crescentColor.withValues(alpha: alpha);
      final outerR = radius * 0.3;
      final offset = Offset(size.width / 2 + outerR * 0.45, size.height / 2);
      final path = Path()
        ..addArc(
          Rect.fromCircle(center: center(size), radius: outerR),
          0,
          math.pi * 2,
        )
        ..addArc(
          Rect.fromCircle(center: offset, radius: outerR * 0.92),
          0,
          math.pi * 2,
        );
      canvas.drawPath(path, Paint()..color = c);
    }
  }

  Offset center(Size size) => Offset(size.width / 2, size.height / 2);

  @override
  bool shouldRepaint(covariant _KhatamPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.alpha != alpha ||
      oldDelegate.filled != filled ||
      oldDelegate.crescent != crescent ||
      oldDelegate.crescentColor != crescentColor;
}

class MihrabOrnament extends StatelessWidget {
  const MihrabOrnament({
    super.key,
    required this.size,
    this.color = FigmaTokens.ornamentGold,
    this.outerAlpha = 0.22,
    this.innerAlpha = 0.42,
    this.strokeWidth = 1.6,
  });

  final double size;
  final Color color;
  final double outerAlpha;
  final double innerAlpha;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _MihrabPainter(
        color: color,
        outerAlpha: outerAlpha,
        innerAlpha: innerAlpha,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class _MihrabPainter extends CustomPainter {
  _MihrabPainter({
    required this.color,
    required this.outerAlpha,
    required this.innerAlpha,
    required this.strokeWidth,
  });

  final Color color;
  final double outerAlpha;
  final double innerAlpha;
  final double strokeWidth;

  Path _arch(Size size, double inset) {
    final w = size.width;
    final h = size.height;
    final lx = w * (0.06 + inset);
    final rx = w * (0.94 - inset);
    final baseY = h * 0.94;
    final apexY = h * (0.02 + inset * 0.6);
    final midX = w / 2;
    return Path()
      ..moveTo(lx, baseY)
      ..lineTo(lx, h * 0.52)
      ..cubicTo(lx, h * 0.10, w * 0.26, h * (0.03 - inset * 0.4), midX, apexY)
      ..cubicTo(w * 0.74, h * (0.03 - inset * 0.4), rx, h * 0.10, rx, h * 0.52)
      ..lineTo(rx, baseY);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    paint.color = color.withValues(alpha: outerAlpha);
    canvas.drawPath(_arch(size, 0.0), paint);
    paint.color = color.withValues(alpha: innerAlpha);
    canvas.drawPath(_arch(size, 0.10), paint);
  }

  @override
  bool shouldRepaint(covariant _MihrabPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.outerAlpha != outerAlpha ||
      oldDelegate.innerAlpha != innerAlpha;
}

class ArabicRoundel extends StatelessWidget {
  const ArabicRoundel({
    super.key,
    required this.size,
    this.text = '﷽',
    this.gold = FigmaTokens.ornamentGold,
    this.glow = 0.22,
    this.borderAlpha = 0.6,
    this.ringWidth = 1.5,
    this.textSize,
  });

  final double size;
  final String text;
  final Color gold;
  final double glow;
  final double borderAlpha;
  final double ringWidth;
  final double? textSize;

  @override
  Widget build(BuildContext context) {
    final core = gold.withValues(alpha: glow);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: Alignment.center,
          colors: [
            core.withValues(alpha: glow),
            core.withValues(alpha: glow * 0.45),
            gold.withValues(alpha: 0.02),
          ],
        ),
        border: Border.all(
          color: gold.withValues(alpha: borderAlpha),
          width: ringWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.18),
            blurRadius: size * 0.18,
            spreadRadius: size * 0.02,
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontFamily: FigmaTokens.fontFamilyArabicSerif,
            fontSize: textSize ?? size * 0.42,
            height: 1,
            color: gold,
            shadows: [
              Shadow(
                color: gold.withValues(alpha: 0.55),
                blurRadius: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GoldRule extends StatelessWidget {
  const GoldRule({
    super.key,
    this.height = 2,
    this.alpha = 0.35,
    this.khatamSize = 22,
    this.khatam = true,
    this.color = FigmaTokens.ornamentGold,
  });

  final double height;
  final double alpha;
  final double khatamSize;
  final bool khatam;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bar = Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.02),
            color.withValues(alpha: alpha),
            color.withValues(alpha: 0.02),
          ],
        ),
      ),
    );
    return Row(
      children: [
        Expanded(child: bar),
        if (khatam)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: KhatamOrnament(
              size: khatamSize,
              color: color,
              alpha: 0.85,
              strokeWidth: 1.2,
            ),
          ),
        Expanded(child: bar),
      ],
    );
  }
}

class ArabesqueBand extends StatelessWidget {
  const ArabesqueBand({
    super.key,
    this.height = 72,
    this.color = FigmaTokens.ornamentGold,
    this.alpha = 0.08,
  });

  final double height;
  final Color color;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _ArabesqueBandPainter(
          color: color.withValues(alpha: alpha),
        ),
      ),
    );
  }
}

class _ArabesqueBandPainter extends CustomPainter {
  _ArabesqueBandPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const motif = 34.0;
    final gap = motif * 0.42;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = color
      ..strokeJoin = StrokeJoin.round;
    final y = size.height / 2;
    final start = -motif;
    for (double x = start; x < size.width + motif; x += motif + gap) {
      final center = Offset(x + motif / 2, y);
      final r = motif * 0.42;
      final sq = Path();
      for (int i = 0; i < 4; i++) {
        final a = i * math.pi / 2 + math.pi / 4;
        final pt = center + Offset(math.cos(a), math.sin(a)) * r;
        if (i == 0) {
          sq.moveTo(pt.dx, pt.dy);
        } else {
          sq.lineTo(pt.dx, pt.dy);
        }
      }
      sq.close();
      canvas.drawPath(sq, paint);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r * 0.36),
        0,
        math.pi * 2,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ArabesqueBandPainter oldDelegate) =>
      oldDelegate.color != color;
}

class GoldIconBadge extends StatelessWidget {
  const GoldIconBadge({
    super.key,
    required this.icon,
    this.size = 48,
    this.iconColor = FigmaTokens.textOnDark,
    this.iconSize = 22,
  });

  final IconData icon;
  final double size;
  final Color iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: FigmaTokens.primaryButtonGradient,
        border: Border.all(
          color: FigmaTokens.ornamentGold.withValues(alpha: 0.65),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: FigmaTokens.ornamentGold.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: iconColor, size: iconSize),
    );
  }
}

class CrescentOrnament extends StatelessWidget {
  const CrescentOrnament({
    super.key,
    required this.size,
    this.color = FigmaTokens.ornamentGold,
    this.alpha = 1.0,
    this.thickness = 0.35,
  });

  final double size;
  final Color color;
  final double alpha;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _CrescentPainter(
        color: color,
        alpha: alpha,
        thickness: thickness,
      ),
    );
  }
}

class _CrescentPainter extends CustomPainter {
  _CrescentPainter({
    required this.color,
    required this.alpha,
    required this.thickness,
  });

  final Color color;
  final double alpha;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final outer = size.shortestSide / 2;
    final inner = outer * (1 - thickness);
    final shift = outer * thickness * 0.72;
    final path = Path()
      ..addArc(
        Rect.fromCircle(center: c, radius: outer),
        -math.pi / 2,
        math.pi * 2,
      )
      ..addArc(
        Rect.fromCircle(
          center: c + Offset(shift, 0),
          radius: inner,
        ),
        -math.pi / 2,
        math.pi * 2,
      );
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: alpha));
  }

  @override
  bool shouldRepaint(covariant _CrescentPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.alpha != alpha ||
      oldDelegate.thickness != thickness;
}