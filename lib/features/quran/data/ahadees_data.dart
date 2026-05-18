// lib/features/quran/data/ahadees_data.dart

class AhadeesData {
  AhadeesData._();

  static const List<Map<String, String>> ahadees = [
    {
      'text':     '"Whoever believes in Allah and the Last Day should speak a good word or remain silent."',
      'narrator': 'Narrated by Abu Huraira',
      'book':     'SAHIH BUKHARI',
      'grade':    'SAHIH',
      'topic':    'Character',
    },
    {
      'text':     '"The most perfect believer in faith is the one who is best in moral character."',
      'narrator': 'Narrated by Aisha (R.A)',
      'book':     'SUNAN TIRMIDHI',
      'grade':    'HASAN',
      'topic':    'Faith',
    },
    {
      'text':     '"Purity is half of faith, and Al-hamdu lillah fills the scale."',
      'narrator': 'Narrated by Abu Malik al-Ash\'ari',
      'book':     'SAHIH MUSLIM',
      'grade':    'SAHIH',
      'topic':    'Prayer',
    },
    {
      'text':     '"The best among you are those who have the best manners and character."',
      'narrator': 'Narrated by Abdullah ibn Amr',
      'book':     'SAHIH BUKHARI',
      'grade':    'SAHIH',
      'topic':    'Character',
    },
    {
      'text':     '"None of you will have faith till he wishes for his Muslim brother what he likes for himself."',
      'narrator': 'Narrated by Anas',
      'book':     'SAHIH BUKHARI',
      'grade':    'SAHIH',
      'topic':    'Faith',
    },
    {
      'text':     '"Make things easy and do not make them difficult, cheer the people up by conveying glad tidings to them and do not repulse them."',
      'narrator': 'Narrated by Anas ibn Malik',
      'book':     'SAHIH BUKHARI',
      'grade':    'SAHIH',
      'topic':    'Character',
    },
    {
      'text':     '"The strong man is not the one who wrestles, but the strong man is in fact the one who controls himself in a fit of rage."',
      'narrator': 'Narrated by Abu Huraira',
      'book':     'SAHIH BUKHARI',
      'grade':    'SAHIH',
      'topic':    'Character',
    },
    {
      'text':     '"Pray as you have seen me praying."',
      'narrator': 'Narrated by Malik ibn al-Huwairith',
      'book':     'SAHIH BUKHARI',
      'grade':    'SAHIH',
      'topic':    'Prayer',
    },
    {
      'text':     '"The best of you are those who learn the Quran and teach it."',
      'narrator': 'Narrated by Uthman ibn Affan',
      'book':     'SAHIH BUKHARI',
      'grade':    'SAHIH',
      'topic':    'Faith',
    },
    {
      'text':     '"Seek knowledge from the cradle to the grave."',
      'narrator': 'Narrated by Anas ibn Malik',
      'book':     'SUNAN IBN MAJAH',
      'grade':    'HASAN',
      'topic':    'Faith',
    },
    {
      'text':     '"Feed the hungry, visit the sick, and set free the captives."',
      'narrator': 'Narrated by Abu Musa al-Ashari',
      'book':     'SAHIH BUKHARI',
      'grade':    'SAHIH',
      'topic':    'Character',
    },
    {
      'text':     '"The world is a prison for the believer and a paradise for the disbeliever."',
      'narrator': 'Narrated by Abu Huraira',
      'book':     'SAHIH MUSLIM',
      'grade':    'SAHIH',
      'topic':    'Faith',
    },
  ];

  static const List<String> topics  = ['All', 'Faith', 'Prayer', 'Character'];
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