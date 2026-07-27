// lib/features/splash/splash_screen.dart
// =============================================================================
// ASK IMAN — Premium Islamic Splash Screen
// Pure Flutter, zero extra packages.
//
// Animation sequence:
//   0.00s → Background radial expands
//   0.35s → Rehal stand fades + slides in
//   1.00s → Quran drops onto shelf with bounce
//   2.00s → Quran opens (easeInOutCubic)
//   3.50s → Divine light rays + beam cone appear
//   4.50s → ASK · IMAN text slides up
//   5.20s → Tagline fades in
//   5.40s → Quranic verse strip fades in
//   6.20s → Screen fades out → navigates to MainShell
// =============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../shared/widgets/main_shell.dart';

// Inline colour constants so the file compiles stand-alone during development.
abstract final class SplashColors {
  static const Color gold = Color(0xFFC9A84C);
  static const Color background = Color(0xFF050C08);
  static const Color primaryGreen = Color(0xFF0F3D2E);
  static const Color secondGreen = Color(0xFF2E6B4A);
  static const Color divineLight = Color(0xFFFFF7D0);
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Controllers ─────────────────────────────────────────────────────────
  late AnimationController _bgCtrl;
  late AnimationController _bookCtrl;
  late AnimationController _lightCtrl;
  late AnimationController _textCtrl;
  late AnimationController _loopCtrl; // infinite loop for particles / stars
  late AnimationController _exitCtrl;

  // ── Derived animations ───────────────────────────────────────────────────
  late Animation<double> _bgExpand;
  late Animation<double> _rehalAppear;
  late Animation<double> _bookDrop;
  late Animation<double> _bookOpen;
  late Animation<double> _bookGlow;
  late Animation<double> _lightOpacity;
  late Animation<double> _sparkRing;
  late Animation<double> _textFade;
  late Animation<double> _textSlide;
  late Animation<double> _tagFade;
  late Animation<double> _tagSlide;
  late Animation<double> _verseFade;
  late Animation<double> _exitFade;

  // ── Particle data ────────────────────────────────────────────────────────
  late final List<_FloatOrb> _orbs;
  late final List<_TwinkleStar> _stars;
  late final List<_DustMote> _dusts;

  @override
  void initState() {
    super.initState();
    _initParticles();
    _initControllers();
    _initAnimations();
    _runSequence();
  }

  void _initParticles() {
    final rng = math.Random(42);

    _orbs = List.generate(
      24,
      (i) => _FloatOrb(
        x: rng.nextDouble(),
        y: 0.3 + rng.nextDouble() * 0.7,
        radius: rng.nextDouble() * 1.4 + 0.8,
        speed: rng.nextDouble() * 0.09 + 0.04,
        phase: rng.nextDouble(),
        gold: i % 3 != 0,
      ),
    );

    final sr = math.Random(77);
    _stars = List.generate(
      28,
      (i) => _TwinkleStar(
        x: sr.nextDouble() * 0.9 + 0.05,
        y: sr.nextDouble() * 0.45 + 0.02,
        size: sr.nextDouble() * 2.2 + 1.4,
        speed: sr.nextDouble() * 0.7 + 0.4,
        phase: sr.nextDouble() * math.pi * 2,
      ),
    );

    final dr = math.Random(13);
    _dusts = List.generate(
      16,
      (i) => _DustMote(
        x: dr.nextDouble() * 0.4 + 0.3,
        y: dr.nextDouble() * 0.3 + 0.25,
        speed: dr.nextDouble() * 0.05 + 0.02,
        phase: dr.nextDouble(),
        radius: dr.nextDouble() * 1.3 + 0.5,
      ),
    );
  }

