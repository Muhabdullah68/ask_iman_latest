// lib/widgets/ask_iman_logo.dart
// =============================================================================
// ASK IMAN logo — 100% widgets, no image asset.
// 8-point star outline (two overlapping squares rotated 45deg) drawn by a
// CustomPainter, a gold crescent cut out of it with Path.combine, then the
// static wordmark, gold rule and ISLAMIC GUIDANCE subtitle (Poppins).
// The whole block is fixed-width and meant to be scaled by the splash's
// FittedBox, so every measurement below is in reference pixels.
// =============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Brand colours for the splash (also used by the tiny card widget).
abstract final class SplashPalette {
  static const Color green = Color(0xFF0E4D3C);
  static const Color gold = Color(0xFFC9A24B);
  static const Color ivory = Color(0xFFF8F6F0);
}

class AskImanLogo extends StatelessWidget {
  const AskImanLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 8-point star outline with a gold crescent inside.
          const SizedBox(
            width: 130,
            height: 130,
            child: CustomPaint(painter: _StarCrescentPainter()),
          ),
          const SizedBox(height: 12),
          const Text(
            'ASK IMAN',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 46,
              fontWeight: FontWeight.w800,
              color: SplashPalette.green,
              letterSpacing: 1,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 90,
            height: 2.5,
            decoration: const BoxDecoration(
              color: SplashPalette.gold,
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ISLAMIC GUIDANCE',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: SplashPalette.gold,
              letterSpacing: 5,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// 8-point star (Rub el Hizb style: two squares, one rotated 45deg) in the
/// deep green, with the gold crescent punched out by path difference so the
/// background is never painted over with a solid block.
class _StarCrescentPainter extends CustomPainter {
  const _StarCrescentPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    // Square side chosen so the outer corners sit inside the 130 box with
    // room for the 6px stroke (half-diagonal ~= 57).
    final halfDiag = 57.0;
    final side = (halfDiag * 2.0) / math.sqrt2;

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeJoin = StrokeJoin.round
      ..color = SplashPalette.green;

    final square = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: side, height: side),
        const Radius.circular(2),
      ));

    // Two overlapping squares: axis-aligned + rotated 45deg = 8-point star.
    canvas.drawPath(square, stroke);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(math.pi / 4);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawPath(square, stroke);
    canvas.restore();

    // Crescent: gold circle ~55% of the star size, a smaller circle offset
    // toward the upper-right carved out so it opens toward the top.
    final outer = Path()
      ..addOval(Rect.fromCenter(
        center: center + const Offset(0, 2),
        width: 72,
        height: 72,
      ));
    final inner = Path()
      ..addOval(Rect.fromCenter(
        center: center + const Offset(13, -9),
        width: 56,
        height: 56,
      ));
    final crescent = Path.combine(PathOperation.difference, outer, inner);
    canvas.drawPath(
      crescent,
      Paint()
        ..style = PaintingStyle.fill
        ..color = SplashPalette.gold,
    );
  }

  @override
  bool shouldRepaint(_StarCrescentPainter oldDelegate) => false;
}