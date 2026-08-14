// lib/core/data/daily_data.dart

import 'dart:math';
import '../../features/quran/data/quran_api_service.dart';

class DailyData {
  static final List<Map<String, String>> ayahs = [
    {
      'arabic': 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
      'translation':
          '"So remember Me; I will remember you. And be grateful to Me and do not deny Me."',
      'reference': 'Al-Baqarah 2:152',
    },
    {
      'arabic': 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      'translation': '"For indeed, with hardship will be ease."',
      'reference': 'Ash-Sharh 94:6',
    },
    {
      'arabic': 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
      'translation':
          '"And whoever relies upon Allah — then He is sufficient for him."',
      'reference': 'At-Talaq 65:3',
    },
    {
      'arabic': 'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا',
      'translation':
          '"Our Lord, let not our hearts deviate after You have guided us."',
      'reference': 'Ali \'Imran 3:8',
    },
    {
      'arabic': 'وَقُل رَّبِّ زِدْنِي عِلْمًا',
      'translation': '"And say, \'My Lord, increase me in knowledge.\'"',
      'reference': 'Ta-Ha 20:114',
    },
    {
      'arabic': 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
      'translation': '"Allah does not burden a soul beyond that it can bear."',
      'reference': 'Al-Baqarah 2:286',
    },
    {
      'arabic': 'وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ',
      'translation':
          '"And when My servants ask you concerning Me, indeed I am near."',
      'reference': 'Al-Baqarah 2:186',
    },
    {
      'arabic': 'إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
      'translation': '"Indeed, Allah is with the patient."',
      'reference': 'Al-Baqarah 2:153',
    },
    {
      'arabic': 'وَأَحْسِنُوا ۖ إِنَّ اللَّهَ يُحِبُّ الْمُحْسِنِينَ',
      'translation': '"And do good; indeed, Allah loves the doers of good."',
      'reference': 'Al-Baqarah 2:195',
    },
    {
      'arabic': 'قُلْ هُوَ ٱللَّهُ أَحَدٌ',
      'translation': '"Say, \'He is Allah, [who is] One.\'"',
      'reference': 'Al-Ikhlas 112:1',
    },
    {
      'arabic':
          'وَلَا تَهِنُوا وَلَا تَحْزَنُوا وَأَنتُمُ الْأَعْلَوْنَ إِن كُنتُم مُّؤْمِنِينَ',
      'translation':
          '"So do not weaken and do not grieve, and you will be superior if you are believers."',
      'reference': 'Ali \'Imran 3:139',
    },
    {
      'arabic': 'وَلَا تَقُولُوا لِشَيْءٍ أَنِّي فَاعِلٌ ذَلِكَ غَدًا',
      'translation':
          '"And never say of anything, \'I shall do that tomorrow.\'"',
      'reference': 'Al-Kahf 18:23',
    },
    {
      'arabic':
          'يَٰٓأَيُّهَا ٱلنَّاسُ إِنَّا خَلَقْنَاكُم مِّن ذَكَرٍ وَأُنثَىٰ وَجَعَلْنَاكُمْ شُعُوبًا وَقَبَائِلَ لِتَعَارَفُوٓا۟',
      'translation':
          '"O mankind, indeed We have created you from male and female and made you peoples and tribes that you may know one another."',
      'reference': 'Al-Hujurat 49:13',
    },
    {
      'arabic':
          'وَلَا تَقْتُلُوا أَنفُسَكُمْ ۚ إِنَّ اللَّهَ كَانَ بِكُمْ رَحِيمًا',
      'translation':
          '"And do not kill yourselves; surely Allah is Merciful to you."',
      'reference': 'An-Nisa 4:29',
    },
    {
      'arabic': 'إِنَّ اللَّهَ يُحِبُّ الْمُتَوَكِّلِينَ',
      'translation': '"Indeed, Allah loves those who rely upon Him."',
      'reference': 'Ali \'Imran 3:159',
    },
    {
      'arabic': 'وَٱتَّقُوا ٱللَّهَ وَيُعَلِّمُكُمُ ٱللَّهُ',
      'translation': '"And fear Allah, and Allah will teach you."',
      'reference': 'Al-Baqarah 2:239',
    },
    {
      'arabic': 'فَاذْكُرُوا ذِكْرَىٰ شَهِيدًا وَغَائِبًا',
      'translation':
          '"So remember Allah, whether standing, sitting, or lying down."',
      'reference': 'An-Nisa 4:103',
    },
    {
      'arabic': 'وَسَبِّحْ بِحَمْدِ رَبِّكَ وَٱسْتَغْفِرْهُ',
      'translation':
          '"And glorify the praises of your Lord and seek forgiveness of Him."',
      'reference': 'An-Nasr 110:3',
    },
    {
      'arabic': 'إِنَّمَا ٱلْأَمْرُ كُلُّهُ لِلَّهِ',
      'translation': '"Indeed, the command belongs entirely to Allah."',
      'reference': 'Yunus 10:3',
    },
    {
      'arabic': 'وَٱللَّهُ أَحْسَنُ ٱلْحَافِظِينَ',
      'translation': '"And Allah is the best of guardians."',
      'reference': 'Yusuf 12:64',
    },
    {
      'arabic':
          'إِنَّ اللَّهَ يُحِبُّ ٱلتَّوَّابِينَ وَيُحِبُّ ٱلْمُتَطَهِّرِينَ',
      'translation':
          '"Indeed, Allah loves those who repent and those who purify themselves."',
      'reference': 'Al-Baqarah 2:222',
    },
    {
      'arabic': 'رَبِّ اغْفِرْ وَارْحَمْ وَأَنتَ خَيْرُ ٱلرَّاحِمِينَ',
      'translation':
          '"My Lord, forgive and have mercy, and You are the best of the merciful."',
      'reference': 'Al-Mu\'minun 23:118',
    },
    {
      'arabic': 'إِنَّ اللَّهَ يُحِبُّ ٱلْمُقْسِطِينَ',
      'translation': '"Indeed, Allah loves the just."',
      'reference': 'Al-Ma\'idah 5:42',
    },
    {
      'arabic': 'إِنَّ اللَّهَ يُغْفِرُ ٱلذُّنُوبَ جَمِيعًا',
      'translation': '"Indeed, Allah forgives all sins."',
      'reference': 'Az-Zumar 39:53',
    },
    {
      'arabic': 'وَٱتَّخِذُوا مِن مَّقَامِ إِبْرَاهِيمَ مُصَلًّى',
      'translation':
          '"And take from the standing place of Abraham a place of prayer."',
      'reference': 'Al-Baqarah 2:125',
    },
    {
      'arabic':
          'إِنَّ ٱلصَّلَاةَ كَانَتْ عَلَى ٱلْمُؤْمِنِينَ كِتَابًا مَّوْقُوتًا',
      'translation':
          '"Indeed, prayer has been decreed upon the believers a decree of specified times."',
      'reference': 'An-Nisa 4:103',
    },
    {
      'arabic': 'ٱللَّهُ نُورُ ٱلسَّمَاوَاتِ وَٱلْأَرْضِ',
      'translation': '"Allah is the Light of the heavens and the earth."',
      'reference': 'An-Nur 24:35',
    },
    {
      'arabic': 'وَمَن يُحْسِنْ أَحْسَنْ لِنَفْسِهِ وَمَن يُسِئْ فَعَلَيْهَا',
      'translation':
          '"And whoever does good, it is for himself; and whoever does evil, it is against himself."',
      'reference': 'An-Nisa 4:131',
    },
    {
      'arabic':
          'وَلَا تَحْسَبَنَّ ٱللَّهَ غَافِلًا عَمَّا يَعْمَلُ ٱلظَّٰلِمُونَ',
      'translation':
          '"And never think that Allah is unaware of what the wrongdoers do."',
      'reference': 'Ibrahim 14:42',
    },
  ];

