import 'dart:math' as math show sin, cos, pi;
import 'package:flutter/material.dart';
import '../../core/theme/figma_tokens.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/breakpoints.dart';
import '../../shared/widgets/ask_iman_app_bar.dart';
import '../../shared/widgets/tooltip_overlay.dart';
import '../../shared/widgets/islamic_background.dart';
import '../../shared/widgets/theme_hero_banner.dart';
import '../../core/services/tutorial_service.dart';
import '../ibadah/qiblah_screen.dart';
import '../ibadah/tasbeeh_screen.dart';
import '../charity/charity_list_screen.dart';
import '../../core/data/daily_data.dart';
import '../../core/services/community_service.dart';

/// Top-level star ornament widget (shared between HomeScreenState and
/// sibling standalone widgets like _SacredCollectionBook).
Widget figmaStarOrnament({double size = 36, Color? color}) => SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StarOrnamentPainter(color ?? FigmaTokens.accentGoldAmber),
      ),
    );

class HomeScreen extends StatefulWidget {
  final void Function(int index)? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _ayahController = PageController(viewportFraction: 0.88);
  final ScrollController _scrollController = ScrollController();

  final _sacredKey = GlobalKey();
  final _askAiKey = GlobalKey();
  final _eventsKey = GlobalKey();
  final _dailyInspirationKey = GlobalKey();
  final _streaksKey = GlobalKey();

  Map<String, double> _soulProgress = {'namaz': 0, 'quran': 0, 'zikr': 0};
  late final List<Map<String, String>> _dailyAyahs;
  late final List<Map<String, String>> _dailyHadiths;

  @override
  void initState() {
    super.initState();
    _dailyAyahs = DailyData.getDailyAyahs(5);
    _dailyHadiths = DailyData.getDailyHadiths(5);
    _loadSoulProgress();
    TutorialService.instance.addListener(_onTutorialUpdate);
  }

  @override
  void dispose() {
    _ayahController.dispose();
    _scrollController.dispose();
    TutorialService.instance.removeListener(_onTutorialUpdate);
    super.dispose();
  }

