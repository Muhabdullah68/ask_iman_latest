// lib/web/pages/quran_page.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — PAGE 2 · QURAN EXPLORER (WEB-NATIVE)
//
// Desktop-first Quran explorer per the Figma spec: dark hero band with the
// bismillah ornament, a slim sub-nav bar (Back to Library, Search, Settings,
// Profile), Surah/Juz toggle pill, segmented pill tab bar synced to real URLs
// under /quran, and five bounded tab panes (Talawat, Tarjuma, Tafseer,
// Settings, Share). A sticky audio bar driven by the shared QuranAudioService
// appears at the bottom whenever recitation is playing.
//
// Layout rule: every pane is height-bounded (Expanded), scrolls internally and
// never nests an unbounded scrollable — this structurally prevents the blank
// page / RenderFlex overflow seen with the old embedded mobile screen.
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
import 'quran/settings_web.dart';
import 'quran/share_web.dart';
import 'quran/surah_explorer_web.dart';
import 'quran/tafseer_web.dart';
import 'quran/translation_web.dart';
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
  bool _juzMode = false;
  bool _indexDrawerOpen = false;

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

  void _toggleJuz() => setState(() => _juzMode = !_juzMode);

  void _toggleIndexDrawer() =>
      setState(() => _indexDrawerOpen = !_indexDrawerOpen);

  Widget _pane(int i) {
    return _built.putIfAbsent(i, () {
      switch (WebQuranTab.values[i]) {
        case WebQuranTab.talawat:
          return SurahExplorerWeb(
            juzMode: _juzMode,
            onToggleJuz: _toggleJuz,
            drawerOpen: _indexDrawerOpen,
            onToggleDrawer: _toggleIndexDrawer,
          );
        case WebQuranTab.tarjuma:
          return const TranslationWeb();
        case WebQuranTab.tafseer:
          return const TafseerWeb();
        case WebQuranTab.settings:
          return const QuranSettingsWeb();
        case WebQuranTab.share:
          return const QuranShareWeb();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    final audioPad = MediaQuery.sizeOf(context).width < 600 ? 80.0 : 132.0;
    setPageTitle('Quran Explorer — Talawat, Tarjuma, Tafseer · Ask Iman');
    return Stack(
      children: [
        Container(
          color: figma.surfaceBackground,
          child: CustomScrollView(
            physics: webScrollPhysics,
            slivers: [
              SliverToBoxAdapter(child: const _QuranHero()),
              SliverToBoxAdapter(
                child: _SubNavBar(
                  indexDrawerOpen: _indexDrawerOpen,
                  onToggleIndex: _toggleIndexDrawer,
                ),
              ),
              SliverToBoxAdapter(
                child: _ControlBar(
                  juzMode: _juzMode,
                  onToggleJuz: _toggleJuz,
                  indexDrawerOpen: _indexDrawerOpen,
                  onToggleIndex: _toggleIndexDrawer,
                ),
              ),
              SliverToBoxAdapter(
                child: _PillTabBar(
                  current: _tabIndex,
                  onSelect: _select,
                ),
              ),
              SliverToBoxAdapter(
                child: IndexedStack(
                  index: _tabIndex,
                  children: [
                    for (var i = 0; i < WebQuranTab.values.length; i++)
                      i == 0
                          ? _TalawatBounded(child: _pane(i))
                          : _pane(i)
                                .animate(key: ValueKey(i))
                                .fadeIn(duration: 300.ms, curve: Curves.easeOut),
                  ],
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 44)),
              const SliverToBoxAdapter(child: WebFooter()),
              SliverToBoxAdapter(child: SizedBox(height: audioPad)),
            ],
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: QuranAudioBar(),
        ),
      ],
    );
  }
}

class _TalawatBounded extends StatelessWidget {
  final Widget child;
  const _TalawatBounded({required this.child});

  @override
  Widget build(BuildContext context) {
    final minH = (MediaQuery.sizeOf(context).height * 0.72).clamp(640.0, 960.0);
    return SizedBox(
      height: minH,
      child: child,
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
          child: Row(
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
                        color: figma.accentGoldLight.withValues(
                          alpha: 0.85,
                        ),
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
                      'Talawat · Tarjuma · Tafseer · Settings · Share',
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
    );
  }
}

// ── Sub-nav bar: Back to Library, Search, Settings, Profile ──────────────────
class _SubNavBar extends StatelessWidget {
  final bool indexDrawerOpen;
  final VoidCallback onToggleIndex;
  const _SubNavBar({
    required this.indexDrawerOpen,
    required this.onToggleIndex,
  });

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Container(
      color: FigmaTokens.brandDeepGreen,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: SizedBox(
            height: 44,
            child: Row(
              children: [
                InkWell(
                  onTap: () => context.go('/home'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_rounded, size: 17, color: figma.accentGoldLight),
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
                  icon: const Icon(Icons.search_rounded, size: 20, color: FigmaTokens.textOnDark),
                  tooltip: 'Search',
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.settings_rounded, size: 20, color: FigmaTokens.textOnDark),
                  tooltip: 'Settings',
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => context.go('/profile'),
                  icon: const Icon(Icons.person_outline_rounded, size: 20, color: FigmaTokens.textOnDark),
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

// ── Control bar: Surah/Juz toggle + Index button ─────────────────────────────
class _ControlBar extends StatelessWidget {
  final bool juzMode;
  final VoidCallback onToggleJuz;
  final bool indexDrawerOpen;
  final VoidCallback onToggleIndex;
  const _ControlBar({
    required this.juzMode,
    required this.onToggleJuz,
    required this.indexDrawerOpen,
    required this.onToggleIndex,
  });

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Container(
      color: figma.surfaceCard,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Row(
            children: [
              _SegmentedToggle(
                left: 'QURAN',
                right: 'JUZ',
                leftSelected: !juzMode,
                onTap: onToggleJuz,
              ),
              const SizedBox(width: 12),
              Material(
                color: indexDrawerOpen
                    ? FigmaTokens.brandMidGreen
                    : figma.surfacePanelMint,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(FigmaTokens.radiusButton),
                ),
                child: InkWell(
                  onTap: onToggleIndex,
                  borderRadius: BorderRadius.circular(FigmaTokens.radiusButton),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.menu_rounded,
                          size: 17,
                          color: indexDrawerOpen
                              ? FigmaTokens.textOnDark
                              : FigmaTokens.brandMidGreen,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Index',
                          style: TextStyle(
                            fontFamily: FigmaTokens.fontFamilyUiSans,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: indexDrawerOpen
                                ? FigmaTokens.textOnDark
                                : FigmaTokens.brandMidGreen,
                          ),
                        ),
                      ],
                    ),
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

class _SegmentedToggle extends StatelessWidget {
  final String left;
  final String right;
  final bool leftSelected;
  final VoidCallback onTap;
  const _SegmentedToggle({
    required this.left,
    required this.right,
    required this.leftSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Container(
      decoration: BoxDecoration(
        color: figma.surfaceBackground,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SegPill(
            label: left,
            selected: leftSelected,
            onTap: onTap,
          ),
          _SegPill(
            label: right,
            selected: !leftSelected,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _SegPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SegPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Material(
      color: selected ? FigmaTokens.brandMidGreen : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: selected ? FigmaTokens.textOnDark : figma.textMuted,
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
                  color: selected
                      ? figma.accentGoldLight
                      : figma.textMuted,
                ),
                const SizedBox(width: 7),
                Text(
                  tab.label,
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? FigmaTokens.textOnDark
                        : figma.textBody,
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