  static final List<Map<String, String>> hadiths = [
    {
      'arabic': 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
      'translation': '"Actions are but by intentions."',
      'reference': 'Sahih Bukhari',
    },
    {
      'arabic': 'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
      'translation':
          '"The best of you are those who learn the Quran and teach it."',
      'reference': 'Sahih Bukhari',
    },
    {
      'arabic': 'الدِّينُ النَّصِيحَةُ',
      'translation': '"Religion is sincere advice."',
      'reference': 'Sahih Muslim',
    },
    {
      'arabic':
          'لاَ يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
      'translation':
          '"None of you will have faith until he loves for his brother what he loves for himself."',
      'reference': 'Sahih Bukhari',
    },
    {
      'arabic':
          'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ',
      'translation':
          '"Whoever believes in Allah and the Last Day, let him speak good or remain silent."',
      'reference': 'Sahih Bukhari',
    },
    {
      'arabic': 'الطَّهُورُ شَطْرُ الإِيمَانِ',
      'translation': '"Purity is half of faith."',
      'reference': 'Sahih Muslim',
    },
    {
      'arabic':
          'مَنْ سَلَكَ طَرِيقًا يَطْلُبُ فِيهِ عِلْمًا سَلَّكَ اللَّهُ طَرِيقًا مِنْ طُرُقِ الجَنَّةِ',
      'translation':
          '"Whoever travels a path seeking knowledge, Allah will make easy for him a path to Paradise."',
      'reference': 'Sunan Ibn Majah',
    },
    {
      'arabic': 'الْمُسْلِمُ مَنْ يَسْلَمُ النَّاسُ مِنْ لِسَانِهِ وَيَدِهِ',
      'translation':
          '"A Muslim is one from whose tongue and hand the people are safe."',
      'reference': 'Sahih Bukhari',
    },
    {
      'arabic':
          'مَنْ يَصُنْ مُؤْمِنًا يَصُنْهُ اللَّهُ مِنْ شَرِّ الدُّنْيَا وَالْآخِرَةِ',
      'translation':
          '"Whoever defends a Muslim, Allah will defend him from the evil of this world and the Hereafter."',
      'reference': 'Sunan Ibn Majah',
    },
    {
      'arabic':
          'إِنَّمَا الرِّزْقُ مِنْ سَمَاءٍ وَإِنَّمَا الْعِلْمُ مِنْ تَحْتِ الرِّسَالَةِ',
      'translation':
          '"Indeed, sustenance is from the heaven, and knowledge is from beneath the message."',
      'reference': 'Sunan Ibn Majah',
    },
    {
      'arabic': 'مَنْ يُؤْتَ الْحِكْمَةَ فَقَدْ أُوتِيَ خَيْرًا كَثِيرًا',
      'translation': '"Whoever is given wisdom has been given much good."',
      'reference': 'Sahih Bukhari',
    },
    {
      'arabic':
          'الْحِكْمَةُ ضَالَّةُ الْمُؤْمِنِ فَحَيْثُ وَجَدَهَا فَهُوَ أَحَقُّ بِهَا',
      'translation':
          '"Wisdom is the lost property of the believer; wherever he finds it, he has more right to it."',
      'reference': 'Sunan Ibn Majah',
    },
    {
      'arabic':
          'مَنْ يَصْنَعْ عَمَلًا صَالِحًا يَجِدْ ثَوَابَهُ فِي الدُّنْيَا وَالْآخِرَةِ',
      'translation':
          '"Whoever does a righteous deed will find its reward in this world and the Hereafter."',
      'reference': 'Sahih Bukhari',
    },
    {
      'arabic':
          'إِنَّ اللَّهَ يُحِبُّ أَنْ يُرَىٰ آثَارُ نِعْمَتِهِ عَلَى عَبْدِهِ',
      'translation':
          '"Indeed, Allah loves to see the effects of His blessings upon His servant."',
      'reference': 'Sunan Ibn Majah',
    },
    {
      'arabic': 'مَنْ تَوَضَّأَ حَسَنًا كَانَتْ صَلاتُهُ بُرْهَانًا لَهُ',
      'translation':
          '"Whoever performs ablution well, his prayer will be a proof for him."',
      'reference': 'Sunan Ibn Majah',
    },
    {
      'arabic': 'الْقُرْآنُ يَشْفَعُ لِصَاحِبِهِ يَوْمَ الْقِيَامَةِ',
      'translation':
          '"The Quran will intercede for its companion on the Day of Resurrection."',
      'reference': 'Sahih Muslim',
    },
    {
      'arabic': 'مَنْ يَقْرَأُ الْقُرْآنَ وَيَحْفَظُهُ يُحْشَرُ مَعَ الرُّسُلِ',
      'translation':
          '"Whoever recites the Quran and memorizes it will be resurrected with the messengers."',
      'reference': 'Sahih Bukhari',
    },
    {
      'arabic':
          'إِنَّ لِلَّهِ مَلَائِكَةً يَتَحَوَّلُونَ فِي الطَّرِيقِ يَلْتَمِسُونَ مَجَالِسَ الذِّكْرِ',
      'translation':
          '"Indeed, Allah has angels who travel the roads seeking the circles of remembrance."',
      'reference': 'Sahih Bukhari',
    },
    {
      'arabic': 'مَنْ يَذْكُرُ اللَّهَ وَحْدَهُ يَحْفَظُهُ أَرْبَعُونَ مَلَكًا',
      'translation':
          '"Whoever remembers Allah alone will be guarded by forty angels."',
      'reference': 'Sunan Ibn Majah',
    },
    {
      'arabic':
          'الصَّوَابِقُ الصَّوَابِقُ مَنْ تَقَرَّبَ إِلَى اللَّهِ شَيْئًا تَقَرَّبَ اللَّهُ إِلَيْهِ ذِرَاعًا',
      'translation':
          '"The forerunners, the forerunners - whoever draws near to Allah a little, Allah will draw near to him an arm\'s length."',
      'reference': 'Sahih Bukhari',
    },
    {
      'arabic': 'إِنَّ اللَّهَ يُحِبُّ الْمُحِبِّينَ لِلَّهِ',
      'translation':
          '"Indeed, Allah loves those who love for the sake of Allah."',
      'reference': 'Sunan Ibn Majah',
    },
    {
      'arabic':
          'مَنْ يَصُنْ عِصْمَتَهُ يَصُنْهُ اللَّهُ مِنْ شَرِّ كُلِّ شَيْءٍ',
      'translation':
          '"Whoever guards his chastity, Allah will guard him from the evil of everything."',
      'reference': 'Sunan Ibn Majah',
    },
    {
      'arabic': 'الْجَنَّةُ فِي ظِلِّ أَسْوَاقِ الْعِلْمِ',
      'translation': '"Paradise is in the shade of the paths of knowledge."',
      'reference': 'Sunan Ibn Majah',
    },
    {
      'arabic': 'مَنْ يُرِدْ اللَّهُ بِهِ خَيْرًا يُفَقِّهْهُ فِي الدِّينِ',
      'translation':
          '"Whoever Allah intends good for, He makes him understand the religion."',
      'reference': 'Sahih Bukhari',
    },
    {
      'arabic': 'إِنَّ الْعِلْمَ يُؤْتَىٰ عَلَىٰ مَنْ يَسْتَحْقُّهُ',
      'translation': '"Indeed, knowledge is given to whoever deserves it."',
      'reference': 'Sunan Ibn Majah',
    },
    {
      'arabic': 'الْمُؤْمِنُ شَجَاعٌ وَلَا يَخَافُ شَيْئًا إِلَّا اللَّهَ',
      'translation': '"The believer is brave and fears nothing except Allah."',
      'reference': 'Sunan Ibn Majah',
    },
    {
      'arabic':
          'مَنْ يَتَوَضَّأَ وَقْتَ الصَّلَاةِ تَحْتَهُ مَلَكٌ يَصِلُ لَهُ أَثَرَهُ',
      'translation':
          '"Whoever performs ablution at the time of prayer has an angel beneath him who follows his steps."',
      'reference': 'Sunan Ibn Majah',
    },
    {
      'arabic': 'إِنَّمَا الْحَسَنَاتُ تُحْذَفُ بِالْحَسَنَاتِ',
      'translation': '"Indeed, good deeds are erased by good deeds."',
      'reference': 'Sahih Muslim',
    },
    {
      'arabic': 'الصَّلَاةُ نُورٌ وَالزَّكَاةُ بُرْهَانٌ وَالصِّيَامُ جُنَّةٌ',
      'translation':
          '"Prayer is light, zakah is a proof, and fasting is a shield."',
      'reference': 'Sunan Ibn Majah',
    },
    {
      'arabic': 'مَنْ يُؤْتَ الْحِكْمَةَ يُؤْتَ خَيْرًا كَثِيرًا',
      'translation': '"Whoever is given wisdom has been given much good."',
      'reference': 'Sahih Bukhari',
    },
  ];

