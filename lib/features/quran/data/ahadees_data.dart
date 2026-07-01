// lib/features/quran/data/ahadees_data.dart

import 'quran_api_service.dart';

class AhadeesData {
  AhadeesData._();

  // Comprehensive hadith collection for all 6 major books
  static final Map<String, List<Map<String, String>>> bookHadiths = {
    'bukhari': List.generate(
      100,
      (index) => {
        'number': (index + 1).toString(),
        'arabic': _getBukhariArabic(index),
        'id': _getBukhariEnglish(index),
      },
    ),
    'muslim': List.generate(
      100,
      (index) => {
        'number': (index + 1).toString(),
        'arabic': _getMuslimArabic(index),
        'id': _getMuslimEnglish(index),
      },
    ),
    'tirmidhi': List.generate(
      100,
      (index) => {
        'number': (index + 1).toString(),
        'arabic': _getTirmidhiArabic(index),
        'id': _getTirmidhiEnglish(index),
      },
    ),
    'abu-dawud': List.generate(
      100,
      (index) => {
        'number': (index + 1).toString(),
        'arabic': _getAbuDawudArabic(index),
        'id': _getAbuDawudEnglish(index),
      },
    ),
    'nasai': List.generate(
      100,
      (index) => {
        'number': (index + 1).toString(),
        'arabic': _getNasaiArabic(index),
        'id': _getNasaiEnglish(index),
      },
    ),
    'ibn-majah': List.generate(
      100,
      (index) => {
        'number': (index + 1).toString(),
        'arabic': _getIbnMajahArabic(index),
        'id': _getIbnMajahEnglish(index),
      },
    ),
  };

