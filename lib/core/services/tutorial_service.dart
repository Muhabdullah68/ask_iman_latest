import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TooltipArrowDirection { up, down, left, right }

class TutorialStep {
  final String id;
  final String screen;
  final String titleKey;
  final String descKey;
  final TooltipArrowDirection arrowDirection;
  final int? navigateToTab;
  final int? navigateToSubTab;
  final String? pushRoute;

  const TutorialStep({
    required this.id,
    required this.screen,
    required this.titleKey,
    required this.descKey,
    this.arrowDirection = TooltipArrowDirection.up,
    this.navigateToTab,
    this.navigateToSubTab,
    this.pushRoute,
  });
}

class TutorialService extends ChangeNotifier {
  static final TutorialService _instance = TutorialService._internal();
  factory TutorialService() => _instance;
  TutorialService._internal();

  static TutorialService get instance => _instance;

  static const List<TutorialStep> tutorialSequence = [
    // ── Home Screen ─────────────────────────────────────────────────────
    TutorialStep(
      id: 'tut_home_ayah',
      screen: 'home',
      titleKey: 'tutHomeTitle',
      descKey: 'tutHomeDesc',
      arrowDirection: TooltipArrowDirection.up,
    ),
    TutorialStep(
      id: 'tut_home_streaks',
      screen: 'home',
      titleKey: 'tutHomeDuaTitle',
      descKey: 'tutHomeDuaDesc',
      arrowDirection: TooltipArrowDirection.up,
    ),
    TutorialStep(
      id: 'tut_home_inspiration',
      screen: 'home',
      titleKey: 'tutHomeDailyInspiration',
      descKey: 'tutHomeDailyInspirationDesc',
      arrowDirection: TooltipArrowDirection.up,
    ),
    TutorialStep(
      id: 'tut_nav',
      screen: 'home',
      titleKey: 'tutNavTitle',
      descKey: 'tutNavDesc',
      arrowDirection: TooltipArrowDirection.up,
    ),

    // ── Quran Tab + Sub-tabs ────────────────────────────────────────────
    TutorialStep(
      id: 'tut_quran',
      screen: 'quran',
      titleKey: 'tutQuranTitle',
      descKey: 'tutQuranDesc',
      arrowDirection: TooltipArrowDirection.up,
      navigateToTab: 1,
    ),
    TutorialStep(
      id: 'tut_quran_talawat',
      screen: 'quran',
      titleKey: 'tutQuranTalawatTitle',
      descKey: 'tutQuranTalawatDesc',
      arrowDirection: TooltipArrowDirection.up,
      navigateToSubTab: 0,
    ),
    TutorialStep(
      id: 'tut_quran_translation',
      screen: 'quran',
      titleKey: 'tutQuranTranslationTitle',
      descKey: 'tutQuranTranslationDesc',
      arrowDirection: TooltipArrowDirection.up,
      navigateToSubTab: 1,
    ),
    TutorialStep(
      id: 'tut_quran_tafseer',
      screen: 'quran',
      titleKey: 'tutQuranTafseerTitle',
      descKey: 'tutQuranTafseerDesc',
      arrowDirection: TooltipArrowDirection.up,
      navigateToSubTab: 2,
    ),
    TutorialStep(
      id: 'tut_quran_ayat',
      screen: 'quran',
      titleKey: 'tutQuranAyatTitle',
      descKey: 'tutQuranAyatDesc',
      arrowDirection: TooltipArrowDirection.up,
      navigateToSubTab: 3,
    ),
    TutorialStep(
      id: 'tut_quran_ahadees',
      screen: 'quran',
      titleKey: 'tutQuranAhadeesTitle',
      descKey: 'tutQuranAhadeesDesc',
      arrowDirection: TooltipArrowDirection.up,
      navigateToSubTab: 4,
    ),

    // ── Ibadah Tab ──────────────────────────────────────────────────────
    TutorialStep(
      id: 'tut_ibadah',
      screen: 'ibadah',
      titleKey: 'tutIbadahPrayerTitle',
      descKey: 'tutIbadahPrayerDesc',
      arrowDirection: TooltipArrowDirection.up,
      navigateToTab: 2,
    ),

    // ── Qibla Screen ────────────────────────────────────────────────────
    TutorialStep(
      id: 'tut_qiblah',
      screen: 'qiblah',
      titleKey: 'tutIbadahQiblaTitle',
      descKey: 'tutIbadahQiblaDesc',
      arrowDirection: TooltipArrowDirection.up,
      pushRoute: 'qiblah',
    ),

    // ── Tasbeeh Screen (individual mode first) ──────────────────────────
    TutorialStep(
      id: 'tut_tasbeeh_individual',
      screen: 'tasbeeh',
      titleKey: 'tutTasbeehIndividualTitle',
      descKey: 'tutTasbeehIndividualDesc',
      arrowDirection: TooltipArrowDirection.up,
      pushRoute: 'tasbeeh',
    ),

    // ── Tasbeeh Screen (package mode) ───────────────────────────────────
    TutorialStep(
      id: 'tut_tasbeeh_package',
      screen: 'tasbeeh',
      titleKey: 'tutTasbeehPackageTitle',
      descKey: 'tutTasbeehPackageDesc',
      arrowDirection: TooltipArrowDirection.up,
    ),

    // ── Streaks Tab ────────────────────────────────────────────────────
    TutorialStep(
      id: 'tut_streaks',
      screen: 'streaks',
      titleKey: 'tutStreaksComingSoonTitle',
      descKey: 'tutStreaksComingSoonDesc',
      arrowDirection: TooltipArrowDirection.up,
      navigateToTab: 3,
    ),

    // ── Profile Tab ─────────────────────────────────────────────────────
    TutorialStep(
      id: 'tut_profile',
      screen: 'profile',
      titleKey: 'tutProfileSettingsTitle',
      descKey: 'tutProfileSettingsDesc',
      arrowDirection: TooltipArrowDirection.up,
      navigateToTab: 4,
    ),
  ];

