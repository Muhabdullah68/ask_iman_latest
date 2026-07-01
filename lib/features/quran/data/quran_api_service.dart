// lib/features/quran/data/quran_api_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// CHANGE: Arabic edition switched from 'quran-simple' → 'quran-uthmani'
//   • quran-uthmani uses full Uthmani script with proper diacritics/tashkeel
//   • Renders correctly with ScheherazadeNew and Amiri fonts (Mushaf style)
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class QuranAyah {
  final int number;
  final int numberInQuran;
  final String arabic;
  final String translation;
  final String audioUrl;

  const QuranAyah({
    required this.number,
    required this.numberInQuran,
    required this.arabic,
    required this.translation,
    required this.audioUrl,
  });

  factory QuranAyah.fromJson(
      Map<String, dynamic> arabic, Map<String, dynamic> translation) {
    return QuranAyah(
      number: arabic['numberInSurah'] as int,
      numberInQuran: arabic['number'] as int,
      arabic: cleanArabicText(arabic['text'] as String),
      translation: translation['text'] as String,
      audioUrl: arabic['audio'] as String? ?? '',
    );
  }
}

class QuranSurahDetail {
  final int number;
  final String name;
  final String englishName;
  final String meaning;
  final String revelationType;
  final int numberOfAyahs;
  final List<QuranAyah> ayahs;

  const QuranSurahDetail({
    required this.number,
    required this.name,
    required this.englishName,
    required this.meaning,
    required this.revelationType,
    required this.numberOfAyahs,
    required this.ayahs,
  });
}

class JuzSurahGroup {
  final int    surahNum;
  final String surahName;
  final String surahArabic;
  final List<Map<String, String>> ayahs;

  const JuzSurahGroup({
    required this.surahNum,
    required this.surahName,
    required this.surahArabic,
    required this.ayahs,
  });
}

class HadithModel {
  final String text;
  final String narrator;
  final String book;
  final String grade;
  final String topic;

  const HadithModel({
    required this.text,
    required this.narrator,
    required this.book,
    required this.grade,
    required this.topic,
  });
}

