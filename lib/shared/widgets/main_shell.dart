// lib/shared/widgets/main_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../../features/home/home_screen.dart';
import '../../features/quran/quran_screen.dart';
import '../../features/ibadah/ibadah_screen.dart';
// import '../../features/community/community_auth_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/alarm_service.dart';

import '../../features/community/community_auth_screen.dart'; // Needed for CommunityGate if applicable

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final List<int> _history = [0];

  @override
  void initState() {
    super.initState();
    // Request notification permissions when the main app is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.requestPermission();
      AlarmService.instance.requestPermissions();
    });
  }

  void _changeTab(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
      _history.add(index);
    });
    
    // Auto-show Quran preferences only when navigating to the Quran tab
    if (index == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        QuranScreen.screenKey.currentState?.showPreferencesAutomatically();
      });
    }
  }

  // Global navigator key to handle nested navigations
  final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

  Future<bool> _onWillPop() async {
    // First check if there's a nested navigator that can pop
    if (_shellNavigatorKey.currentState?.canPop() ?? false) {
      _shellNavigatorKey.currentState?.pop();
      return false;
    }

    // Then check tab history
    if (_history.length > 1) {
      setState(() {
        _history.removeLast();
        _currentIndex = _history.last;
      });
      return false;
    }

    // If nothing else, exit app
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onNavigateToTab: _changeTab),
      QuranScreen(key: QuranScreen.screenKey),
      const IbadahScreen(),
      const CommunityGate(), // Updated to only show streaks (guest mode) as requested
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
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: _BottomNav(
          currentIndex: _currentIndex,
          onTap: _changeTab,
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
      _NavItem(icon: Icons.home_outlined,        activeIcon: Icons.home,        label: loc.translate('home')),
      _NavItem(icon: Icons.menu_book_outlined,    activeIcon: Icons.menu_book,    label: loc.translate('quran')),
      _NavItem(icon: Icons.auto_awesome_outlined, activeIcon: Icons.auto_awesome, label: loc.translate('ibadah')),
      _NavItem(icon: Icons.local_fire_department_outlined, activeIcon: Icons.local_fire_department, label: loc.translate('streaks')),
      _NavItem(icon: Icons.person_outline,        activeIcon: Icons.person,       label: loc.translate('profile')),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.only(
          topLeft:  Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final item   = items[i];
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
                        color: active ? AppColors.gold : AppColors.textGreenMuted,
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                          color: active ? AppColors.gold : AppColors.textGreenMuted,
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
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}
