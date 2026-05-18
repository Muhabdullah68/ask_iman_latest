import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/ask_iman_app_bar.dart';
import '../ibadah/qiblah_screen.dart';
import '../ibadah/tasbeeh_screen.dart';

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

  // ── Dummy Data ─────────────────────────────────────────────────────────────
  final List<Map<String, String>> _ayahs = [
    {
      'arabic':
      'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
      'translation':
      '"So remember Me; I will remember you. And be grateful to Me and do not deny Me."',
      'reference': 'Al-Baqarah 2:152',
    },
    {
      'arabic': 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      'translation': '"For indeed, with hardship will be ease."',
      'reference': 'Ash-Sharh 94:6',
    },
    {
      'arabic': 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
      'translation':
      '"And whoever relies upon Allah — then He is sufficient for him."',
      'reference': 'At-Talaq 65:3',
    },
  ];

  final List<Map<String, dynamic>> _sacredItems = [
    {'image': 'assets/images/Holy Quran.png',      'label': 'Quran',   'tab': 1},
    {'image': 'assets/images/Kaaba.png',           'label': 'Qiblah',  'tab': 2},
    {'image': 'assets/images/mosque interior.png', 'label': 'Prayers', 'tab': 2},
    {'image': 'assets/images/AI orb.png',          'label': 'Ask AI',  'tab': 4},
    {'image': 'assets/images/tasbih beads.png',    'label': 'Tasbeeh', 'tab': 2},
    {'image': 'assets/images/islamic lanterns.png','label': 'Events',  'tab': 3},
  ];

  final List<Map<String, dynamic>> _progress = [
    {'label': 'Namaz', 'sub': 'WEEKLY', 'value': 0.85, 'display': '85%'},
    {'label': 'Quran', 'sub': 'WEEKLY', 'value': 0.45, 'display': '45%'},
    {'label': 'Zikr',  'sub': 'WEEKLY', 'value': 0.60, 'display': '60%'},
  ];

  final List<Map<String, String>> _inspirations = [
    {
      'quote':
      '"The heart finds its peace only in the remembrance of Allah."',
      'ref':   'SURAH AR-RA\'D',
      'image': 'assets/images/mosque interior.png',
    },
    {
      'quote': '"Verily, with hardship comes ease."',
      'ref':   'SURAH AL-INSHIRAH',
      'image': 'assets/images/Kaaba.png',
    },
    {
      'quote':
      '"Allah does not burden a soul beyond that it can bear."',
      'ref':   'SURAH AL-BAQARAH',
      'image': 'assets/images/islamic lanterns.png',
    },
  ];

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
      default:
        _navigateTo(tab);
    }
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
          child: PageView.builder(
            controller: _ayahController,
            onPageChanged: (i) => setState(() => _ayahPageIndex = i),
            itemCount: _ayahs.length,
            itemBuilder: (_, i) => _AyahCard(ayah: _ayahs[i]),
          ),
        ),
        const SizedBox(height: 12),
        // Dot indicators — centred
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _ayahs.length,
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
            children: _progress.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SoulProgressCard(
                label:   p['label']   as String,
                sub:     p['sub']     as String,
                value:   p['value']   as double,
                display: p['display'] as String,
              ),
            )).toList(),
          ),
        ),
      ],
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
          height: 270,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: _inspirations.length,
            itemBuilder: (_, i) => _InspirationCard(
              quote: _inspirations[i]['quote']!,
              ref:   _inspirations[i]['ref']!,
              image: _inspirations[i]['image']!,
            ),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: ClipPath(
        clipper: _MosqueDomeClipper(),
        child: Container(
          decoration: const BoxDecoration(color: AppColors.primaryDarkest),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Full background — mosque interior photo
              Image.asset(
                'assets/images/mosque interior.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: AppColors.primaryDark),
              ),

              // Dark green gradient overlay — keeps text readable
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xCC0D2818), // dark green 80% at top
                      Color(0xBB1B4332), // primaryDark 73% mid
                      Color(0xEE0A1A10), // near-black 93% at bottom
                    ],
                    stops: [0.0, 0.45, 1.0],
                  ),
                ),
              ),

              // Content column
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Arabic
                    Flexible(
                      child: Text(
                        ayah['arabic']!,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textWhite,
                          height: 2.0,
                        ),
                      ),
                    ),

                    // Translation
                    Text(
                      ayah['translation']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textCream,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // REFLECT pill button
                    SizedBox(
                      height: 36,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.gold, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          foregroundColor: AppColors.gold,
                          // No splash outside — clean
                          splashFactory: InkRipple.splashFactory,
                        ),
                        child: const Text(
                          'REFLECT',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gold,
                            letterSpacing: 1.5,
                          ),
                        ),
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
                errorBuilder: (_, __, ___) =>
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

// ══════════════════════════════════════════════════════════════════════════════
// WIDGET — Daily Inspiration Card (arch-top, photo bg)
// ══════════════════════════════════════════════════════════════════════════════
class _InspirationCard extends StatelessWidget {
  final String quote;
  final String ref;
  final String image;

  const _InspirationCard({
    required this.quote,
    required this.ref,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final cardW = MediaQuery.of(context).size.width * 0.68;

    return Container(
      width: cardW,
      margin: const EdgeInsets.only(right: 12),
      // Arch shape via BorderRadius — tall top radius mimics arch
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft:     Radius.circular(84),
          topRight:    Radius.circular(84),
          bottomLeft:  Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image — fills card
          Image.asset(
            image,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: AppColors.primaryDark),
          ),

          // Dark overlay — stronger at bottom for text
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x44000000), Color(0xEE000000)],
              ),
            ),
          ),

          // Text — bottom aligned, never overflows
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  quote,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textWhite,
                    height: 1.5,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  ref,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
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
}