import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../shared/widgets/main_shell.dart';
import '../widgets/topic_card.dart';

class OrbitCardSpec {
  final String title;
  final String subtitle;
  final IconData icon;
  final double radius;
  final double baseAngle;
  final double speed;
  final double baseRot;
  final double floatAmp;

  const OrbitCardSpec({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.radius,
    required this.baseAngle,
    required this.speed,
    required this.baseRot,
    this.floatAmp = 8,
  });

  Key get key => ValueKey('orbit_card_$title');
  Key get floatKey => ValueKey('orbit_float_$title');
}

const List<OrbitCardSpec> orbitCards = [
  OrbitCardSpec(
    title: 'Talawat',
    subtitle: 'Read & Listen',
    icon: Icons.menu_book_rounded,
    radius: 295,
    baseAngle: -1.66,
    speed: 0.28,
    baseRot: 0.00,
    floatAmp: 7,
  ),
  OrbitCardSpec(
    title: 'Translation',
    subtitle: 'Understand',
    icon: Icons.translate,
    radius: 280,
    baseAngle: -2.48,
    speed: 0.34,
    baseRot: -0.02,
    floatAmp: 9,
  ),
  OrbitCardSpec(
    title: 'Tafseer',
    subtitle: 'Go Deeper',
    icon: Icons.auto_stories_rounded,
    radius: 300,
    baseAngle: -0.80,
    speed: 0.25,
    baseRot: 0.02,
    floatAmp: 8,
  ),
  OrbitCardSpec(
    title: 'Ahadees',
    subtitle: 'Learn & Reflect',
    icon: Icons.mosque,
    radius: 335,
    baseAngle: -0.28,
    speed: 0.22,
    baseRot: 0.03,
    floatAmp: 9,
  ),
  OrbitCardSpec(
    title: 'Prayer',
    subtitle: 'Stay Connected',
    icon: Icons.self_improvement,
    radius: 315,
    baseAngle: 2.42,
    speed: 0.30,
    baseRot: -0.02,
    floatAmp: 8,
  ),
  OrbitCardSpec(
    title: 'Progress',
    subtitle: 'Be Better',
    icon: Icons.trending_up_rounded,
    radius: 350,
    baseAngle: 1.78,
    speed: 0.26,
    baseRot: -0.01,
    floatAmp: 9,
  ),
  OrbitCardSpec(
    title: 'Personal Growth',
    subtitle: 'Build Your Best Self',
    icon: Icons.person_outline_rounded,
    radius: 355,
    baseAngle: 0.62,
    speed: 0.20,
    baseRot: 0.03,
    floatAmp: 8,
  ),
];

const List<double> _floatPhases = [0.0, 0.14, 0.28, 0.43, 0.57, 0.71, 0.85];

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const String _bgPath = 'assets/category_images/splash_image.png';
  static const String _logoPath = 'assets/images/applogo.png';

  static const double _canvasW = 1024;
  static const double _canvasH = 1536;
  static const Offset _orbitCenter = Offset(512, 860);
  static const double _cardW = 165;
  static const double _cardH = 132;

  static const double _logoTop = 100;
  static const double _logoLeft = 312;
  static const double _logoWidth = 400;
  static const double _logoHeight = 420;

  late final AnimationController _orbit;
  Timer? _enterTimer;
  bool _bgReady = false;
  bool _logoReady = false;
  bool _animStarted = false;
  bool _precacheStarted = false;

  @override
  void initState() {
    super.initState();
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
      value: 0,
    );
    _enterTimer = Timer(const Duration(seconds: 6), _enterApp);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_precacheStarted) {
      _precacheStarted = true;
      _precacheAssets();
    }
    if (!_animStarted) {
      _animStarted = true;
      if (!MediaQuery.disableAnimationsOf(context)) {
        _orbit.repeat();
      }
    }
  }

  Future<void> _precacheAssets() async {
    try {
      await rootBundle.load(_bgPath);
      if (!mounted) return;
      await precacheImage(const AssetImage(_bgPath), context);
      if (mounted) setState(() => _bgReady = true);
    } catch (_) {}

    try {
      await rootBundle.load(_logoPath);
      if (!mounted) return;
      await precacheImage(const AssetImage(_logoPath), context);
      if (mounted) setState(() => _logoReady = true);
    } catch (_) {}
  }

  void _enterApp() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainShell(),
        transitionDuration: const Duration(milliseconds: 450),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _enterTimer?.cancel();
    _orbit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      body: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: _canvasW,
            height: _canvasH,
            child: Stack(
              children: [
                Positioned.fill(
                  key: const ValueKey('ambient_wash_layer'),
                  child: _bgReady
                      ? Image.asset(
                          _bgPath,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                        )
                      : const ColoredBox(color: Color(0xFFF8F6F0)),
                ),
                Positioned(
                  top: _logoTop,
                  left: _logoLeft,
                  width: _logoWidth,
                  height: _logoHeight,
                  child: Center(
                    child: _logoReady
                        ? Image.asset(
                            _logoPath,
                            fit: BoxFit.contain,
                            gaplessPlayback: true,
                            errorBuilder: (_, __, ___) =>
                                const _LogoFallback(),
                          )
                        : const _LogoFallback(),
                  ),
                ),
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _orbit,
                    builder: (context, _) {
                      final value =
                          reduceMotion ? 0.0 : _orbit.value;
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          for (var i = 0; i < orbitCards.length; i++)
                            _positionCard(i, value),
                        ],
                      );
                    },
                  ),
                ),
                const Positioned(
                  top: 1330,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'Your Complete Islamic Companion',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 23,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF1B5E48),
                        letterSpacing: 6.5,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 1392,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _pill(const Color(0xFF0E4D3C)),
                        const SizedBox(width: 10),
                        _pill(const Color(0xFFD5DDD8)),
                        const SizedBox(width: 10),
                        _pill(const Color(0xFFD5DDD8)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pill(Color color) {
    return Container(
      width: 45,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _positionCard(int index, double value) {
    final spec = orbitCards[index];
    final phase = _floatPhases[index];
    final tFloat = math.sin(2 * math.pi * (value + phase));

    final orbitAngle =
        spec.baseAngle + 2 * math.pi * value * spec.speed;
    final cx = _orbitCenter.dx + spec.radius * math.cos(orbitAngle);
    final cy = _orbitCenter.dy + spec.radius * math.sin(orbitAngle);

    final left = cx - _cardW / 2;
    final top = cy - _cardH / 2 + tFloat * spec.floatAmp;
    final rot = spec.baseRot + tFloat * 0.008;

    return Positioned(
      left: left,
      top: top,
      child: Transform.translate(
        key: spec.floatKey,
        offset: Offset.zero,
        child: Transform.rotate(
          angle: rot,
          child: TopicCard(
            key: spec.key,
            icon: spec.icon,
            title: spec.title,
            subtitle: spec.subtitle,
          ),
        ),
      ),
    );
  }
}

class _LogoFallback extends StatelessWidget {
  const _LogoFallback();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        SizedBox(
          width: 130,
          height: 130,
          child: Icon(
            Icons.mosque,
            color: Color(0xFF0E4D3C),
            size: 84,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'ASK IMAN',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 46,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0E4D3C),
            letterSpacing: 1,
            height: 1.0,
          ),
        ),
        SizedBox(height: 10),
        SizedBox(
          width: 90,
          height: 2.5,
          child: ColoredBox(color: Color(0xFFC9A24B)),
        ),
        SizedBox(height: 8),
        Text(
          'ISLAMIC GUIDANCE',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFFC9A24B),
            letterSpacing: 5,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
