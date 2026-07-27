// lib/features/quran/data/ayahs_data.dart
// Ayahs keyed by surah number.
// Surah 1 (Al-Fatihah) — all 7 ayahs with Arabic + translation.
// Other surahs: stub entries — add ayahs incrementally as needed.

class AyahsData {
  AyahsData._();

  /// Returns the list of ayahs for a given surah number.
  static List<Map<String, dynamic>> forSurah(int surahNumber) {
    return _ayahs[surahNumber] ?? [];
  }

  static const Map<int, List<Map<String, dynamic>>> _ayahs = {
    // ── Surah 1: Al-Fatihah ──────────────────────────────────────────────────
    1: [
      {
        'number': 1,
        'arabic': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        'translation':
            'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
        'audioUrl': '',
      },
      {
        'number': 2,
        'arabic': 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
        'translation': '[All] praise is [due] to Allah, Lord of the worlds –',
        'audioUrl': '',
      },
      {
        'number': 3,
        'arabic': 'الرَّحْمَٰنِ الرَّحِيمِ',
        'translation': 'The Entirely Merciful, the Especially Merciful,',
        'audioUrl': '',
      },
      {
        'number': 4,
        'arabic': 'مَالِكِ يَوْمِ الدِّينِ',
        'translation': 'Sovereign of the Day of Recompense.',
        'audioUrl': '',
      },
      {
        'number': 5,
        'arabic': 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
        'translation': 'It is You we worship and You we ask for help.',
        'audioUrl': '',
      },
      {
        'number': 6,
        'arabic': 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
        'translation': 'Guide us to the straight path –',
        'audioUrl': '',
      },
      {
        'number': 7,
        'arabic':
            'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
        'translation':
            'The path of those upon whom You have bestowed favor, not of those who have earned [Your] anger or of those who are astray.',
        'audioUrl': '',
      },
    ],

    // ── Surah 2–114: Stubs (add full ayahs incrementally) ───────────────────
    // Each will be populated in future iterations.
    2: [
      {
        'number': 1,
        'arabic': 'الٓمٓ',
        'translation': 'Alif, Lam, Meem.',
        'audioUrl': '',
      },
    ],
    3: [
      {
        'number': 1,
        'arabic': 'الٓمٓ',
        'translation': 'Alif, Lam, Meem.',
        'audioUrl': '',
      },
    ],
    4: [
      {
        'number': 1,
        'arabic': 'يَا أَيُّهَا النَّاسُ',
        'translation': 'O mankind...',
        'audioUrl': '',
      },
    ],
    5: [
      {
        'number': 1,
        'arabic': 'يَا أَيُّهَا الَّذِينَ آمَنُوا',
        'translation': 'O you who have believed...',
        'audioUrl': '',
      },
    ],
    36: [
      {'number': 1, 'arabic': 'يس', 'translation': 'Ya, Seen.', 'audioUrl': ''},
    ],
    55: [
      {
        'number': 1,
        'arabic': 'الرَّحْمَٰنُ',
        'translation': 'The Most Merciful',
        'audioUrl': '',
      },
    ],
    67: [
      {
        'number': 1,
        'arabic': 'تَبَارَكَ الَّذِي بِيَدِهِ الْمُلْكُ',
        'translation': 'Blessed is He in whose hand is dominion...',
        'audioUrl': '',
      },
    ],
    112: [
      {
        'number': 1,
        'arabic': 'قُلْ هُوَ اللَّهُ أَحَدٌ',
        'translation': 'Say, "He is Allah, [who is] One,"',
        'audioUrl': '',
      },
      {
        'number': 2,
        'arabic': 'اللَّهُ الصَّمَدُ',
        'translation': 'Allah, the Eternal Refuge.',
        'audioUrl': '',
      },
      {
        'number': 3,
        'arabic': 'لَمْ يَلِدْ وَلَمْ يُولَدْ',
        'translation': 'He neither begets nor is born,',
        'audioUrl': '',
      },
      {
        'number': 4,
        'arabic': 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
        'translation': 'Nor is there to Him any equivalent.',
        'audioUrl': '',
      },
    ],
    114: [
      {
        'number': 1,
        'arabic': 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
        'translation': 'Say, "I seek refuge in the Lord of mankind,"',
        'audioUrl': '',
      },
      {
        'number': 2,
        'arabic': 'مَلِكِ النَّاسِ',
        'translation': 'The Sovereign of mankind.',
        'audioUrl': '',
      },
      {
        'number': 3,
        'arabic': 'إِلَٰهِ النَّاسِ',
        'translation': 'The God of mankind,',
        'audioUrl': '',
      },
      {
        'number': 4,
        'arabic': 'مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ',
        'translation': 'From the evil of the retreating whisperer –',
        'audioUrl': '',
      },
      {
        'number': 5,
        'arabic': 'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ',
        'translation': 'Who whispers [evil] into the breasts of mankind –',
        'audioUrl': '',
      },
      {
        'number': 6,
        'arabic': 'مِنَ الْجِنَّةِ وَالنَّاسِ',
        'translation': 'From among the jinn and mankind.',
        'audioUrl': '',
      },
    ],
  };
}
