// lib/features/ibadah/tasbeeh_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// TASBEEH SCREEN — Full standalone screen (not a bottom sheet)
// Features:
//   • Individual mode  — pick a dhikr, tap to count
//   • Custom Package   — build a playlist of dhikrs with custom targets
//     → Auto-advances to next dhikr when target reached
//     → Islamic completion animation when entire package finishes
//   • Package builder bottom sheet (drag to reorder, +/- count)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/tutorial_service.dart';
import 'dart:math' as math;
import '../../shared/widgets/ask_iman_app_bar.dart';
import '../../shared/widgets/tooltip_overlay.dart';

// ── Data models ───────────────────────────────────────────────────────────────
class DhikrItem {
  final String name;
  final String arabic;
  final String meaning;
  int target;

  DhikrItem({
    required this.name,
    required this.arabic,
    required this.meaning,
    required this.target,
  });
}

class PackageStep {
  final DhikrItem dhikr;
  int target;
  PackageStep({required this.dhikr, required this.target});
}

// ── Preset library ────────────────────────────────────────────────────────────
final _kDhikrLibrary = [
  DhikrItem(
    name: 'SubhanAllah',
    arabic: 'سُبْحَانَ اللَّهِ',
    meaning: '"Glory be to Allah"',
    target: 33,
  ),
  DhikrItem(
    name: 'Alhamdulillah',
    arabic: 'الْحَمْدُ لِلَّهِ',
    meaning: '"All praise is for Allah"',
    target: 33,
  ),
  DhikrItem(
    name: 'Allahu Akbar',
    arabic: 'اللَّهُ أَكْبَرُ',
    meaning: '"Allah is the Greatest"',
    target: 34,
  ),
  DhikrItem(
    name: 'Bismillah',
    arabic: 'بِسْمِ اللَّهِ',
    meaning: '"In the name of Allah"',
    target: 100,
  ),
  DhikrItem(
    name: 'Astaghfirullah',
    arabic: 'أَسْتَغْفِرُ اللَّهَ',
    meaning: '"I seek forgiveness"',
    target: 100,
  ),
  DhikrItem(
    name: 'La ilaha illallah',
    arabic: 'لَا إِلَٰهَ إِلَّا اللَّهُ',
    meaning: '"There is no god but Allah"',
    target: 100,
  ),
  DhikrItem(
    name: 'Salawat',
    arabic: 'صَلَّى اللهُ عَلَيْهِ',
    meaning: '"Blessings upon the Prophet"',
    target: 100,
  ),
  DhikrItem(
    name: 'Hasbunallah',
    arabic: 'حَسْبُنَا اللَّهُ',
    meaning: '"Allah is sufficient for us"',
    target: 40,
  ),
];

