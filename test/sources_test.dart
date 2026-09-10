import 'package:ask_iman/core/services/ask_iman_ai_service.dart';
import 'package:flutter_test/flutter_test.dart';

// Regression tests for the pure topic-source gate + retrieval ranking used to
// enrich general Islamic Q&A with grounded Quran/hadith sources.
void main() {
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
}