  void _initControllers() {
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bookCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4600),
    );
    _lightCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _loopCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  void _initAnimations() {
    // Background
    _bgExpand = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeOut);

    // Book sequence — all driven by a single _bookCtrl
    _rehalAppear = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _bookCtrl,
        curve: const Interval(0.00, 0.30, curve: Curves.easeOut),
      ),
    );

    _bookDrop = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _bookCtrl,
        curve: const Interval(0.20, 0.46, curve: Curves.bounceOut),
      ),
    );

    _bookOpen = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _bookCtrl,
        curve: const Interval(0.46, 1.00, curve: Curves.easeInOutCubic),
      ),
    );

    _bookGlow = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _bookCtrl,
        curve: const Interval(0.66, 1.00, curve: Curves.easeOut),
      ),
    );

    _sparkRing = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _bookCtrl,
        curve: const Interval(0.72, 1.00, curve: Curves.easeOut),
      ),
    );

    // Light rays
    _lightOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _lightCtrl,
        curve: const Interval(0.30, 0.95, curve: Curves.easeOut),
      ),
    );

    // Text — title
    _textSlide = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.00, 0.65, curve: Curves.easeOutCubic),
      ),
    );
    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.00, 0.65, curve: Curves.easeIn),
      ),
    );

    // Text — tagline
    _tagSlide = Tween<double>(begin: 12, end: 0).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.35, 1.00, curve: Curves.easeOutCubic),
      ),
    );
    _tagFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.35, 1.00, curve: Curves.easeIn),
      ),
    );

    // Text — verse strip
    _verseFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.55, 1.00, curve: Curves.easeIn),
      ),
    );

    // Exit
    _exitFade = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));
  }

  Future<void> _runSequence() async {
    // Start the animation sequence
    _bgCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 350));
    _bookCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 900));
    _lightCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 3100));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 2600));

    // Fade out splash and navigate WITHOUT waiting for any network calls!
    await _exitCtrl.forward();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const MainShell(),
        transitionDuration: Duration.zero,
      ),
    );
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _bookCtrl.dispose();
    _lightCtrl.dispose();
    _textCtrl.dispose();
    _loopCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: SplashColors.background,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _bgExpand,
          _rehalAppear,
          _bookDrop,
          _bookOpen,
          _bookGlow,
          _lightOpacity,
          _sparkRing,
          _textFade,
          _textSlide,
          _tagFade,
          _tagSlide,
          _verseFade,
          _loopCtrl,
          _exitFade,
        ]),
        builder: (_, _) {
          return Opacity(
            opacity: _exitFade.value,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1 — Radial background
                CustomPaint(
                  size: size,
                  painter: _BgPainter(expand: _bgExpand.value),
                ),
                // 2 — Divine rays
                CustomPaint(
                  size: size,
                  painter: _RaysPainter(
                    loop: _loopCtrl.value,
                    opacity: _lightOpacity.value,
                  ),
                ),
                // 3 — Floating orbs
                ..._buildOrbs(size),
                // 4 — Twinkling stars
                CustomPaint(
                  size: size,
                  painter: _StarsPainter(stars: _stars, loop: _loopCtrl.value),
                ),
                // 5 — Spark ring around open book
                CustomPaint(
                  size: size,
                  painter: _OrbsPainter(orbs: _orbs, loop: _loopCtrl.value),
                ),
                // 6 — Dust motes (only when light is on)
                if (_lightOpacity.value > 0)
                  CustomPaint(
                    size: size,
                    painter: _DustPainter(
                      dusts: _dusts,
                      loop: _loopCtrl.value,
                      opacity: _lightOpacity.value,
                      size: size,
                    ),
                  ),
                // 7 — Quran
                _buildBook(size),
                // 8 — Light-embedded Verse (Moved above book)
                _buildLightVerse(size),
                // 9 — Text overlay
                _buildText(size),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Floating orbs ─────────────────────────────────────────────────────────
  List<Widget> _buildOrbs(Size size) {
    final t = _loopCtrl.value;
    return _orbs.map((o) {
      final phase = (t + o.phase) % 1.0;
      final dx = math.sin(phase * math.pi * 2 + o.phase * 6) * 10.0;
      final dy = -(phase * size.height * 0.36);
      final rawOp = math.sin(phase * math.pi).clamp(0.0, 1.0);
      final opacity = rawOp * 0.32 * _bgExpand.value;
      if (opacity <= 0) return const SizedBox.shrink();
      return Positioned(
        left: o.x * size.width + dx,
        top: o.y * size.height + dy,
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: o.radius * 2,
            height: o.radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: o.gold ? SplashColors.gold : Colors.white70,
              boxShadow: [
                BoxShadow(
                  color: (o.gold ? SplashColors.gold : Colors.white).withValues(
                    alpha: 0.5,
                  ),
                  blurRadius: o.radius * 5,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  // ── Rehal + Quran ─────────────────────────────────────────────────────────
  Widget _buildBook(Size size) {
    const painterW = 360.0;
    const painterH = 340.0;
    final cx = size.width / 2;
    final cy = size.height * 0.44;
    return Positioned(
      left: cx - painterW / 2,
      top: cy - painterH / 2,
      child: SizedBox(
        width: painterW,
        height: painterH,
        child: CustomPaint(
          painter: _BookPainter(
            rehalAppear: _rehalAppear.value,
            bookDrop: _bookDrop.value,
            openProgress: _bookOpen.value,
            glowProgress: _bookGlow.value,
            lightAnim: _lightOpacity.value,
            loopAnim: _loopCtrl.value,
          ),
        ),
      ),
    );
  }

  // ── Title + tagline ───────────────────────────────────────────────────────
  Widget _buildText(Size size) {
    return Positioned(
      bottom: size.height * 0.185,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Divider ornament
          Transform.translate(
            offset: Offset(0, _textSlide.value),
            child: Opacity(
              opacity: _textFade.value,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 34,
                    height: 1.2,
                    color: SplashColors.gold.withValues(alpha: 0.45),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: SplashColors.gold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 34,
                    height: 1.2,
                    color: SplashColors.gold.withValues(alpha: 0.45),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          // App name
          Transform.translate(
            offset: Offset(0, _textSlide.value * 0.7),
            child: Opacity(
              opacity: _textFade.value,
              child: const Text(
                'ASK IMAN',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: SplashColors.gold,
                  letterSpacing: 6,
                  shadows: [Shadow(color: Color(0x88C9A84C), blurRadius: 18)],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Tagline
          Transform.translate(
            offset: Offset(0, _tagSlide.value),
            child: Opacity(
              opacity: _tagFade.value * 0.85,
              child: const Text(
                'YOUR DIVINE COMPANION',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A7A5A),
                  letterSpacing: 3.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Verse above book in the light ────────────────────────────────────────
  Widget _buildLightVerse(Size size) {
    final cy = size.height * 0.44;
    return Positioned(
      top: cy - 220, // Positioned in the light beam above the book
      left: 0,
      right: 0,
      child: Opacity(
        opacity: _verseFade.value.clamp(0.0, 1.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'يَا أَيُّهَا الَّذِينَ آمَنُوا اتَّقُوا اللَّهَ حَقَّ تُقَاتِهِ',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'AlQalam',
                  fontSize: 22,
                  color: SplashColors.gold,
                  height: 1.5,
                  shadows: [Shadow(color: Colors.white60, blurRadius: 20)],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '"O believers! Be mindful of Allah as He deserves." — 3:102',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    height: 1.4,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// PAINTERS
// =============================================================================

// ── Deep radial background ───────────────────────────────────────────────────
class _BgPainter extends CustomPainter {
  final double expand;
  const _BgPainter({required this.expand});

  @override
  void paint(Canvas canvas, Size size) {
    // Solid base
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = SplashColors.background,
    );
    if (expand <= 0) return;

    final cx = size.width / 2;
    final cy = size.height * 0.44;
    final r = size.width * 0.9 * expand;

    final grad = RadialGradient(
      colors: [
        const Color(0xFF123723).withValues(alpha: 0.9),
        const Color(0xFF0A2012).withValues(alpha: 0.45),
        Colors.transparent,
      ],
      stops: const [0.0, 0.58, 1.0],
    );
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..shader = grad.createShader(
          Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: r * 2),
        ),
    );

    // Subtle radial spokes
    final lp = Paint()
      ..color = const Color(0xFF2A6040).withValues(alpha: 0.04 * expand)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 18; i++) {
      final a = i * math.pi / 9;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(
          cx + math.cos(a) * size.width * 2,
          cy + math.sin(a) * size.height * 2,
        ),
        lp,
      );
    }
  }

  @override
  bool shouldRepaint(_BgPainter o) => o.expand != expand;
}

// ── Divine light rays from above ─────────────────────────────────────────────
class _RaysPainter extends CustomPainter {
  final double loop;
  final double opacity;
  const _RaysPainter({required this.loop, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    final cx = size.width / 2;
    final cy = size.height * 0.44;
    final oy = cy - 300.0;

    for (int i = 0; i < 11; i++) {
      final base = math.pi / 2 + (i - 5.0) * 0.135;
      final ang = base + math.sin(loop * math.pi * 2 + i * 2.0) * 0.011;
      final bw = 20.0 + math.sin(loop * math.pi * 4 + i) * 6;

      final g = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.16 * opacity),
          SplashColors.gold.withValues(alpha: 0.07 * opacity),
          Colors.transparent,
        ],
      );
      final path = Path()
        ..moveTo(cx, oy)
        ..lineTo(
          cx + math.cos(ang - 0.042) * 650,
          cy + math.sin(ang - 0.042) * 650 + 85,
        )
        ..lineTo(
          cx + math.cos(ang + 0.042) * 650 + bw,
          cy + math.sin(ang + 0.042) * 650 + 85,
        )
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = g.createShader(
            Rect.fromPoints(
              Offset(cx, oy),
              Offset(cx + math.cos(ang) * 650, cy + math.sin(ang) * 650),
            ),
          ),
      );
    }

    // Central bright cone
    final beam = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withValues(alpha: 0.20 * opacity),
        const Color(0xFFFFF8B4).withValues(alpha: 0.07 * opacity),
        Colors.transparent,
      ],
    );
    final cone = Path()
      ..moveTo(cx - 52, oy)
      ..lineTo(cx + 52, oy)
      ..lineTo(cx + 11, cy - 38)
      ..lineTo(cx - 11, cy - 38)
      ..close();
    canvas.drawPath(
      cone,
      Paint()
        ..shader = beam.createShader(Rect.fromLTWH(cx - 52, oy, 104, cy - oy)),
    );
  }

  @override
  bool shouldRepaint(_RaysPainter o) => o.loop != loop || o.opacity != opacity;
}

// ── 4-pointed twinkling stars ────────────────────────────────────────────────
class _StarsPainter extends CustomPainter {
  final List<_TwinkleStar> stars;
  final double loop;
  const _StarsPainter({required this.stars, required this.loop});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..style = PaintingStyle.fill;
    for (final s in stars) {
      final ph = (loop * 2 * math.pi * s.speed + s.phase) % (math.pi * 2);
      final op = ((math.sin(ph) + 1) / 2) * 0.82;
      final sz = s.size * (0.6 + 0.4 * ((math.sin(ph) + 1) / 2));
      final sx = s.x * size.width;
      final sy = s.y * size.height;
      p.color = const Color(0xFFFFF7D6).withValues(alpha: op);
      final path = Path()
        ..moveTo(sx, sy - sz)
        ..quadraticBezierTo(sx, sy, sx + sz, sy)
        ..quadraticBezierTo(sx, sy, sx, sy + sz)
        ..quadraticBezierTo(sx, sy, sx - sz, sy)
        ..quadraticBezierTo(sx, sy, sx, sy - sz)
        ..close();
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(_StarsPainter o) => o.loop != loop;
}

// ── Floating dust motes (light-phase only) ───────────────────────────────────
class _DustPainter extends CustomPainter {
  final List<_DustMote> dusts;
  final double loop;
  final double opacity;
  final Size size;
  const _DustPainter({
    required this.dusts,
    required this.loop,
    required this.opacity,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size _) {
    final p = Paint()..style = PaintingStyle.fill;
    for (final d in dusts) {
      final ph = (loop * d.speed + d.phase) % 1.0;
      final dx = math.sin(ph * math.pi * 3 + d.phase * 7) * 16.0;
      final dy = ph * size.height * 0.07;
      final op = math.sin(ph * math.pi) * 0.5 * opacity;
      p.color = const Color(0xFFFFF7B4).withValues(alpha: op);
      canvas.drawCircle(
        Offset(d.x * size.width + dx, d.y * size.height - dy),
        d.radius,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(_DustPainter o) => o.loop != loop || o.opacity != opacity;
}

// ── Floating orbs (secondary) ────────────────────────────────────────────────
class _OrbsPainter extends CustomPainter {
  final List<_FloatOrb> orbs;
  final double loop;
  const _OrbsPainter({required this.orbs, required this.loop});

  @override
  void paint(Canvas canvas, Size size) {
    for (final o in orbs) {
      final phase = (loop + o.phase) % 1.0;
      final dx = math.sin(phase * math.pi * 2 + o.phase * 6) * 10.0;
      final dy = -(phase * size.height * 0.36);
      final rawOp = math.sin(phase * math.pi).clamp(0.0, 1.0);
      final opacity = rawOp * 0.32;
      if (opacity <= 0) continue;

      final rect = Rect.fromLTWH(
        o.x * size.width + dx,
        o.y * size.height + dy,
        o.radius * 2,
        o.radius * 2,
      );

      final p = Paint()
        ..color = (o.gold ? SplashColors.gold : Colors.white70).withValues(
          alpha: opacity,
        );

      canvas.drawCircle(rect.center, o.radius, p);
    }
  }

  @override
  bool shouldRepaint(_OrbsPainter o) => o.loop != loop;
}

// ── Rehal + Quran book ────────────────────────────────────────────────────────
class _BookPainter extends CustomPainter {
  final double rehalAppear;
  final double bookDrop;
  final double openProgress;
  final double glowProgress;
  final double lightAnim;
  final double loopAnim;

  const _BookPainter({
    required this.rehalAppear,
    required this.bookDrop,
    required this.openProgress,
    required this.glowProgress,
    required this.lightAnim,
    required this.loopAnim,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2; // 180 when size.width = 360

    // Layout constants (local, relative to this 360×340 painter canvas)
    const bookH = 95.0;
    const bookBot = 197.0; // Fixed position since shelf is removed
    const bookTop = bookBot - bookH;
    final ow = 86.0 * openProgress;

    // Removed Rehal stand and shadow as per user request

    // ── Quran book ────────────────────────────────────────────────────────
    if (bookDrop <= 0) return;

    final dropOffset = (1.0 - bookDrop) * -58.0;
    final squeeze = bookDrop > 0.9
        ? 1.0 - math.sin((bookDrop - 0.9) * math.pi / 0.1) * 0.025
        : 1.0;

    canvas.save();
    canvas.translate(0, dropOffset);
    // Squeeze vertically on bounce impact
    canvas.scale(1.0, squeeze);

    _drawBookGlow(canvas, cx, bookTop, bookH, glowProgress);
    _drawLightBeam(canvas, cx, bookTop, bookH, lightAnim);

    if (openProgress < 0.04) {
      _drawClosedBook(canvas, cx, bookTop, bookH);
      canvas.restore();
      return;
    }

    _drawPages(canvas, cx, bookTop, bookBot, bookH, ow);
    _drawCovers(
      canvas,
      cx,
      bookTop,
      bookBot,
      bookH,
      ow,
      glowProgress,
      openProgress,
    );
    _drawSpine(canvas, cx, bookTop, bookBot, openProgress);
    if (openProgress > 0.30) {
      _drawPageDecor(
        canvas,
        cx,
        bookTop,
        bookH,
        ow,
        openProgress,
        glowProgress,
      );
    }
    if (openProgress > 0.66) {
      _drawBookmark(canvas, cx, bookTop, bookH, ow, openProgress);
    }

    canvas.restore();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _drawBookGlow(
    Canvas c,
    double cx,
    double bookTop,
    double bookH,
    double glow,
  ) {
    if (glow <= 0) return;
    final gg =
        RadialGradient(
          colors: [
            SplashColors.gold.withValues(alpha: 0.48 * glow),
            SplashColors.gold.withValues(alpha: 0.16 * glow),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(
          Rect.fromCenter(
            center: Offset(cx, bookTop + bookH * 0.5),
            width: 260,
            height: 260,
          ),
        );
    c.drawCircle(Offset(cx, bookTop + bookH * 0.5), 130, Paint()..shader = gg);
  }

  void _drawLightBeam(
    Canvas c,
    double cx,
    double bookTop,
    double bookH,
    double la,
  ) {
    if (la <= 0) return;

    // Add a pulsing effect using loopAnim
    final pulse = 0.9 + 0.1 * math.sin(loopAnim * math.pi * 2);
    final opPulse = la * (0.8 + 0.2 * math.sin(loopAnim * math.pi * 4));

    // Cone
    final bg =
        LinearGradient(
          colors: [
            const Color(0xFFFFFCC8).withValues(alpha: 0.15 * opPulse),
            const Color(0xFFFFF8B4).withValues(alpha: 0.25 * opPulse),
            const Color(0xFFFFF5A0).withValues(alpha: 0.08 * opPulse),
          ],
          stops: const [0, 0.7, 1],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(
          Rect.fromLTWH(0, bookTop - 180 * pulse, 1, bookH + 190 * pulse),
        );

    final cone = Path()
      ..moveTo(cx - 80 * pulse, bookTop - 180 * pulse)
      ..lineTo(cx + 80 * pulse, bookTop - 180 * pulse)
      ..lineTo(cx + 15, bookTop + 10)
      ..lineTo(cx - 15, bookTop + 10)
      ..close();
    c.drawPath(cone, Paint()..shader = bg);

    // Hotspot on pages
    final hs =
        RadialGradient(
          colors: [
            const Color(0xFFFFFCDC).withValues(alpha: 0.65 * la),
            const Color(0xFFFFF0A0).withValues(alpha: 0.22 * la),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCenter(
            center: Offset(cx, bookTop + bookH * 0.28),
            width: 120,
            height: 120,
          ),
        );
    c.drawCircle(
      Offset(cx, bookTop + bookH * 0.28),
      60 * pulse,
      Paint()..shader = hs,
    );
  }

  void _drawClosedBook(Canvas c, double cx, double bookTop, double bookH) {
    final rr = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 9, bookTop - 2, 18, bookH * 1.04),
      const Radius.circular(3),
    );
    c.drawRRect(rr, Paint()..color = const Color(0xFF091812));
    c.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = SplashColors.gold,
    );
    c.drawCircle(
      Offset(cx, bookTop + bookH * 0.5),
      7,
      Paint()..color = SplashColors.gold.withValues(alpha: 0.72),
    );
  }

  void _drawPages(
    Canvas c,
    double cx,
    double bookTop,
    double bookBot,
    double bookH,
    double ow,
  ) {
    final pg = LinearGradient(
      colors: const [
        Color(0xFFEDE0B0),
        Color(0xFFF8F0D8),
        Color(0xFFF8F0D8),
        Color(0xFFF5EAC0),
      ],
      stops: const [0.0, 0.44, 0.56, 1.0],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(Rect.fromLTWH(cx - ow, bookTop, ow * 2, bookH));
    final pagePaint = Paint()..shader = pg;

    // Left page
    final lp = Path()
      ..moveTo(cx, bookBot)
      ..cubicTo(
        cx - ow * 0.28,
        bookBot - 5,
        cx - ow * 0.72,
        bookTop + 11,
        cx - ow,
        bookTop + 4,
      )
      ..lineTo(cx - ow - 3, bookTop - 4)
      ..cubicTo(
        cx - ow * 0.72,
        bookTop + 1,
        cx - ow * 0.28,
        bookTop - 13,
        cx,
        bookBot - 7,
      )
      ..close();
    c.drawPath(lp, pagePaint);

    // Right page
    final rp = Path()
      ..moveTo(cx, bookBot)
      ..cubicTo(
        cx + ow * 0.28,
        bookBot - 5,
        cx + ow * 0.72,
        bookTop + 11,
        cx + ow,
        bookTop + 4,
      )
      ..lineTo(cx + ow + 3, bookTop - 4)
      ..cubicTo(
        cx + ow * 0.72,
        bookTop + 1,
        cx + ow * 0.28,
        bookTop - 13,
        cx,
        bookBot - 7,
      )
      ..close();
    c.drawPath(rp, pagePaint);

    // Page stack edge lines
    final ep = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = const Color(0xFF968C3C).withValues(alpha: 0.20);
    for (int i = 1; i <= 4; i++) {
      final o2 = i * 1.5;
      c.drawPath(
        Path()
          ..moveTo(cx, bookBot + o2)
          ..cubicTo(
            cx - ow * 0.28,
            bookBot - 5 + o2,
            cx - ow * 0.72,
            bookTop + 11 + o2,
            cx - ow,
            bookTop + 4 + o2,
          ),
        ep,
      );
      c.drawPath(
        Path()
          ..moveTo(cx, bookBot + o2)
          ..cubicTo(
            cx + ow * 0.28,
            bookBot - 5 + o2,
            cx + ow * 0.72,
            bookTop + 11 + o2,
            cx + ow,
            bookTop + 4 + o2,
          ),
        ep,
      );
    }
  }

  void _drawCovers(
    Canvas c,
    double cx,
    double bookTop,
    double bookBot,
    double bookH,
    double ow,
    double glow,
    double open,
  ) {
    final cw = ow * 1.1;
    for (final s in [-1.0, 1.0]) {
      final coverGrad = LinearGradient(
        colors: const [Color(0xFF0F2818), Color(0xFF102015), Color(0xFF071008)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(cx - cw, bookTop - 10, cw * 2, bookH + 30));

      final cover = Path()
        ..moveTo(cx, bookBot + 3)
        ..cubicTo(
          cx + s * cw * 0.28,
          bookBot - 4,
          cx + s * cw * 0.72,
          bookTop + 10,
          cx + s * cw,
          bookTop + 2,
        )
        ..lineTo(cx + s * cw + s * 3, bookTop - 7)
        ..cubicTo(
          cx + s * cw * 0.72,
          bookTop - 1,
          cx + s * cw * 0.28,
          bookTop - 14,
          cx,
          bookBot - 7,
        )
        ..close();

      c.drawPath(cover, Paint()..shader = coverGrad);
      c.drawPath(
        cover,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..color = SplashColors.gold.withValues(alpha: glow * 0.88),
      );

      // Bevel highlight on top edge
      c.drawPath(
        Path()
          ..moveTo(cx, bookBot - 7)
          ..cubicTo(
            cx + s * cw * 0.28,
            bookTop - 14,
            cx + s * cw * 0.72,
            bookTop - 1,
            cx + s * cw + s * 3,
            bookTop - 7,
          ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = Colors.white.withValues(alpha: 0.11 * glow),
      );
    }
  }

  void _drawSpine(
    Canvas c,
    double cx,
    double bookTop,
    double bookBot,
    double open,
  ) {
    c.drawLine(
      Offset(cx, bookBot - 7),
      Offset(cx, bookTop - 3),
      Paint()
        ..strokeWidth = 1.8
        ..color = SplashColors.gold.withValues(alpha: 0.58 * open),
    );
  }

  void _drawPageDecor(
    Canvas c,
    double cx,
    double bookTop,
    double bookH,
    double ow,
    double open,
    double glow,
  ) {
    final df = ((open - 0.30) / 0.70).clamp(0.0, 1.0) * glow;

    final frame = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = SplashColors.gold.withValues(alpha: df * 0.80);

    for (final s in [-1.0, 1.0]) {
      c.drawPath(
        Path()
          ..moveTo(cx + s * ow * 0.10, bookTop + bookH - 10)
          ..cubicTo(
            cx + s * ow * 0.34,
            bookTop + bookH - 18,
            cx + s * ow * 0.78,
            bookTop + 16,
            cx + s * ow * 0.88,
            bookTop + 5,
          )
          ..lineTo(cx + s * ow * 0.88, bookTop + 1)
          ..cubicTo(
            cx + s * ow * 0.78,
            bookTop + 8,
            cx + s * ow * 0.34,
            bookTop - 11,
            cx + s * ow * 0.10,
            bookTop - 3,
          )
          ..close(),
        frame,
      );
      // Header ornament box
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cx + s * ow * 0.11, bookTop + 4, ow * 0.7, 8),
          const Radius.circular(2),
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.75
          ..color = SplashColors.gold.withValues(alpha: df * 0.55),
      );
    }

    // Decorative text lines
    final lp = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = const Color(0xFF8B7040).withValues(alpha: df * 0.28);
    for (int i = 0; i < 8; i++) {
      final ly = bookTop + 20.0 + i * 8;
      for (final s in [-1.0, 1.0]) {
        c.drawLine(
          Offset(cx + s * ow * 0.11, ly),
          Offset(cx + s * ow * 0.82, ly - 1),
          lp,
        );
      }
    }
  }

  void _drawBookmark(
    Canvas c,
    double cx,
    double bookTop,
    double bookH,
    double ow,
    double open,
  ) {
    final tf = ((open - 0.66) / 0.34).clamp(0.0, 1.0);
    final tasselEnd = bookTop + bookH * 0.62 * tf;
    final tassel = Path()
      ..moveTo(cx + ow * 0.06, bookTop + 2)
      ..lineTo(cx + ow * 0.13, tasselEnd)
      ..lineTo(cx + ow * 0.19, tasselEnd)
      ..lineTo(cx + ow * 0.26, bookTop + 2)
      ..close();
    c.drawPath(
      tassel,
      Paint()..color = SplashColors.gold.withValues(alpha: tf * 0.85),
    );
    c.drawCircle(
      Offset(cx + ow * 0.16, tasselEnd),
      2.4,
      Paint()..color = const Color(0xFFFFD060),
    );
  }

  @override
  bool shouldRepaint(_BookPainter o) =>
      o.rehalAppear != rehalAppear ||
      o.bookDrop != bookDrop ||
      o.openProgress != openProgress ||
      o.glowProgress != glowProgress ||
      o.lightAnim != lightAnim ||
      o.loopAnim != loopAnim;
}

// =============================================================================
// DATA CLASSES
// =============================================================================

class _FloatOrb {
  final double x, y, radius, speed, phase;
  final bool gold;
  const _FloatOrb({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.gold,
  });
}

class _TwinkleStar {
  final double x, y, size, speed, phase;
  const _TwinkleStar({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
  });
}

class _DustMote {
  final double x, y, speed, phase, radius;
  const _DustMote({
    required this.x,
    required this.y,
    required this.speed,
    required this.phase,
    required this.radius,
  });
}