// ══════════════════════════════════════════════════════════════════════════════
// TASBEEH SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});
  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen>
    with TickerProviderStateMixin {
  // ── Library ────────────────────────────────────────────────────────────────
  late List<DhikrItem> _dhikrLibrary;

  // ── Mode ───────────────────────────────────────────────────────────────────
  bool _packageMode = false;

  // ── Individual mode ────────────────────────────────────────────────────────
  int _dhikrIndex = 0;
  int _count = 0;

  // ── Package mode ───────────────────────────────────────────────────────────
  List<PackageStep> _package = [];
  int _pkgStepIndex = 0;
  int _pkgStepCount = 0;
  bool _pkgRunning = false;
  bool _showCompletion = false;

  // ── Tap animation ──────────────────────────────────────────────────────────
  bool _soundEnabled = true;
  bool _hapticEnabled = true;
  late AudioPlayer _audioPlayer;
  late AudioPlayer _previewPlayer;
  // Sound uses SystemSound (no asset needed)
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;
  late AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _previewPlayer = AudioPlayer();
    _initAudioPlayer(); // Preload the custom sound
    _dhikrLibrary = List.from(_kDhikrLibrary);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _pulse = Tween<double>(
      begin: 1.0,
      end: 0.93,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Stop sounds when app is backgrounded
    _lifecycleListener = AppLifecycleListener(
      onPause: () => stopAllSounds(),
      onDetach: () => stopAllSounds(),
    );
  }

  Future<void> _initAudioPlayer() async {
    // Preload the custom sound for immediate playback
    try {
      await _audioPlayer.setAsset(
        'assets/sounds/mixkit-camera-shutter-click-1133.wav',
      );
    } catch (e) {
      debugPrint('Sound playback error: $e');
    }
  }

  Future<void> _playClickSound() async {
    // Play the preloaded custom sound
    try {
      await _audioPlayer.seek(Duration.zero); // Reset to start
      await _audioPlayer.play();
    } catch (e) {
      // Fallback to system click if custom sound fails
      SystemSound.play(SystemSoundType.click);
    }
  }

  // Make audioPlayer and previewPlayer accessible, or add a stop method
  void stopAllSounds() {
    try {
      _audioPlayer.stop();
      _previewPlayer.stop();
    } catch (e) {
      debugPrint('Sound playback error: $e');
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _audioPlayer.dispose();
    _previewPlayer.dispose();
    _lifecycleListener.dispose();
    super.dispose();
  }

  // ── Computed ───────────────────────────────────────────────────────────────
  DhikrItem get _currentDhikr => _packageMode && _package.isNotEmpty
      ? _package[_pkgStepIndex].dhikr
      : _dhikrLibrary[_dhikrIndex];

  int get _currentTarget => _packageMode && _package.isNotEmpty
      ? _package[_pkgStepIndex].target
      : _dhikrLibrary[_dhikrIndex].target;

  int get _currentCount => _packageMode ? _pkgStepCount : _count;

  double get _progress => _currentTarget == 0
      ? 0
      : (_currentCount / _currentTarget).clamp(0.0, 1.0);

  // ── Custom Dhikr Logic ─────────────────────────────────────────────────────
  void _showAddDhikrDialog() {
    final nameCtrl = TextEditingController();
    final arabicCtrl = TextEditingController();
    final meaningCtrl = TextEditingController();
    final targetCtrl = TextEditingController(text: '33');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.primaryDark,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Add Custom Dhikr',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogInput('Dhikr Name', nameCtrl, hint: 'e.g. SubhanAllah'),
              const SizedBox(height: 16),
              _dialogInput(
                'Arabic Text (Optional)',
                arabicCtrl,
                hint: 'سُبْحَانَ اللَّهِ',
                isArabic: true,
              ),
              const SizedBox(height: 16),
              _dialogInput(
                'Meaning (Optional)',
                meaningCtrl,
                hint: 'Glory be to Allah',
              ),
              const SizedBox(height: 16),
              _dialogInput(
                'Target Count',
                targetCtrl,
                hint: '33',
                isNumber: true,
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
                color: AppColors.textGrey,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: AppColors.gold,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              final name = nameCtrl.text.trim();
              final target = int.tryParse(targetCtrl.text) ?? 33;
              if (name.isNotEmpty) {
                setState(() {
                  _dhikrLibrary.add(
                    DhikrItem(
                      name: name,
                      arabic: arabicCtrl.text.trim().isEmpty
                          ? name
                          : arabicCtrl.text.trim(),
                      meaning: meaningCtrl.text.trim(),
                      target: target,
                    ),
                  );
                });
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Dhikr Name and Target Count are required'),
                  ),
                );
              }
            },
            child: const Text(
              'Add Dhikr',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dialogInput(
    String label,
    TextEditingController ctrl, {
    String? hint,
    bool isArabic = false,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
          ),
          child: TextField(
            controller: ctrl,
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: TextStyle(
              fontFamily: isArabic ? 'AlQalam' : 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 13,
                fontFamily: isArabic ? 'AlQalam' : 'Cairo',
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onTap() {
    _pulseCtrl.forward().then((_) => _pulseCtrl.reverse());

    if (_soundEnabled) {
      _playClickSound(); // No await, just fire and forget
    }
    if (_hapticEnabled) {
      // The vibration package has no web support — fall back to HapticFeedback.
      if (!kIsWeb) {
        // Use STRONG, GUARANTEED vibration with the vibration package!
        Vibration.vibrate(duration: 100); // Vibrate for 100ms
      }
      // Also use HapticFeedback for extra effect
      HapticFeedback.heavyImpact();
      HapticFeedback.mediumImpact();
    }

    if (_packageMode) {
      _packageTap();
    } else {
      setState(() => _count++);
    }
  }

  void _packageTap() {
    if (!_pkgRunning || _package.isEmpty) return;
    final newCount = _pkgStepCount + 1;
    final step = _package[_pkgStepIndex];

    if (newCount >= step.target) {
      if (_pkgStepIndex < _package.length - 1) {
        setState(() {
          _pkgStepIndex++;
          _pkgStepCount = 0;
        });
        _showStepSnack();
      } else {
        setState(() {
          _pkgStepCount = step.target;
          _pkgRunning = false;
        });
        _triggerCompletion();
      }
    } else {
      setState(() => _pkgStepCount = newCount);
    }
  }

  void _showStepSnack() {
    if (!mounted) return;
    final next = _package[_pkgStepIndex].dhikr.name;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✓ Done! Now: $next',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _triggerCompletion() => setState(() => _showCompletion = true);

  void _resetPackage() => setState(() {
    _pkgStepIndex = 0;
    _pkgStepCount = 0;
    _pkgRunning = false;
    _showCompletion = false;
  });

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: const AskImanAppBar(showBackButton: true),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeroBanner(),
                const SizedBox(height: 16),
                TooltipOverlay(
                  id: 'tut_tasbeeh_package',
                  title: 'Custom Package Mode',
                  description:
                      'Create a sequence of dhikrs to recite together. Build your own worship routine.',
                  arrowDirection: TooltipArrowDirection.up,
                  onNext: () {
                    Navigator.maybePop(context);
                    TutorialService.instance.next();
                  },
                  child: _buildModeToggle(),
                ),
                const SizedBox(height: 16),
                if (_packageMode) _buildPackageHeader(),
                _buildRecitationCard(),
                const SizedBox(height: 32),
                TooltipOverlay(
                  id: 'tut_tasbeeh_individual',
                  title: 'Tasbeeh Counter',
                  description:
                      'Tap the circle to count each recitation. Switch to Custom Package for a sequence.',
                  arrowDirection: TooltipArrowDirection.down,
                  onNext: () {
                    setState(() {
                      _packageMode = true;
                    });
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      TutorialService.instance.next();
                    });
                  },
                  child: _buildCounter(),
                ),
                const SizedBox(height: 28),
                _buildControls(),
                const SizedBox(height: 28),
                if (!_packageMode) _buildDhikrSelector(),
                if (_packageMode && _package.isNotEmpty)
                  _buildPackageStepsPreview(),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (_showCompletion) _CompletionOverlay(onDismiss: _resetPackage),
        ],
      ),
    );
  }

  // ── Hero banner ────────────────────────────────────────────────────────────
  Widget _buildHeroBanner() {
    final sw = MediaQuery.of(context).size.width;
    return ClipPath(
      clipper: _ArchBannerClipper(),
      child: SizedBox(
        height: sw * 0.50,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/tasbih beads.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, _, _) =>
                  Container(color: AppColors.primaryDark),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xAA000000)],
                  stops: [0.3, 1.0],
                ),
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 22),
                child: Text(
                  'Digital Tasbeeh',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Mode toggle ────────────────────────────────────────────────────────────
  Widget _buildModeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            _modePill('Individual', !_packageMode, () {
              setState(() {
                _packageMode = false;
                _showCompletion = false;
              });
            }),
            _modePill('Custom Package', _packageMode, () {
              setState(() {
                _packageMode = true;
                _showCompletion = false;
              });
              if (_package.isEmpty) _openPackageBuilder();
            }),
          ],
        ),
      ),
    );
  }

  Widget _modePill(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primaryDark : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.gold : AppColors.textGrey,
            ),
          ),
        ),
      ),
    );
  }

  // ── Package header ─────────────────────────────────────────────────────────
  Widget _buildPackageHeader() {
    if (_package.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: GestureDetector(
          onTap: _openPackageBuilder,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.bgWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: AppColors.primaryDark,
                  size: 22,
                ),
                SizedBox(width: 10),
                Text(
                  'Build Your Dhikr Package',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final totalDone =
        _package.take(_pkgStepIndex).fold(0, (s, e) => s + e.target) +
        _pkgStepCount;
    final totalTarget = _package.fold(0, (s, e) => s + e.target);
    final overall = totalTarget == 0
        ? 0.0
        : (totalDone / totalTarget).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'STEP ${_pkgStepIndex + 1} / ${_package.length}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.goldDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '$totalDone / $totalTarget',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _openPackageBuilder,
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: overall,
                backgroundColor: AppColors.borderLight,
                color: AppColors.gold,
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Recitation card ────────────────────────────────────────────────────────
  Widget _buildRecitationCard() {
    final d = _currentDhikr;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryDark, width: 1.5),
      ),
      child: Column(
        children: [
          const Text(
            'CURRENT RECITATION',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.gold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            d.arabic,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 26,
              color: AppColors.primaryDark,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            d.name,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            d.meaning,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  // ── Counter circle ─────────────────────────────────────────────────────────
  Widget _buildCounter() {
    final canTap = !_packageMode || (_pkgRunning && _package.isNotEmpty);
    return Center(
      child: GestureDetector(
        onTap: canTap ? _onTap : null,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (_, child) =>
              Transform.scale(scale: _pulse.value, child: child),
          child: SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF5F2EC),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 256,
                  height: 256,
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 4,
                    backgroundColor: const Color(0xFFE8E4DA),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _progress >= 1.0 ? AppColors.success : AppColors.gold,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Container(
                  width: 228,
                  height: 228,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryDark,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_currentCount',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 80,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.0,
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

  // ── Controls row ───────────────────────────────────────────────────────────
  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ctrlBtn(
          Icons.refresh_rounded,
          'Reset',
          () => setState(() => _packageMode ? _resetPackage() : _count = 0),
        ),
        _ctrlBtn(Icons.volume_up_outlined, 'Sound', () {
          setState(() => _soundEnabled = !_soundEnabled);
        }, active: _soundEnabled),
        _ctrlBtn(Icons.vibration_rounded, 'Haptic', () {
          setState(() => _hapticEnabled = !_hapticEnabled);
        }, active: _hapticEnabled),
      ],
    );
  }

  Widget _ctrlBtn(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool active = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF0EDE6),
              border: Border.all(color: const Color(0xFFE0DDD5)),
            ),
            child: Icon(
              icon,
              color: active ? AppColors.primaryDark : Colors.grey,
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  // ── Individual dhikr selector ──────────────────────────────────────────────
  Widget _buildDhikrSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text(
                'Choose Dhikr',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _showAddDhikrDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.gold, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '+ ADD NEW',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(_dhikrLibrary.length, (i) {
              final active = _dhikrIndex == i;
              final d = _dhikrLibrary[i];
              return GestureDetector(
                onTap: () => setState(() {
                  _dhikrIndex = i;
                  _count = 0;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFF8B6914)
                        : const Color(0xFFEEEBE4),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        d.name,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: active ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: active
                              ? Colors.white.withValues(alpha: 0.2)
                              : const Color(0xFFDDD9D0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${d.target}×',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: active ? Colors.white70 : AppColors.textGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ── Package steps preview ──────────────────────────────────────────────────
  Widget _buildPackageStepsPreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Package Steps',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(_package.length, (i) {
            final step = _package[i];
            final done = i < _pkgStepIndex;
            final current = i == _pkgStepIndex;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: done
                    ? AppColors.success.withValues(alpha: 0.06)
                    : current
                    ? AppColors.primaryDark
                    : AppColors.bgWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: done
                      ? AppColors.success.withValues(alpha: 0.3)
                      : current
                      ? AppColors.primaryDark
                      : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: done
                          ? AppColors.success
                          : current
                          ? AppColors.gold
                          : AppColors.bgCream,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: done
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: current
                                    ? AppColors.primaryDarkest
                                    : AppColors.textGrey,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.dhikr.name,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: current
                                ? AppColors.textWhite
                                : AppColors.textDark,
                          ),
                        ),
                        Text(
                          step.dhikr.meaning,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: current
                                ? AppColors.textGreenMuted
                                : AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    current
                        ? '$_pkgStepCount / ${step.target}'
                        : done
                        ? '${step.target} / ${step.target}'
                        : '×${step.target}',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: done
                          ? AppColors.success
                          : current
                          ? AppColors.gold
                          : AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Package builder sheet ──────────────────────────────────────────────────
  void _openPackageBuilder() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PackageBuilderSheet(
        initial: List.from(_package),
        library: _dhikrLibrary,
        onSave: (steps) => setState(() {
          _package = steps;
          _pkgStepIndex = 0;
          _pkgStepCount = 0;
          _pkgRunning = false;
          _showCompletion = false;
        }),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PACKAGE BUILDER SHEET
// ══════════════════════════════════════════════════════════════════════════════
class _PackageBuilderSheet extends StatefulWidget {
  final List<PackageStep> initial;
  final List<DhikrItem> library;
  final void Function(List<PackageStep>) onSave;
  const _PackageBuilderSheet({
    required this.initial,
    required this.library,
    required this.onSave,
  });
  @override
  State<_PackageBuilderSheet> createState() => _PackageBuilderSheetState();
}

class _PackageBuilderSheetState extends State<_PackageBuilderSheet> {
  late List<PackageStep> _steps;

  @override
  void initState() {
    super.initState();
    _steps = widget.initial.isEmpty
        ? [PackageStep(dhikr: widget.library[0], target: 33)]
        : List.from(widget.initial);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.96,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.bgCream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Text(
                    'Build Dhikr Package',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      widget.onSave(_steps);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                '${_steps.length} dhikrs  •  ${_steps.fold(0, (s, e) => s + e.target)} total',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: AppColors.textGrey,
                ),
              ),
            ),
            Container(height: 1, color: AppColors.borderLight),
            // Reorderable steps list
            Expanded(
              child: ReorderableListView.builder(
                scrollController: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                itemCount: _steps.length,
                onReorder: (o, n) => setState(() {
                  final item = _steps.removeAt(o);
                  _steps.insert(n > o ? n - 1 : n, item);
                }),
                itemBuilder: (_, i) => _StepCard(
                  key: ValueKey('step_$i'),
                  step: _steps[i],
                  index: i,
                  onDelete: () => setState(() => _steps.removeAt(i)),
                  onTargetChanged: (v) => setState(() => _steps[i].target = v),
                ),
              ),
            ),
            // Add dhikr section
            Container(
              color: AppColors.bgWhite,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add to Package',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: widget.library
                          .map(
                            (d) => GestureDetector(
                              onTap: () => setState(
                                () => _steps.add(
                                  PackageStep(dhikr: d, target: d.target),
                                ),
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryDark,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.add,
                                      color: AppColors.gold,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      d.name,
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            // ── FIX: SizedBox.height instead of .bottom ──────────────────────
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
          ],
        ),
      ),
    );
  }
}

// ── Step card inside builder ──────────────────────────────────────────────────
class _StepCard extends StatelessWidget {
  final PackageStep step;
  final int index;
  final VoidCallback onDelete;
  final void Function(int) onTargetChanged;
  const _StepCard({
    super.key,
    required this.step,
    required this.index,
    required this.onDelete,
    required this.onTargetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.drag_handle_rounded,
            color: AppColors.textLightGrey,
            size: 20,
          ),
          const SizedBox(width: 10),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.dhikr.name,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  step.dhikr.meaning,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _countBtn(
                Icons.remove,
                () => onTargetChanged((step.target - 10).clamp(1, 99999)),
              ),
              SizedBox(
                width: 52,
                child: Center(
                  child: Text(
                    '${step.target}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),
              _countBtn(Icons.add, () => onTargetChanged(step.target + 10)),
            ],
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDelete,
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.textGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _countBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.bgCream,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Icon(icon, size: 14, color: AppColors.primaryDark),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// COMPLETION OVERLAY — animated Islamic celebration
// ══════════════════════════════════════════════════════════════════════════════
class _CompletionOverlay extends StatefulWidget {
  final VoidCallback onDismiss;
  const _CompletionOverlay({required this.onDismiss});
  @override
  State<_CompletionOverlay> createState() => _CompletionOverlayState();
}

class _CompletionOverlayState extends State<_CompletionOverlay>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _starCtrl;
  late AnimationController _textCtrl;
  late AnimationController _particleCtrl;

  late Animation<double> _bgFade;
  late Animation<double> _starScale;
  late Animation<double> _starRotate;
  late Animation<double> _textSlide;
  late Animation<double> _textFade;

  final List<_Particle> _particles = [];
  final _rng = math.Random();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 30; i++) {
      _particles.add(
        _Particle(
          x: _rng.nextDouble(),
          y: _rng.nextDouble() * 0.6 + 0.2,
          size: _rng.nextDouble() * 6 + 3,
          speed: _rng.nextDouble() * 0.4 + 0.3,
          color: _rng.nextBool() ? AppColors.gold : AppColors.goldLight,
          type: _rng.nextInt(3),
        ),
      );
    }

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _bgFade = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeOut);
    _starScale = CurvedAnimation(parent: _starCtrl, curve: Curves.elasticOut);
    _starRotate = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _starCtrl, curve: Curves.easeOut));
    _textSlide = Tween<double>(
      begin: 40,
      end: 0,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _textFade = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut);

    _bgCtrl.forward().then(
      (_) => _starCtrl.forward().then((_) => _textCtrl.forward()),
    );
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _starCtrl.dispose();
    _textCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _bgFade,
        _starScale,
        _starRotate,
        _textSlide,
        _textFade,
        _particleCtrl,
      ]),
      builder: (ctx, _) => Positioned.fill(
        child: Container(
          color: AppColors.primaryDarkest.withValues(
            alpha: 0.93 * _bgFade.value,
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Floating particles
                ..._particles.map((p) {
                  final t = (_particleCtrl.value + p.speed) % 1.0;
                  final yPos = p.y - t * 0.5;
                  return Positioned(
                    left: p.x * MediaQuery.of(ctx).size.width,
                    top: yPos * MediaQuery.of(ctx).size.height,
                    child: Opacity(
                      opacity: (1 - t) * _bgFade.value,
                      child: _buildParticle(p),
                    ),
                  );
                }),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.rotate(
                        angle: _starRotate.value * 2 * math.pi * 0.05,
                        child: Transform.scale(
                          scale: _starScale.value,
                          child: SizedBox(
                            width: 140,
                            height: 140,
                            child: CustomPaint(
                              painter: _IslamicStarPainter(
                                progress: _starScale.value,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Transform.translate(
                        offset: Offset(0, _textSlide.value),
                        child: Opacity(
                          opacity: _textFade.value,
                          child: Column(
                            children: [
                              const Text(
                                'مَا شَاءَ اللَّهُ',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 36,
                                  color: AppColors.gold,
                                  height: 1.8,
                                ),
                              ),
                              const Text(
                                'MashaAllah!',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Your dhikr package is complete.',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 16,
                                  color: AppColors.textGreenMuted,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                '"And remember Allah much,\nthat you may succeed."',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                  color: AppColors.textGreenMuted,
                                  fontStyle: FontStyle.italic,
                                  height: 1.5,
                                ),
                              ),
                              const Text(
                                '— Quran 8:45',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  color: AppColors.textGreenMuted,
                                ),
                              ),
                              const SizedBox(height: 32),
                              GestureDetector(
                                onTap: widget.onDismiss,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 36,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold,
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  child: const Text(
                                    'Start Again',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDarkest,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildParticle(_Particle p) {
    switch (p.type) {
      case 0:
        return Transform.rotate(
          angle: math.pi / 4,
          child: Container(width: p.size, height: p.size, color: p.color),
        );
      case 1:
        return Container(
          width: p.size,
          height: p.size,
          decoration: BoxDecoration(color: p.color, shape: BoxShape.circle),
        );
      default:
        return SizedBox(
          width: p.size * 2,
          height: p.size * 2,
          child: CustomPaint(painter: _MiniStarPainter(color: p.color)),
        );
    }
  }
}

class _Particle {
  final double x, y, size, speed;
  final Color color;
  final int type;
  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
    required this.type,
  });
}

// ── Star painters ─────────────────────────────────────────────────────────────
class _IslamicStarPainter extends CustomPainter {
  final double progress;
  const _IslamicStarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2, r = size.width / 2;

    canvas.drawCircle(
      Offset(cx, cy),
      r * 1.1,
      Paint()..color = AppColors.gold.withValues(alpha: 0.15 * progress),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.95,
      Paint()..color = AppColors.primaryDark,
    );
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.92,
      Paint()
        ..color = AppColors.gold.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    _drawStar(canvas, cx, cy, r * 0.70, r * 0.32, 8);
    _drawStar(
      canvas,
      cx,
      cy,
      r * 0.26,
      r * 0.12,
      8,
      fill: AppColors.primaryDark,
    );
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.06,
      Paint()..color = AppColors.gold,
    );
  }

  void _drawStar(
    Canvas c,
    double cx,
    double cy,
    double outer,
    double inner,
    int pts, {
    Color? fill,
  }) {
    final paint = Paint()..color = fill ?? AppColors.gold;
    final path = Path();
    for (int i = 0; i < pts * 2; i++) {
      final rad = i.isEven ? outer : inner;
      final angle = (i * math.pi / pts) - math.pi / 2;
      final x = cx + rad * math.cos(angle);
      final y = cy + rad * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    c.drawPath(path, paint);
    if (fill == null) {
      c.drawPath(
        path,
        Paint()
          ..color = AppColors.primaryDark.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }
  }

  @override
  bool shouldRepaint(_IslamicStarPainter old) => old.progress != progress;
}

class _MiniStarPainter extends CustomPainter {
  final Color color;
  const _MiniStarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2, r = size.width / 2;
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final rad = i.isEven ? r : r * 0.45;
      final angle = (i * math.pi / 5) - math.pi / 2;
      final x = cx + rad * math.cos(angle);
      final y = cy + rad * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Arch clipper ──────────────────────────────────────────────────────────────
class _ArchBannerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width, h = size.height;
    return Path()
      ..moveTo(0, h)
      ..lineTo(w, h)
      ..lineTo(w, h * 0.45)
      ..cubicTo(w, h * 0.10, w * 0.70, 0, w / 2, 0)
      ..cubicTo(w * 0.30, 0, 0, h * 0.10, 0, h * 0.45)
      ..close();
  }

  @override
  bool shouldReclip(_) => false;
}