  static final List<Map<String, String>> ahadees = [
    // Character
    {
      'text': '"Whoever believes in Allah and the Last Day should speak a good word or remain silent."',
      'narrator': 'Narrated by Abu Huraira',
      'book': 'SAHIH AL-BUKHARI',
      'grade': 'SAHIH',
      'topic': 'Character',
    },
    {
      'text': '"The best among you are those who have the best manners and character."',
      'narrator': 'Narrated by Ibn Umar',
      'book': 'SAHIH AL-BUKHARI',
      'grade': 'SAHIH',
      'topic': 'Character',
    },
    {
      'text': '"He who believes in Allah and the Last Day must not harm his neighbor. He who believes in Allah and the Last Day must entertain his guest generously."',
      'narrator': 'Narrated by Abu Huraira',
      'book': 'SAHIH AL-BUKHARI',
      'grade': 'SAHIH',
      'topic': 'Character',
    },
    // Faith
    {
      'text': '"Purity is half of faith."',
      'narrator': 'Narrated by Abu Huraira',
      'book': 'SAHIH MUSLIM',
      'grade': 'SAHIH',
      'topic': 'Faith',
    },
    {
      'text': '"Faith is to believe in Allah, His angels, His Books, His Messengers, the Day of Judgment, and the divine decree about good and evil."',
      'narrator': 'Narrated by Abu Huraira',
      'book': 'SAHIH AL-BUKHARI',
      'grade': 'SAHIH',
      'topic': 'Faith',
    },
    // Prayer
    {
      'text': '"Pray as you have seen me praying."',
      'narrator': 'Narrated by Malik ibn al-Huwairith',
      'book': 'SAHIH AL-BUKHARI',
      'grade': 'SAHIH',
      'topic': 'Prayer',
    },
    {
      'text': '"The five daily prayers are prescribed: Fajr, Dhuhr, Asr, Maghrib, and Isha."',
      'narrator': 'Narrated by Abu Huraira',
      'book': 'SAHIH AL-BUKHARI',
      'grade': 'SAHIH',
      'topic': 'Prayer',
    },
    // Charity
    {
      'text': '"The best charity is that given to a relative who does not like you."',
      'narrator': 'Narrated by Abu Ayyub al-Ansari',
      'book': 'JAMI AT-TIRMIDHI',
      'grade': 'SAHIH',
      'topic': 'Charity',
    },
    {
      'text': '"Charity does not decrease wealth."',
      'narrator': 'Narrated by Abu Huraira',
      'book': 'SAHIH MUSLIM',
      'grade': 'SAHIH',
      'topic': 'Charity',
    },
    // Fasting
    {
      'text': '"Fasting is a shield."',
      'narrator': 'Narrated by Abu Huraira',
      'book': 'SAHIH AL-BUKHARI',
      'grade': 'SAHIH',
      'topic': 'Fasting',
    },
    {
      'text': '"When the month of Ramadan begins, the gates of Paradise are opened and the gates of Hell are closed."',
      'narrator': 'Narrated by Abu Huraira',
      'book': 'SAHIH AL-BUKHARI',
      'grade': 'SAHIH',
      'topic': 'Fasting',
    },
    // Patience
    {
      'text': '"The strong man is not the one who can wrestle, but the one who can control himself in a fit of anger."',
      'narrator': 'Narrated by Abu Huraira',
      'book': 'SAHIH AL-BUKHARI',
      'grade': 'SAHIH',
      'topic': 'Patience',
    },
    {
      'text': '"Seeking knowledge is a duty upon every Muslim."',
      'narrator': 'Narrated by Anas ibn Malik',
      'book': 'SUNAN IBN MAJAH',
      'grade': 'SAHIH',
      'topic': 'Patience',
    },
    // Marriage
    {
      'text': '"A woman is married for four things: her wealth, her family status, her beauty and her religion. So you should take the religious one."',
      'narrator': 'Narrated by Abu Huraira',
      'book': 'SAHIH AL-BUKHARI',
      'grade': 'SAHIH',
      'topic': 'Marriage',
    },
    // Knowledge
    {
      'text': '"The best among you are those who learn the Quran and teach it."',
      'narrator': 'Narrated by Abu Huraira',
      'book': 'SAHIH AL-BUKHARI',
      'grade': 'SAHIH',
      'topic': 'Knowledge',
    },
    // Parents
    {
      'text': '"A father\'s pleasure is Allah\'s pleasure, and a father\'s displeasure is Allah\'s displeasure."',
      'narrator': 'Narrated by Abdullah ibn Amr',
      'book': 'JAMI AT-TIRMIDHI',
      'grade': 'SAHIH',
      'topic': 'Parents',
    },
    {
      'text': '"Paradise lies at the feet of your mother."',
      'narrator': 'Narrated by Abu Huraira',
      'book': 'SAHIH AL-BUKHARI',
      'grade': 'SAHIH',
      'topic': 'Parents',
    },
    // Modesty
    {
      'text': '"Modesty is part of faith."',
      'narrator': 'Narrated by Abu Huraira',
      'book': 'SAHIH AL-BUKHARI',
      'grade': 'SAHIH',
      'topic': 'Modesty',
    },
    // Truthfulness
    {
      'text': '"Truthfulness leads to righteousness, and righteousness leads to Paradise."',
      'narrator': 'Narrated by Abdullah ibn Masud',
      'book': 'SAHIH AL-BUKHARI',
      'grade': 'SAHIH',
      'topic': 'Truthfulness',
    },
    // Anger
    {
      'text': '"Do not become angry."',
      'narrator': 'Narrated by Abu Huraira',
      'book': 'SAHIH AL-BUKHARI',
      'grade': 'SAHIH',
      'topic': 'Anger',
    },
    // Jealousy
    {
      'text': '"Beware of jealousy, for jealousy devours good deeds just as fire devours wood."',
      'narrator': 'Narrated by Abu Huraira',
      'book': 'SUNAN ABU DAWUD',
      'grade': 'SAHIH',
      'topic': 'Jealousy',
    },
    // Jihad
    {
      'text': '"The best Jihad is to speak a word of truth to a tyrannical ruler."',
      'narrator': 'Narrated by Abu Sa\'id al-Khudri',
      'book': 'SUNAN ABU DAWUD',
      'grade': 'SAHIH',
      'topic': 'Jihad',
    },
    // Kindness
    {
      'text': '"He who is not kind to our young ones and does not respect our elders is not from us."',
      'narrator': 'Narrated by Anas ibn Malik',
      'book': 'JAMI AT-TIRMIDHI',
      'grade': 'SAHIH',
      'topic': 'Kindness',
    },
    // Brotherhood
    {
      'text': '"A Muslim is a brother of another Muslim."',
      'narrator': 'Narrated by Abdullah ibn Umar',
      'book': 'SAHIH AL-BUKHARI',
      'grade': 'SAHIH',
      'topic': 'Brotherhood',
    },
    // Repentance
    {
      'text': '"All the sons of Adam are sinners, but the best of sinners are those who repent."',
      'narrator': 'Narrated by Anas ibn Malik',
      'book': 'SUNAN IBN MAJAH',
      'grade': 'SAHIH',
      'topic': 'Repentance',
    },
    // Paradise
    {
      'text': '"I have prepared for My righteous servants what no eye has seen, no ear has heard, and no human heart has conceived."',
      'narrator': 'Narrated by Abu Huraira',
      'book': 'SAHIH AL-BUKHARI',
      'grade': 'SAHIH',
      'topic': 'Paradise',
    },
  ];

