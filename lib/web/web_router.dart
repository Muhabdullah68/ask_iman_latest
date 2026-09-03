// lib/web/web_router.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — ROUTES
//
// GoRouter setup for the website with smooth page transitions.
//   /                          Home
//   /quran                     Quran Explorer (tabs)
//   /quran/talawat             Quran → Talawat tab
//   /quran/translation         Quran → Tarjuma tab
//   /quran/hadith              Quran → Ahadith tab
//   /quran/juzz                Quran → Juzz tab
//   /quran/ayah                Quran → Daily Ayah tab
//   /quran/tafseer             Tafseer reader
//   /calendar-tools            Calendar & Tools (Ibadah)
//   /calendar-tools/99-names   99 Names explorer
//   /calendar-tools/tasbeeh    Tasbeeh counter
//   /community                 Community & Charity
//   /community/family          Family (deep link)
//   /charity                   Charity campaigns
//   /about                     About Us (#contact anchor)
//   /profile                   Profile
//   /sign-in, /sign-up         Auth
//   /search                    Global search (?q=)
//   /coming-soon               Placeholder
//   /secret-admin-dashboard    Hidden admin (guard)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/services/alarm_service.dart';
import 'pages/about_page.dart';
import 'pages/auth_page.dart';
import 'pages/calendar_tools_page.dart';
import 'pages/coming_soon_page.dart';
import 'pages/community_page.dart';
import 'pages/home_page.dart';
import 'pages/names_of_allah_page.dart';
import 'pages/profile_page.dart';
import 'pages/quran/surah_reading_page.dart';
import 'pages/quran_page.dart';
import 'pages/search_page.dart';
import 'widgets/web_shell.dart';

class WebRoutes {
  static const home = '/';
  static const quran = '/quran';
  static const calendarTools = '/calendar-tools';
  static const community = '/community';
  static const charity = '/charity';
  static const about = '/about';
  static const profile = '/profile';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const search = '/search';
  static const comingSoon = '/coming-soon';
  static const adminDashboard = '/secret-admin-dashboard';
}

Widget _slideFadeTransition(Widget child, Animation<double> animation) {
  final curved = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  return FadeTransition(
    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.03),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    ),
  );
}

CustomTransitionPage<void> _buildPage(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        _slideFadeTransition(child, animation),
  );
}

