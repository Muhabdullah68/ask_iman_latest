import 'dart:math' as math;

import 'package:ask_iman/screens/splash_screen.dart';
import 'package:ask_iman/widgets/ask_iman_logo.dart';
import 'package:ask_iman/widgets/topic_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpSplash(
    WidgetTester tester, {
    Size size = const Size(1024, 1536),
    bool reduceMotion = false,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        builder: reduceMotion
            ? (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(disableAnimations: true),
                  child: child!,
                )
            : null,
        home: const SplashScreen(),
      ),
    );
    await tester.pump();
  }

  Future<void> dismissSplash(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  }

  group('SplashScreen composition', () {
    testWidgets('renders logo, tagline, wash + all 7 orbit cards at 1024x1536',
        (tester) async {
      await pumpSplash(tester);

      expect(find.byType(AskImanLogo), findsOneWidget);
      expect(find.text('ASK IMAN'), findsOneWidget);
      expect(find.text('ISLAMIC GUIDANCE'), findsOneWidget);
      expect(find.text('Your Complete Islamic Companion'), findsOneWidget);

      expect(find.byType(TopicCard), findsNWidgets(7));
      for (final c in orbitCards) {
        expect(find.byKey(c.key), findsOneWidget, reason: c.title);
      }

      expect(find.byKey(const ValueKey('ambient_wash_layer')), findsOneWidget);
      expect(tester.takeException(), isNull);

      await dismissSplash(tester);
    });

    testWidgets('renders identical composition at 390x844 phone',
        (tester) async {
      await pumpSplash(tester, size: const Size(390, 844));

      expect(find.byType(AskImanLogo), findsOneWidget);
      expect(find.byType(TopicCard), findsNWidgets(7));
      expect(find.byKey(const ValueKey('ambient_wash_layer')), findsOneWidget);
      expect(find.text('Your Complete Islamic Companion'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await dismissSplash(tester);
    });

    testWidgets(
        'at t=0 each card Positioned roughly matches its baseAngle/radius from orbit center',
        (tester) async {
      await pumpSplash(tester);
      const cx = 512.0;
      const cy = 860.0;
      const cardW = 165.0;
      const cardH = 132.0;

      for (final spec in orbitCards) {
        final pos = tester.widget<Positioned>(find.ancestor(
          of: find.byKey(spec.key),
          matching: find.byType(Positioned),
        ).first);

        final centerX = pos.left! + cardW / 2;
        final centerY = pos.top! + cardH / 2;
        final r = math.sqrt(
            (centerX - cx) * (centerX - cx) + (centerY - cy) * (centerY - cy));
        final a = math.atan2(centerY - cy, centerX - cx);

        expect(r, closeTo(spec.radius, 18),
            reason: '${spec.title} radius');
        final delta = ((a - spec.baseAngle + 3 * math.pi) % (2 * math.pi)) -
            math.pi;
        expect(delta.abs(), lessThan(math.pi / 5),
            reason: '${spec.title} angle');
      }
      await dismissSplash(tester);
    });
  });

  group('SplashScreen orbital motion', () {
    testWidgets('cards advance along orbits when animations are on',
        (tester) async {
      await pumpSplash(tester);
      const cardW = 165.0;
      const cardH = 132.0;

      List<Offset> snapshotCenters() {
        final out = <Offset>[];
        for (final spec in orbitCards) {
          final pos = tester.widget<Positioned>(find.ancestor(
            of: find.byKey(spec.key),
            matching: find.byType(Positioned),
          ).first);
          out.add(Offset(pos.left! + cardW / 2, pos.top! + cardH / 2));
        }
        return out;
      }

      final atStart = snapshotCenters();
      await tester.pump(const Duration(seconds: 5));
      final after5s = snapshotCenters();

      bool anyMoved = false;
      for (var i = 0; i < orbitCards.length; i++) {
        if ((atStart[i] - after5s[i]).distance > 8) anyMoved = true;
      }
      expect(anyMoved, isTrue,
          reason: 'at least one card should visibly orbit in 5s');

      await dismissSplash(tester);
    });

    testWidgets('motion freezes when reduce-motion is requested',
        (tester) async {
      await pumpSplash(tester, reduceMotion: true);

      List<Offset> sample() {
        final out = <Offset>[];
        for (final spec in orbitCards) {
          final pos = tester.widget<Positioned>(find.ancestor(
            of: find.byKey(spec.key),
            matching: find.byType(Positioned),
          ).first);
          out.add(Offset(pos.left!, pos.top!));
        }
        return out;
      }

      final atRest = sample();
      await tester.pump(const Duration(seconds: 5));
      final stillThere = sample();

      for (var i = 0; i < orbitCards.length; i++) {
        expect(stillThere[i].dx, closeTo(atRest[i].dx, 1e-6),
            reason: '${orbitCards[i].title} x frozen');
        expect(stillThere[i].dy, closeTo(atRest[i].dy, 1e-6),
            reason: '${orbitCards[i].title} y frozen');
      }
      expect(tester.takeException(), isNull);

      await dismissSplash(tester);
    });
  });
}