  static int _generateSeed(DateTime date, String salt) {
    return date.year * 10000 + date.month * 100 + date.day + salt.hashCode;
  }

  static List<Map<String, String>> getDailyAyahs(int count) {
    final now = DateTime.now();
    final seed = _generateSeed(now, 'ayahs');
    final shuffled = List<Map<String, String>>.from(ayahs)
      ..shuffle(_SeededRandom(seed));
    return shuffled.take(count).map((ayah) {
      return {...ayah, 'arabic': cleanArabicText(ayah['arabic'] ?? '')};
    }).toList();
  }

  static final List<Map<String, String>> duas = [
    {
      'arabic':
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى وَالتُّقَى وَالْعَفَافَ وَالْغِنَى',
      'translation':
          '"O Allah, I ask You for guidance, piety, chastity, and self-sufficiency."',
      'reference': 'Sahih Muslim',
    },
    {
      'arabic':
          'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      'translation':
          '"Our Lord, give us good in this world and good in the Hereafter, and protect us from the punishment of the Fire."',
      'reference': 'Al-Baqarah 2:201',
    },
    {
      'arabic':
          'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ، وَالْجُبْنِ وَالْبُخْلِ',
      'translation':
          '"O Allah, I seek refuge in You from anxiety and sorrow, weakness and laziness, cowardice and miserliness."',
      'reference': 'Sahih Bukhari',
    },
    {
      'arabic': 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ',
      'translation': '"O Ever-Living, O Self-Sustaining, by Your mercy I seek help."',
      'reference': 'Sunan Abu Dawud',
    },
    {
      'arabic': 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
      'translation': '"My Lord, expand for me my chest and ease for me my task."',
      'reference': 'Ta-Ha 20:25-26',
    },
    {
      'arabic': 'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
      'translation':
          '"O Allah, You are Forgiving and love forgiveness, so forgive me."',
      'reference': 'Sunan Ibn Majah',
    },
    {
      'arabic':
          'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
      'translation':
          '"Allah is sufficient for me; there is no deity except Him. Upon Him I rely, and He is the Lord of the Great Throne."',
      'reference': 'At-Tawbah 9:129',
    },
    {
      'arabic': 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ',
      'translation':
          '"O Allah, send prayers upon Muhammad and upon the family of Muhammad."',
      'reference': 'Sahih Bukhari',
    },
    {
      'arabic': 'رَبِّ زِدْنِي عِلْمًا',
      'translation': '"My Lord, increase me in knowledge."',
      'reference': 'Ta-Ha 20:114',
    },
    {
      'arabic': 'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
      'translation':
          '"O Allah, help me to remember You, to thank You, and to worship You excellently."',
      'reference': 'Sunan Abu Dawud',
    },
  ];

