import 'package:ask_iman/core/services/ask_iman_ai_service.dart';
import 'package:flutter_test/flutter_test.dart';

// Regression tests for the grounded verification pipeline. These exercise the
// pure matching/claim helpers only — no network, no Gemini.
void main() {
  group('rankMatch', () {
    test('exact text scores 1.0', () {
      expect(containmentScore('test', 'test'), 1.0);
      final r = rankMatch(
        hayText: 'In the name of Allah, the Most Gracious, the Most Merciful',
        needleText: 'In the name of Allah, the Most Gracious, the Most Merciful',
      );
      expect(r.score, 1.0);
    });

    test('partial fragment has low containment', () {
      final r = rankMatch(
        hayText: 'And of His signs is the creation of the heavens and the earth',
        needleText: 'the heavens and the earth beyond',
      );
      expect(r.containment, lessThan(1.0));
    });
  });

  group('strictAccept (unambiguous gating)', () {
    CorpusMatch m(String id, double score, {double containment = 1.0}) =>
        CorpusMatch({'id': id, 'text': id}, score, containment, score, 1.0);

    test('clear winner passes', () {
      final hits = [m('a', 0.97), m('b', 0.55), m('c', 0.50)];
      final acc = strictAccept(
        hits,
        strictScore: 0.92,
        strictContainment: 0.85,
        gap: 0.08,
      );
      expect(acc.ok, isTrue);
      expect(acc.best!.item['id'], 'a');
    });

    test('tied common fragment is refused, not first-match-guessed', () {
      // e.g. "الرحمن الرحيم" matches many ayahs at identical score → must REFUSE.
      final hits = [m('a', 1.0), m('b', 1.0), m('c', 1.0)];
      final acc = strictAccept(
        hits,
        strictScore: 0.92,
        strictContainment: 0.85,
        gap: 0.08,
      );
      expect(acc.ok, isFalse);
    });

    test('low-score paraphrase below strict bar is refused', () {
      final hits = [m('a', 0.68)];
      final acc = strictAccept(
        hits,
        strictScore: 0.75,
        strictContainment: 0.70,
        gap: 0.10,
      );
      expect(acc.ok, isFalse);
    });

    test('empty hit list is refused', () {
      final acc = strictAccept(
        const [],
        strictScore: 0.92,
        strictContainment: 0.85,
        gap: 0.08,
      );
      expect(acc.ok, isFalse);
    });
  });

  group('findMatches', () {
    test('sorts by score and skips below threshold', () {
      final items = [
        {'text': 'alpha beta gamma delta'},
        {'text': 'alpha beta'},
      ];
      final hits = findMatches(
        items,
        textOf: (i) => (i as Map)['text'] as String,
        needleText: 'alpha beta gamma delta',
        minScore: 0.8,
      );
      expect(hits, isNotEmpty);
      expect(hits.first.item['text'], 'alpha beta gamma delta');
    });
  });

  group('parseQuranClaim', () {
    final idx = surahNameIndex([
      {
        'surah': {
          'number': 2,
          'name': 'سُورَةُ البَقَرَة',
          'englishName': 'Al-Baqarah',
          'meaning': 'The Cow',
        }
      },
      {
        'surah': {
          'number': 3,
          'name': 'سُورَةُ آل عِمْرَان',
          'englishName': 'Aal-E-Imran',
          'meaning': 'The Family of Imran',
        }
      },
      {
        'surah': {
          'number': 18,
          'name': 'سُورَةُ الكَهْف',
          'englishName': 'Al-Kahf',
          'meaning': 'The Cave',
        }
      },
    ]);

    test('colon form 2:255', () {
      expect(parseQuranClaim('2:255', idx), (2, 255));
    });

    test('worded surah + verse', () {
      expect(parseQuranClaim('surah 2 verse 255', idx), (2, 255));
      expect(parseQuranClaim('sura 18 aya 10', idx), (18, 10));
      expect(parseQuranClaim('chapter 2 ayah 255', idx), (2, 255));
    });

    test('surah name + number', () {
      expect(parseQuranClaim('al-baqarah 255', idx), (2, 255));
      expect(parseQuranClaim('The Cave 10', idx), (18, 10));
    });

    test('name before number', () {
      expect(parseQuranClaim('ayah 255 of surah al baqarah', idx), (2, 255));
    });

    test('no claim returns null', () {
      expect(parseQuranClaim('What is the ruling on fasting?', idx), isNull);
      expect(parseQuranClaim('bukhari 1234', idx), isNull);
    });

    test('invalid surah number returns null', () {
      expect(parseQuranClaim('surah 999 verse 1', idx), isNull);
    });
  });

  group('parseHadithClaim', () {
    test('bukhari number', () {
      expect(parseHadithClaim('bukhari 1234')?.$1, 'bukhari');
      expect(parseHadithClaim('bukhari 1234')?.$2, 1234);
    });

    test('sahih muslim hadith number', () {
      final c = parseHadithClaim('sahih muslim hadith 345');
      expect(c?.$1, 'muslim');
      expect(c?.$2, 345);
    });

    test('book name without a number is not a pin (full search)', () {
      expect(parseHadithClaim('is this in bukhari?'), isNull);
    });

    test('no claim returns null', () {
      expect(parseHadithClaim('what should I do?'), isNull);
      expect(parseHadithClaim('2:255'), isNull);
    });
  });

  group('sanity: common-fragment trap', () {
    test('a fragment repeated across many items is NOT strict-accepted', () {
      // A short common phrase present in many corpus items must not resolve to
      // a single "verified" source. Exact duplicates tie at the same score →
      // the strict gate refuses instead of guessing the first match.
      final items = List.generate(40, (i) {
        return {
          'text': (i % 7 == 0) ? 'bismillah ar rahman ar rahim' : 'a b c d e f',
        };
      });
      final hits = findMatches(
        items,
        textOf: (i) => (i as Map)['text'] as String,
        needleText: 'bismillah ar rahman ar rahim',
        minScore: 0.58,
      );
      final acc = strictAccept(
        hits,
        strictScore: 0.92,
        strictContainment: 0.85,
        gap: 0.08,
      );
      expect(acc.ok, isFalse);
    });
  });
}