final router = GoRouter(
  navigatorKey: AlarmService.instance.navigatorKey,
  initialLocation: WebRoutes.home,
  routes: [
    // ── Home ─────────────────────────────────────────────────────────────
    GoRoute(
      path: WebRoutes.home,
      name: 'home',
      pageBuilder: (context, state) =>
          _buildPage(const WebShell(child: HomePage()), state),
    ),

    // ── Quran Explorer ────────────────────────────────────────────────────
    GoRoute(
      path: '/quran',
      name: 'quran',
      pageBuilder: (context, state) =>
          _buildPage(const WebShell(child: QuranPage()), state),
      routes: [
        GoRoute(
          path: 'talawat',
          name: 'quranTalawat',
          pageBuilder: (context, state) =>
              _buildPage(WebShell(child: const QuranPage(tab: 0)), state),
        ),
        GoRoute(
          path: 'tarjuma',
          name: 'quranTarjuma',
          pageBuilder: (context, state) =>
              _buildPage(WebShell(child: const QuranPage(tab: 1)), state),
        ),
        GoRoute(
          path: 'tafseer',
          name: 'quranTafseer',
          pageBuilder: (context, state) =>
              _buildPage(WebShell(child: const QuranPage(tab: 2)), state),
        ),
        GoRoute(
          path: 'settings',
          name: 'quranSettings',
          pageBuilder: (context, state) =>
              _buildPage(WebShell(child: const QuranPage(tab: 3)), state),
        ),
        GoRoute(
          path: 'share',
          name: 'quranShare',
          pageBuilder: (context, state) =>
              _buildPage(WebShell(child: const QuranPage(tab: 4)), state),
        ),
        GoRoute(
          path: 'surah/:id',
          name: 'quranSurah',
          pageBuilder: (context, state) => _buildPage(
            WebShell(
              child: SurahReadingPage(
                surahNum:
                    int.tryParse(state.pathParameters['id'] ?? '') ?? 1,
              ),
            ),
            state,
          ),
        ),
        // Legacy route redirects
        GoRoute(
          path: 'translation',
          name: 'quranTranslationLegacy',
          redirect: (_, _) => '/quran/tarjuma',
        ),
        GoRoute(
          path: 'hadith',
          name: 'quranHadithLegacy',
          redirect: (_, _) => '/quran/tarjuma',
        ),
        GoRoute(
          path: 'juzz',
          name: 'quranJuzzLegacy',
          redirect: (_, _) => '/quran/talawat',
        ),
        GoRoute(
          path: 'ayah',
          name: 'quranAyahLegacy',
          redirect: (_, _) => '/quran/tarjuma',
        ),
      ],
    ),

    // ── Calendar & Tools ──────────────────────────────────────────────────
    GoRoute(
      path: WebRoutes.calendarTools,
      name: 'calendarTools',
      pageBuilder: (context, state) =>
          _buildPage(const WebShell(child: CalendarToolsPage()), state),
      routes: [
        GoRoute(
          path: '99-names',
          name: 'namesOfAllah',
          pageBuilder: (context, state) =>
              _buildPage(const WebShell(child: NamesOfAllahPage()), state),
        ),
        GoRoute(
          path: 'tasbeeh',
          name: 'tasbeeh',
          pageBuilder: (context, state) =>
              _buildPage(const WebShell(child: TasbeehPage()), state),
        ),
      ],
    ),

    // ── Community & Charity ───────────────────────────────────────────────
    GoRoute(
      path: WebRoutes.community,
      name: 'community',
      pageBuilder: (context, state) =>
          _buildPage(const WebShell(child: CommunityPage()), state),
      routes: [
        GoRoute(
          path: 'family',
          name: 'communityFamily',
          pageBuilder: (context, state) =>
              _buildPage(const WebShell(child: CommunityPage()), state),
        ),
      ],
    ),
    GoRoute(
      path: WebRoutes.charity,
      name: 'charity',
      pageBuilder: (context, state) =>
          _buildPage(const WebShell(child: CharityPage()), state),
    ),

    // ── About Us ──────────────────────────────────────────────────────────
    GoRoute(
      path: WebRoutes.about,
      name: 'about',
      pageBuilder: (context, state) =>
          _buildPage(const WebShell(child: AboutPage()), state),
    ),

    // ── Profile & Auth ────────────────────────────────────────────────────
    GoRoute(
      path: WebRoutes.profile,
      name: 'profile',
      pageBuilder: (context, state) =>
          _buildPage(const WebShell(child: ProfilePage()), state),
    ),
    GoRoute(
      path: WebRoutes.signIn,
      name: 'signIn',
      pageBuilder: (context, state) =>
          _buildPage(const WebShell(child: SignInPage()), state),
    ),
    GoRoute(
      path: '/sign-up',
      name: 'signUp',
      pageBuilder: (context, state) =>
          _buildPage(const WebShell(child: SignUpPage()), state),
      routes: [
        GoRoute(
          path: ':role',
          name: 'signUpRole',
          pageBuilder: (context, state) =>
              _buildPage(const WebShell(child: SignUpPage()), state),
        ),
      ],
    ),

    // ── Search ────────────────────────────────────────────────────────────
    GoRoute(
      path: WebRoutes.search,
      name: 'search',
      pageBuilder: (context, state) {
        final q = state.uri.queryParameters['q'] ?? '';
        return _buildPage(WebShell(child: SearchPage(initialQuery: q)), state);
      },
    ),

    // ── Placeholders ──────────────────────────────────────────────────────
    GoRoute(
      path: WebRoutes.comingSoon,
      name: 'comingSoon',
      pageBuilder: (context, state) =>
          _buildPage(const WebShell(child: ComingSoonPage()), state),
    ),

    // ── Hidden admin dashboard (guard) ────────────────────────────────────
    GoRoute(
      path: WebRoutes.adminDashboard,
      name: 'adminDashboard',
      pageBuilder: (context, state) =>
          _buildPage(const WebShell(child: ProfilePage()), state),
    ),
  ],
  errorBuilder: (context, state) => WebShell(
    child: ComingSoonPage(title: 'Page Not Found'),
  ),
);