  void _onTutorialUpdate() {
    if (!mounted) return;
    final currentStepId = TutorialService.instance.currentStepId;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final keyToScrollTo = switch (currentStepId) {
        'tut_home_inspiration' => _dailyInspirationKey,
        'tut_home_streaks' => _streaksKey,
        _ => null,
      };
      if (keyToScrollTo != null && keyToScrollTo.currentContext != null) {
        await Scrollable.ensureVisible(
          keyToScrollTo.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.3,
        );
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(const Duration(milliseconds: 50), () {
              if (mounted) TutorialService.instance.forceRefresh();
            });
          });
        }
      }
    });
  }

  List<Map<String, dynamic>> _sacredItems(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return [
      {'image': 'assets/images/Holy Quran.png', 'label': loc.translate('quran'), 'tab': 1, 'icon': Icons.menu_book_rounded},
      {'image': 'assets/images/Kaaba.png', 'label': loc.translate('qiblah'), 'tab': 2, 'icon': Icons.mosque_rounded},
      {'image': 'assets/images/mosque interior.png', 'label': loc.translate('prayers'), 'tab': 2, 'icon': Icons.self_improvement},
      {'image': 'assets/images/AI orb.png', 'label': loc.translate('askAI'), 'tab': 4, 'icon': Icons.auto_awesome},
      {'image': 'assets/images/tasbih beads.png', 'label': loc.translate('tasbeeh'), 'tab': 2, 'icon': Icons.spa_rounded},
      {'image': 'assets/images/islamic lanterns.png', 'label': loc.translate('events'), 'tab': 3, 'icon': Icons.event_available_rounded},
    ];
  }

  List<Map<String, String>> get _sacredCollections => const [
        {'title': 'Quranic Classics', 'desc': 'TafsÄ«r & Tajweed', 'cover': 'assets/images/Holy Quran.png'},
        {'title': 'Hadith Insights', 'desc': 'SahÄ«h Collections', 'cover': 'assets/images/islamic lanterns.png'},
        {'title': 'Daily Wisdom', 'desc': 'Supplications & AdhkÄr', 'cover': 'assets/images/tasbih beads.png'},
        {'title': 'Stories of Prophets', 'desc': 'Lessons from the QurÊ¾Än', 'cover': 'assets/images/mosque interior.png'},
      ];

  Future<void> _loadSoulProgress() async {
    if (CommunityService.instance.cachedSoulProgress != null) {
      if (mounted) {
        setState(() => _soulProgress = CommunityService.instance.cachedSoulProgress!);
      }
    }
    final progress = await CommunityService.instance.getSoulProgress();
    if (mounted) setState(() => _soulProgress = progress);
  }

  void _navigateTo(int tab) => widget.onNavigateToTab?.call(tab);

  void _handleSacredTap(String label, int tab, BuildContext context) {
    final loc = AppLocalizations.of(context);
    final qiblahLabel = loc.translate('qiblah');
    final tasbeehLabel = loc.translate('tasbeeh');
    final askAILabel = loc.translate('askAI');
    final eventsLabel = loc.translate('events');

    if (label == qiblahLabel) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const QiblahScreen()));
    } else if (label == tasbeehLabel) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const TasbeehScreen()));
    } else if (label == eventsLabel) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CharityListScreen()));
    } else if (label == askAILabel) {
      _showComingSoon(label, context);
    } else {
      _navigateTo(tab);
    }
  }

  void _showComingSoon(String feature, BuildContext context) {
    final loc = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFFC9962C), size: 20),
            const SizedBox(width: 12),
            Text(
              '$feature ${loc.translate('isComingSoon')}',
              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: FigmaTokens.brandDeepGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // â”€â”€ FIGMA SECTION HEADER â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _sectionHeader(
    String title, {
    String? eyebrow,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eyebrow != null)
            Text(
              eyebrow.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: FigmaTokens.accentGoldAmber,
                letterSpacing: 2.0,
              ),
            ),
          if (eyebrow != null) const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: FigmaTokens.brandDeepGreen,
                  height: 1.15,
                ),
              ),
              const Spacer(),
              if (actionLabel != null)
                GestureDetector(
                  onTap: onAction,
                  child: Text(
                    actionLabel,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: FigmaTokens.brandMidGreen,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // â”€â”€ FIGMA GOLD ACCENT BAR (left vertical on cards) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _goldAccentBar() => Container(
        width: 4,
        height: 48,
        decoration: BoxDecoration(
          color: FigmaTokens.accentGoldAmber,
          borderRadius: BorderRadius.circular(4),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const AskImanAppBar(),
      body: IslamicBackground(
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: ContentContainer(
            maxWidth: 1200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const ThemeHeroBanner(),
                const SizedBox(height: 24),
                _buildFigmaHero(context),
                const SizedBox(height: 48),
                _buildSacredJourney(context),
                const SizedBox(height: 56),
                _buildDailyInspiration(context),
                const SizedBox(height: 56),
                _buildSoulProgress(context),
                const SizedBox(height: 56),
                _buildSacredCollections(context),
                const SizedBox(height: 56),
                _buildDailyDuaSection(context),
                const SizedBox(height: 72),
                _buildFigmaFooter(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // HERO â€” Figma 2-col Mint Panel with Bismillah
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildFigmaHero(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isWide = context.isDesktop || context.isTablet;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FigmaTokens.surfacePanelMint,
          borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
          boxShadow: [
            BoxShadow(
              color: FigmaTokens.brandDeepGreen.withValues(alpha: 0.08),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
          child: Stack(
            children: [
              // Background image overlay â€” reduced opacity (changes.txt Â§0.4 / Â§1.1)
              Positioned.fill(
                child: Image.asset(
                  'assets/images/mosque interior.png',
                  fit: BoxFit.cover,
                  opacity: const AlwaysStoppedAnimation(0.08),
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(isWide ? 56 : 24, isWide ? 64 : 36, isWide ? 40 : 24, isWide ? 64 : 36),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(flex: 6, child: _heroLeft(context, loc)),
                          Expanded(flex: 5, child: _heroBismillah(context)),
                        ],
                      )
                    : Column(
                        children: [
                          _heroLeft(context, loc),
                          const SizedBox(height: 28),
                          _heroBismillah(context),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroLeft(BuildContext context, AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ASK YOUR WAY TO INNER LIGHT',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: context.isDesktop ? 44 : 32,
            fontWeight: FontWeight.w900,
            color: FigmaTokens.brandDeepGreen,
            height: 1.15,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 20),
        _goldAccentBar(),
        const SizedBox(height: 20),
        Text(
          'Your trusted companion for QurÊ¾Än, SalÄh, Dhikr, and the path of Ahl al-Sunnah wa al-JamÄÊ¿ah.',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: FigmaTokens.brandMidGreen,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: () => _navigateTo(1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FigmaTokens.brandDeepGreen,
                  foregroundColor: FigmaTokens.textOnDark,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  elevation: 4,
                  shadowColor: FigmaTokens.brandDeepGreen.withValues(alpha: 0.25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      loc.translate('startJourney'),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            SizedBox(
              height: 54,
              child: OutlinedButton(
                onPressed: () => _navigateTo(5),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: FigmaTokens.accentGoldAmber, width: 1.3),
                  foregroundColor: FigmaTokens.brandDeepGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  loc.translate('ourVision'),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            _statPill('1.2B+', 'Muslims Worldwide'),
            const SizedBox(width: 16),
            _statPill('99', 'Ninety-Nine Names'),
            const SizedBox(width: 16),
            _statPill('114', 'Surahs'),
          ],
        ),
      ],
    );
  }

  Widget _statPill(String value, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: FigmaTokens.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: FigmaTokens.borderHairline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: FigmaTokens.accentGoldAmber,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: FigmaTokens.textMuted,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );

  Widget _heroBismillah(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        figmaStarOrnament(size: 44),
        const SizedBox(height: 24),
        Text(
          'Ø¨ÙØ³Ù’Ù…Ù Ø§Ù„Ù„ÙŽÙ‘Ù‡Ù Ø§Ù„Ø±ÙŽÙ‘Ø­Ù’Ù…ÙŽÙ°Ù†Ù Ø§Ù„Ø±ÙŽÙ‘Ø­ÙÙŠÙ…Ù',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: context.isDesktop ? 44 : 32,
            color: FigmaTokens.brandDeepGreen,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'In the Name of Allah â€”\nThe Most Gracious, The Most Merciful.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: FigmaTokens.brandMidGreen,
            height: 1.5,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 24),
        figmaStarOrnament(size: 32),
      ],
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // SACRED JOURNEY â€” Figma 6-up feature tiles
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildSacredJourney(BuildContext context) {
    final items = _sacredItems(context);
    final loc = AppLocalizations.of(context);
    final isDesktop = context.isDesktop;
    return KeyedSubtree(
      key: _sacredKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            loc.translate('sacredJourney'),
            eyebrow: 'Explore Your Deen',
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 3 : 2,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: isDesktop ? 1.15 : 1.0,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) {
                _SacredJourneyTile tile;
                if (i == 3) {
                  tile = _SacredJourneyTile(
                    key: _askAiKey,
                    image: items[i]['image'] as String,
                    label: items[i]['label'] as String,
                    icon: items[i]['icon'] as IconData,
                    onTap: () => _handleSacredTap(
                      items[i]['label'] as String,
                      items[i]['tab'] as int,
                      context,
                    ),
                  );
                } else if (i == 5) {
                  tile = _SacredJourneyTile(
                    key: _eventsKey,
                    image: items[i]['image'] as String,
                    label: items[i]['label'] as String,
                    icon: items[i]['icon'] as IconData,
                    onTap: () => _handleSacredTap(
                      items[i]['label'] as String,
                      items[i]['tab'] as int,
                      context,
                    ),
                  );
                } else {
                  tile = _SacredJourneyTile(
                    image: items[i]['image'] as String,
                    label: items[i]['label'] as String,
                    icon: items[i]['icon'] as IconData,
                    onTap: () => _handleSacredTap(
                      items[i]['label'] as String,
                      items[i]['tab'] as int,
                      context,
                    ),
                  );
                }
                if (i == 0) {
                  return TooltipOverlay(
                    id: 'tut_home_sacred_journey',
                    title: loc.translate('tutQuranTitle'),
                    description: loc.translate('tutQuranDesc'),
                    arrowDirection: TooltipArrowDirection.down,
                    child: tile,
                  );
                }
                if (i == 3) {
                  return TooltipOverlay(
                    id: 'tut_home_ask_ai',
                    title: loc.translate('tutHomeAskAiTitle'),
                    description: loc.translate('tutHomeAskAiDesc'),
                    arrowDirection: TooltipArrowDirection.down,
                    child: tile,
                  );
                }
                if (i == 5) {
                  return TooltipOverlay(
                    id: 'tut_home_events',
                    title: loc.translate('tutHomeEventsTitle'),
                    description: loc.translate('tutHomeEventsDesc'),
                    arrowDirection: TooltipArrowDirection.down,
                    child: tile,
                  );
                }
                return tile;
              },
            ),
          ),
        ],
      ),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // SOUL PROGRESS â€” Figma 3 cards side-by-side
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildSoulProgress(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final progressCards = [
      _SoulProgressCard(
        label: loc.translate('namaz'),
        sub: loc.translate('weekly'),
        value: _soulProgress['namaz']!,
        display: '${(_soulProgress['namaz']! * 100).toInt()}%',
      ),
      _SoulProgressCard(
        label: loc.translate('quran'),
        sub: loc.translate('weekly'),
        value: _soulProgress['quran']!,
        display: '${(_soulProgress['quran']! * 100).toInt()}%',
      ),
      _SoulProgressCard(
        label: loc.translate('zikr'),
        sub: loc.translate('weekly'),
        value: _soulProgress['zikr']!,
        display: '${(_soulProgress['zikr']! * 100).toInt()}%',
      ),
    ];
    final isWide = context.isTablet || context.isDesktop;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(loc.translate('soulProgress'), eyebrow: 'Weekly Ibadah'),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: isWide
              ? Row(
                  children: [
                    Expanded(child: progressCards[0]),
                    const SizedBox(width: 16),
                    Expanded(child: progressCards[1]),
                    const SizedBox(width: 16),
                    Expanded(child: progressCards[2]),
                  ],
                )
              : Column(
                  children: [
                    progressCards[0],
                    const SizedBox(height: 12),
                    progressCards[1],
                    const SizedBox(height: 12),
                    progressCards[2],
                  ],
                ),
        ),
      ],
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // DAILY INSPIRATION â€” Figma 2-col split panel with star ornament
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildDailyInspiration(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isWide = context.isDesktop || context.isTablet;
    final firstAyah = _dailyAyahs.first;
    final firstHadith = _dailyHadiths.first;

    return KeyedSubtree(
      key: _dailyInspirationKey,
      child: TooltipOverlay(
        id: 'tut_home_inspiration',
        title: loc.translate('tutHomeDailyInspiration'),
        description: loc.translate('tutHomeDailyInspirationDesc'),
        arrowDirection: TooltipArrowDirection.up,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(
              loc.translate('dailyInspiration'),
              eyebrow: 'Reflect Â· Ponder Â· Apply',
              actionLabel: 'See More â†’',
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: _inspirationLeftCard(firstAyah)),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              _inspirationRightColumn(loc, firstAyah),
                              const SizedBox(height: 20),
                              _inspirationHadithCard(firstHadith),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _inspirationLeftCard(firstAyah),
                        const SizedBox(height: 20),
                        _inspirationRightColumn(loc, firstAyah),
                        const SizedBox(height: 20),
                        _inspirationHadithCard(firstHadith),
                      ],
                    ),
            ),
            const SizedBox(height: 20),
            Center(child: figmaStarOrnament(size: 40)),
          ],
        ),
      ),
    );
  }

  Widget _inspirationLeftCard(Map<String, String> ayah) {
    return ClipPath(
      clipper: _MosqueDomeClipper(),
      child: Container(
        height: 320,
        decoration: BoxDecoration(
          color: FigmaTokens.brandDeepGreen,
          image: DecorationImage(
            image: const AssetImage('assets/images/mosque interior.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              FigmaTokens.brandDeepGreen.withValues(alpha: 0.72),
              BlendMode.srcATop,
            ),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            figmaStarOrnament(size: 28, color: FigmaTokens.accentGoldAmber),
            const SizedBox(height: 16),
            Text(
              ayah['arabic'] ?? '',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 28,
                color: FigmaTokens.textOnDark,
                height: 1.55,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              ayah['reference'] ?? '',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: FigmaTokens.accentGoldAmber,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inspirationRightColumn(AppLocalizations loc, Map<String, String> ayah) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: FigmaTokens.surfaceCard,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        border: Border.all(color: FigmaTokens.borderHairline),
        boxShadow: [
          BoxShadow(
            color: FigmaTokens.brandDeepGreen.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _goldAccentBar(),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.translate('ayahOfTheDay'),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: FigmaTokens.accentGoldAmber,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'A Light for Every Step',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: FigmaTokens.brandDeepGreen,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  ayah['translation'] ?? ayah['text'] ?? '',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: FigmaTokens.textBody,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateTo(1),
                    icon: const Icon(Icons.menu_book_rounded, size: 18),
                    label: Text(
                      loc.translate('exploreQuran'),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FigmaTokens.brandDeepGreen,
                      foregroundColor: FigmaTokens.textOnDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inspirationHadithCard(Map<String, String> hadith) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: FigmaTokens.surfacePanelMint,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        border: Border.all(color: FigmaTokens.accentGoldLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: FigmaTokens.brandDeepGreen.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mic_external_on_rounded,
              color: FigmaTokens.brandDeepGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hadith['arabic'] ?? '',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 20,
                    color: FigmaTokens.brandDeepGreen,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  hadith['translation'] ?? hadith['text'] ?? '',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: FigmaTokens.textBody,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hadith['reference'] ?? hadith['book'] ?? '',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: FigmaTokens.accentGoldAmber,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // SACRED COLLECTIONS â€” Figma book covers grid
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildSacredCollections(BuildContext context) {
    final isWide = context.isDesktop || context.isTablet;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          'Sacred Collections',
          eyebrow: 'Curated Knowledge',
          actionLabel: 'Browse All â†’',
        ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWide ? 4 : 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: isWide ? 0.72 : 0.85,
            ),
            itemCount: _sacredCollections.length,
            itemBuilder: (_, i) => _SacredCollectionBook(
              title: _sacredCollections[i]['title']!,
              description: _sacredCollections[i]['desc']!,
              cover: _sacredCollections[i]['cover']!,
            ),
          ),
        ),
      ],
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // DAILY DUA â€” Figma gradient card
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildDailyDuaSection(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final dua = DailyData.getDailyDua();
    final isWide = context.isDesktop || context.isTablet;
    return KeyedSubtree(
      key: _streaksKey,
      child: TooltipOverlay(
        id: 'tut_home_streaks',
        title: loc.translate('tutHomeDuaTitle'),
        description: loc.translate('tutHomeDuaDesc'),
        arrowDirection: TooltipArrowDirection.up,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [FigmaTokens.brandDeepGreen, FigmaTokens.brandMidGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: FigmaTokens.brandDeepGreen.withValues(alpha: 0.3),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 2, child: _buildDuaDetails(loc, dua, center: false)),
                      Container(
                        width: 1,
                        height: 150,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      const SizedBox(width: 32),
                      Expanded(flex: 3, child: _buildDuaArabic(loc, dua)),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDuaDetails(loc, dua, center: true),
                      const SizedBox(height: 24),
                      _buildDuaArabic(loc, dua),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDuaDetails(
    AppLocalizations loc,
    Map<String, String> dua, {
    required bool center,
  }) {
    final align = center ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: FigmaTokens.accentGoldAmber.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: FigmaTokens.accentGoldAmber.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.volunteer_activism_rounded, color: FigmaTokens.accentGoldAmber, size: 16),
              const SizedBox(width: 8),
              Text(
                loc.translate('dailyDua'),
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: FigmaTokens.accentGoldAmber,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          dua['translation'] ?? '',
          textAlign: align,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: FigmaTokens.textOnDark,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          dua['reference'] ?? '',
          textAlign: align,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: FigmaTokens.accentGoldAmber,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDuaArabic(AppLocalizations loc, Map<String, String> dua) {
    return Text(
      dua['arabic'] ?? '',
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
      style: TextStyle(
        fontFamily: 'Amiri',
        fontSize: 28,
        color: FigmaTokens.accentGoldAmber,
        height: 1.7,
      ),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // FOOTER â€” Figma 4-column + gold copyright band
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildFigmaFooter(BuildContext context) {
    final isWide = context.isDesktop;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: FigmaTokens.brandDeepGreen,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 48, 40, 32),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 4, child: _footerBrand()),
                      const SizedBox(width: 32),
                      Expanded(flex: 2, child: _footerCol('Explore', ['Quran', 'Prayer', 'Dhikr', 'Events'])),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: _footerCol('Community', ['Classes', 'Charity', 'Family', 'About Us'])),
                      const SizedBox(width: 24),
                      Expanded(flex: 3, child: _footerContact()),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _footerBrand(),
                      const SizedBox(height: 32),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _footerCol('Explore', ['Quran', 'Prayer', 'Dhikr', 'Events'])),
                          Expanded(child: _footerCol('Community', ['Classes', 'Charity', 'Family', 'About Us'])),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _footerContact(),
                    ],
                  ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            decoration: BoxDecoration(
              color: FigmaTokens.accentGoldAmber.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Â© ${DateTime.now().year} ASK ÄªMÄ€N â€” All rights reserved.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: FigmaTokens.accentGoldLight,
                  ),
                ),
                const Spacer(),
                Text(
                  'Built with ðŸ¤² for the Ummah',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: FigmaTokens.textOnDark.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerBrand() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'ASK',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: FigmaTokens.accentGoldAmber,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Ø§ÛŒÙ…Ø§Ù†',
                style: const TextStyle(
                  fontFamily: 'NotoNastaliq',
                  fontSize: 28,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Guiding hearts to the light of IslÄm â€” one Äyah, one sujÅ«d, one day at a time.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.75),
              height: 1.55,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _footerSocial(Icons.facebook_outlined),
              const SizedBox(width: 10),
              _footerSocial(Icons.alternate_email_rounded),
              const SizedBox(width: 10),
              _footerSocial(Icons.ondemand_video_rounded),
              const SizedBox(width: 10),
              _footerSocial(Icons.share_location_rounded),
            ],
          ),
        ],
      );

  Widget _footerSocial(IconData icon) => Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Icon(icon, color: FigmaTokens.accentGoldAmber, size: 18),
      );

  Widget _footerCol(String heading, List<String> items) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: FigmaTokens.accentGoldAmber,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map(
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                i,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.82),
                ),
              ),
            ),
          ),
        ],
      );

  Widget _footerContact() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STAY CONNECTED',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: FigmaTokens.accentGoldAmber,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          _contactRow(Icons.email_outlined, 'hello@askiman.app'),
          const SizedBox(height: 12),
          _contactRow(Icons.location_on_outlined, 'Serving the Global Ummah'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Your email address',
                      hintStyle: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FigmaTokens.accentGoldAmber,
                    foregroundColor: FigmaTokens.brandDeepGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  ),
                  child: const Text(
                    'Join',
                    style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _contactRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, color: FigmaTokens.accentGoldAmber, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.78),
              ),
            ),
          ),
        ],
      );
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// STAR ORNAMENT PAINTER â€” Figma 8-point Islamic star
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class _StarOrnamentPainter extends CustomPainter {
  final Color color;
  _StarOrnamentPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final c = Offset(size.width / 2, size.height / 2);
    final rOuter = size.width / 2;
    final rInner = rOuter * 0.42;
    final path = Path();
    for (int i = 0; i < 16; i++) {
      final angle = (i * math.pi) / 8 - math.pi / 2;
      final r = i.isEven ? rOuter : rInner;
      final x = c.dx + r * math.cos(angle);
      final y = c.dy + r * math.sin(angle);
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
  bool shouldRepaint(covariant _StarOrnamentPainter oldDelegate) => oldDelegate.color != color;
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// MOSQUE DOME CLIPPER
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class _MosqueDomeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final domeHeight = h * 0.28;
    final domeBaseY = domeHeight;
    final peakX = w / 2;
    final peakY = h * 0.02;
    final spireHeight = h * 0.04;
    final spireTipY = 0.0;
    final path = Path();
    path.moveTo(0, h);
    path.lineTo(0, domeBaseY);
    path.cubicTo(0, domeBaseY * 0.7, w * 0.20, domeBaseY * 0.3, w * 0.35, peakY + spireHeight);
    path.cubicTo(w * 0.42, peakY + spireHeight * 0.5, w * 0.48, peakY + spireHeight * 0.2, peakX, spireTipY);
    path.cubicTo(w * 0.52, peakY + spireHeight * 0.2, w * 0.58, peakY + spireHeight * 0.5, w * 0.65, peakY + spireHeight);
    path.cubicTo(w * 0.80, domeBaseY * 0.3, w, domeBaseY * 0.7, w, domeBaseY);
    path.lineTo(w, h);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_MosqueDomeClipper old) => false;
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// SACRED JOURNEY TILE â€” Figma card-style
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class _SacredJourneyTile extends StatelessWidget {
  final String image;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SacredJourneyTile({
    super.key,
    required this.image,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: FigmaTokens.surfaceCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: FigmaTokens.borderHairline),
            boxShadow: [
              BoxShadow(
                color: FigmaTokens.brandDeepGreen.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    image,
                    fit: BoxFit.cover,
                    opacity: const AlwaysStoppedAnimation(0.18),
                    errorBuilder: (_, _, _) =>
                        Container(color: FigmaTokens.surfacePanelMint),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          FigmaTokens.surfaceCard.withValues(alpha: 0.55),
                          FigmaTokens.surfaceCard.withValues(alpha: 0.88),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: FigmaTokens.brandDeepGreen,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: FigmaTokens.brandDeepGreen.withValues(alpha: 0.22),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: FigmaTokens.accentGoldAmber, size: 24),
                      ),
                      const Spacer(),
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: FigmaTokens.brandDeepGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to explore â†’',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: FigmaTokens.accentGoldAmber,
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

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// SACRED COLLECTION BOOK CARD
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class _SacredCollectionBook extends StatelessWidget {
  final String title;
  final String description;
  final String cover;

  const _SacredCollectionBook({
    required this.title,
    required this.description,
    required this.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: FigmaTokens.brandDeepGreen.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(cover, fit: BoxFit.cover, errorBuilder: (_, _, _) => Container(color: FigmaTokens.brandMidGreen)),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        FigmaTokens.brandDeepGreen.withValues(alpha: 0.15),
                        FigmaTokens.brandDeepGreen.withValues(alpha: 0.88),
                      ],
                      stops: const [0.30, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 16,
                  child: Center(child: figmaStarOrnament(size: 26, color: FigmaTokens.accentGoldAmber)),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: FigmaTokens.accentGoldAmber.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'COLLECTION',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: FigmaTokens.accentGoldAmber,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.70),
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

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// SOUL PROGRESS CARD
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class _SoulProgressCard extends StatelessWidget {
  final String label;
  final String sub;
  final double value;
  final String display;

  const _SoulProgressCard({
    required this.label,
    required this.sub,
    required this.value,
    required this.display,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: FigmaTokens.surfaceCard,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        border: Border.all(color: FigmaTokens.borderHairline),
        boxShadow: [
          BoxShadow(
            color: FigmaTokens.brandDeepGreen.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: FigmaTokens.brandDeepGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sub.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: FigmaTokens.textMuted,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 54,
            height: 54,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: value,
                  strokeWidth: 5,
                  backgroundColor: FigmaTokens.borderHairline,
                  valueColor: AlwaysStoppedAnimation<Color>(FigmaTokens.brandAccentSageStart),
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Text(
                    display,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: FigmaTokens.brandDeepGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