class _LocalData {
  // Uthmani script — matches quran-uthmani API edition
  // Surah 1: ayah 1 IS the Bismillah (it is genuinely part of Al-Fatihah).
  static const Map<int, List<Map<String, String>>> ayahs = {
    1: [
      {'a': 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ', 't': 'In the name of Allah, the Entirely Merciful, the Especially Merciful.', 'tu': 'اللہ کے نام سے جو بہت بڑا مہربان نہایت رحم والا ہے', 'num': '1'},
      {'a': 'ٱلۡحَمۡدُ لِلَّهِ رَبِّ ٱلۡعَٰلَمِينَ', 't': '[All] praise is [due] to Allah, Lord of the worlds –', 'tu': 'سب تعریفیں اللہ ہی کے لیے ہیں جو تمام جہانوں کا پالنے والا ہے', 'num': '2'},
      {'a': 'ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ', 't': 'The Entirely Merciful, the Especially Merciful,', 'tu': 'بہت بڑا مہربان نہایت رحم والا ہے', 'num': '3'},
      {'a': 'مَٰلِكِ يَوۡمِ ٱلدِّينِ', 't': 'Sovereign of the Day of Recompense.', 'tu': 'روزِ جزا کا مالک ہے', 'num': '4'},
      {'a': 'إِيَّاكَ نَعۡبُدُ وَإِيَّاكَ نَسۡتَعِينُ', 't': 'It is You we worship and You we ask for help.', 'tu': 'ہم تیری ہی عبادت کرتے ہیں اور تجھ ہی سے مدد چاہتے ہیں', 'num': '5'},
      {'a': 'ٱهۡدِنَا ٱلصِّرَٰطَ ٱلۡمُسۡتَقِيمَ', 't': 'Guide us to the straight path –', 'tu': 'ہمیں سیدھی راہ دکھا', 'num': '6'},
      {'a': 'صِرَٰطَ ٱلَّذِينَ أَنۡعَمۡتَ عَلَيۡهِمۡ غَيۡرِ ٱلۡمَغۡضُوبِ عَلَيۡهِمۡ وَلَا ٱلضَّآلِّينَ', 't': 'The path of those upon whom You have bestowed favor, not of those who have earned [Your] anger or of those who are astray.', 'tu': 'ان لوگوں کی راہ جن پر تو نے انعام کیا نہ کہ ان کی جن پر غضب کیا گیا اور نہ گمراہوں کی', 'num': '7'},
    ],
    36: [
      {'a': 'يسٓ', 't': 'Ya, Seen.', 'num': '1'},
      {'a': 'وَٱلۡقُرۡءَانِ ٱلۡحَكِيمِ', 't': 'By the wise Quran.', 'num': '2'},
      {'a': 'إِنَّكَ لَمِنَ ٱلۡمُرۡسَلِينَ', 't': 'Indeed you, [O Muhammad], are from among the messengers,', 'num': '3'},
      {'a': 'عَلَىٰ صِرَٰطٍ مُّسۡتَقِيمٍ', 't': 'On a straight path.', 'num': '4'},
      {'a': 'تَنزِيلَ ٱلۡعَزِيزِ ٱلرَّحِيمِ', 't': '[This is] a revelation of the Exalted in Might, the Merciful,', 'num': '5'},
    ],
    67: [
      {'a': 'تَبَٰرَكَ ٱلَّذِي بِيَدِهِ ٱلۡمُلۡكُ وَهُوَ عَلَىٰ كُلِّ شَيۡءٍ قَدِيرٌ', 't': 'Blessed is He in whose hand is dominion, and He is over all things competent –', 'num': '1'},
      {'a': 'ٱلَّذِي خَلَقَ ٱلۡمَوۡتَ وَٱلۡحَيَوٰةَ لِيَبۡلُوَكُمۡ أَيُّكُمۡ أَحۡسَنُ عَمَلًا', 't': '[He] who created death and life to test you [as to] which of you is best in deed –', 'num': '2'},
      {'a': 'ٱلَّذِي خَلَقَ سَبۡعَ سَمَٰوَٰتٍ طِبَاقًا', 't': '[And] who created seven heavens in layers.', 'num': '3'},
    ],
    112: [
      {'a': 'قُلۡ هُوَ ٱللَّهُ أَحَدٌ', 't': 'Say, "He is Allah, [who is] One,', 'num': '1'},
      {'a': 'ٱللَّهُ ٱلصَّمَدُ', 't': 'Allah, the Eternal Refuge.', 'num': '2'},
      {'a': 'لَمۡ يَلِدۡ وَلَمۡ يُولَدۡ', 't': 'He neither begets nor is born,', 'num': '3'},
      {'a': 'وَلَمۡ يَكُن لَّهُۥ كُفُوًا أَحَدٌ', 't': 'Nor is there to Him any equivalent."', 'num': '4'},
    ],
    113: [
      {'a': 'قُلۡ أَعُوذُ بِرَبِّ ٱلۡفَلَقِ', 't': 'Say, "I seek refuge in the Lord of daybreak', 'num': '1'},
      {'a': 'مِن شَرِّ مَا خَلَقَ', 't': 'From the evil of that which He created', 'num': '2'},
      {'a': 'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ', 't': 'And from the evil of darkness when it settles', 'num': '3'},
      {'a': 'وَمِن شَرِّ ٱلنَّفَّٰثَٰتِ فِي ٱلۡعُقَدِ', 't': 'And from the evil of the blowers in knots', 'num': '4'},
      {'a': 'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ', 't': 'And from the evil of an envier when he envies."', 'num': '5'},
    ],
    114: [
      {'a': 'قُلۡ أَعُوذُ بِرَبِّ ٱلنَّاسِ', 't': 'Say, "I seek refuge in the Lord of mankind,', 'num': '1'},
      {'a': 'مَلِكِ ٱلنَّاسِ', 't': 'The Sovereign of mankind.', 'num': '2'},
      {'a': 'إِلَٰهِ ٱلنَّاسِ', 't': 'The God of mankind,', 'num': '3'},
      {'a': 'مِن شَرِّ ٱلۡوَسۡوَاسِ ٱلۡخَنَّاسِ', 't': 'From the evil of the retreating whisperer –', 'num': '4'},
      {'a': 'ٱلَّذِي يُوَسۡوِسُ فِي صُدُورِ ٱلنَّاسِ', 't': 'Who whispers [evil] into the breasts of mankind –', 'num': '5'},
      {'a': 'مِنَ ٱلۡجِنَّةِ وَٱلنَّاسِ', 't': 'From among the jinn and mankind."', 'num': '6'},
    ],
  };

  static const Map<int, Map<String, String>> tafseer = {
    1: {
      'Ibn Kathir': 'Al-Fatihah is the greatest surah in the Quran. The Prophet said it is "the Mother of the Book, the seven oft-repeated verses, and the Great Quran." It encompasses praise of Allah, affirmation of His lordship, His mercy and sovereignty over the Day of Judgment, the declaration of exclusive worship, and the supplication for guidance.',
      "Ma'ariful Quran": "Mufti Muhammad Shafi explains: Allah Himself taught this surah as the perfect way for humanity to address Him. The seven verses cover three realities: divine attributes (Rahman, Rahim, Malik), the covenant of exclusive worship, and the request for guidance.",
      'Al-Jalalayn': 'Bismillah: In the name of Allah, the name encompassing all divine attributes. Al-hamdulillah: all praise belongs to Allah exclusively, as He alone is the source of all blessing.',
    },
    36: {
      'Ibn Kathir': 'The Prophet described Ya-Sin as "the heart of the Quran." The surah confirms prophethood through an oath on the Quran, then narrates the parable of the city whose people rejected messengers.',
      "Ma'ariful Quran": "The Quran uses Ya-Sin to introduce its affirmation of the Prophets mission. Three major themes: prophethood, resurrection, and divine power manifest in creation.",
      'Al-Jalalayn': "The oath Wal Quranil Hakeem has its response in Innaka la minal mursaleen confirming the Prophets status.",
    },
    67: {
      'Ibn Kathir': "Al-Mulk protects its reciter from punishment in the grave. Tabaraka indicates that Allahs blessings are perfect and overflowing. He created death before life as a test.",
      "Ma'ariful Quran": 'The surah opens with an affirmation that all sovereignty belongs exclusively to Allah. The purpose of death and life is to test who is best in deeds.',
      'Al-Jalalayn': 'Tabaraka: Exalted is He, whose blessings are perfect. Bi yadihi al-mulk: In His hand is dominion. The creation of death before life signifies that this world is temporary by design.',
    },
    112: {
      'Ibn Kathir': "Surah Al-Ikhlas is equivalent to one third of the Quran. Ahad means He is absolutely One. As-Samad means the Master whom all creation depends upon.",
      "Ma'ariful Quran": 'This surah refutes three forms of shirk: partners with Allah, claiming He has offspring, and comparing Him to creation.',
      'Al-Jalalayn': 'Say (qul) — a command to declare. Huwa: He — pointing to the divine essence. Ahad: the Unique One with no equal.',
    },
  };
}

// Helper: Clean problematic Unicode characters to fix overlaps, keep important diacritics
String cleanArabicText(String text) {
  return text
      // Only remove zero-width characters and problematic tatweel (kashida)
      .replaceAll(RegExp(r'[\u0640\u06DD-\u06ED\u08F0-\u08FF]'), '');
}

class QuranApiService {
  QuranApiService._();

