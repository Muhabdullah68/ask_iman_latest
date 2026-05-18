// lib/features/splash/splash_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// SPLASH SCREEN — 3D Islamic animated intro
//
// Animations (all pure Flutter — no extra packages):
//   1. Background — deep green radial gradient, slowly expands outward
//   2. Islamic 8-pointed star — 3D perspective rotate on Y axis (Matrix4)
//      Comes in from a flat sliver, opens to full face, then settles
//   3. Crescent moon — draws itself with path animation, glows gold
//   4. Particle field — 40 floating light orbs (gold & cream)
//   5. Arabesque ring — 16-fold symmetry pattern spins slowly in
//   6. App name "ASK IMAN" — letter-by-letter fade-up in Cairo ExtraBold
//   7. Tagline — fades in last with a Quran verse (3:102)
//   8. Auto-navigates to MainShell after 4 seconds total
//
// Place this screen in lib/features/splash/splash_screen.dart
// Add to main.dart:
//   home: const SplashScreen(),
//
// SplashScreen navigates to MainShell automatically — no route changes needed.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Controllers ────────────────────────────────────────────────────────────
  late AnimationController _bgCtrl;         // bg radial expand
  late AnimationController _starCtrl;       // star 3D flip-in + idle spin
  late AnimationController _crescentCtrl;   // crescent draw
  late AnimationController _arabCtrl;       // arabesque ring spin-in
  late AnimationController _textCtrl;       // text appear
  late AnimationController _particleCtrl;   // particle float (repeats)
  late AnimationController _exitCtrl;       // fade-out before nav

  // ── Animations ─────────────────────────────────────────────────────────────
  late Animation<double> _bgExpand;
  late Animation<double> _starFlip;       // 0 → 1, Y perspective rotation
  late Animation<double> _starIdleSpin;   // subtle idle rotation after flip
  late Animation<double> _starFade;
  late Animation<double> _crescentDraw;
  late Animation<double> _arabSpin;
  late Animation<double> _arabFade;
  late Animation<double> _textFade;
  late Animation<double> _textSlide;
  late Animation<double> _taglineFade;
  late Animation<double> _exitFade;

  final _rng = math.Random(42);
  late final List<_FloatParticle> _particles;

  @override
  void initState() {
    super.initState();

    _particles = List.generate(40, (i) => _FloatParticle(
      x:     _rng.nextDouble(),
      y:     _rng.nextDouble(),
      r:     _rng.nextDouble() * 3 + 1.5,
      speed: _rng.nextDouble() * 0.25 + 0.08,
      phase: _rng.nextDouble(),
      isGold: i % 3 != 0,
    ));

    // ── Timeline:
    //  0 ms   – bg starts expanding
    //  200ms  – star begins 3D flip-in
    //  900ms  – crescent begins drawing
    //  1200ms – arabesque spins in
    //  1600ms – text appears
    //  2200ms – tagline fades
    //  3400ms – exit fade begins
    //  4000ms – navigate

    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _starCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200));
    _crescentCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _arabCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _particleCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 5))..repeat();
    _exitCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    // Background
    _bgExpand = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeOut);

    // Star: 0→0.6 = 3D flip (perspective Y), 0.6→1.0 = idle spin
    _starFlip = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _starCtrl,
            curve: const Interval(0.0, 0.55, curve: Curves.easeOut)));
    _starIdleSpin = Tween<double>(begin: 0, end: 0.08).animate(
        CurvedAnimation(
            parent: _starCtrl,
            curve: const Interval(0.55, 1.0, curve: Curves.easeInOut)));
    _starFade = CurvedAnimation(
        parent: _starCtrl,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn));

    // Crescent path draw
    _crescentDraw = CurvedAnimation(
        parent: _crescentCtrl, curve: Curves.easeInOut);

    // Arabesque spin-in
    _arabSpin = Tween<double>(begin: -0.12, end: 0).animate(
        CurvedAnimation(parent: _arabCtrl, curve: Curves.elasticOut));
    _arabFade = CurvedAnimation(parent: _arabCtrl, curve: Curves.easeIn);

    // Text
    _textSlide = Tween<double>(begin: 24, end: 0).animate(
        CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _textFade  = CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn);
    _taglineFade = CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn));

    // Exit
    _exitFade = Tween<double>(begin: 1, end: 0).animate(
        CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));

    // ── Fire sequence ──────────────────────────────────────────────────────
    _runSequence();
  }

  Future<void> _runSequence() async {
    _bgCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _starCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    _crescentCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _arabCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1800));
    // Exit
    _exitCtrl.forward().then((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainShell(),
            transitionDuration: Duration.zero,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _starCtrl.dispose();
    _crescentCtrl.dispose();
    _arabCtrl.dispose();
    _textCtrl.dispose();
    _particleCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primaryDarkest,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _bgExpand, _starFlip, _starIdleSpin, _starFade,
          _crescentDraw, _arabSpin, _arabFade,
          _textFade, _textSlide, _taglineFade,
          _particleCtrl, _exitFade,
        ]),
        builder: (ctx, _) {
          return Opacity(
            opacity: _exitFade.value,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Radial background
                _buildBackground(size),
                // 2. Particles
                ..._buildParticles(size),
                // 3. Arabesque ring (behind star)
                _buildArabesqueRing(size),
                // 4. Main star + crescent composition
                _buildStarComposition(size),
                // 5. Text
                _buildText(size),
                // 6. Bottom verse strip
                _buildVerseStrip(size),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── 1. Background ──────────────────────────────────────────────────────────

  Widget _buildBackground(Size size) {
    final r = size.width * 0.9 * _bgExpand.value;
    return CustomPaint(
      painter: _RadialBgPainter(radius: r, size: size),
    );
  }

  // ── 2. Particles ───────────────────────────────────────────────────────────

  List<Widget> _buildParticles(Size size) {
    final t = _particleCtrl.value;
    return _particles.map((p) {
      final phase = (t + p.phase) % 1.0;
      // Gentle upward float with sine drift
      final dx = math.sin(phase * math.pi * 2 + p.phase * 6) * 18;
      final dy = -(phase * size.height * 0.4);
      final opacity = math.sin(phase * math.pi).clamp(0.0, 1.0) *
          0.55 * _starFade.value;

      return Positioned(
        left: p.x * size.width + dx,
        top:  p.y * size.height + dy,
        child: Opacity(
          opacity: opacity,
          child: Container(
            width:  p.r * 2,
            height: p.r * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: p.isGold ? AppColors.gold : AppColors.textCream,
              boxShadow: [
                BoxShadow(
                  color: (p.isGold ? AppColors.gold : Colors.white)
                      .withOpacity(0.6),
                  blurRadius: p.r * 3,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  // ── 3. Arabesque ring ──────────────────────────────────────────────────────

  Widget _buildArabesqueRing(Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.40;
    return Opacity(
      opacity: _arabFade.value * 0.6,
      child: Transform.translate(
        offset: Offset(cx - 160, cy - 160),
        child: Transform.rotate(
          angle: _arabSpin.value * 2 * math.pi,
          origin: const Offset(160, 160),
          child: SizedBox(
            width: 320,
            height: 320,
            child: CustomPaint(
              painter: _ArabRingPainter(
                  fade: _arabFade.value),
            ),
          ),
        ),
      ),
    );
  }

  // ── 4. Star + crescent ─────────────────────────────────────────────────────

  Widget _buildStarComposition(Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.40;

    // 3D perspective Y-flip: 0 = flat (sliver), 1 = full face
    // map flip (0→1) to angle: π/2 → 0 (opens from edge)
    final flipAngle = (1 - _starFlip.value) * math.pi / 2;
    final idleAngle = _starIdleSpin.value * 2 * math.pi;

    // Perspective matrix for 3D Y-rotation
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // perspective
      ..rotateY(flipAngle);

    return Stack(
      children: [
        // Outer glow halo
        Positioned(
          left: cx - 100,
          top:  cy - 100,
          child: Opacity(
            opacity: _starFade.value * 0.35,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.6),
                    blurRadius: 60,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Islamic star — 3D perspective flip
        Positioned(
          left: cx - 88,
          top:  cy - 88,
          child: Opacity(
            opacity: _starFade.value,
            child: Transform(
              alignment: Alignment.center,
              transform: matrix,
              child: Transform.rotate(
                angle: idleAngle,
                child: SizedBox(
                  width: 176,
                  height: 176,
                  child: CustomPaint(
                    painter: _SplashStarPainter(),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Crescent moon — draws in above/right of star
        Positioned(
          left: cx + 44,
          top:  cy - 110,
          child: Opacity(
            opacity: _crescentDraw.value * _starFade.value,
            child: SizedBox(
              width: 72,
              height: 72,
              child: CustomPaint(
                painter: _CrescentPainter(progress: _crescentDraw.value),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── 5. Text ────────────────────────────────────────────────────────────────

  Widget _buildText(Size size) {
    return Positioned(
      bottom: size.height * 0.20,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // App name
          Transform.translate(
            offset: Offset(0, _textSlide.value),
            child: Opacity(
              opacity: _textFade.value,
              child: const Text(
                'ASK IMAN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 6.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Gold divider
          Opacity(
            opacity: _textFade.value,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 1,
                  color: AppColors.gold.withOpacity(0.5),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 40,
                  height: 1,
                  color: AppColors.gold.withOpacity(0.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Tagline
          Opacity(
            opacity: _taglineFade.value,
            child: const Text(
              'Your Islamic Companion',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.textGreenMuted,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 6. Bottom Quranic verse strip ──────────────────────────────────────────

  Widget _buildVerseStrip(Size size) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: _taglineFade.value * 0.75,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.4),
              ],
            ),
          ),
          child: const Column(
            children: [
              Text(
                'يَا أَيُّهَا الَّذِينَ آمَنُوا اتَّقُوا اللَّهَ حَقَّ تُقَاتِهِ',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 18,
                  color: AppColors.gold,
                  height: 1.8,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '"O believers! Be mindful of Allah as He deserves." — 3:102',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: AppColors.textGreenMuted,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PAINTERS
// ══════════════════════════════════════════════════════════════════════════════

/// Deep radial background — dark forest centre, slightly lighter edges
class _RadialBgPainter extends CustomPainter {
  final double radius;
  final Size size;
  const _RadialBgPainter({required this.radius, required this.size});

  @override
  void paint(Canvas canvas, Size _) {
    // Fill base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = AppColors.primaryDarkest,
    );

    // Radial glow from centre
    final gradient = RadialGradient(
      center: Alignment(0, -0.2),
      radius: 1.0,
      colors: [
        const Color(0xFF1B4332).withOpacity(0.85),
        AppColors.primaryDarkest.withOpacity(0.0),
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.4),
          width: radius * 2,
          height: radius * 2,
        ),
      );

    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.4),
      radius,
      paint,
    );

    // Subtle geometric grid lines (very faint)
    final linePaint = Paint()
      ..color = AppColors.primaryMid.withOpacity(0.06)
      ..strokeWidth = 0.5;
    for (int i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      final x2 = size.width / 2 + math.cos(angle) * size.width;
      final y2 = size.height * 0.4 + math.sin(angle) * size.height;
      canvas.drawLine(
        Offset(size.width / 2, size.height * 0.4),
        Offset(x2, y2),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RadialBgPainter old) => old.radius != radius;
}

/// 8-pointed Islamic star for splash (larger, richer than completion star)
class _SplashStarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width / 2;

    // Multiple layered rings for depth
    _drawRing(canvas, cx, cy, r * 1.04,
        AppColors.gold.withOpacity(0.08), fill: true);
    _drawRing(canvas, cx, cy, r * 0.98,
        AppColors.primaryDark.withOpacity(0.8), fill: true);
    _drawRing(canvas, cx, cy, r * 0.97,
        AppColors.gold.withOpacity(0.18), fill: false, width: 1.0);

    // Outer 8-pointed star
    _drawStar(canvas, cx, cy, r * 0.88, r * 0.42, 8, AppColors.gold);

    // Second layer — slightly smaller, rotated 22.5°
    _drawStarRotated(canvas, cx, cy, r * 0.68, r * 0.34, 8,
        AppColors.gold.withOpacity(0.35), rotation: math.pi / 8);

    // Inner 8-pointed star
    _drawStar(canvas, cx, cy, r * 0.40, r * 0.18, 8,
        AppColors.primaryDark);

    // Decorative inner ring
    _drawRing(canvas, cx, cy, r * 0.42,
        AppColors.gold.withOpacity(0.35), fill: false, width: 0.8);

    // Centre hexagram (Star of Rub el Hizb style)
    _drawStar(canvas, cx, cy, r * 0.18, r * 0.09, 4,
        AppColors.gold, rotation: math.pi / 4);

    // Centre dot
    canvas.drawCircle(Offset(cx, cy), r * 0.05,
        Paint()..color = AppColors.primaryDark);
  }

  void _drawStar(Canvas canvas, double cx, double cy,
      double outer, double inner, int points, Color color,
      {double rotation = 0}) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path  = Path();
    for (int i = 0; i < points * 2; i++) {
      final rad   = i.isEven ? outer : inner;
      final angle = (i * math.pi / points) - math.pi / 2 + rotation;
      final x = cx + rad * math.cos(angle);
      final y = cy + rad * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawStarRotated(Canvas canvas, double cx, double cy,
      double outer, double inner, int points, Color color,
      {double rotation = 0}) {
    _drawStar(canvas, cx, cy, outer, inner, points, color, rotation: rotation);
  }

  void _drawRing(Canvas canvas, double cx, double cy, double r,
      Color color, {bool fill = false, double width = 1.5}) {
    final paint = Paint()
      ..color = color
      ..style = fill ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = width;
    canvas.drawCircle(Offset(cx, cy), r, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

/// Crescent moon that draws itself based on progress (0 → 1)
class _CrescentPainter extends CustomPainter {
  final double progress;
  const _CrescentPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width / 2;

    // Outer circle
    final outerPath = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));

    // Inner circle (offset to cut crescent shape)
    final innerPath = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(cx + r * 0.35, cy - r * 0.1),
        radius: r * 0.78,
      ));

    // Crescent = outer minus inner
    final crescent =
    Path.combine(PathOperation.difference, outerPath, innerPath);

    // Draw progress portion using path metric
    final metric = crescent.computeMetrics().first;
    final len    = metric.length;

    if (progress >= 1.0) {
      // Full fill
      final goldFill = Paint()
        ..color = AppColors.gold
        ..style = PaintingStyle.fill;
      canvas.drawPath(crescent, goldFill);

      // Glow stroke
      final glow = Paint()
        ..color = AppColors.gold.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawPath(crescent, glow);
    } else {
      // Partial stroke draw
      final strokePath = metric.extractPath(0, len * progress);
      final strokePaint = Paint()
        ..color = AppColors.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(strokePath, strokePaint);
    }
  }

  @override
  bool shouldRepaint(_CrescentPainter old) => old.progress != progress;
}

/// 16-fold symmetry arabesque ring
class _ArabRingPainter extends CustomPainter {
  final double fade;
  const _ArabRingPainter({required this.fade});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width / 2;

    final paint = Paint()
      ..color = AppColors.gold.withOpacity(0.28 * fade)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const n = 16;
    for (int i = 0; i < n; i++) {
      final angle = i * 2 * math.pi / n;
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);

      // Petal shape: outer arch
      final petalPath = Path();
      petalPath.moveTo(0, -r * 0.62);
      petalPath.cubicTo(
        r * 0.12, -r * 0.80,
        r * 0.18, -r * 0.95,
        0, -r * 0.98,
      );
      petalPath.cubicTo(
        -r * 0.18, -r * 0.95,
        -r * 0.12, -r * 0.80,
        0, -r * 0.62,
      );
      canvas.drawPath(petalPath, paint);
      canvas.restore();
    }

    // Outer circle
    canvas.drawCircle(Offset(cx, cy), r * 0.98,
        Paint()
          ..color = AppColors.gold.withOpacity(0.15 * fade)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6);

    // Inner circle
    canvas.drawCircle(Offset(cx, cy), r * 0.62,
        Paint()
          ..color = AppColors.gold.withOpacity(0.12 * fade)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6);
  }

  @override
  bool shouldRepaint(_ArabRingPainter old) => old.fade != fade;
}

// ── Particle data ─────────────────────────────────────────────────────────────

class _FloatParticle {
  final double x, y, r, speed, phase;
  final bool isGold;
  const _FloatParticle({
    required this.x, required this.y, required this.r,
    required this.speed, required this.phase, required this.isGold,
  });
}