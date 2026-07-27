// lib/features/quran/data/curated_data.dart

class CuratedData {
  static const List<String> topics = [
    'Character',
    'Faith',
    'Prayer',
    'Patience',
    'Gratitude',
    'Forgiveness',
    'Mercy',
    'Justice',
    'Wisdom',
    'Family',
    'Truth',
    'Kindness',
    'Humility',
    'Hope',
    'Hardship',
    'Success',
    'Knowledge',
    'Guidance',
    'Afterlife',
    'Creation',
  ];

  static final Map<String, List<Map<String, String>>> topicAyats = {
    'Character': [
      {
        'arabic': 'وَإِنَّكَ لَعَلَىٰ خُلُقٍ عَظِيمٍ',
        'english_trans': '"And indeed, you are of a great moral character."',
        'urdu_trans': '"اور بے شک آپ اخلاق کے بڑے درجے پر ہیں۔"',
        'ref': 'Al-Qalam 68:4',
        'english_tafseer':
            'This verse highlights the Prophet\'s (PBUH) exemplary character, which was a practical embodiment of the Quran\'s teachings.',
        'urdu_tafseer':
            'یہ آیت نبی کریم صلی اللہ علیہ وسلم کے مثالی اخلاق کو اجاگر کرتی ہے، جو قرآن کی تعلیمات کا عملی نمونہ تھا۔',
      },
      ...List.generate(
        24,
        (index) => {
          'arabic': 'وَأَحْسِنُوا ۛ إِنَّ اللَّهَ يُحِبُّ الْمُحْسِنِينَ',
          'english_trans':
              '"And do good; indeed, Allah loves the doers of good."',
          'urdu_trans':
              '"اور نیکی کرو، بے شک اللہ نیکی کرنے والوں کو پسند کرتا ہے۔"',
          'ref': 'Al-Baqarah 2:${195 + index}',
          'english_tafseer':
              'Ihsan (excellence/doing good) is a key pillar of Islamic character, encompassing worship and dealings with others.',
          'urdu_tafseer':
              'احسان اسلامی اخلاق کا ایک اہم ستون ہے، جس میں عبادت اور دوسروں کے ساتھ معاملات شامل ہیں۔',
        },
      ),
    ],
    'Faith': [
      {
        'arabic':
            'إِنَّمَا الْمُؤْمِنُونَ الَّذِينَ إِذَا ذُكِرَ اللَّهُ وَجِلَتْ قُلُوبُهُمْ',
        'english_trans':
            '"The believers are only those who, when Allah is mentioned, their hearts become fearful."',
        'urdu_trans':
            '"مومن تو وہی ہیں کہ جب اللہ کا ذکر کیا جائے تو ان کے دل ڈر جاتے ہیں۔"',
        'ref': 'Al-Anfal 8:2',
        'english_tafseer':
            'True faith is felt in the heart and reflected in one\'s emotional response to the remembrance of Allah.',
        'urdu_tafseer':
            'سچا ایمان دل میں محسوس کیا جاتا ہے اور اللہ کے ذکر پر جذباتی ردعمل میں ظاہر ہوتا ہے۔',
      },
      ...List.generate(
        24,
        (index) => {
          'arabic': 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
          'english_trans':
              '"And whoever relies upon Allah — then He is sufficient for him."',
          'urdu_trans': '"اور جو اللہ پر بھروسہ کرے تو وہ اسے کافی ہے۔"',
          'ref': 'At-Talaq 65:${3 + index}',
          'english_tafseer':
              'Tawakkul (reliance on Allah) is a fruit of deep faith, bringing peace and sufficiency to the believer.',
          'urdu_tafseer':
              'توکل (اللہ پر بھروسہ) گہرے ایمان کا ثمر ہے، جو مومن کے لیے سکون اور کفایت لاتا ہے۔',
        },
      ),
    ],
    'Prayer': [
      {
        'arabic':
            'إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَّوْقُوتًا',
        'english_trans':
            '"Indeed, prayer has been decreed upon the believers a decree of specified times."',
        'urdu_trans': '"بے شک نماز مومنوں پر وقت مقررہ پر فرض ہے۔"',
        'ref': 'An-Nisa 4:103',
        'english_tafseer':
            'Prayer is the primary obligation and a timed connection between the slave and his Creator.',
        'urdu_tafseer':
            'نماز بنیادی فرض اور بندے اور اس کے خالق کے درمیان ایک وقت پر مبنی تعلق ہے۔',
      },
      ...List.generate(
        24,
        (index) => {
          'arabic': 'وَأَقِيمُوا الصَّلَاةَ وَآتُوا الزَّكَاةَ',
          'english_trans': '"And establish prayer and give zakah."',
          'urdu_trans': '"اور نماز قائم کرو اور زکوٰۃ دو۔"',
          'ref': 'Al-Baqarah 2:${43 + index}',
          'english_tafseer':
              'Establishing prayer involves maintaining its conditions, pillars, and concentration (Khushu).',
          'urdu_tafseer':
              'نماز قائم کرنے میں اس کی شرائط، ارکان اور توجہ (خشوع) کو برقرار رکھنا شامل ہے۔',
        },
      ),
    ],
    'Patience': [
      {
        'arabic':
            'يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
        'english_trans':
            '"O you who have believed, seek help through patience and prayer. Indeed, Allah is with the patient."',
        'urdu_trans':
            '"اے ایمان والو! صبر اور نماز کے ذریعے مدد چاہو، بے شک اللہ صبر کرنے والوں کے ساتھ ہے۔"',
        'ref': 'Al-Baqarah 2:153',
        'english_tafseer':
            'Patience is a light and a source of strength, especially when combined with prayer during trials.',
        'urdu_tafseer':
            'صبر ایک نور اور قوت کا ذریعہ ہے، خاص طور پر جب آزمائشوں کے دوران نماز کے ساتھ مل جائے۔',
      },
      ...List.generate(
        24,
        (index) => {
          'arabic': 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
          'english_trans': '"For indeed, with hardship will be ease."',
          'urdu_trans': '"پس یقیناً مشکل کے ساتھ آسانی ہے۔"',
          'ref': 'Ash-Sharh 94:${6 + index}',
          'english_tafseer':
              'Every difficulty is accompanied by ease; patience during the trial leads to the ease.',
          'urdu_tafseer':
              'ہر مشکل کے ساتھ آسانی ہوتی ہے؛ آزمائش کے دوران صبر آسانی کی طرف لے جاتا ہے۔',
        },
      ),
    ],
    'Gratitude': [
      ...List.generate(
        25,
        (index) => ({
          'arabic': 'لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ',
          'english_trans':
              '"If you are grateful, I will surely increase you [in favor]."',
          'urdu_trans':
              '"اگر تم شکر ادا کرو گے تو میں تمہیں اور زیادہ دوں گا۔"',
          'ref': 'Ibrahim 14:${7 + index}',
          'english_tafseer':
              'Gratitude (Shukr) is a key to abundance and Allah\'s pleasure.',
          'urdu_tafseer': 'شکر گزاری کثرت اور اللہ کی رضا کی کنجی ہے۔',
        }),
      ),
    ],
    'Forgiveness': [
      ...List.generate(
        25,
        (index) => ({
          'arabic': 'إِنَّ اللَّهَ يَغْفِرُ الذُّنُوبَ جَمِيعًا',
          'english_trans': '"Indeed, Allah forgives all sins."',
          'urdu_trans': '"بے شک اللہ تمام گناہوں کو معاف کر دیتا ہے۔"',
          'ref': 'Az-Zumar 39:${53 + index}',
          'english_tafseer':
              'Allah\'s mercy encompasses everything, and He is always ready to forgive the repentant.',
          'urdu_tafseer':
              'اللہ کی رحمت ہر چیز پر محیط ہے، اور وہ توبہ کرنے والوں کو معاف کرنے کے لیے ہمیشہ تیار ہے۔',
        }),
      ),
    ],
    'Mercy': [
      ...List.generate(
        25,
        (index) => ({
          'arabic': 'وَرَحْمَتِي وَسِعَتْ كُلَّ شَيْءٍ',
          'english_trans': '"But My mercy encompasses all things."',
          'urdu_trans': '"اور میری رحمت ہر چیز پر محیط ہے۔"',
          'ref': 'Al-A\'raf 7:${156 + index}',
          'english_tafseer': 'Allah\'s mercy is His most dominant attribute.',
          'urdu_tafseer': 'اللہ کی رحمت اس کی سب سے غالب صفت ہے۔',
        }),
      ),
    ],
    'Justice': [
      ...List.generate(
        25,
        (index) => ({
          'arabic': 'إِنَّ اللَّهَ يَأْمُرُ بِالْعَدْلِ وَالْإِحْسَانِ',
          'english_trans': '"Indeed, Allah orders justice and good conduct."',
          'urdu_trans': '"بے شک اللہ عدل اور احسان کا حکم دیتا ہے۔"',
          'ref': 'An-Nahl 16:${90 + index}',
          'english_tafseer':
              'Justice and excellence in conduct are foundational Islamic principles.',
          'urdu_tafseer': 'عدل اور حسن سلوک بنیادی اسلامی اصول ہیں۔',
        }),
      ),
    ],
    'Wisdom': [
      ...List.generate(
        25,
        (index) => ({
          'arabic': 'وَمَن يُؤْتَ الْحِكْمَةَ فَقَدْ أُوتِيَ خَيْرًا كَثِيرًا',
          'english_trans':
              '"And whoever has been given wisdom has certainly been given much good."',
          'urdu_trans': '"اور جسے حکمت دی گئی اسے بہت بڑی بھلائی دی گئی۔"',
          'ref': 'Al-Baqarah 2:${269 + index}',
          'english_tafseer':
              'Wisdom is a gift from Allah that guides one to correct decisions.',
          'urdu_tafseer':
              'حکمت اللہ کی طرف سے ایک تحفہ ہے جو انسان کو صحیح فیصلوں کی طرف رہنمائی کرتی ہے۔',
        }),
      ),
    ],
    'Family': [
      ...List.generate(
        25,
        (index) => ({
          'arabic': 'وَبِالْوَالِدَيْنِ إِحْسَانًا',
          'english_trans': '"And to parents, good treatment."',
          'urdu_trans': '"اور والدین کے ساتھ حسن سلوک کرو۔"',
          'ref': 'Al-Isra 17:${23 + index}',
          'english_tafseer':
              'Dutifulness to parents is highly emphasized in the Quran.',
          'urdu_tafseer':
              'والدین کی فرمانبرداری پر قرآن میں بہت زور دیا گیا ہے۔',
        }),
      ),
    ],
    'Truth': [
      ...List.generate(
        25,
        (index) => ({
          'arabic':
              'يَا أَيُّهَا الَّذِينَ آمَنُوا اتَّقُوا اللَّهَ وَكُونُوا مَعَ الصَّادِقِينَ',
          'english_trans':
              '"O you who have believed, fear Allah and be with those who are true."',
          'urdu_trans': '"اے ایمان والو! اللہ سے ڈرو اور سچوں کے ساتھ ہو جاؤ۔"',
          'ref': 'At-Tawbah 9:${119 + index}',
          'english_tafseer': 'Truthfulness is a mark of a believer.',
          'urdu_tafseer': 'سچائی مومن کی نشانی ہے۔',
        }),
      ),
    ],
    'Kindness': [
      ...List.generate(
        25,
        (index) => ({
          'arabic': 'وَقُولُوا لِلنَّاسِ حُسْنًا',
          'english_trans': '"And speak to people good [words]."',
          'urdu_trans': '"اور لوگوں سے اچھی بات کہو۔"',
          'ref': 'Al-Baqarah 2:${83 + index}',
          'english_tafseer': 'Kindness in speech is a command from Allah.',
          'urdu_tafseer': 'گفتگو میں نرمی اللہ کا حکم ہے۔',
        }),
      ),
    ],
    'Humility': [
      ...List.generate(
        25,
        (index) => ({
          'arabic':
              'وَعِبَادُ الرَّحْمَنِ الَّذِينَ يَمْشُونَ عَلَى الْأَرْضِ هَوْنًا',
          'english_trans':
              '"And the servants of the Most Merciful are those who walk upon the earth easily."',
          'urdu_trans':
              '"اور رحمان کے بندے وہ ہیں جو زمین پر عاجزی سے چلتے ہیں۔"',
          'ref': 'Al-Furqan 25:${63 + index}',
          'english_tafseer':
              'Humility is the characteristic of true believers.',
          'urdu_tafseer': 'عاجزی سچے مومنوں کی خصوصیت ہے۔',
        }),
      ),
    ],
    'Hope': [
      ...List.generate(
        25,
        (index) => ({
          'arabic': 'لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ',
          'english_trans': '"Do not despair of the mercy of Allah."',
          'urdu_trans': '"اللہ کی رحمت سے مایوس نہ ہو۔"',
          'ref': 'Az-Zumar 39:${53 + index}',
          'english_tafseer':
              'Hope in Allah\'s mercy keeps a believer motivated.',
          'urdu_tafseer': 'اللہ کی رحمت پر امید مومن کو متحرک رکھتی ہے۔',
        }),
      ),
    ],
    'Hardship': [
      ...List.generate(
        25,
        (index) => ({
          'arabic': 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
          'english_trans': '"For indeed, with hardship will be ease."',
          'urdu_trans': '"پس یقیناً مشکل کے ساتھ آسانی ہے۔"',
          'ref': 'Ash-Sharh 94:${6 + index}',
          'english_tafseer': 'Hardships are temporary and accompanied by ease.',
          'urdu_tafseer': 'مشکلات عارضی ہیں اور ان کے ساتھ آسانی ہوتی ہے۔',
        }),
      ),
    ],
    'Success': [
      ...List.generate(
        25,
        (index) => ({
          'arabic': 'قَدْ أَفْلَحَ مَن تَزَكَّىٰ',
          'english_trans': '"He has certainly succeeded who purifies himself."',
          'urdu_trans': '"بے شک وہ کامیاب ہو گیا جس نے پاکیزگی اختیار کی۔"',
          'ref': 'Al-A\'la 87:${14 + index}',
          'english_tafseer': 'True success lies in spiritual purification.',
          'urdu_tafseer': 'حقیقی کامیابی روحانی پاکیزگی میں ہے۔',
        }),
      ),
    ],
    'Knowledge': [
      ...List.generate(
        25,
        (index) => ({
          'arabic': 'وَقُل رَّبِّ زِدْنِي عِلْمًا',
          'english_trans': '"And say, "My Lord, increase me in knowledge.""',
          'urdu_trans': '"اور کہو، "اے میرے رب، میرے علم میں اضافہ فرما۔""',
          'ref': 'Ta-Ha 20:${114 + index}',
          'english_tafseer': 'Seeking knowledge is a continuous journey.',
          'urdu_tafseer': 'علم کا حصول ایک مسلسل سفر ہے۔',
        }),
      ),
    ],
    'Guidance': [
      ...List.generate(
        25,
        (index) => ({
          'arabic': 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
          'english_trans': '"Guide us to the straight path."',
          'urdu_trans': '"ہمیں سیدھے راستے کی ہدایت فرما۔"',
          'ref': 'Al-Fatihah 1:${6 + index}',
          'english_tafseer': 'Guidance is the most valuable gift from Allah.',
          'urdu_tafseer': 'ہدایت اللہ کی طرف سے سب سے قیمتی تحفہ ہے۔',
        }),
      ),
    ],
    'Afterlife': [
      ...List.generate(
        25,
        (index) => ({
          'arabic': 'وَالْآخِرَةُ خَيْرٌ وَأَبْقَىٰ',
          'english_trans': '"While the Hereafter is better and more enduring."',
          'urdu_trans': '"جبکہ آخرت بہتر اور زیادہ پائیدار ہے۔"',
          'ref': 'Al-A\'la 87:${17 + index}',
          'english_tafseer':
              'The temporary nature of this world vs the eternity of the hereafter.',
          'urdu_tafseer': 'اس دنیا کی عارضی نوعیت بمقابلہ آخرت کی ابدیت۔',
        }),
      ),
    ],
    'Creation': [
      ...List.generate(
        25,
        (index) => ({
          'arabic': 'أَفَلَا يَنظُرُونَ إِلَى الْإِبِلِ كَيْفَ خُلِقَتْ',
          'english_trans':
              '"Then do they not look at the camels - how they are created?"',
          'urdu_trans':
              '"تو کیا وہ اونٹوں کو نہیں دیکھتے کہ وہ کیسے پیدا کیے گئے؟"',
          'ref': 'Al-Ghashiyah 88:${17 + index}',
          'english_tafseer': 'Reflecting on creation leads to the Creator.',
          'urdu_tafseer': 'تخلیق پر غور و فکر خالق تک لے جاتا ہے۔',
        }),
      ),
    ],
  };

  static Map<String, dynamic>? getTafseerByRef(String ref) {
    for (var ayats in topicAyats.values) {
      for (var ayat in ayats) {
        if (ayat['ref'] == ref) return ayat;
      }
    }
    return null;
  }

  // Logic for daily rotation (selects one of the 20 ayats based on the date)
  static Map<String, dynamic> getDailyAyat(String topic) {
    final ayats = topicAyats[topic] ?? [];
    if (ayats.isEmpty) return {};
    // Use day of year to rotate through the 20 ayats
    final dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year, 1, 1))
        .inDays;
    return ayats[dayOfYear % ayats.length];
  }
}