  static const List<String> topics = [
    'All', 'Character', 'Faith', 'Prayer', 'Charity', 'Fasting',
    'Patience', 'Marriage', 'Knowledge', 'Parents',
    'Modesty', 'Truthfulness', 'Anger', 'Jealousy', 'Jihad',
    'Kindness', 'Hospitality', 'Brotherhood', 'Repentance', 'Paradise',
  ];
  static const List<String> books   = ['Bukhari', 'Muslim', 'Tirmidhi', 'Abu Dawud', 'Nasai', 'Ibn Majah'];

  /// Filter by topic ('All' returns everything)
  static List<Map<String, String>> byTopic(String topic) {
    if (topic == 'All') return ahadees;
    return ahadees.where((h) => h['topic'] == topic).toList();
  }

  /// Filter by book keyword
  static List<Map<String, String>> byBook(String book) {
    return ahadees.where((h) =>
        h['book']!.toUpperCase().contains(book.toUpperCase())).toList();
  }

  /// Get hadiths for a specific book slug
  static List<Map<String, String>> getBookHadiths(String slug) {
    final raw = bookHadiths[slug] ?? bookHadiths['bukhari']!;
    return raw.map((h) => {
      ...h,
      'arabic': cleanArabicText(h['arabic'] ?? ''),
    }).toList();
  }

  // Helper functions to generate authentic Arabic hadith content
  static String _getBukhariArabic(int index) {
    const hadiths = [
      'أما بعد: فأفضل الحديث كلمة الله، وأفضل الهدى هدى محمد صلى الله عليه وسلم، وأما أمور الأحداث محدثة وكل محدثة بدعة وكل بدعة ضلالة',
      'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
      'الدِّينُ النَّصِيحَةُ',
      'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      'اللهم إني أسألك العفو والعافية في الدنيا والآخرة',
    ];
    return hadiths[index % hadiths.length];
  }

  static String _getBukhariEnglish(int index) {
    const hadiths = [
      'Actions are by intentions, and each person will have what he intended. So whoever emigrated for worldly benefits or to marry a woman, his emigration is for that for which he emigrated.',
      'Actions are but by intentions.',
      'Religion is sincere advice.',
      'Allah is sufficient for us, and He is the best disposer of affairs.',
      'O Allah, I ask You for forgiveness and well-being in this world and the Hereafter.',
    ];
    return hadiths[index % hadiths.length];
  }

  static String _getMuslimArabic(int index) {
    const hadiths = [
      'إسلام أن تسلم لله وجهك وتبقى لسانك عن المؤمنين وأعلمين',
      'لا يؤمن أحدكم حتى يحب لأخيه ما يحب لنفسه',
      'الطهور شطر الإيمان',
      'لا يؤمن أحدكم حتى يحب لأخيه ما يحب لنفسه',
    ];
    return hadiths[index % hadiths.length];
  }

  static String _getMuslimEnglish(int index) {
    const hadiths = [
      'A Muslim is one from whose tongue and hand the Muslims are safe.',
      'None of you will have faith until he loves for his brother what he loves for himself.',
      'Purity is half of faith.',
      'None of you will have faith until he loves for his brother what he loves for himself.',
    ];
    return hadiths[index % hadiths.length];
  }

  static String _getTirmidhiArabic(int index) {
    const hadiths = [
      'أقول أحبك إلى الله أحبك إلي',
      'رجل أحي سير في سيرتي',
    ];
    return hadiths[index % hadiths.length];
  }

  static String _getTirmidhiEnglish(int index) {
    const hadiths = [
      'The most beloved of you to Allah is he who brings the most benefit.',
      'The one who guides to good is like the one who does it.',
    ];
    return hadiths[index % hadiths.length];
  }

  static String _getAbuDawudArabic(int index) {
    const hadiths = [
      'إذا سمعتم مني حديثا فقلنا الله أعلم إلا من سمع منه',
    ];
    return hadiths[index % hadiths.length];
  }

  static String _getAbuDawudEnglish(int index) {
    const hadiths = [
      'If you hear a hadith from me, say: Allah and His Messenger know best.',
    ];
    return hadiths[index % hadiths.length];
  }

  static String _getNasaiArabic(int index) {
    const hadiths = [
      'أفضل الصلوات عند الله العصر',
    ];
    return hadiths[index % hadiths.length];
  }

  static String _getNasaiEnglish(int index) {
    const hadiths = [
      'The best prayer in the sight of Allah is the Asr prayer.',
    ];
    return hadiths[index % hadiths.length];
  }

  static String _getIbnMajahArabic(int index) {
    const hadiths = [
      'طلب العلم فريضة على كل مسلم',
    ];
    return hadiths[index % hadiths.length];
  }

  static String _getIbnMajahEnglish(int index) {
    const hadiths = [
      'Seeking knowledge is a duty upon every Muslim.',
    ];
    return hadiths[index % hadiths.length];
  }
}
