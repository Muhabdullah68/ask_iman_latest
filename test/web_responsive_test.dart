// test/web_responsive_test.dart
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// RESPONSIVE / NO-OVERFLOW REGRESSION GUARD (website)
//
// Pumps each firebase-free website page inside its real theme + router harness
// at phone / tablet / laptop / desktop widths and asserts the frame never
// reports a RenderFlex overflow or other layout exception.
//
// Excluded surfaces (need Firebase / network / audio that tests can't provide):
//   * CommunityPage / CharityPage / ProfilePage / SignIn / SignUp (Firebase)
//   * QuranPage (IndexedStack builds 5 async data-fetching panes at once; its
//     pinned chrome + per-pane layout is verified in the local build step)
//
// IMPORTANT: fonts fall back to the test "Ahem" font, so this guards against
// layout/overflow regressions structurally, not as a pixel-perfect screenshot.
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ask_iman/core/theme/app_theme.dart';
import 'package:ask_iman/web/pages/about_page.dart';
import 'package:ask_iman/web/pages/calendar_tools_page.dart';
import 'package:ask_iman/web/pages/coming_soon_page.dart';
import 'package:ask_iman/web/pages/home_page.dart';
import 'package:ask_iman/web/pages/names_of_allah_page.dart';
import 'package:ask_iman/web/pages/search_page.dart';

/// Every route a page could navigate to (dummy targets) so any `context.go`
/// triggered during layout/taps never throws.
const _dummyPaths = <String>[
  '/quran',
  '/quran/talawat',
  '/quran/tarjuma',
  '/quran/tafseer',
  '/quran/settings',
  '/quran/share',
  '/quran/surah/:id',
  '/calendar-tools',
  '/calendar-tools/99-names',
  '/calendar-tools/tasbeeh',
  '/community',
  '/community/family',
  '/charity',
  '/about',
  '/profile',
  '/sign-in',
  '/sign-up',
  '/sign-up/:role',
  '/search',
  '/coming-soon',
  '/secret-admin-dashboard',
];

GoRouter _harness(Widget page) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => Material(child: page),
      ),
      for (final p in _dummyPaths)
        GoRoute(
          path: p,
          builder: (_, _) => const Scaffold(body: SizedBox.shrink()),
        ),
    ],
  );
}

Future<void> _pumpAt(
  WidgetTester tester,
  Widget page,
  Size size,
  String label,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(const Locale('en'), Brightness.light),
      routerConfig: _harness(page),
    ),
  );
  // Advance a few frames so entrance animations run their first frames.
  await tester.pump(const Duration(milliseconds: 120));
  await tester.pump(const Duration(milliseconds: 120));
  await tester.pump(const Duration(milliseconds: 120));

  expect(
    tester.takeException(),
    isNull,
    reason: 'Overflow / exception on "$label" at ${size.width.toInt()}px',
  );
}

/// Flushes pending entrance-animation timers, then unmounts the page so
/// periodic timers (home slider) and repeating tickers are disposed before
/// the framework's invariant checks.
Future<void> _settleAndUnmount(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  const sizes = <Size>[
    Size(360, 900),
    Size(560, 900),
    Size(820, 900),
    Size(1280, 900),
  ];

  String sizeLabel(Size s) {
    return switch (s.width) {
      360 => '360 phone',
      560 => '560 phablet',
      820 => '820 tablet',
      1280 => '1280 desktop',
      _ => '${s.width.toInt()}px',
    };
  }

  testWidgets('HomePage renders without overflow at all widths', (t) async {
    for (final s in sizes) {
      await _pumpAt(t, const HomePage(), s, 'Home ${sizeLabel(s)}');
    }
    await _settleAndUnmount(t);
  });

  testWidgets('AboutPage renders without overflow at all widths', (t) async {
    for (final s in sizes) {
      await _pumpAt(t, const AboutPage(), s, 'About ${sizeLabel(s)}');
    }
    await _settleAndUnmount(t);
  });

  testWidgets('CalendarToolsPage renders without overflow at all widths', (
    t,
  ) async {
    for (final s in sizes) {
      await _pumpAt(
        t,
        const CalendarToolsPage(),
        s,
        'Calendar ${sizeLabel(s)}',
      );
    }
    await _settleAndUnmount(t);
  });

  testWidgets('NamesOfAllahPage renders without overflow at all widths', (
    t,
  ) async {
    for (final s in sizes) {
      await _pumpAt(t, const NamesOfAllahPage(), s, '99 Names ${sizeLabel(s)}');
    }
    await _settleAndUnmount(t);
  });

  testWidgets('SearchPage renders without overflow at all widths', (t) async {
    for (final s in sizes) {
      await _pumpAt(t, const SearchPage(), s, 'Search ${sizeLabel(s)}');
    }
    await _settleAndUnmount(t);
  });

  testWidgets('ComingSoonPage renders without overflow at all widths', (
    t,
  ) async {
    for (final s in sizes) {
      await _pumpAt(t, const ComingSoonPage(), s, 'ComingSoon ${sizeLabel(s)}');
    }
    await _settleAndUnmount(t);
  });
}
