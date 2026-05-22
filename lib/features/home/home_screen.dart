import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/ask_iman_app_bar.dart';
import '../ibadah/qiblah_screen.dart';
import '../ibadah/tasbeeh_screen.dart';
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
  final PageController _ayahController =
  PageController(viewportFraction: 0.88);
  
  Map<String, double> _soulProgress = {'namaz': 0, 'quran': 0, 'zikr': 0};

  // ── Daily Data ─────────────────────────────────────────────────────────────
  late final List<Map<String, String>> _dailyAyahs;
  late final List<Map<String, String>> _dailyHadiths;

  final List<Map<String, dynamic>> _sacredItems = [
    {'image': 'assets/images/Holy Quran.png',      'label': 'Quran',   'tab': 1},
    {'image': 'assets/images/Kaaba.png',           'label': 'Qiblah',  'tab': 2},
    {'image': 'assets/images/mosque interior.png', 'label': 'Prayers', 'tab': 2},
    {'image': 'assets/images/AI orb.png',          'label': 'Ask AI',  'tab': 4},
    {'image': 'assets/images/tasbih beads.png',    'label': 'Tasbeeh', 'tab': 2},
    {'image': 'assets/images/islamic lanterns.png','label': 'Events',  'tab': 3},
  ];

  @override
  void initState() {
    super.initState();
    _dailyAyahs = DailyData.getDailyAyahs(5);
    _dailyHadiths = DailyData.getDailyHadiths(5);
    _loadSoulProgress();
  }

  Future<void> _loadSoulProgress() async {
    final progress = await CommunityService.instance.getSoulProgress();
    if (mounted) {
      setState(() {
        _soulProgress = progress;
      });
    }
  }

  @override
  void dispose() {
    _ayahController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _navigateTo(int tab) => widget.onNavigateToTab?.call(tab);

  void _handleSacredTap(String label, int tab) {
    switch (label) {
      case 'Qiblah':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const QiblahScreen()));
        break;
      case 'Tasbeeh':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const TasbeehScreen()));
        break;
      case 'Ask AI':
      case 'Events':
        _showComingSoon(label);
        break;
      default:
        _navigateTo(tab);
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.gold, size: 20),
            const SizedBox(width: 12),
            Text(
              '$feature is coming soon! 🌙',
              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
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

  Widget _sectionHeader(String title,
      {String? actionLabel, VoidCallback? onAction}) {
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
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildAyahOfDay(),
            const SizedBox(height: 28),
            _buildSacredJourney(),
            const SizedBox(height: 28),
            _buildSoulProgress(),
            const SizedBox(height: 28),
            _buildStreakSection(),
            const SizedBox(height: 28),
            _buildDailyInspiration(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 1 — Ayah of the Day
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildAyahOfDay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Ayah of the Day'),
        const SizedBox(height: 14),
        SizedBox(
          height: 310,
          child: PageView(
            controller: _ayahController,
            onPageChanged: (i) => setState(() => _ayahPageIndex = i),
            children: _dailyAyahs.map((ayah) => _AyahCard(ayah: ayah)).toList(),
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
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 2 — Sacred Journey Grid
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildSacredJourney() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Sacred Journey'),
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
            itemCount: _sacredItems.length,
            itemBuilder: (_, i) => _SacredJourneyTile(
              image: _sacredItems[i]['image'] as String,
              label: _sacredItems[i]['label'] as String,
              onTap: () => _handleSacredTap(
                _sacredItems[i]['label'] as String,
                _sacredItems[i]['tab'] as int,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 3 — Soul Progress
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildSoulProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Soul Progress'),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _SoulProgressCard(
                label: 'Namaz',
                sub: 'WEEKLY',
                value: _soulProgress['namaz']!,
                display: '${(_soulProgress['namaz']! * 100).toInt()}%',
              ),
              const SizedBox(height: 10),
              _SoulProgressCard(
                label: 'Quran',
                sub: 'WEEKLY',
                value: _soulProgress['quran']!,
                display: '${(_soulProgress['quran']! * 100).toInt()}%',
              ),
              const SizedBox(height: 10),
              _SoulProgressCard(
                label: 'Zikr',
                sub: 'WEEKLY',
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
  Widget _buildStreakSection() {
    return StreamBuilder<AppUser?>(
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
                  child: const Icon(Icons.local_fire_department_rounded, 
                    color: AppColors.gold, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Streak',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textGreenMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '$streak Days',
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: const Text(
                    'KEEP IT UP!',
                    style: TextStyle(
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
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 4 — Daily Inspiration
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildDailyInspiration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Daily Inspiration'),
        const SizedBox(height: 14),
        SizedBox(
          height: 310, // Match Ayah card height
          child: PageView(
            physics: const BouncingScrollPhysics(),
            children: _dailyHadiths.map((hadith) => _AyahCard(ayah: hadith)).toList(),
          ),
        ),
      ],
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
    final domeHeight = h * 0.28;        // Dome rises 28% of card height
    final domeBaseY = domeHeight;       // Where dome meets straight walls
    final peakX = w / 2;                // Center peak
    final peakY = h * 0.02;             // Peak near top with small margin

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
      0, domeBaseY * 0.7,                    // control point 1
      w * 0.20, domeBaseY * 0.3,             // control point 2
      w * 0.35, peakY + spireHeight,         // end point - left of center
    );

    // Curve to the peak (with minaret spire)
    path.cubicTo(
      w * 0.42, peakY + spireHeight * 0.5,   // control point 1
      w * 0.48, peakY + spireHeight * 0.2,   // control point 2
      peakX, spireTipY,                       // end point - top spire
    );

    // Right side of spire down
    path.cubicTo(
      w * 0.52, peakY + spireHeight * 0.2,   // control point 1
      w * 0.58, peakY + spireHeight * 0.5,   // control point 2
      w * 0.65, peakY + spireHeight,         // end point - right of center
    );

    // Right dome curve down to base
    path.cubicTo(
      w * 0.80, domeBaseY * 0.3,             // control point 1
      w, domeBaseY * 0.7,                    // control point 2
      w, domeBaseY,                          // end point - right base
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
                  valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.gold),
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
