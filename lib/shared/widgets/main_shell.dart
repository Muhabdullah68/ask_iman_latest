import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../../shared/widgets/tooltip_overlay.dart';
import '../../features/home/home_screen.dart';
import '../../features/quran/quran_screen.dart';
import '../../features/ibadah/ibadah_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../core/services/tutorial_service.dart';
import '../../features/streaks/streaks_screen.dart';
import '../../features/ibadah/qiblah_screen.dart';
import '../../features/ibadah/tasbeeh_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final List<int> _history = [0];
  final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();
  AnimationController? _celebrationController;
  Animation<double>? _celebrationAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoStartTutorial();
    });
    TutorialService.instance.addListener(_onTutorialChanged);
  }

  @override
  void dispose() {
    TutorialService.instance.removeListener(_onTutorialChanged);
    _celebrationController?.dispose();
    super.dispose();
  }

  void _autoStartTutorial() {
    final svc = TutorialService.instance;
    if (!svc.allSeen()) {
      svc.start();
    }
  }

  void _onTutorialChanged() {
    if (!mounted) return;
    final svc = TutorialService.instance;

    if (svc.showCelebration) {
      _showCelebration();
      return;
    }

    final step = svc.currentStep;
    if (step == null) return;

    // First, ensure we go to Home for reset
    if (svc.currentStepIndex == 0 && _currentIndex != 0) {
      _changeTab(0);
      return;
    }

    if (step.navigateToTab != null && step.navigateToTab != _currentIndex) {
      _changeTab(step.navigateToTab!);
      return;
    }

    if (step.navigateToSubTab != null && _currentIndex == 1) {
      QuranScreen.screenKey.currentState?.animateToTab(step.navigateToSubTab!);
      return;
    }

    if (step.pushRoute == 'qiblah') {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const QiblahScreen()));
      return;
    }
    if (step.pushRoute == 'tasbeeh') {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const TasbeehScreen()));
      return;
    }
  }

  void _showCelebration() {
    _celebrationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _celebrationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _celebrationController!,
        curve: Curves.elasticOut,
      ),
    );
    _celebrationController!.forward();

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (ctx) {
        return AnimatedBuilder(
          animation: _celebrationAnimation!,
          builder: (context, child) {
            return Transform.scale(
              scale: _celebrationAnimation!.value,
              child: child,
            );
          },
          child: AlertDialog(
            backgroundColor: const Color(0xFF1B4332),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: AppColors.gold, width: 2),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 48,
                    color: AppColors.primaryDarkest,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context).translate('tutorialComplete'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(
                    context,
                  ).translate('tutorialCompleteDesc'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.primaryDarkest,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context).translate('startExploring'),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      _celebrationController?.dispose();
      _celebrationController = null;
    });
  }

  void _changeTab(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
      _history.add(index);
    });
    if (index == 1 && !TutorialService.instance.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        QuranScreen.screenKey.currentState?.showPreferencesAutomatically();
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_shellNavigatorKey.currentState?.canPop() ?? false) {
      _shellNavigatorKey.currentState?.pop();
      return false;
    }
    if (_history.length > 1) {
      setState(() {
        _history.removeLast();
        _currentIndex = _history.last;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onNavigateToTab: _changeTab),
      QuranScreen(key: QuranScreen.screenKey, onNavigateToTab: _changeTab),
      const IbadahScreen(),
      const StreaksScreen(),
      const ProfileScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: screens),
        bottomNavigationBar: TooltipOverlay(
          id: 'tut_nav',
          title: AppLocalizations.of(context).translate('tutNavTitle'),
          description: AppLocalizations.of(context).translate('tutNavDesc'),
          arrowDirection: TooltipArrowDirection.up,
          child: _BottomNav(currentIndex: _currentIndex, onTap: _changeTab),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final items = [
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: loc.translate('home'),
      ),
      _NavItem(
        icon: Icons.menu_book_outlined,
        activeIcon: Icons.menu_book,
        label: loc.translate('quran'),
      ),
      _NavItem(
        icon: Icons.auto_awesome_outlined,
        activeIcon: Icons.auto_awesome,
        label: loc.translate('ibadah'),
      ),
      _NavItem(
        icon: Icons.local_fire_department_outlined,
        activeIcon: Icons.local_fire_department,
        label: loc.translate('streaks'),
      ),
      _NavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: loc.translate('profile'),
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final active = currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        active ? item.activeIcon : item.icon,
                        color: active
                            ? AppColors.gold
                            : AppColors.textGreenMuted,
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: active
                              ? AppColors.gold
                              : AppColors.textGreenMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