  SharedPreferences? _prefs;
  final Set<String> _seenTooltipIds = {};
  bool _isInitialized = false;
  int _currentStepIndex = -1;
  bool _celebration = false;

  bool get isInitialized => _isInitialized;
  bool get isActive =>
      _currentStepIndex >= 0 && _currentStepIndex < tutorialSequence.length;
  int get currentStepIndex => _currentStepIndex;
  String? get currentStepId =>
      isActive ? tutorialSequence[_currentStepIndex].id : null;
  TutorialStep? get currentStep =>
      isActive ? tutorialSequence[_currentStepIndex] : null;
  bool get showCelebration => _celebration;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    final seenIds = _prefs?.getStringList('seen_tooltip_ids') ?? [];
    _seenTooltipIds.addAll(seenIds);
    _isInitialized = true;
  }

  bool isSeen(String id) => _seenTooltipIds.contains(id);

  Future<void> markSeen(String id) async {
    if (_seenTooltipIds.contains(id)) return;
    _seenTooltipIds.add(id);
    await _prefs?.setStringList('seen_tooltip_ids', _seenTooltipIds.toList());
  }

  bool allSeen() {
    for (final step in tutorialSequence) {
      if (!_seenTooltipIds.contains(step.id)) return false;
    }
    return true;
  }

  void start() {
    if (allSeen()) return;
    _currentStepIndex = tutorialSequence.indexWhere(
      (s) => !_seenTooltipIds.contains(s.id),
    );
    if (_currentStepIndex < 0) _currentStepIndex = 0;
    _celebration = false;
    notifyListeners();
  }

  Future<void> next() async {
    if (_currentStepIndex < 0 || _currentStepIndex >= tutorialSequence.length) {
      return;
    }

    await markSeen(tutorialSequence[_currentStepIndex].id);

    _currentStepIndex++;
    if (_currentStepIndex >= tutorialSequence.length) {
      _currentStepIndex = -1;
      _celebration = true;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 4));
      _celebration = false;
      notifyListeners();
      return;
    }
    notifyListeners();
  }

  Future<void> skipAll() async {
    for (final step in tutorialSequence) {
      if (!_seenTooltipIds.contains(step.id)) {
        await markSeen(step.id);
      }
    }
    _currentStepIndex = -1;
    _celebration = false;
    notifyListeners();
  }

  Future<void> resetAll() async {
    _seenTooltipIds.clear();
    _prefs?.remove('seen_tooltip_ids');
    _currentStepIndex = 0; // Start from first step
    _celebration = false;
    notifyListeners();
  }

  // Public method to force listeners to update (for after scroll animation)
  void forceRefresh() {
    notifyListeners();
  }
}
