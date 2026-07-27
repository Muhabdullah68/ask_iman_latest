import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/l10n/app_localizations.dart';
import '../../shared/widgets/ask_iman_app_bar.dart';
import '../../shared/widgets/tooltip_overlay.dart';
import '../../core/services/tutorial_service.dart';
import '../ibadah/qiblah_screen.dart';
import '../ibadah/tasbeeh_screen.dart';
import '../charity/charity_list_screen.dart';
import '../../core/data/daily_data.dart';
import '../../core/services/community_service.dart';

class HomeScreen extends StatefulWidget {
  // Receives tab-switching callback from MainShell
  final void Function(int index)? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _ayahPageIndex = 0;
  final PageController _ayahController = PageController(viewportFraction: 0.88);
  final ScrollController _scrollController = ScrollController();

  // Global Keys for tutorial scroll targets
  final _sacredKey = GlobalKey();
  final _askAiKey = GlobalKey();
  final _eventsKey = GlobalKey();
  final _dailyInspirationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _dailyAyahs = DailyData.getDailyAyahs(5);
    _dailyHadiths = DailyData.getDailyHadiths(5);
    _loadSoulProgress();

    // Listen to tutorial changes to scroll to relevant widgets
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
    // Schedule scroll for next frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final keyToScrollTo = switch (currentStepId) {
        'tut_home_inspiration' => _dailyInspirationKey,
        'tut_home_streaks' => _streaksKey,
        _ => null,
      };
      if (keyToScrollTo != null && keyToScrollTo.currentContext != null) {
        // Scroll to the key and wait for animation to complete
        await Scrollable.ensureVisible(
          keyToScrollTo.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.3, // Align slightly above center
        );
        // Wait an extra frame for rendering to catch up
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Manually trigger tutorial service to re-sync overlays
            // (we'll need to add a method to TutorialService for this, or just update our listener)
            // Wait — TutorialService already notifies listeners; let's just make sure TooltipOverlay syncs after scroll
            // We can also add a small delay to be safe
            Future.delayed(const Duration(milliseconds: 50), () {
              if (mounted) {
                // Force re-render of tooltip overlays
                TutorialService.instance.forceRefresh();
              }
            });
          });
        }
      }
    });
  }

  Map<String, double> _soulProgress = {'namaz': 0, 'quran': 0, 'zikr': 0};

  // ── Daily Data ──────────────────────────────────────────────────────────────
  late final List<Map<String, String>> _dailyAyahs;
  late final List<Map<String, String>> _dailyHadiths;

  List<Map<String, dynamic>> _sacredItems(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return [
      {
        'image': 'assets/images/Holy Quran.png',
        'label': loc.translate('quran'),
        'tab': 1,
      },
      {
        'image': 'assets/images/Kaaba.png',
        'label': loc.translate('qiblah'),
        'tab': 2,
      },
      {
        'image': 'assets/images/mosque interior.png',
        'label': loc.translate('prayers'),
        'tab': 2,
      },
      {
        'image': 'assets/images/AI orb.png',
        'label': loc.translate('askAI'),
        'tab': 4,
      },
      {
        'image': 'assets/images/tasbih beads.png',
        'label': loc.translate('tasbeeh'),
        'tab': 2,
      },
      {
        'image': 'assets/images/islamic lanterns.png',
        'label': loc.translate('events'),
        'tab': 3,
      },
    ];
  }

  Future<void> _loadSoulProgress() async {
    // First, check if CommunityService has cached data to use immediately!
    if (CommunityService.instance.cachedSoulProgress != null) {
      if (mounted) {
        setState(() {
          _soulProgress = CommunityService.instance.cachedSoulProgress!;
        });
      }
    }
    // Still, load the data in case the cache is not available or needs refresh!
    final progress = await CommunityService.instance.getSoulProgress();
    if (mounted) {
      setState(() {
        _soulProgress = progress;
      });
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _navigateTo(int tab) => widget.onNavigateToTab?.call(tab);
  final _streaksKey = GlobalKey();

  void _handleSacredTap(String label, int tab, BuildContext context) {
    final loc = AppLocalizations.of(context);
    final qiblahLabel = loc.translate('qiblah');
    final tasbeehLabel = loc.translate('tasbeeh');
    final askAILabel = loc.translate('askAI');
    final eventsLabel = loc.translate('events');

    if (label == qiblahLabel) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const QiblahScreen()),
      );
    } else if (label == tasbeehLabel) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TasbeehScreen()),
      );
    } else if (label == eventsLabel) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CharityListScreen()),
      );
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
            const Icon(Icons.auto_awesome, color: AppColors.gold, size: 20),
            const SizedBox(width: 12),
            Text(
              '$feature ${loc.translate('isComingSoon')}',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryDarkest,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _sectionHeader(
    String title, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: AppTextStyles.headlineMedium),
          const Spacer(),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(actionLabel, style: AppTextStyles.goldLabel),
            ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: const AskImanAppBar(),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildAyahOfDay(context),
            const SizedBox(height: 28),
            _buildSacredJourney(context),
            const SizedBox(height: 28),
            _buildSoulProgress(context),
            const SizedBox(height: 28),
            _buildStreakSection(context),
            const SizedBox(height: 28),
            _buildDailyInspiration(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 1 — Ayah of the Day
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildAyahOfDay(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return TooltipOverlay(
      id: 'tut_home_ayah',
      title: loc.translate('tutHomeTitle'),
      description: loc.translate('tutHomeDesc'),
      arrowDirection: TooltipArrowDirection.up,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(loc.translate('ayahOfTheDay')),
          const SizedBox(height: 14),
          SizedBox(
            height: 310,
            child: PageView(
              controller: _ayahController,
              onPageChanged: (i) => setState(() => _ayahPageIndex = i),
              children: _dailyAyahs
                  .map((ayah) => _AyahCard(ayah: ayah))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          // Dot indicators — centred
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _ayahPageIndex ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _ayahPageIndex
                      ? AppColors.gold
                      : AppColors.textLightGrey,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 2 — Sacred Journey Grid
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildSacredJourney(BuildContext context) {
    final items = _sacredItems(context);
    final loc = AppLocalizations.of(context);
    return KeyedSubtree(
      key: _sacredKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(loc.translate('sacredJourney')),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) {
                _SacredJourneyTile tile;
                if (i == 3) {
                  tile = _SacredJourneyTile(
                    key: _askAiKey,
                    image: items[i]['image'] as String,
                    label: items[i]['label'] as String,
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

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 3 — Soul Progress
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildSoulProgress(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(loc.translate('soulProgress')),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _SoulProgressCard(
                label: loc.translate('namaz'),
                sub: loc.translate('weekly'),
                value: _soulProgress['namaz']!,
                display: '${(_soulProgress['namaz']! * 100).toInt()}%',
              ),
              const SizedBox(height: 10),
              _SoulProgressCard(
                label: loc.translate('quran'),
                sub: loc.translate('weekly'),
                value: _soulProgress['quran']!,
                display: '${(_soulProgress['quran']! * 100).toInt()}%',
              ),
              const SizedBox(height: 10),
              _SoulProgressCard(
                label: loc.translate('zikr'),
                sub: loc.translate('weekly'),
                value: _soulProgress['zikr']!,
                display: '${(_soulProgress['zikr']! * 100).toInt()}%',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 3.5 — Streak Section
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildStreakSection(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return KeyedSubtree(
      key: _streaksKey,
      child: TooltipOverlay(
        id: 'tut_home_streaks',
        title: loc.translate('tutHomeStreaksTitle'),
        description: loc.translate('tutHomeStreaksDesc'),
        arrowDirection: TooltipArrowDirection.up,
        child: StreamBuilder<AppUser?>(
          stream: CommunityService.instance.watchCurrentUser(),
          builder: (context, snapshot) {
            final streak = snapshot.data?.streakCount ?? 0;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primaryMid],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.gold,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.translate('currentStreak'),
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textGreenMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            '$streak ${loc.translate('days')}',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        loc.translate('keepItUp'),
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 4 — Daily Inspiration
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildDailyInspiration(BuildContext context) {
    final loc = AppLocalizations.of(context);
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
            _sectionHeader(loc.translate('dailyInspiration')),
            const SizedBox(height: 14),
            SizedBox(
              height: 310, // Match Ayah card height
              child: PageView(
                physics: const BouncingScrollPhysics(),
                children: _dailyHadiths
                    .map((hadith) => _AyahCard(ayah: hadith))
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// WIDGET — Ayah Card (arched Islamic arch shape)
// ══════════════════════════════════════════════════════════════════════════════
class _AyahCard extends StatelessWidget {
  final Map<String, String> ayah;

  const _AyahCard({required this.ayah});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _MosqueDomeClipper(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: AppColors.primaryDark,
          image: DecorationImage(
            image: AssetImage('assets/images/mosque interior.png'),
            fit: BoxFit.cover,
            opacity: 0.15,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ayah['arabic'] ?? '',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 22,
                color: AppColors.gold,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              ayah['translation'] ?? ayah['text'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Colors.white,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Text(
              ayah['reference'] ?? ayah['book'] ?? '',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: AppColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pointed Islamic arch — wider arch opening, deeper point at top centre
// lib/features/home/home_screen.dart
// Replace the _ArchClipper class with this mosque dome (khobat) clipper

// ══════════════════════════════════════════════════════════════════════════════
// MOSQUE DOME (KHOBAT) CLIPPER — Proper mosque dome shape with minaret tips
// ══════════════════════════════════════════════════════════════════════════════
class _MosqueDomeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    // Dome parameters - classic mosque dome proportions
    final domeHeight = h * 0.28; // Dome rises 28% of card height
    final domeBaseY = domeHeight; // Where dome meets straight walls
    final peakX = w / 2; // Center peak
    final peakY = h * 0.02; // Peak near top with small margin

    // Minaret (small spire) at the very top
    final spireHeight = h * 0.04;
    final spireTipY = 0.0;

    final path = Path();

    // Start from bottom-left
    path.moveTo(0, h);

    // Left straight wall up to dome base
    path.lineTo(0, domeBaseY);

    // Left dome curve - elegant Islamic arch shape
    // Control points create the characteristic pointed dome
    path.cubicTo(
      0,
      domeBaseY * 0.7, // control point 1
      w * 0.20,
      domeBaseY * 0.3, // control point 2
      w * 0.35,
      peakY + spireHeight, // end point - left of center
    );

    // Curve to the peak (with minaret spire)
    path.cubicTo(
      w * 0.42,
      peakY + spireHeight * 0.5, // control point 1
      w * 0.48,
      peakY + spireHeight * 0.2, // control point 2
      peakX,
      spireTipY, // end point - top spire
    );

    // Right side of spire down
    path.cubicTo(
      w * 0.52,
      peakY + spireHeight * 0.2, // control point 1
      w * 0.58,
      peakY + spireHeight * 0.5, // control point 2
      w * 0.65,
      peakY + spireHeight, // end point - right of center
    );

    // Right dome curve down to base
    path.cubicTo(
      w * 0.80,
      domeBaseY * 0.3, // control point 1
      w,
      domeBaseY * 0.7, // control point 2
      w,
      domeBaseY, // end point - right base
    );

    // Right straight wall down
    path.lineTo(w, h);

    // Close path
    path.close();

    return path;
  }

  @override
  bool shouldReclip(_MosqueDomeClipper old) => false;
}

// Update _AyahCard build method to use the new clipper:
// Replace ClipPath(clipper: _ArchClipper()) with:
// ClipPath(clipper: _MosqueDomeClipper())

// ══════════════════════════════════════════════════════════════════════════════
// WIDGET — Sacred Journey Tile
// ══════════════════════════════════════════════════════════════════════════════
class _SacredJourneyTile extends StatelessWidget {
  final String image;
  final String label;
  final VoidCallback onTap;

  const _SacredJourneyTile({
    super.key,
    required this.image,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo — fills tile completely, no overflow
              Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    Container(color: AppColors.primaryMid),
              ),

              // Gradient overlay — dark at bottom for text readability
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xD5000000)],
                    stops: [0.35, 1.0],
                  ),
                ),
              ),

              // Label — positioned at bottom, never overflows
              Positioned(
                left: 0,
                right: 0,
                bottom: 12,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textWhite,
                    shadows: [Shadow(color: Colors.black87, blurRadius: 6)],
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

// ══════════════════════════════════════════════════════════════════════════════
// WIDGET — Soul Progress Card
// ══════════════════════════════════════════════════════════════════════════════
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
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Left: label + sub
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textWhite,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textGreenMuted,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Right: circular progress with % text inside
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: value,
                  strokeWidth: 4,
                  backgroundColor: AppColors.primaryMid,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.gold,
                  ),
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Text(
                    display,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
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