  static const String _base    = 'https://api.alquran.cloud/v1';
  // CHANGED: quran-uthmani-hafs for authentic Uthmani script with proper diacritics
  static const String _arabic  = 'quran-uthmani-hafs';
  static const String _english = 'en.sahih';
  static const String _urdu    = 'ur.ahmedali';
  static const String _audio   = 'ar.alafasy';

  static Future<List<Map<String, String>>?> getLocalAyahs(int surahNum) async {
    final ayahs = _LocalData.ayahs[surahNum];
    if (ayahs == null) return null;
    return ayahs.map((ayah) => {
      'a': cleanArabicText(ayah['a']!),
      't': ayah['t']!,
      'tu': ayah['tu']!,
      'num': ayah['num']!,
    }).toList();
  }

  /// Fetches Arabic + English + Urdu (fast mode now includes both translations)
  static Future<List<Map<String, String>>?> fetchSurah(int num) async {
    try {
      final results = await Future.wait([
        http.get(Uri.parse('$_base/surah/$num/$_arabic')),
        http.get(Uri.parse('$_base/surah/$num/$_english')),
        http.get(Uri.parse('$_base/surah/$num/$_urdu')),
      ]).timeout(const Duration(seconds: 15));

      if (results.any((r) => r.statusCode != 200)) return null;

      final arAyahs = jsonDecode(results[0].body)['data']['ayahs'] as List;
      final enAyahs = jsonDecode(results[1].body)['data']['ayahs'] as List;
      final urAyahs = jsonDecode(results[2].body)['data']['ayahs'] as List;

      return List.generate(arAyahs.length, (i) => {
        'a':     cleanArabicText(arAyahs[i]['text'] as String),
        't':     enAyahs[i]['text'] as String,
        'tu':    urAyahs[i]['text'] as String,
        'num':   '${arAyahs[i]['numberInSurah']}',
        'audio': arAyahs[i]['audio'] as String? ?? '',
      });
    } catch (e) {
      debugPrint('fetchSurah error: $e');
      return null;
    }
  }

