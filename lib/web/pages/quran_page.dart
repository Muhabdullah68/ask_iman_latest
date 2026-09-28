// lib/web/pages/quran_page.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — PAGE 2 · QURAN EXPLORER (DOCUMENT SCROLL)
//
// The Quran Explorer is a normal scrolling document, not a fixed app shell:
// the hero band, sub-nav and pill tab bar sit in-flow at the top and scroll
// away as you read, exactly like a web page. Three sub-tabs live under /quran
// — Talawat (recitation), Tarjuma (translation) and Tafseer (commentary) —
// each with its own dedicated UI. A sticky audio bar stays pinned at the
// bottom whenever recitation is playing.
//
// Layout rule: every pane is self-sizing content laid out in the page flow —
// no nested unbounded scrollables. The shared footer appears once at the end
// of the whole scroll.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/figma_tokens.dart';
import '../../core/utils/seo_meta.dart';
import '../web_router.dart' show WebRoutes;
import '../widgets/web_animations.dart';
import '../widgets/web_footer.dart';
import 'quran/audio_bar_web.dart';
import 'quran/quran_tabs_web.dart';
import 'quran/tafseer_web.dart';
import 'quran/web_quran_tab.dart';

class QuranPage extends StatefulWidget {
  final int tab;
  const QuranPage({super.key, this.tab = 0});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  late int _tabIndex = widget.tab.clamp(0, WebQuranTab.values.length - 1);
  final Map<int, Widget> _built = {};

  @override
  void didUpdateWidget(covariant QuranPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tab != widget.tab) {
      _tabIndex = widget.tab.clamp(0, WebQuranTab.values.length - 1);
    }
  }

  void _select(int index) {
    if (index == _tabIndex) return;
    setState(() {
      _tabIndex = index;
      _built.remove(index);
    });
    context.go('${WebRoutes.quran}${WebQuranTab.values[index].path}');
  }

  Widget _pane(int i) {
    return _built.putIfAbsent(i, () {
      switch (WebQuranTab.values[i]) {
        case WebQuranTab.talawat:
          return const TalawatTabWeb();
        case WebQuranTab.tarjuma:
          return const TarjumaTabWeb();
        case WebQuranTab.tafseer:
          return const TafseerWeb();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    setPageTitle('Quran Explorer — Talawat, Tarjuma, Tafseer · Ask Iman');
    return Stack(
      children: [
        Container(
          color: figma.surfaceBackground,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: webScrollPhysics,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      const _QuranHero(),
                      const _SubNavBar(),
                      _PillTabBar(current: _tabIndex, onSelect: _select),
                      const SizedBox(height: 28),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1180),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: _pane(_tabIndex)
                                .animate(key: ValueKey<int>(_tabIndex))
                                .fadeIn(
                                  duration: 300.ms,
                                  curve: Curves.easeOut,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 56),
                      const WebFooter(),
                      const SizedBox(height: 72),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const Positioned(left: 0, right: 0, bottom: 0, child: QuranAudioBar()),
      ],
    );
  }
}

// ── Hero band ────────────────────────────────────────────────────────────────
class _QuranHero extends StatelessWidget {
  const _QuranHero();

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Container(
      decoration: const BoxDecoration(gradient: FigmaTokens.heroGradientDark),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 120),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: figma.accentGoldAmber.withValues(alpha: 0.55),
                      width: 1.5,
                    ),
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                  child: Text(
                    '﴿﷽﴾',
                    style: TextStyle(
                      fontFamily: FigmaTokens.fontFamilyArabicSerif,
                      fontSize: 30,
                      height: 1,
                      color: figma.accentGoldLight,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AL-QUR\'ĀN AL-KARĪM',
                        style: TextStyle(
                          fontFamily: FigmaTokens.fontFamilyUiSans,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.4,
                          color: figma.accentGoldLight.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Quran Explorer',
                        style: TextStyle(
                          fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: FigmaTokens.textOnDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Talawat · Tarjuma · Tafseer',
                        style: TextStyle(
                          fontFamily: FigmaTokens.fontFamilyUiSans,
                          fontSize: 13.5,
                          color: Colors.white.withValues(alpha: 0.72),
                        ),
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

// ── Sub-nav bar: Back to Library, Search, Profile ────────────────────────────
class _SubNavBar extends StatelessWidget {
  const _SubNavBar();

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Container(
      decoration: BoxDecoration(
        color: FigmaTokens.brandDeepGreen,
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.18),
            width: 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: SizedBox(
            height: 44,
            child: Row(
              children: [
                InkWell(
                  onTap: () => context.go(WebRoutes.home),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back_rounded,
                        size: 17,
                        color: figma.accentGoldLight,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Back to Library',
                        style: TextStyle(
                          fontFamily: FigmaTokens.fontFamilyUiSans,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: figma.accentGoldLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => context.go('/search'),
                  icon: const Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: FigmaTokens.textOnDark,
                  ),
                  tooltip: 'Search',
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => context.go('/profile'),
                  icon: const Icon(
                    Icons.person_outline_rounded,
                    size: 20,
                    color: FigmaTokens.textOnDark,
                  ),
                  tooltip: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Segmented pill tab bar ───────────────────────────────────────────────────
class _PillTabBar extends StatelessWidget {
  final int current;
  final ValueChanged<int> onSelect;
  const _PillTabBar({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Container(
      color: figma.surfaceCard,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < WebQuranTab.values.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  _TabPill(
                    tab: WebQuranTab.values[i],
                    selected: i == current,
                    onTap: () => onSelect(i),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final WebQuranTab tab;
  final bool selected;
  final VoidCallback onTap;
  const _TabPill({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return AnimatedScale(
      scale: selected ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Material(
        color: selected ? FigmaTokens.brandMidGreen : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
          hoverColor: selected
              ? FigmaTokens.brandMidGreen
              : figma.surfacePanelMint,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  tab.icon,
                  size: 17,
                  color: selected ? figma.accentGoldLight : figma.textMuted,
                ),
                const SizedBox(width: 7),
                Text(
                  tab.label,
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: selected ? FigmaTokens.textOnDark : figma.textBody,
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
