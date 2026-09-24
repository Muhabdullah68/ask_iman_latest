import 'dart:io';

import 'package:ask_iman/core/services/ask_iman_ai_service.dart';
import 'package:flutter_test/flutter_test.dart';

// Regression tests for the pure topic-source gate + retrieval ranking used to
// enrich general Islamic Q&A with grounded Quran/hadith sources.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('looksLikeIslamicTopic (gate)', () {
    test('namaz question is a topic', () {
      expect(looksLikeIslamicTopic('is namaz necessary in islam'), isTrue);
    });

    test('charity/quran question is a topic', () {
      expect(looksLikeIslamicTopic('what does the quran say about charity'), isTrue);
    });

    test('salah keyword triggers topic', () {
      expect(looksLikeIslamicTopic('importance of salah'), isTrue);
    });

    test('roman-urdu question with weak domain word is a topic', () {
      expect(looksLikeIslamicTopic('islam kya hai'), isTrue);
      expect(looksLikeIslamicTopic('muslim ke liye zaroori'), isTrue);
    });

    test('chit-chat stays off-topic', () {
      expect(looksLikeIslamicTopic('what is your name'), isFalse);
      expect(looksLikeIslamicTopic('hi'), isFalse);
      expect(looksLikeIslamicTopic('how are you today'), isFalse);
    });

    test('fiqh / daily-life questions are now topics', () {
      expect(looksLikeIslamicTopic('what is the ruling on music'), isTrue);
      expect(looksLikeIslamicTopic('can we pray in english'), isTrue);
      expect(looksLikeIslamicTopic('is eating pork allowed in islam'), isTrue);
      expect(looksLikeIslamicTopic('does islam say dreams have meaning'), isTrue);
      expect(looksLikeIslamicTopic('is wearing gold forbidden'), isTrue);
    });

    test('explicit reference-request is a topic even without anchors', () {
      expect(looksLikeIslamicTopic('quran about gratitude'), isTrue);
      expect(looksLikeIslamicTopic('what does islam say about patience'), isTrue);
    });

    test('"related to" + ahadees phrasing opens the topic gate', () {
      expect(looksLikeIslamicTopic('ayat and ahadees related to patience'), isTrue);
      expect(looksLikeIslamicTopic('give me quran verses related with honesty'), isTrue);
      expect(looksLikeIslamicTopic('ahadees about forgiveness'), isTrue);
    });
  });

  group('_possibleQuote (routing)', () {
    test('verb-initial questions containing quran/hadith are NOT quotes', () {
      expect(AskImanAiService.possibleQuote('is salah obligatory in islam according to quran'), isFalse);
      expect(AskImanAiService.possibleQuote('does the quran say anything about forgiveness'), isFalse);
      expect(AskImanAiService.possibleQuote('can you find me a hadith about patience'), isFalse);
      expect(AskImanAiService.possibleQuote('what does quran say about charity'), isFalse);
    });
  });

  group('topicQueryTerms', () {
    test('anchors appear before content, deduplicated', () {
      final terms = topicQueryTerms('is namaz necessary in islam');
      expect(terms, contains('namaz'));
      expect(terms, contains('necessary'));
      expect(terms, contains('islam'));
      expect(terms.indexOf('namaz'), lessThan(terms.indexOf('necessary')));
    });

    test('stopword-only input yields no terms', () {
      expect(topicQueryTerms('hi how are you'), isEmpty);
      expect(topicQueryTerms('the and of'), isEmpty);
    });

    test('arabic-script words are kept as content', () {
      final terms = topicQueryTerms('سنت کیا ہے');
      expect(terms, isNotEmpty);
    });

    test('hajj question keeps hajj anchor + content + domain words', () {
      final terms = topicQueryTerms('what does the quran and hadith say about hajj');
      expect(terms, contains('hajj'));
      expect(terms, contains('quran'));
      expect(terms, contains('hadith'));
    });
  });

  group('buildTermIndex + topicRank', () {
    const docs = [
      'Establish prayer and pay zakat, and bow with those who bow',
      'We sent down the Torah and the Gospel as guidance for mankind',
      'The sky is blue and the grass is green',
    ];

    test('anchor query ranks the right document at the top', () {
      final idx = buildTermIndex(docs);
      final terms = topicQueryTerms('salah and zakat');
      final ranked = topicRank(idx, docs.length, terms);
      expect(ranked, isNotEmpty);
      expect(ranked.first.index, 0);
      expect(ranked.first.matchedTerms, greaterThanOrEqualTo(1));
    });

    test('free-form content query ranks by word overlap', () {
      final idx = buildTermIndex(docs);
      final terms = topicQueryTerms('gospel guidance');
      final ranked = topicRank(idx, docs.length, terms);
      expect(ranked.first.index, 1);
    });

    test('no-matching terms returns empty', () {
      final idx = buildTermIndex(docs);
      final terms = topicQueryTerms('zzzzz qqqqq');
      expect(topicRank(idx, docs.length, terms), isEmpty);
    });

    test('short common phrases do not dominate', () {
      final idx = buildTermIndex(docs);
      final terms = topicQueryTerms('sky blue');
      final ranked = topicRank(idx, docs.length, terms);
      expect(ranked.first.index, 2);
    });
  });

  group('sanity: topic vs verification separation', () {
    test('plain quotes still go to verification, not topic gate', () {
      // A full ayah quote has no topic words but is >30 chars: it must NOT be
      // treated as a topic question (it never reaches topicQueryTerms anyway),
      // verifying the gate stays permissive only for real questions.
      expect(looksLikeIslamicTopic('do not raise your voice above the prophet'), isFalse);
    });
  });

  group('topicEvidenceConfident', () {
    test('any single matched term is confident (gate is the primary filter)', () {
      expect(topicEvidenceConfident(['namaz'], [1]), isTrue);
      expect(topicEvidenceConfident(['people'], [1]), isTrue);
      expect(topicEvidenceConfident(['music'], [1]), isTrue);
    });

    test('two distinct matched terms are confident without anchors', () {
      expect(topicEvidenceConfident(['gold', 'silver'], [2]), isTrue);
    });

    test('no hits is never confident', () {
      expect(topicEvidenceConfident(['namaz'], []), isFalse);
      expect(topicEvidenceConfident(['people'], []), isFalse);
    });
  });

  group('buildSourcedAnswer (verdict-first structured answer)', () {
    const ayah = AskAICitation(
      kind: 'ayah',
      book: 'Quran',
      surahNumber: 2,
      surahName: 'Al-Baqarah',
      surahArabic: 'سُورَةُ البَقَرَة',
      ayahNumber: 45,
      arabic: 'وَاسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ',
      text: 'And seek help through patience and prayer.',
    );
    const hadith = AskAICitation(
      kind: 'hadith',
      book: 'Sahih al-Bukhari',
      hadithNumber: 527,
      arabic: 'حَدَّثَنَا ...',
      text: 'The Prophet ﷺ said: Pray as you have seen me praying.',
      grade: 'Sahih',
    );

    test('starts with verdict, then supported-refs label, explanation last', () {
      final out = buildSourcedAnswer(
        verdict: 'Yes.',
        refs: const [ayah, hadith],
        explanation: 'Salah is a pillar of Islam.',
      );
      expect(out.startsWith('Yes.'), isTrue);
      expect(out.indexOf('supported by Surah Al-Baqarah 2:45'),
          greaterThan(out.indexOf('Yes.')));
      expect(out.indexOf('Sahih al-Bukhari #527'),
          greaterThan(out.indexOf('Surah Al-Baqarah 2:45')));
      expect(out.indexOf('Salah is a pillar of Islam.'),
          greaterThan(out.indexOf('Sahih al-Bukhari #527')));
    });

    test('does NOT embed Arabic/translation inline (citations shown as cards)', () {
      final out = buildSourcedAnswer(
        verdict: 'Yes.',
        refs: const [ayah, hadith],
        explanation: '',
      );
      expect(out, isNot(contains(ayah.arabic)));
      expect(out, isNot(contains(ayah.text)));
      expect(out, isNot(contains(hadith.text)));
      expect(out, isNot(contains('Authenticity note')));
    });

    test('empty verdict still lists supported references', () {
      final out = buildSourcedAnswer(
        verdict: '',
        refs: const [ayah, hadith],
        explanation: 'Guidance.',
      );
      expect(out, contains('Surah Al-Baqarah 2:45'));
      expect(out, contains('Guidance.'));
    });
  });

  group('looksLikeHadith (photo classification)', () {
    test('English narration signatures classify as hadith', () {
      expect(AskImanAiService.looksLikeHadith(
          'Narrated Abu Huraira: The Prophet said, whoever believes in Allah and the last day, let him speak good or remain silent.'),
          isTrue);
      expect(AskImanAiService.looksLikeHadith(
          'The Messenger of Allah said: pray as you have seen me praying'),
          isTrue);
      expect(AskImanAiService.looksLikeHadith(
          'Ibn Umar reported that the Prophet used to pray at the Kaaba'),
          isTrue);
    });

    test('Arabic isnad signatures classify as hadith', () {
      expect(AskImanAiService.looksLikeHadith(
          'عن أبي هريرة قال رسول الله ﷺ: من صام رمضان إيمانا واحتسابا...'),
          isTrue);
      expect(AskImanAiService.looksLikeHadith(
          'حدثنا قتيبة حدثنا الليث عن نافع عن ابن عمر...'),
          isTrue);
    });

    test('pure ayah text is NOT classified as hadith', () {
      expect(AskImanAiService.looksLikeHadith(
          'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ الْحَمْدُ لِلّٰهِ رَبِّ الْعٰلَمِيْنَ'),
          isFalse);
    });
  });

  group('ocrBarsForTest (photo OCR tolerance)', () {
    test('default bars match plain-text verification bands', () {
      final en = AskImanAiService.ocrBarsForTest(false);
      final ar = AskImanAiService.ocrBarsForTest(true);
      expect(en.strictScore, 0.75);
      expect(en.strictContainment, 0.70);
      expect(en.adjudicateMin, 0.50);
      expect(ar.strictScore, 0.92);
      expect(ar.strictContainment, 0.85);
      expect(ar.adjudicateMin, 0.60);
    });

    test('OCR tolerance relaxes the scoring bands', () {
      final enTight = AskImanAiService.ocrBarsForTest(false);
      final enLoose = AskImanAiService.ocrBarsForTest(false, ocrTolerance: true);
      final arTight = AskImanAiService.ocrBarsForTest(true);
      final arLoose = AskImanAiService.ocrBarsForTest(true, ocrTolerance: true);
      expect(enLoose.strictScore, lessThan(enTight.strictScore));
      expect(enLoose.strictContainment, lessThan(enTight.strictContainment));
      expect(arLoose.strictScore, lessThan(arTight.strictScore));
      expect(arLoose.strictContainment, lessThan(arTight.strictContainment));
      expect(arTight.strictScore, greaterThan(enTight.strictScore));
      expect(enLoose.adjudicateMin, lessThanOrEqualTo(enLoose.strictScore));
      expect(arLoose.adjudicateMin, lessThanOrEqualTo(arLoose.strictScore));
    });

    test('OCR tolerance never loosens past the plain-text band', () {
      const floorHigh = 0.38;
      const floorLow = 0.30;
      final enLoose = AskImanAiService.ocrBarsForTest(false, ocrTolerance: true);
      final arLoose = AskImanAiService.ocrBarsForTest(true, ocrTolerance: true);
      expect(enLoose.strictScore, greaterThan(floorLow));
      expect(arLoose.strictScore, greaterThan(floorHigh));
      expect(enLoose.adjudicateMin, greaterThanOrEqualTo(0.20));
      expect(arLoose.adjudicateMin, greaterThanOrEqualTo(0.20));
    });
  });

  group('_buildContextTurns (multi-turn context)', () {
    Map<String, dynamic> msg(String role, String text, [String error = '']) =>
        {'role': role, 'text': text, 'errorCode': error};

    test('maps user->user and ai->model', () {
      final turns = AskImanAiService.buildContextTurnsForTest([
        msg('user', 'is salah important'),
        msg('ai', 'Yes, salah is a pillar.'),
      ]);
      expect(turns.map((t) => t.role).toList(), ['user', 'model']);
      expect(turns.map((t) => t.text).toList(),
          ['is salah important', 'Yes, salah is a pillar.']);
    });

    test('failed/blocked AI bubbles are excluded from context', () {
      final turns = AskImanAiService.buildContextTurnsForTest([
        msg('user', 'what is zakat'),
        msg('ai', 'Zakat is the third pillar.', 'rate_limited'),
        msg('user', 'thank you'),
      ]);
      expect(turns.map((t) => t.role).toList(), ['user', 'user']);
      expect(turns.map((t) => t.text).toList(), ['what is zakat', 'thank you']);
    });

    test('empty or null history yields no turns', () {
      expect(AskImanAiService.buildContextTurnsForTest(null), isEmpty);
      expect(AskImanAiService.buildContextTurnsForTest([]), isEmpty);
    });

    test('char budget trims the oldest turns, newest always survives', () {
      final turns = AskImanAiService.buildContextTurnsForTest([
        msg('user', 'first question about patience in islam'),
        msg('ai', 'Patience is taught throughout the Quran and has great reward.'),
        msg('user', 'second question about gratitude in islam'),
      ], maxTurns: 8, maxChars: 60);
      final joined = turns.map((t) => t.text).join(' ');
      expect(joined, isNot(contains('first question')));
      expect(joined, contains('second question'));
    });

    test('a long turn is trimmed to maxPerTurn with an ellipsis', () {
      final long = 'a' * 600;
      final turns = AskImanAiService.buildContextTurnsForTest([
        msg('user', long),
      ]);
      expect(turns.single.text.length, 501);
      expect(turns.single.text.endsWith('…'), isTrue);
    });
  });

  group('isSimilarFollowUp (similar/correct ayah follow-up)', () {
    test('direct similarity requests are detected', () {
      expect(isSimilarFollowUp('what is the correct ayah?'), isTrue);
      expect(isSimilarFollowUp('which hadith is similar?'), isTrue);
      expect(isSimilarFollowUp('find the closest verse please'), isTrue);
      expect(isSimilarFollowUp('give me the right hadith'), isTrue);
      expect(isSimilarFollowUp('what is the nearest match in quran'), isTrue);
    });

    test('broad reference + similarity keywords are detected', () {
      expect(isSimilarFollowUp('show me similar ayat'), isTrue);
      expect(isSimilarFollowUp('is there a correct quran verse'), isTrue);
      expect(isSimilarFollowUp('a hadith about this similar one'), isTrue);
    });

    test('unrelated questions are NOT detected', () {
      expect(isSimilarFollowUp('what is zakat'), isFalse);
      expect(isSimilarFollowUp('how are you'), isFalse);
      expect(isSimilarFollowUp('please explain wudu'), isFalse);
      expect(isSimilarFollowUp('tell me about patience in islam'), isFalse);
    });
  });

  group('extractUnverifiedClaimForTest (history parsing)', () {
    Map<String, dynamic> msg(String role, String text,
            {String verdict = '', String? ocrText, String errorCode = ''}) =>
        {
          'role': role,
          'text': text,
          'verdict': verdict,
          'errorCode': errorCode,
          'ocrText':? ocrText,
        };

    test('returns the claim that received an unverified verdict', () {
      final claim = AskImanAiService.extractUnverifiedClaimForTest([
        msg('user', 'the quick brown fox jumps over the lazy dog'),
        msg('ai', 'This is not in my knowledge.', verdict: 'unverified'),
      ]);
      expect(claim, 'the quick brown fox jumps over the lazy dog');
    });

    test('prefers OCR text over the bubble text (photo path)', () {
      final claim = AskImanAiService.extractUnverifiedClaimForTest([
        msg('user', 'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ الْحَمْدُ لِلّٰهِ رَبِّ الْعٰلَمِيْنَ',
            ocrText: 'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ الْحَمْدُ لِلّٰهِ'),
        msg('ai', 'This is not in my knowledge.', verdict: 'unverified'),
      ]);
      expect(claim, 'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ الْحَمْدُ لِلّٰهِ');
    });

    test('verified responses do not trigger claim extraction', () {
      final claim = AskImanAiService.extractUnverifiedClaimForTest([
        msg('user', 'Allah will not change the condition of a people...'),
        msg('ai', 'Verified.', verdict: 'verified'),
      ]);
      expect(claim, isNull);
    });

    test('a later resolved exchange shadows an older unverified one', () {
      final claim = AskImanAiService.extractUnverifiedClaimForTest([
        msg('user', 'old unverified claim text'),
        msg('ai', 'This is not in my knowledge.', verdict: 'unverified'),
        msg('user', 'newer claim'),
        msg('ai', 'Verified.', verdict: 'verified'),
      ]);
      expect(claim, isNull);
    });
  });

  group('isGreetingOnly (chit-chat stays card-free)', () {
    test('plain greetings are greeting-only', () {
      expect(isGreetingOnly('hi'), isTrue);
      expect(isGreetingOnly('hello there'), isTrue);
      expect(isGreetingOnly('assalam o alaikum'), isTrue);
      expect(isGreetingOnly('salam'), isTrue);
      expect(isGreetingOnly('السلام علیکم'), isTrue);
    });

    test('actual questions are NOT greeting-only', () {
      expect(isGreetingOnly('what does the quran say about patience'), isFalse);
      expect(isGreetingOnly('assalam o alaikum please tell me about hajj'), isFalse);
    });

    test('greetings gates off source retrieval entirely', () {
      expect(looksLikeIslamicTopic('hi'), isFalse);
      expect(looksLikeIslamicTopic('assalam o alaikum'), isFalse);
      // The widened gate (>= 2 query terms) must not pull greetings into the
      // corpus path: isGreetingOnly short-circuits it.
      final widened = topicQueryTerms('assalam o alaikum').length >= 2;
      expect(widened, isTrue);
      expect(isGreetingOnly('assalam o alaikum'), isTrue);
    });
  });

  group('bundled corpus loads offline (assets)', () {
    test('single-flight: concurrent identical loads share one future', () async {
      final f1 = AskImanAiService.loadQuranForTest('eng');
      final f2 = AskImanAiService.loadQuranForTest('eng');
      expect(identical(f1, f2), isTrue);
      final items = await f1;
      expect(items.length, greaterThanOrEqualTo(6000));
    });

    test('quran eng/ara/urd assets parse to the full corpus', () async {
      final eng = await AskImanAiService.loadQuranForTest('eng');
      final ara = await AskImanAiService.loadQuranForTest('ara');
      final urd = await AskImanAiService.loadQuranForTest('urd');
      expect(eng.length, greaterThanOrEqualTo(6000));
      expect(ara.length, greaterThanOrEqualTo(6000));
      expect(urd.length, greaterThanOrEqualTo(6000));
      expect(eng.first['surah'], isA<Map>());
      expect(eng.first['text'], isA<String>());
    });

    test('all 6 hadith books load eng+ara from bundled assets', () async {
      for (final slug in [
        'bukhari', 'muslim', 'abudawud', 'tirmidhi', 'nasai', 'ibnmajah'
      ]) {
        final eng = await AskImanAiService.loadHadithForTest(slug, 'eng');
        final ara = await AskImanAiService.loadHadithForTest(slug, 'ara');
        expect(eng.length, greaterThanOrEqualTo(50), reason: '$slug en');
        expect(ara.length, greaterThanOrEqualTo(50), reason: '$slug ar');
      }
    });
  });

  group('issue7: retrieveTopicSources produces 2 Quran + 2 hadith', () {
    test('hajj question yields >=2 ayah and >=1 hadith citations', () async {
      final refs = await AskImanAiService.retrieveTopicSourcesForTest(
        'what does the quran and hadith say about hajj',
      );
      if (refs == null) {
        markTestSkipped('bundled corpus unavailable');
        return;
      }
      final ayahs = refs.where((r) => r.kind == 'ayah').toList();
      final hadiths = refs.where((r) => r.kind == 'hadith').toList();
      expect(ayahs.length, greaterThanOrEqualTo(2));
      expect(hadiths.length, greaterThanOrEqualTo(1));
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('every hadith card carries book + narration text', () async {
      final refs = await AskImanAiService.retrieveTopicSourcesForTest(
        'what does the quran and hadith say about hajj',
      );
      if (refs == null) {
        markTestSkipped('bundled corpus unavailable');
        return;
      }
      final hadiths = refs.where((r) => r.kind == 'hadith').toList();
      for (final h in hadiths) {
        expect(h.book, isNotEmpty);
        expect(h.text, isNotEmpty);
        expect(h.hadithNumber, isNotNull);
      }
    }, timeout: const Timeout(Duration(minutes: 2)));
  });

  group('voice-note transcription (offline helpers)', () {
    test('caps keep notes inside Gemini inline budget', () {
      expect(AskImanAiService.maxVoiceBytes,
          lessThanOrEqualTo(15 * 1024 * 1024));
      expect(AskImanAiService.maxVoiceDuration, const Duration(seconds: 120));
    });

    test('formatDuration renders 00:00-style labels', () {
      expect(AskImanAiService.formatDurationForTest(Duration.zero), '00:00');
      expect(
          AskImanAiService.formatDurationForTest(const Duration(seconds: 65)),
          '01:05');
      expect(
          AskImanAiService.formatDurationForTest(const Duration(seconds: 120)),
          '02:00');
      expect(AskImanAiService.formatDurationForTest(const Duration(hours: 1)),
          '60:00');
    });

    test('transcribeAudio returns empty for a missing file (never throws)',
        () async {
      final dir =
          await Directory.systemTemp.createTemp('ask_iman_voice_test_');
      addTearDown(() => dir.delete(recursive: true));
      final path = '${dir.path}${Platform.pathSeparator}gone.m4a';
      expect(await AskImanAiService.transcribeAudioForTest(path), '');
    });

    test('transcribeAudio returns empty on a bogus audio file offline',
        () async {
      final dir =
          await Directory.systemTemp.createTemp('ask_iman_voice_test_');
      addTearDown(() => dir.delete(recursive: true));
      final f = File('${dir.path}${Platform.pathSeparator}sample.m4a');
      await f.writeAsBytes(List.filled(256, 0));
      expect(await AskImanAiService.transcribeAudioForTest(f.path), '');
    }, timeout: const Timeout(Duration(minutes: 2)));
  });

  group('hadith topicality floor + grade tiebreak', () {
    test('grade tiebreak prefers Sahih over Hasan over Daif', () {
      expect(AskImanAiService.gradeQualityForTest('Sahih'), 3);
      expect(AskImanAiService.gradeQualityForTest('Hasan Sahih'), 3);
      expect(
          AskImanAiService.gradeQualityForTest('Sahih - Bukhari And Muslim'), 3);
      expect(AskImanAiService.gradeQualityForTest(''), 3);
      expect(AskImanAiService.gradeQualityForTest('Hasan'), 2);
      expect(AskImanAiService.gradeQualityForTest("Da'if (Darussalam)"), 1);
      expect(AskImanAiService.gradeQualityForTest('Daif'), 1);
      expect(AskImanAiService.gradeQualityForTest('Weak'), 1);
    });

    test('a single generic non-anchor term cannot attach a hadith (dropped)',
        () async {
      for (final slug in ['bukhari', 'muslim', 'abudawud', 'tirmidhi']) {
        final r = await AskImanAiService.hadithTopicMatchedForTest(
            slug, ['camel']);
        expect(r, isNull,
            reason: '$slug should drop an anchorless 1-term match');
      }
    }, timeout: const Timeout(Duration(minutes: 1)));

    test('gibberish question yields no hadith (empty rank)', () async {
      final r =
          await AskImanAiService.hadithTopicMatchedForTest('bukhari', [
        'zxqwvpl',
        'qrtyzbn',
      ]);
      expect(r, isNull);
    }, timeout: const Timeout(Duration(minutes: 1)));

    test('topic-anchor question keeps an on-topic hadith', () async {
      for (final (slug, terms) in [
        ('bukhari', ['hajj']),
        ('bukhari', ['charity']),
        ('muslim', ['fasting']),
        ('tirmidhi', ['zakat']),
        ('nasai', ['prayer']),
      ]) {
        final r =
            await AskImanAiService.hadithTopicMatchedForTest(slug, terms);
        expect(r, isNotNull,
            reason: '$slug/$terms should keep an on-topic hadith');
        expect(r!.matched, greaterThanOrEqualTo(1));
      }
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('multi-term topic question keeps a multi-term narration', () async {
      final r = await AskImanAiService.hadithTopicMatchedForTest(
          'bukhari', ['prayer', 'fasting']);
      expect(r, isNotNull);
      expect(r!.matched, greaterThanOrEqualTo(1));
    }, timeout: const Timeout(Duration(minutes: 1)));
  });
}