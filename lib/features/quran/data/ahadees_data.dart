// lib/features/quran/data/ahadees_data.dart

class AhadeesData {
  AhadeesData._();

  static final List<Map<String, String>> ahadees = [
    ...List.generate(25, (index) => {
      'text':     '"Whoever believes in Allah and the Last Day should speak a good word or remain silent. (${index + 1})"',
      'narrator': 'Narrated by Abu Huraira',
      'book':     'SAHIH BUKHARI',
      'grade':    'SAHIH',
      'topic':    'Character',
    }),
    ...List.generate(25, (index) => {
      'text':     '"Purity is half of faith. (${index + 1})"',
      'narrator': 'Narrated by Abu Malik al-Ashari',
      'book':     'SAHIH MUSLIM',
      'grade':    'SAHIH',
      'topic':    'Faith',
    }),
    ...List.generate(25, (index) => {
      'text':     '"Pray as you have seen me praying. (${index + 1})"',
      'narrator': 'Narrated by Malik ibn al-Huwairith',
      'book':     'SAHIH BUKHARI',
      'grade':    'SAHIH',
      'topic':    'Prayer',
    }),
    ...List.generate(25, (index) => {
      'text':     '"The best charity is that given to a relative who does not like you. (${index + 1})"',
      'narrator': 'Narrated by Abu Ayyub al-Ansari',
      'book':     'TIRMIDHI',
      'grade':    'SAHIH',
      'topic':    'Charity',
    }),
    ...List.generate(25, (index) => {
      'text':     '"Fasting is a shield. (${index + 1})"',
      'narrator': 'Narrated by Abu Huraira',
      'book':     'SAHIH BUKHARI',
      'grade':    'SAHIH',
      'topic':    'Fasting',
    }),
    ...List.generate(25, (index) => {
      'text':     '"The strong man is not the one who can wrestle, but the one who can control himself in a fit of anger. (${index + 1})"',
      'narrator': 'Narrated by Abu Huraira',
      'book':     'SAHIH BUKHARI',
      'grade':    'SAHIH',
      'topic':    'Patience',
    }),
    ...List.generate(25, (index) => {
      'text':     '"A woman is married for four things: her wealth, her family status, her beauty and her religion. So you should take the religious one. (${index + 1})"',
      'narrator': 'Narrated by Abu Huraira',
      'book':     'SAHIH BUKHARI',
      'grade':    'SAHIH',
      'topic':    'Marriage',
    }),
    ...List.generate(25, (index) => {
      'text':     '"Seeking knowledge is a duty upon every Muslim. (${index + 1})"',
      'narrator': 'Narrated by Anas ibn Malik',
      'book':     'IBN MAJAH',
      'grade':    'SAHIH',
      'topic':    'Knowledge',
    }),
    ...List.generate(25, (index) => {
      'text':     '"A father\'s pleasure is Allah\'s pleasure, and a father\'s displeasure is Allah\'s displeasure. (${index + 1})"',
      'narrator': 'Narrated by Abdullah ibn Amr',
      'book':     'TIRMIDHI',
      'grade':    'SAHIH',
      'topic':    'Parents',
    }),
    ...List.generate(25, (index) => {
      'text':     '"Modesty is part of faith. (${index + 1})"',
      'narrator': 'Narrated by Abu Huraira',
      'book':     'SAHIH BUKHARI',
      'grade':    'SAHIH',
      'topic':    'Modesty',
    }),
    ...List.generate(25, (index) => {
      'text':     '"Truthfulness leads to righteousness, and righteousness leads to Paradise. (${index + 1})"',
      'narrator': 'Narrated by Abdullah ibn Mas\'ud',
      'book':     'SAHIH BUKHARI',
      'grade':    'SAHIH',
      'topic':    'Truthfulness',
    }),
    ...List.generate(25, (index) => {
      'text':     '"Do not become angry. (${index + 1})"',
      'narrator': 'Narrated by Abu Huraira',
      'book':     'SAHIH BUKHARI',
      'grade':    'SAHIH',
      'topic':    'Anger',
    }),
    ...List.generate(25, (index) => {
      'text':     '"Beware of jealousy, for jealousy devours good deeds just as fire devours wood. (${index + 1})"',
      'narrator': 'Narrated by Abu Huraira',
      'book':     'ABU DAWUD',
      'grade':    'SAHIH',
      'topic':    'Jealousy',
    }),
    ...List.generate(25, (index) => {
      'text':     '"The best Jihad is to speak a word of truth to a tyrannical ruler. (${index + 1})"',
      'narrator': 'Narrated by Abu Sa\'id al-Khudri',
      'book':     'ABU DAWUD',
      'grade':    'SAHIH',
      'topic':    'Jihad',
    }),
    ...List.generate(25, (index) => {
      'text':     '"He who is not kind to our young ones and does not respect our elders is not from us. (${index + 1})"',
      'narrator': 'Narrated by Anas ibn Malik',
      'book':     'TIRMIDHI',
      'grade':    'SAHIH',
      'topic':    'Kindness',
    }),
    ...List.generate(25, (index) => {
      'text':     '"Whoever believes in Allah and the Last Day should be hospitable to his guest. (${index + 1})"',
      'narrator': 'Narrated by Abu Shuraih al-Ka\'bi',
      'book':     'SAHIH BUKHARI',
      'grade':    'SAHIH',
      'topic':    'Hospitality',
    }),
    ...List.generate(25, (index) => {
      'text':     '"A Muslim is a brother of another Muslim. (${index + 1})"',
      'narrator': 'Narrated by Abdullah ibn Umar',
      'book':     'SAHIH BUKHARI',
      'grade':    'SAHIH',
      'topic':    'Brotherhood',
    }),
    ...List.generate(25, (index) => {
      'text':     '"All the sons of Adam are sinners, but the best of sinners are those who repent. (${index + 1})"',
      'narrator': 'Narrated by Anas ibn Malik',
      'book':     'IBN MAJAH',
      'grade':    'SAHIH',
      'topic':    'Repentance',
    }),
    ...List.generate(25, (index) => {
      'text':     '"I have prepared for My righteous servants what no eye has seen, no ear has heard, and no human heart has conceived. (${index + 1})"',
      'narrator': 'Narrated by Abu Huraira',
      'book':     'SAHIH BUKHARI',
      'grade':    'SAHIH',
      'topic':    'Paradise',
    }),
  ];

  static const List<String> topics = [
    'All', 'Character', 'Faith', 'Prayer', 'Charity', 'Fasting',
    'Patience', 'Marriage', 'Knowledge', 'Parents',
    'Modesty', 'Truthfulness', 'Anger', 'Jealousy', 'Jihad',
    'Kindness', 'Hospitality', 'Brotherhood', 'Repentance', 'Paradise',
  ];
  static const List<String> books   = ['Bukhari', 'Muslim', 'Tirmidhi', 'Abu Dawud'];

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
}
