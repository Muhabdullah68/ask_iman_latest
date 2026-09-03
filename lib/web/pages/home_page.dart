// lib/web/pages/home_page.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — PAGE 1 · HOME (PREMIUM)
//
// Classy Islamic landing page:
//   • Auto-rotating AYAT SLIDER hero — curated verses over rich per-slide
//     color gradients with gold ornamental patterns, fade/scale transitions,
//     pause-on-hover, progress dots and an overlaid search bar.
//   • Image-backed feature tiles routing into the Quran Explorer.
//   • Daily Inspiration spotlight over a mosque backdrop.
//   • Sacred Collections as a bookshelf of classic book covers.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/figma_tokens.dart';
import '../../core/data/daily_data.dart';
import '../../features/quran/data/ahadees_data.dart';
import '../widgets/web_widgets.dart';
import '../widgets/web_footer.dart';
import '../widgets/web_animations.dart';
import '../web_router.dart' show WebRoutes;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return WebPageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const _AyatSlider(),
          const SizedBox(height: 72),
          const ScrollReveal(
            duration: Duration(milliseconds: 600),
            slideOffset: Offset(0, 30),
            child: _FeatureTiles(),
          ),
          const SizedBox(height: 72),
          const ScrollReveal(
            delay: Duration(milliseconds: 100),
            duration: Duration(milliseconds: 600),
            slideOffset: Offset(0, 30),
            child: _DailyInspiration(),
          ),
          const SizedBox(height: 72),
          const ScrollReveal(
            delay: Duration(milliseconds: 200),
            duration: Duration(milliseconds: 600),
            slideOffset: Offset(0, 30),
            child: _SacredCollections(),
          ),
          const SizedBox(height: 72),
          const WebFooter(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AYAT SLIDER HERO
// ─────────────────────────────────────────────────────────────────────────────
class _SlideData {
  final String arabic;
  final String translation;
  final String reference;
  final Color accent;
  const _SlideData({
    required this.arabic,
    required this.translation,
    required this.reference,
    required this.accent,
  });
}

const List<_SlideData> _slides = [
  _SlideData(
    arabic: 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
    translation:
        'Allah does not burden a soul beyond that it can bear.',
    reference: 'Al-Baqarah 2:286',
    accent: Color(0xFF0C3A2C),
  ),
  _SlideData(
    arabic: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
    translation: 'For indeed, with hardship comes ease.',
    reference: 'Ash-Sharh 94:6',
    accent: Color(0xFF0B3A40),
  ),
  _SlideData(
    arabic: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
    translation: 'Verily, in the remembrance of Allah do hearts find rest.',
    reference: "Ar-Ra'd 13:28",
    accent: Color(0xFF4A3316),
  ),
  _SlideData(
    arabic:
        'وَيُطْعِمُونَ الطَّعَامَ عَلَىٰ حُبِّهِ مِسْكِينًا وَيَتِيمًا وَأَسِيرًا',
    translation:
        'And they give food, in spite of love for it, to the needy, the orphan and the captive.',
    reference: 'Al-Insan 76:8',
    accent: Color(0xFF431F24),
  ),
  _SlideData(
    arabic:
        'قُلْ يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا عَلَىٰ أَنفُسِهِمْ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ',
    translation:
        'Say: O My servants who have transgressed against themselves, do not despair of the mercy of Allah.',
    reference: 'Az-Zumar 39:53',
    accent: Color(0xFF1B2A4A),
  ),
];

Color _lighten(Color c, double t) => Color.lerp(c, Colors.white, t) ?? c;

Color _darken(Color c, double t) => Color.lerp(c, Colors.black, t) ?? c;

class _AyatSlider extends StatefulWidget {
  const _AyatSlider();

  @override
  State<_AyatSlider> createState() => _AyatSliderState();
}

class _AyatSliderState extends State<_AyatSlider> {
  static const _interval = Duration(seconds: 5);

  final TextEditingController _search = TextEditingController();
  Timer? _timer;
  int _index = 0;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) {
      if (_paused) return;
      if (mounted) _next();
    });
  }

  void _next() {
    setState(() => _index = (_index + 1) % _slides.length);
  }

  void _prev() {
    setState(() => _index = (_index - 1 + _slides.length) % _slides.length);
  }

  void _submitSearch() {
    final q = _search.text.trim();
    if (q.isEmpty) return;
    context.go('/search?q=${Uri.encodeComponent(q)}');
  }

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    final slide = _slides[_index];

    return MouseRegion(
      onEnter: (_) {
        setState(() => _paused = true);
        _timer?.cancel();
      },
      onExit: (_) {
        setState(() => _paused = false);
        _startTimer();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 820;
          return GestureDetector(
            onHorizontalDragEnd: (d) {
              if (d.primaryVelocity != null && d.primaryVelocity! < -120) {
                _next();
              } else if (d.primaryVelocity != null &&
                  d.primaryVelocity! > 120) {
                _prev();
              }
            },
            child: Stack(
              children: [
                // ── Background color + ornament + glow ─────────────────────
                Positioned.fill(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 700),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: Container(
                      key: ValueKey<int>(_index),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _lighten(slide.accent, 0.22),
                            slide.accent,
                            _darken(slide.accent, 0.30),
                          ],
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Stack(
                          children: [
                            Positioned(
                              top: -150,
                              left: -130,
                              child: Container(
                                width: 440,
                                height: 440,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      figma.accentGoldLight.withValues(
                                        alpha: 0.22,
                                      ),
                                      figma.accentGoldLight.withValues(
                                        alpha: 0.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -180,
                              right: -160,
                              child: Container(
                                width: 480,
                                height: 480,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.10),
                                      Colors.white.withValues(alpha: 0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: IgnorePointer(
                                child: CustomPaint(
                                  painter: _OrnamentPainter(
                                    color: figma.accentGoldLight
                                        .withValues(alpha: 0.08),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // ── Content ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(36),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.985, end: 1.0)
                              .animate(anim),
                          child: child,
                        ),
                      ),
                      child: Column(
                        key: ValueKey<int>(_index),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: figma.accentGoldAmber,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'AYAH OF THE MOMENT',
                                  style: TextStyle(
                                    fontFamily: FigmaTokens.fontFamilyUiSans,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.6,
                                    color: FigmaTokens.textOnDark,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                slide.reference,
                                style: TextStyle(
                                  fontFamily: FigmaTokens.fontFamilyUiSans,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: figma.accentGoldLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          Text(
                            slide.arabic,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontFamily: FigmaTokens.fontFamilyArabicSerif,
                              fontSize: 34,
                              height: 1.9,
                              color: FigmaTokens.textOnDark,
                              shadows: [
                                Shadow(
                                  blurRadius: 22,
                                  color: Color(0x60000000),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            width: 72,
                            height: 3,
                            decoration: BoxDecoration(
                              color: figma.accentGoldAmber,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            slide.translation,
                            style: TextStyle(
                              fontFamily: FigmaTokens.fontFamilyUiSans,
                              fontSize: wide ? 16.5 : 14.5,
                              height: 1.6,
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                          const SizedBox(height: 30),
                          // ── Search bar ──────────────────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.22,
                                      ),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _search,
                                    onSubmitted: (_) => _submitSearch(),
                                    textInputAction: TextInputAction.search,
                                    style: const TextStyle(
                                      fontFamily: FigmaTokens.fontFamilyUiSans,
                                      fontSize: 14.5,
                                      color: FigmaTokens.textOnDark,
                                    ),
                                    decoration: InputDecoration(
                                      hintText:
                                          'Search Quran, surah, hadith or topic…',
                                      hintStyle: TextStyle(
                                        fontFamily:
                                            FigmaTokens.fontFamilyUiSans,
                                        fontSize: 14,
                                        color: Colors.white.withValues(
                                          alpha: 0.6,
                                        ),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search_rounded,
                                        color: figma.accentGoldLight,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (wide)
                                SizedBox(
                                  height: 54,
                                  child: ElevatedButton.icon(
                                    onPressed: _submitSearch,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          figma.accentGoldAmber,
                                      foregroundColor: FigmaTokens.textOnDark,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 22,
                                      ),
                                    ),
                                    icon: const Icon(Icons.search_rounded,
                                        size: 18),
                                    label: const Text(
                                      'Search',
                                      style: TextStyle(
                                        fontFamily:
                                            FigmaTokens.fontFamilyUiSans,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 26),
                          // ── Dots + arrows (in-flow, no overlap) ─────────
                          Row(
                            children: [
                              for (var i = 0; i < _slides.length; i++) ...[
                                if (i > 0) const SizedBox(width: 7),
                                AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 300),
                                  width: i == _index ? 30 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: i == _index
                                        ? figma.accentGoldAmber
                                        : Colors.white.withValues(alpha: 0.35),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ],
                              const Spacer(),
                              _SliderArrow(
                                icon: Icons.chevron_left_rounded,
                                onTap: _prev,
                              ),
                              const SizedBox(width: 8),
                              _SliderArrow(
                                icon: Icons.chevron_right_rounded,
                                onTap: _next,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SliderArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SliderArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: Icon(icon, color: figma.accentGoldLight, size: 22),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FEATURE TILES (image-backed, 6-up)
// ─────────────────────────────────────────────────────────────────────────────
class _FeatureTiles extends StatelessWidget {
  const _FeatureTiles();

  static const _tiles = [
    (
      icon: Icons.menu_book_rounded,
      label: 'Quran Shareef',
      subtitle: 'Read & listen',
      route: WebRoutes.quran,
      image: 'assets/images/Holy Quran.png',
    ),
    (
      icon: Icons.format_quote_rounded,
      label: 'Daily Ayats',
      subtitle: 'Curated topics',
      route: '${WebRoutes.quran}/ayah',
      image: 'assets/images/islamic lanterns.png',
    ),
    (
      icon: Icons.collections_bookmark_rounded,
      label: 'Ahadees',
      subtitle: '6 authentic books',
      route: '${WebRoutes.quran}/hadith',
      image: 'assets/images/mosque.png',
    ),
    (
      icon: Icons.headphones_rounded,
      label: 'Talawat',
      subtitle: 'Surah audio',
      route: '${WebRoutes.quran}/talawat',
      image: 'assets/images/tasbih beads.png',
    ),
    (
      icon: Icons.translate_rounded,
      label: 'Tarjuma',
      subtitle: 'EN / اردو',
      route: '${WebRoutes.quran}/translation',
      image: 'assets/images/Kaaba.png',
    ),
    (
      icon: Icons.auto_stories_rounded,
      label: 'Tafseer',
      subtitle: 'Ibn Kathir & more',
      route: '${WebRoutes.quran}/tafseer',
      image: 'assets/images/mosque interior.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const WebSectionHeader(
          eyebrow: 'Explore Your Deen',
          title: 'Begin Your Sacred Journey',
          subtitle:
              'Everything you need to connect, learn and grow — all in one place.',
        ),
        const SizedBox(height: 28),
        LayoutBuilder(
          builder: (context, constraints) {
            final cols = constraints.maxWidth >= 900
                ? 3
                : (constraints.maxWidth >= 560 ? 2 : 1);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: cols >= 3 ? 1.35 : 1.6,
              ),
              itemCount: _tiles.length,
              itemBuilder: (_, i) {
                final t = _tiles[i];
                return _ImageFeatureTile(
                  icon: t.icon,
                  label: t.label,
                  subtitle: t.subtitle,
                  image: t.image,
                  onTap: () => context.go(t.route),
                )
                    .animate(delay: Duration(milliseconds: 100 + i * 80))
                    .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
                    .slideY(
                      begin: 0.15,
                      end: 0,
                      duration: 400.ms,
                      curve: Curves.easeOutCubic,
                    );
              },
            );
          },
        ),
      ],
    );
  }
}

class _ImageFeatureTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final String image;
  final VoidCallback onTap;

  const _ImageFeatureTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return HoverLift(
      onTap: onTap,
      lift: 1.03,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: figma.surfaceCard,
          borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
          border: Border.all(color: figma.borderHairline),
          boxShadow: figma.cardShadows,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: figma.surfacePanelMint,
                      child: Icon(icon,
                          size: 40, color: FigmaTokens.brandMidGreen),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          FigmaTokens.brandDeepGreen.withValues(alpha: 0.35),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    bottom: 12,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: figma.surfaceCard,
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: figma.cardShadows,
                      ),
                      child: Icon(icon,
                          color: FigmaTokens.brandDeepGreen, size: 21),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: figma.textHeading,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: FigmaTokens.fontFamilyUiSans,
                            fontSize: 11.5,
                            color: figma.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: figma.accentGoldAmber,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DAILY INSPIRATION
// ─────────────────────────────────────────────────────────────────────────────
class _DailyInspiration extends StatelessWidget {
  const _DailyInspiration();

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    final ayahs = DailyData.getDailyAyahs(5);
    final dua = DailyData.getDailyDua();
    final ayah = ayahs.isNotEmpty ? ayahs.first : null;

    final panel = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        boxShadow: figma.cardShadows,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/mosque interior.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: figma.surfacePanelMint,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    figma.surfaceCard.withValues(alpha: 0.96),
                    figma.surfacePanelMint.withValues(alpha: 0.92),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: figma.accentGoldAmber,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'DAILY INSPIRATION',
                    style: TextStyle(
                      fontFamily: FigmaTokens.fontFamilyUiSans,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      color: FigmaTokens.textOnDark,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (ayah != null) ...[
                  Text(
                    ayah['arabic'] ?? '',
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontFamily: FigmaTokens.fontFamilyArabicSerif,
                      fontSize: 26,
                      height: 1.9,
                      color: FigmaTokens.brandDeepGreen,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    ayah['translation'] ?? '',
                    style: TextStyle(
                      fontFamily: FigmaTokens.fontFamilyUiSans,
                      fontSize: 15,
                      height: 1.6,
                      color: figma.textBody,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ayah['reference'] ?? '',
                    style: TextStyle(
                      fontFamily: FigmaTokens.fontFamilyUiSans,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: figma.accentGoldAmber,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                if (dua['arabic'] != null) ...[
                  Divider(color: figma.borderHairline),
                  const SizedBox(height: 14),
                  Text(
                    'Today\u2019s Dua',
                    style: TextStyle(
                      fontFamily: FigmaTokens.fontFamilyUiSans,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: figma.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dua['arabic'] ?? '',
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontFamily: FigmaTokens.fontFamilyArabicSerif,
                      fontSize: 20,
                      height: 1.8,
                      color: FigmaTokens.brandDeepGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dua['translation'] ?? '',
                    style: TextStyle(
                      fontFamily: FigmaTokens.fontFamilyUiSans,
                      fontSize: 13,
                      height: 1.55,
                      color: figma.textBody,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    WebButton(
                      label: 'Explore Quran',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () => context.go(WebRoutes.quran),
                    ),
                    const SizedBox(width: 12),
                    WebButton(
                      label: 'View Tafseer',
                      outlined: true,
                      onPressed: () =>
                          context.go('${WebRoutes.quran}/tafseer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final ornament = Center(
      child: SizedBox(
        width: 180,
        height: 180,
        child: CustomPaint(
          painter: _StarOrnamentPainter(
            accentGoldAmber: figma.accentGoldAmber,
            surfaceCardColor: figma.surfaceCard,
          ),
        ),
      ).animate(
        onPlay: (controller) => controller.repeat(reverse: false),
      ).rotate(
        begin: 0,
        end: 1,
        duration: const Duration(seconds: 60),
        curve: Curves.linear,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const WebSectionHeader(
          eyebrow: 'Reflect',
          title: 'Daily Inspiration',
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 800) {
              return Column(
                children: [panel, const SizedBox(height: 16), ornament],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 6, child: panel),
                Expanded(flex: 2, child: ornament),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SACRED COLLECTIONS (bookshelf)
// ─────────────────────────────────────────────────────────────────────────────
class _SacredCollections extends StatelessWidget {
  const _SacredCollections();

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    final books = AhadeesData.books.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WebSectionHeader(
          eyebrow: 'Library',
          title: 'Sacred Collections',
          subtitle: 'Authentic hadith books, curated for daily guidance.',
          actionLabel: 'View All',
          onAction: () => context.go('${WebRoutes.quran}/hadith'),
        ),
        const SizedBox(height: 24),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
            boxShadow: figma.cardShadows,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/bgcolor.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: figma.surfacePanelMint,
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        FigmaTokens.brandDeepGreen.withValues(alpha: 0.9),
                        FigmaTokens.brandDeepGreen.withValues(alpha: 0.96),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.collections_bookmark_rounded,
                          color: figma.accentGoldAmber,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Authentic Hadith Library',
                            style: TextStyle(
                              fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: FigmaTokens.textOnDark,
                            ),
                          ),
                        ),
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: figma.accentGoldAmber
                                .withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: figma.accentGoldAmber
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          child: Icon(
                            Icons.auto_stories_rounded,
                            color: figma.accentGoldLight,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 760;
                        final row = Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (var i = 0; i < books.length; i++) ...[
                              if (i > 0) const SizedBox(width: 20),
                              Expanded(
                                child: _BookCard(book: books[i], index: i),
                              ),
                            ],
                          ],
                        );
                        return wide
                            ? row
                            : Column(
                                children: [
                                  for (var i = 0;
                                      i < books.length;
                                      i++) ...[
                                    if (i > 0) const SizedBox(height: 16),
                                    _BookCard(book: books[i], index: i),
                                  ],
                                ],
                              );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookCard extends StatelessWidget {
  final String book;
  final int index;
  const _BookCard({required this.book, required this.index});

  static const _covers = [
    [Color(0xFF14532D), Color(0xFF0F3D23)],
    [Color(0xFF0F3D4C), Color(0xFF0B2B34)],
    [Color(0xFF3D2B0F), Color(0xFF2A1E0A)],
  ];

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    final cover = _covers[index % _covers.length];
    return HoverLift(
      onTap: () => context.go('${WebRoutes.quran}/hadith'),
      lift: 1.04,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Row(
          children: [
            // Book cover
            Container(
              width: 62,
              height: 88,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
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
                    color: Colors.black38,
                    blurRadius: 8,
                    offset: Offset(2, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 30,
                    height: 2,
                    color: figma.accentGoldAmber.withValues(alpha: 0.8),
                  ),
                  const SizedBox(height: 6),
                  Icon(
                    Icons.menu_book_rounded,
                    color: figma.accentGoldLight,
                    size: 18,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 30,
                    height: 2,
                    color: figma.accentGoldAmber.withValues(alpha: 0.8),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: FigmaTokens.textOnDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${index + 1}. Authentic collection',
                    style: TextStyle(
                      fontFamily: FigmaTokens.fontFamilyUiSans,
                      fontSize: 11.5,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: figma.accentGoldAmber,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 8-point star ornament ─────────────────────────────────────────────────
class _StarOrnamentPainter extends CustomPainter {
  final Color accentGoldAmber;
  final Color surfaceCardColor;
  _StarOrnamentPainter({
    required this.accentGoldAmber,
    required this.surfaceCardColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    final outer = Paint()
      ..color = accentGoldAmber.withValues(alpha: 0.9);
    final inner = Paint()..color = surfaceCardColor;

    Path starPath(int points, double rOuter, double rInner, double angleOffset) {
      final path = Path();
      for (int i = 0; i < points * 2; i++) {
        final r = i.isEven ? rOuter : rInner;
        final a = angleOffset + i * math.pi / points;
        final p = Offset(
          center.dx + math.cos(a) * r,
          center.dy + math.sin(a) * r,
        );
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      return path;
    }

    canvas.drawPath(starPath(4, radius, radius * 0.32, -math.pi / 2), outer);
    canvas.drawPath(
      starPath(4, radius, radius * 0.32, -math.pi / 2 + math.pi / 4),
      outer,
    );
    canvas.drawPath(
      starPath(4, radius * 0.14, radius * 0.06, -math.pi / 2),
      inner,
    );
  }

  @override
  bool shouldRepaint(covariant _StarOrnamentPainter oldDelegate) =>
      oldDelegate.accentGoldAmber != accentGoldAmber ||
      oldDelegate.surfaceCardColor != surfaceCardColor;
}

// ── Subtle gold ornamental lattice (stars + dots) ────────────────────────────
class _OrnamentPainter extends CustomPainter {
  final Color color;
  _OrnamentPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..isAntiAlias = true;
    final cell = 140.0;

    void star(Offset c, double r) {
      final path = Path();
      const points = 8;
      for (int i = 0; i < points * 2; i++) {
        final rr = i.isEven ? r : r * 0.42;
        final a = -math.pi / 2 + i * math.pi / points;
        final p = Offset(c.dx + math.cos(a) * rr, c.dy + math.sin(a) * rr);
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }

    for (double y = -cell; y < size.height + cell; y += cell) {
      for (double x = -cell; x < size.width + cell; x += cell) {
        final offset = (y / cell) % 2 == 0 ? 0.0 : cell / 2;
        final cx = x + offset + cell / 2;
        final cy = y + cell / 2;
        star(Offset(cx, cy), 26);
        canvas.drawCircle(
          Offset(cx - cell / 2, cy - cell / 2),
          2.4,
          paint..style = PaintingStyle.fill,
        );
        paint.style = PaintingStyle.stroke;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OrnamentPainter oldDelegate) =>
      oldDelegate.color != color;
}
