// lib/web/web_router.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — ROUTES
//
// GoRouter setup for the website. Real URLs:
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

final router = GoRouter(
  navigatorKey: AlarmService.instance.navigatorKey,
  initialLocation: WebRoutes.home,
  routes: [
    // ── Home ─────────────────────────────────────────────────────────────
    GoRoute(
      path: WebRoutes.home,
      name: 'home',
      builder: (context, state) => const WebShell(child: HomePage()),
    ),

    // ── Quran Explorer ────────────────────────────────────────────────────
    GoRoute(
      path: '/quran',
      name: 'quran',
      builder: (context, state) => const WebShell(child: QuranPage()),
      routes: [
        GoRoute(
          path: 'talawat',
          name: 'quranTalawat',
          builder: (context, state) =>
              WebShell(child: const QuranPage(tab: 0)),
        ),
        GoRoute(
          path: 'tarjuma',
          name: 'quranTarjuma',
          builder: (context, state) =>
              WebShell(child: const QuranPage(tab: 1)),
        ),
        GoRoute(
          path: 'tafseer',
          name: 'quranTafseer',
          builder: (context, state) =>
              WebShell(child: const QuranPage(tab: 2)),
        ),
        GoRoute(
          path: 'settings',
          name: 'quranSettings',
          builder: (context, state) =>
              WebShell(child: const QuranPage(tab: 3)),
        ),
        GoRoute(
          path: 'share',
          name: 'quranShare',
          builder: (context, state) =>
              WebShell(child: const QuranPage(tab: 4)),
        ),
        GoRoute(
          path: 'surah/:id',
          name: 'quranSurah',
          builder: (context, state) => WebShell(
            child: SurahReadingPage(
              surahNum:
                  int.tryParse(state.pathParameters['id'] ?? '') ?? 1,
            ),
          ),
        ),
        // Legacy route redirects
        GoRoute(
          path: 'translation',
          name: 'quranTranslationLegacy',
          builder: (context, state) =>
              WebShell(child: const QuranPage(tab: 1)),
        ),
        GoRoute(
          path: 'hadith',
          name: 'quranHadithLegacy',
          builder: (context, state) =>
              WebShell(child: const QuranPage(tab: 1)),
        ),
        GoRoute(
          path: 'juzz',
          name: 'quranJuzzLegacy',
          builder: (context, state) =>
              WebShell(child: const QuranPage(tab: 0)),
        ),
        GoRoute(
          path: 'ayah',
          name: 'quranAyahLegacy',
          builder: (context, state) =>
              WebShell(child: const QuranPage(tab: 1)),
        ),
      ],
    ),

    // ── Calendar & Tools ──────────────────────────────────────────────────
    GoRoute(
      path: WebRoutes.calendarTools,
      name: 'calendarTools',
      builder: (context, state) =>
          const WebShell(child: CalendarToolsPage()),
      routes: [
        GoRoute(
          path: '99-names',
          name: 'namesOfAllah',
          builder: (context, state) =>
              const WebShell(child: NamesOfAllahPage()),
        ),
        GoRoute(
          path: 'tasbeeh',
          name: 'tasbeeh',
          builder: (context, state) => const WebShell(child: TasbeehPage()),
        ),
      ],
    ),

    // ── Community & Charity ───────────────────────────────────────────────
    GoRoute(
      path: WebRoutes.community,
      name: 'community',
      builder: (context, state) => const WebShell(child: CommunityPage()),
      routes: [
        GoRoute(
          path: 'family',
          name: 'communityFamily',
          builder: (context, state) =>
              const WebShell(child: CommunityPage()),
        ),
      ],
    ),
    GoRoute(
      path: WebRoutes.charity,
      name: 'charity',
      builder: (context, state) => const WebShell(child: CharityPage()),
    ),

    // ── About Us ──────────────────────────────────────────────────────────
    GoRoute(
      path: WebRoutes.about,
      name: 'about',
      builder: (context, state) => const WebShell(child: AboutPage()),
    ),

    // ── Profile & Auth ────────────────────────────────────────────────────
    GoRoute(
      path: WebRoutes.profile,
      name: 'profile',
      builder: (context, state) => const WebShell(child: ProfilePage()),
    ),
    GoRoute(
      path: WebRoutes.signIn,
      name: 'signIn',
      builder: (context, state) => const WebShell(child: SignInPage()),
    ),
    GoRoute(
      path: '/sign-up',
      name: 'signUp',
      builder: (context, state) => const WebShell(child: SignUpPage()),
      routes: [
        GoRoute(
          path: ':role',
          name: 'signUpRole',
          builder: (context, state) => const WebShell(child: SignUpPage()),
        ),
      ],
    ),

    // ── Search ────────────────────────────────────────────────────────────
    GoRoute(
      path: WebRoutes.search,
      name: 'search',
      builder: (context, state) {
        final q = state.uri.queryParameters['q'] ?? '';
        return WebShell(child: SearchPage(initialQuery: q));
      },
    ),

    // ── Placeholders ──────────────────────────────────────────────────────
    GoRoute(
      path: WebRoutes.comingSoon,
      name: 'comingSoon',
      builder: (context, state) => const WebShell(child: ComingSoonPage()),
    ),

    // ── Hidden admin dashboard (guard) ────────────────────────────────────
    GoRoute(
      path: WebRoutes.adminDashboard,
      name: 'adminDashboard',
      builder: (context, state) =>
          const WebShell(child: ProfilePage()),
    ),
  ],
  errorBuilder: (context, state) => WebShell(
    child: ComingSoonPage(title: 'Page Not Found'),
  ),
);
