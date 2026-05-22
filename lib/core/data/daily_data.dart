// lib/core/data/daily_data.dart

class DailyData {
  static final List<Map<String, String>> ayahs = [
    {
      'arabic': 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
      'translation': '"So remember Me; I will remember you. And be grateful to Me and do not deny Me."',
      'reference': 'Al-Baqarah 2:152',
    },
    {
      'arabic': 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      'translation': '"For indeed, with hardship will be ease."',
      'reference': 'Ash-Sharh 94:6',
    },
    {
      'arabic': 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
      'translation': '"And whoever relies upon Allah — then He is sufficient for him."',
      'reference': 'At-Talaq 65:3',
    },
    {
      'arabic': 'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا',
      'translation': '"Our Lord, let not our hearts deviate after You have guided us."',
      'reference': 'Ali \'Imran 3:8',
    },
    {
      'arabic': 'وَقُل رَّبِّ زِدْنِي عِلْمًا',
      'translation': '"And say, \'My Lord, increase me in knowledge.\'"',
      'reference': 'Ta-Ha 20:114',
    },
    // ... adding more to reach a good number for demonstration
    {
      'arabic': 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
      'translation': '"Allah does not burden a soul beyond that it can bear."',
      'reference': 'Al-Baqarah 2:286',
    },
    {
      'arabic': 'وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ',
      'translation': '"And when My servants ask you concerning Me, indeed I am near."',
      'reference': 'Al-Baqarah 2:186',
    },
    {
      'arabic': 'إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
      'translation': '"Indeed, Allah is with the patient."',
      'reference': 'Al-Baqarah 2:153',
    },
    {
      'arabic': 'وَأَحْسِنُوا ۛ إِنَّ اللَّهَ يُحِبُّ الْمُحْسِنِينَ',
      'translation': '"And do good; indeed, Allah loves the doers of good."',
      'reference': 'Al-Baqarah 2:195',
    },
    {
      'arabic': 'قُلْ هُوَ اللَّهُ أَحَدٌ',
      'translation': '"Say, \'He is Allah, [who is] One.\'"',
      'reference': 'Al-Ikhlas 112:1',
    },
    // 100 placeholder entries to ensure daily change logic works
    ...List.generate(90, (index) => {
      'arabic': 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      'translation': '"[All] praise is [due] to Allah, Lord of the worlds."',
      'reference': 'Al-Fatiha 1:${index + 1}',
    }),
  ];

  static final List<Map<String, String>> hadiths = [
    {
      'arabic': 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
      'translation': '"Actions are but by intentions."',
      'reference': 'Sahih Bukhari',
    },
    {
      'arabic': 'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
      'translation': '"The best of you are those who learn the Quran and teach it."',
      'reference': 'Sahih Bukhari',
    },
    {
      'arabic': 'الدِّينُ النَّصِيحَةُ',
      'translation': '"Religion is sincere advice."',
      'reference': 'Sahih Muslim',
    },
    {
      'arabic': 'لاَ يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
      'translation': '"None of you will have faith until he loves for his brother what he loves for himself."',
      'reference': 'Sahih Bukhari',
    },
    {
      'arabic': 'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ',
      'translation': '"Whoever believes in Allah and the Last Day, let him speak good or remain silent."',
      'reference': 'Sahih Bukhari',
    },
    // 100 placeholder entries
    ...List.generate(95, (index) => {
      'arabic': 'الطَّهُورُ شَطْرُ الإِيمَانِ',
      'translation': '"Purity is half of faith."',
      'reference': 'Sahih Muslim ${index + 1}',
    }),
  ];

  static List<Map<String, String>> getDailyAyahs(int count) {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    List<Map<String, String>> result = [];
    for (int i = 0; i < count; i++) {
      final index = (dayOfYear + i) % ayahs.length;
      result.add(ayahs[index]);
    }
    return result;
  }

  static List<Map<String, String>> getDailyHadiths(int count) {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    List<Map<String, String>> result = [];
    for (int i = 0; i < count; i++) {
      final index = (dayOfYear + i + 5) % hadiths.length;
      result.add(hadiths[index]);
    }
    return result;
  }
}