  static Map<String, String> getDailyDua() {
    final now = DateTime.now();
    final seed = _generateSeed(now, 'dua');
    final shuffled = List<Map<String, String>>.from(duas)
      ..shuffle(_SeededRandom(seed));
    final dua = shuffled.first;
    return {...dua, 'arabic': cleanArabicText(dua['arabic'] ?? '')};
  }

  static List<Map<String, String>> getDailyHadiths(int count) {
    final now = DateTime.now();
    final seed = _generateSeed(now, 'hadiths');
    final shuffled = List<Map<String, String>>.from(hadiths)
      ..shuffle(_SeededRandom(seed));
    return shuffled.take(count).map((hadith) {
      return {...hadith, 'arabic': cleanArabicText(hadith['arabic'] ?? '')};
    }).toList();
  }
}

class _SeededRandom implements Random {
  int _seed;

  _SeededRandom(int seed) : _seed = seed.abs() & 0xFFFFFFFF;

  @override
  int nextInt(int max) {
    if (max <= 0) {
      return 0;
    }
    _seed = (_seed * 1103515245 + 12345) & 0xFFFFFFFF;
    return (_seed >> 16) % max;
  }

  @override
  double nextDouble() {
    return nextInt(0x7FFFFFFF) / 0x7FFFFFFF;
  }

  @override
  bool nextBool() {
    return nextInt(2) == 1;
  }
}