  /// Fetches Arabic + English + Urdu + audio (3 requests — full mode)
  static Future<List<Map<String, String>>?> fetchSurahFull(int num) async {
    try {
      final results = await Future.wait([
        http.get(Uri.parse('$_base/surah/$num/$_arabic')),
        http.get(Uri.parse('$_base/surah/$num/$_english')),
        http.get(Uri.parse('$_base/surah/$num/$_urdu')),
      ]).timeout(const Duration(seconds: 15));

      if (results.any((r) => r.statusCode != 200)) return null;

      final arAyahs = jsonDecode(results[0].body)['data']['ayahs'] as List;
      final enAyahs = jsonDecode(results[1].body)['data']['ayahs'] as List;
      final urAyahs = jsonDecode(results[2].body)['data']['ayahs'] as List;

      return List.generate(arAyahs.length, (i) => {
        'a':     cleanArabicText(arAyahs[i]['text']  as String),
        't':     enAyahs[i]['text']  as String,
        'tu':    urAyahs[i]['text']  as String,
        'num':   '${arAyahs[i]['numberInSurah']}',
        'audio': arAyahs[i]['audio'] as String? ?? '',
      });
    } catch (e) {
      debugPrint('fetchSurahFull error: $e');
      return null;
    }
  }

  static Future<List<JuzSurahGroup>?> fetchJuz(int juzNum) async {
    try {
      final results = await Future.wait([
        http.get(Uri.parse('$_base/juz/$juzNum/$_arabic')),
        http.get(Uri.parse('$_base/juz/$juzNum/$_english')),
        http.get(Uri.parse('$_base/juz/$juzNum/$_urdu')),
      ]).timeout(const Duration(seconds: 18));

      if (results.any((r) => r.statusCode != 200)) return null;

      final arAyahs = jsonDecode(results[0].body)['data']['ayahs'] as List;
      final enAyahs = jsonDecode(results[1].body)['data']['ayahs'] as List;
      final urAyahs = jsonDecode(results[2].body)['data']['ayahs'] as List;

      final Map<int, _SurahBuf> buf = {};
      for (int i = 0; i < arAyahs.length; i++) {
        final ar      = arAyahs[i];
        final en      = enAyahs[i];
        final ur      = urAyahs[i];
        final sNum    = ar['surah']['number'] as int;
        final sName   = ar['surah']['englishName'] as String;
        final sArabic = ar['surah']['name'] as String;

        buf.putIfAbsent(sNum, () => _SurahBuf(sNum, sName, sArabic));
        buf[sNum]!.ayahs.add({
          'a':   cleanArabicText(ar['text'] as String),
          't':   en['text'] as String,
          'tu':  ur['text'] as String,
          'num': '${ar['numberInSurah']}',
        });
      }

      return buf.values.map((b) => JuzSurahGroup(
        surahNum:    b.num,
        surahName:   b.name,
        surahArabic: b.arabic,
        ayahs:       b.ayahs,
      )).toList();
    } catch (e) {
      debugPrint('fetchJuz error: $e');
      return null;
    }
  }

  static Future<String?> getLocalTafseer(int surahNum, String source) async {
    return _LocalData.tafseer[surahNum]?[source];
  }

