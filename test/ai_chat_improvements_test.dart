import 'package:ask_iman/core/services/ask_iman_ai_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Regression tests for the chatbot improvements: pre-call intent guard,
// offline curated FAQ, Q&A-level caching keys, and madhhab-aware prompts.
// All exercises are pure/offline — no network, no Gemini.
void main() {
  group('_scopeGuard (pre-call intent guard)', () {
    test('refuses code/dev requests', () {
      expect(
        AskImanAiService.outOfScopeForTest(
          'write flutter code to show a notification',
        ),
        isTrue,
      );
    });

    test('refuses medical self-diagnosis', () {
      expect(
        AskImanAiService.outOfScopeForTest('my blood pressure is high'),
        isTrue,
      );
    });

    test('refuses weather requests', () {
      expect(
        AskImanAiService.outOfScopeForTest(
          'what is the weather in new york today',
        ),
        isTrue,
      );
    });

    test('never blocks greetings', () {
      expect(AskImanAiService.outOfScopeForTest('assalamu alaikum'), isFalse);
      expect(
        AskImanAiService.outOfScopeForTest('hello brother, how are you'),
        isFalse,
      );
    });

    test(
      'never blocks Islamic-topic questions, even with an out-of-scope word',
      () {
        // "interest" appears in the out-of-scope patterns list, but zakat makes
        // this clearly Islamic-topic and it must pass through to the AI.
        expect(
          AskImanAiService.outOfScopeForTest('is zakat due on interest?'),
          isFalse,
        );
      },
    );
  });

  group('_faqMatch (offline curated FAQ)', () {
    test('one-key one-content-word question answers from FAQ', () {
      final a = AskImanAiService.offlineFaqForTest('what is wudu', 'en');
      expect(a, isNotNull);
      expect(a, contains('Wudu (ablution)'));
      expect(a, contains('General guidance:'));
    });

    test(
      'two keys on the same entry answer even a two-content-word question',
      () {
        final a = AskImanAiService.offlineFaqForTest(
          'what is ablution and wudu',
          'en',
        );
        expect(a, isNotNull);
      },
    );

    test('single-key rich question falls through to the pipeline', () {
      final a = AskImanAiService.offlineFaqForTest(
        'describe wudu in a poetic style please',
        'en',
      );
      expect(a, isNull);
    });

    test('non-FAQ question returns null', () {
      final a = AskImanAiService.offlineFaqForTest(
        'what happens to my prayers if i miss fajr by mistake and then pray',
        'en',
      );
      expect(a, isNull);
    });

    test('urdu question gets the urdu closer', () {
      final a = AskImanAiService.offlineFaqForTest('what is zakat', 'ur');
      expect(a, isNotNull);
      expect(a, contains('عام رہنمائی'));
    });

    test('pashto question gets the urdu closer', () {
      final a = AskImanAiService.offlineFaqForTest('what is zakat', 'ps');
      expect(a, isNotNull);
      expect(a, contains('عام رہنمائی'));
    });
  });

  group('_qnaIntent (Q&A cache gating)', () {
    test('madhhab is folded into the cache key', () {
      expect(AskImanAiService.qnaCacheIntentForTest('none'), 'qna|none');
      expect(AskImanAiService.qnaCacheIntentForTest('hanafi'), 'qna|hanafi');
      expect(
        AskImanAiService.qnaCacheIntentForTest('hanbali'),
        isNot(AskImanAiService.qnaCacheIntentForTest('none')),
      );
    });
  });

  group('madhhab preference (device-side)', () {
    test('defaults to none and round-trips', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await AskImanAiService.madhhab(), 'none');

      await AskImanAiService.setMadhhab('hanafi');
      expect(await AskImanAiService.madhhab(), 'hanafi');

      await AskImanAiService.setMadhhab('none');
      expect(await AskImanAiService.madhhab(), 'none');
    });
  });

  group('madhhab-aware system prompts', () {
    test('plain Q&A prompt keeps the prior defaults when none selected', () {
      final p = AskImanAiService.qnaSystemForTest();
      expect(p, contains('You are ASK Iman AI'));
      expect(p, contains('NEVER give medical'));
      expect(p, contains('short numbered steps'));
      expect(p, isNot(contains('Preferred school of thought')));
    });

    test('plain Q&A prompt carries the requested school line', () {
      final p = AskImanAiService.qnaSystemForTest(madhhab: 'hanafi');
      expect(p, contains('Preferred school of thought: Hanafi.'));
    });

    test('sourced prompt carries the requested school line', () {
      final p = AskImanAiService.sourcedQnaSystemForTest(madhhab: 'shafi');
      expect(p, contains("Shafi'i"));
      expect(p, contains('short numbered steps'));
      expect(p, isNot(contains('Preferred school of thought: Hanafi')));
    });

    test('sourced prompt keeps prior defaults when none selected', () {
      final p = AskImanAiService.sourcedQnaSystemForTest();
      expect(p, contains('Respond with ONLY valid JSON'));
      expect(p, isNot(contains('Preferred school of thought')));
    });

    test('unknown madhhab is ignored (no line injected)', () {
      expect(
        AskImanAiService.qnaSystemForTest(madhhab: 'nonsense'),
        isNot(contains('Preferred school of thought')),
      );
    });
  });
}
