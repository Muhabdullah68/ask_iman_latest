import 'package:ask_iman/core/services/ask_iman_ai_service.dart';
import 'package:ask_iman/features/ask_iman_ai/ai_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Regression test: the source-details bottom sheet must scroll long hadith /
// ayah text instead of overflowing at the bottom of the screen.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final longTranslation = List.filled(
    45,
    'This is a long hadith translation with many clauses and details that '
        'keeps going and going so the source sheet is forced to be scrollable '
        'instead of overflowing past the bottom of the phone screen.',
  ).join(' ');

  testWidgets('long hadith source sheet scrolls without pixel overflow', (
    tester,
  ) async {
    final citation = AskAICitation(
      kind: 'hadith',
      book: 'Sahih al-Bukhari',
      hadithNumber: 1,
      arabic:
          'حَدَّثَنَا عُمَرُ بْنُ الْخَطَّابِ قَالَ سَمِعْتُ رَسُولَ اللَّهِ '
          'صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ يَقُولُ إِنَّمَا الْأَعْمَالُ '
          'بِالنِّيَّاتِ وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى',
      text: longTranslation,
      grade: 'Sahih',
    );

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => CitationDetailsSheet(citation: citation),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // The sheet opened: both actions must be visible (not pushed off-screen).
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);

    // The long translation is present and reachable via scrolling.
    expect(find.textContaining('long hadith translation'), findsWidgets);
  });
}