  static Future<String?> fetchTafseer(int surahNum, int ayahNum, String source, {bool isUrdu = false}) async {
    final Map<String, int> ids = isUrdu 
      ? {'Ibn Kathir': 159, "Ma'ariful Quran": 161, 'Al-Jalalayn': 74}
      : {'Ibn Kathir': 169, "Ma'ariful Quran": 168, 'Al-Jalalayn': 74};
    
    final id = isUrdu 
      ? (source == 'Ibn Kathir' ? 159 : (source == "Ma'ariful Quran" ? 161 : 158))
      : (ids[source] ?? 169);
    
    try {
      final r = await http.get(
        Uri.parse('https://api.quran.com/api/v4/tafsirs/$id/by_ayah?verse_key=$surahNum:$ayahNum'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      if (r.statusCode != 200) return null;
      final text = jsonDecode(r.body)['tafsir']?['text'] as String?;
      return text?.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    } catch (_) { return null; }
  }

  /// Fetches the entire Tafseer for a specific chapter (continuous reading)
  static Future<List<Map<String, dynamic>>?> fetchChapterTafseer(int surahNum, String source, {bool isUrdu = false}) async {
    final Map<String, int> ids = isUrdu 
      ? {'Ibn Kathir': 159, "Ma'ariful Quran": 161, 'Al-Jalalayn': 74}
      : {'Ibn Kathir': 169, "Ma'ariful Quran": 168, 'Al-Jalalayn': 74};
    
    final id = isUrdu 
      ? (source == 'Ibn Kathir' ? 159 : (source == "Ma'ariful Quran" ? 161 : 158))
      : (ids[source] ?? 169);

    try {
      final r = await http.get(
        Uri.parse('https://api.quran.com/api/v4/tafsirs/$id/by_chapter/$surahNum'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 20));
      
      if (r.statusCode != 200) return null;
      
      final data = jsonDecode(r.body);
      final tafsirs = data['tafsirs'] as List?;
      if (tafsirs == null) return null;

      return tafsirs.map((t) => {
        'ayah_key': t['verse_key'],
        'text': (t['text'] as String).replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim(),
      }).toList();
    } catch (e) {
      debugPrint('fetchChapterTafseer error: $e');
      return null;
    }
  }

  static Future<QuranSurahDetail?> getSurah(int surahNumber) async {
    try {
      final results = await Future.wait([
        http.get(Uri.parse('$_base/surah/$surahNumber/$_arabic')),
        http.get(Uri.parse('$_base/surah/$surahNumber/$_english')),
      ]);
      if (results[0].statusCode != 200 || results[1].statusCode != 200) return null;
      final arabicJson  = jsonDecode(results[0].body)['data'];
      final transJson   = jsonDecode(results[1].body)['data'];
      final arabicAyahs = arabicJson['ayahs'] as List;
      final transAyahs  = transJson['ayahs']  as List;
      final ayahs = List.generate(arabicAyahs.length, (i) => QuranAyah.fromJson(
        arabicAyahs[i] as Map<String, dynamic>,
        transAyahs[i]  as Map<String, dynamic>,
      ));
      return QuranSurahDetail(
        number: arabicJson['number'] as int,
        name: arabicJson['name'] as String,
        englishName: arabicJson['englishName'] as String,
        meaning: arabicJson['englishNameTranslation'] as String,
        revelationType: arabicJson['revelationType'] as String,
        numberOfAyahs: arabicJson['numberOfAyahs'] as int,
        ayahs: ayahs,
      );
    } catch (_) { return null; }
  }

  static Future<QuranAyah?> getRandomAyah() async {
    final day = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays + 1;
    final ayahNum = (day % 6236) + 1;
    try {
      final results = await Future.wait([
        http.get(Uri.parse('$_base/ayah/$ayahNum/$_arabic')),
        http.get(Uri.parse('$_base/ayah/$ayahNum/$_english')),
        http.get(Uri.parse('$_base/ayah/$ayahNum/$_audio')),
      ]);
      if (results.any((r) => r.statusCode != 200)) return null;
      final ad = jsonDecode(results[0].body)['data'];
      final td = jsonDecode(results[1].body)['data'];
      final au = jsonDecode(results[2].body)['data'];
      return QuranAyah(
        number: ad['numberInSurah'] as int,
        numberInQuran: ad['number'] as int,
        arabic: cleanArabicText(ad['text'] as String),
        translation: td['text'] as String,
        audioUrl: au['audio'] as String? ?? '',
      );
    } catch (_) { return null; }
  }
}

class _SurahBuf {
  final int num;
  final String name;
  final String arabic;
  final List<Map<String, String>> ayahs = [];
  _SurahBuf(this.num, this.name, this.arabic);
}

class QuranCache {
  static final Map<int, QuranSurahDetail> _s = {};
  static final Map<String, String>        _t = {};
  static QuranSurahDetail? getSurah(int n)   => _s[n];
  static void putSurah(QuranSurahDetail s)   => _s[s.number] = s;
  static String? getTafseer(String k)        => _t[k];
  static void putTafseer(String k, String v) => _t[k] = v;
  static void clear()                        { _s.clear(); _t.clear(); }
}

class HadithApiService {
  static Future<HadithModel?> getHadithOfDay() async => null;
}
