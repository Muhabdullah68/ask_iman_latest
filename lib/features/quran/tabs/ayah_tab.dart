// lib/features/quran/tabs/ayah_tab.dart
// ─────────────────────────────────────────────────────────────────────────────
// AYAAT TAB — Topic-based curated Quran ayahs
// Topics: Mercy, Patience, Tawbah, Forgiveness, Gratitude, Hope, Prayer, Death
// Each ayah: Arabic + Sahih International translation + Surah reference
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AyahTab extends StatefulWidget {
  final String searchQuery;
  const AyahTab({super.key, this.searchQuery = ''});
  @override State<AyahTab> createState() => _AyahTabState();
}

class _AyahTabState extends State<AyahTab> {
  int _topicIndex = 0;

  static const _topics = [
    'Mercy', 'Patience', 'Tawbah', 'Forgiveness', 'Gratitude', 'Hope', 'Prayer', 'Death',
  ];

  static const Map<String, List<Map<String, String>>> _ayahs = {
    'Mercy': [
      {'ref':'SURAH AR-RAHMAN 55:13',
        'a':'فَبِأَيِّ آلَاءِ رَبِّكُمَا تُكَذِّبَانِ',
        't':'"So which of the favors of your Lord would you deny?"'},
      {'ref':'SURAH AL-ANBIYA 21:107',
        'a':'وَمَا أَرْسَلْنَاكَ إِلَّا رَحْمَةً لِّلْعَالَمِينَ',
        't':'"And We have not sent you, [O Muhammad], except as a mercy to the worlds."'},
      {'ref':'SURAH AL-ARAF 7:156',
        'a':'وَرَحْمَتِي وَسِعَتْ كُلَّ شَيْءٍ',
        't':'"My mercy encompasses all things."'},
      {'ref':'SURAH AZ-ZUMAR 39:53',
        'a':'لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ ۚ إِنَّ اللَّهَ يَغْفِرُ الذُّنُوبَ جَمِيعًا',
        't':'"Do not despair of the mercy of Allah. Indeed, Allah forgives all sins."'},
    ],
    'Patience': [
      {'ref':'SURAH ASH-SHARH 94:5-6',
        'a':'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ۝ إِنَّ مَعَ الْعُسْرِ يُسْرًا',
        't':'"For indeed, with hardship [will be] ease. Indeed, with hardship [will be] ease."'},
      {'ref':'SURAH AL-BAQARAH 2:286',
        'a':'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
        't':'"Allah does not charge a soul except [with that within] its capacity."'},
      {'ref':'SURAH AZ-ZUMAR 39:10',
        'a':'إِنَّمَا يُوَفَّى الصَّابِرُونَ أَجْرَهُم بِغَيْرِ حِسَابٍ',
        't':'"Indeed, the patient will be given their reward without account."'},
      {'ref':'SURAH AL-BAQARAH 2:153',
        'a':'يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ',
        't':'"O you who have believed, seek help through patience and prayer."'},
      {'ref':'SURAH AL-BAQARAH 2:155-157',
        'a':'وَبَشِّرِ الصَّابِرِينَ ۝ الَّذِينَ إِذَا أَصَابَتْهُم مُّصِيبَةٌ قَالُوا إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ',
        't':'"And give good tidings to the patient — Who, when disaster strikes them, say, Indeed we belong to Allah, and indeed to Him we will return."'},
    ],
    'Tawbah': [
      {'ref':'SURAH AZ-ZUMAR 39:53',
        'a':'قُلْ يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا عَلَىٰ أَنفُسِهِمْ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ',
        't':'"Say, O My servants who have exceeded against themselves – do not despair of the mercy of Allah."'},
      {'ref':'SURAH AL-BAQARAH 2:222',
        'a':'إِنَّ اللَّهَ يُحِبُّ التَّوَّابِينَ وَيُحِبُّ الْمُتَطَهِّرِينَ',
        't':'"Indeed, Allah loves those who are constantly repentant and loves those who purify themselves."'},
      {'ref':'SURAH HOUD 11:90',
        'a':'وَاسْتَغْفِرُوا رَبَّكُمْ ثُمَّ تُوبُوا إِلَيْهِ ۚ إِنَّ رَبِّي رَحِيمٌ وَدُودٌ',
        't':'"And ask forgiveness of your Lord and then repent to Him. Indeed, my Lord is Merciful and Affectionate."'},
      {'ref':'SURAH AN-NISA 4:110',
        'a':'وَمَن يَعْمَلْ سُوءًا أَوْ يَظْلِمْ نَفْسَهُ ثُمَّ يَسْتَغْفِرِ اللَّهَ يَجِدِ اللَّهَ غَفُورًا رَّحِيمًا',
        't':'"And whoever does a wrong or wrongs himself but then seeks forgiveness of Allah will find Allah Forgiving and Merciful."'},
    ],
    'Forgiveness': [
      {'ref':'SURAH AL-IMRAN 3:135',
        'a':'وَالَّذِينَ إِذَا فَعَلُوا فَاحِشَةً أَوْ ظَلَمُوا أَنفُسَهُمْ ذَكَرُوا اللَّهَ فَاسْتَغْفَرُوا لِذُنُوبِهِمْ',
        't':'"And those who, when they commit an immorality or wrong themselves [by transgression], remember Allah and seek forgiveness for their sins."'},
      {'ref':'SURAH AL-BAQARAH 2:286',
        'a':'رَبَّنَا لَا تُؤَاخِذْنَا إِن نَّسِينَا أَوْ أَخْطَأْنَا',
        't':'"Our Lord, do not impose blame upon us if we have forgotten or erred."'},
      {'ref':'SURAH AL-MUMINOON 23:118',
        'a':'وَقُل رَّبِّ اغْفِرْ وَارْحَمْ وَأَنتَ خَيْرُ الرَّاحِمِينَ',
        't':'"And say, My Lord, forgive and have mercy, and You are the best of the merciful."'},
    ],
    'Gratitude': [
      {'ref':'SURAH IBRAHIM 14:7',
        'a':'لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ',
        't':'"If you are grateful, I will surely increase you [in favor]."'},
      {'ref':'SURAH AL-BAQARAH 2:152',
        'a':'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
        't':'"So remember Me; I will remember you. And be grateful to Me and do not deny Me."'},
      {'ref':'SURAH LUQMAN 31:12',
        'a':'وَمَن يَشْكُرْ فَإِنَّمَا يَشْكُرُ لِنَفْسِهِ',
        't':'"And whoever is grateful — his gratitude is only for [the benefit of] himself."'},
      {'ref':'SURAH AN-NAHL 16:18',
        'a':'وَإِن تَعُدُّوا نِعْمَةَ اللَّهِ لَا تُحْصُوهَا',
        't':'"And if you should count the favors of Allah, you could not enumerate them."'},
    ],
    'Hope': [
      {'ref':'SURAH AD-DUHA 93:3-5',
        'a':'مَا وَدَّعَكَ رَبُّكَ وَمَا قَلَىٰ ۝ وَلَلْآخِرَةُ خَيْرٌ لَّكَ مِنَ الْأُولَىٰ ۝ وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَىٰ',
        't':'"Your Lord has not taken leave of you, nor has He detested [you]. And the Hereafter is better for you than the first [life]. And your Lord is going to give you, and you will be satisfied."'},
      {'ref':'SURAH AL-HIJR 15:56',
        'a':'وَمَن يَقْنَطُ مِن رَّحْمَةِ رَبِّهِ إِلَّا الضَّالُّونَ',
        't':'"And who despairs of the mercy of his Lord except for those astray?"'},
      {'ref':'SURAH AL-BAQARAH 2:286',
        'a':'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
        't':'"Allah does not burden a soul beyond that it can bear."'},
    ],
    'Prayer': [
      {'ref':'SURAH AL-BAQARAH 2:238',
        'a':'حَافِظُوا عَلَى الصَّلَوَاتِ وَالصَّلَاةِ الْوُسْطَىٰ وَقُومُوا لِلَّهِ قَانِتِينَ',
        't':'"Maintain with care the [obligatory] prayers and [in particular] the middle prayer and stand before Allah, devoutly obedient."'},
      {'ref':'SURAH AL-ANKABUT 29:45',
        'a':'اتْلُ مَا أُوحِيَ إِلَيْكَ مِنَ الْكِتَابِ وَأَقِمِ الصَّلَاةَ ۖ إِنَّ الصَّلَاةَ تَنْهَىٰ عَنِ الْفَحْشَاءِ وَالْمُنكَرِ',
        't':'"Recite what is revealed to you of the Book and establish prayer. Indeed, prayer prohibits immorality and wrongdoing."'},
      {'ref':'SURAH AL-BAQARAH 2:45',
        'a':'وَاسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ',
        't':'"And seek help through patience and prayer."'},
    ],
    'Death': [
      {'ref':'SURAH AL-BAQARAH 2:156',
        'a':'إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ',
        't':'"Indeed we belong to Allah, and indeed to Him we will return."'},
      {'ref':'SURAH AL-JUMU\'AH 62:8',
        'a':'قُلْ إِنَّ الْمَوْتَ الَّذِي تَفِرُّونَ مِنْهُ فَإِنَّهُ مُلَاقِيكُمْ',
        't':'"Say, Indeed, the death from which you flee — indeed, it will meet you."'},
      {'ref':'SURAH AL-IMRAN 3:185',
        'a':'كُلُّ نَفْسٍ ذَائِقَةُ الْمَوْتِ',
        't':'"Every soul will taste death."'},
    ],
  };

  List<Map<String, String>> get _current => _ayahs[_topics[_topicIndex]] ?? [];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroBanner(),
          _buildTopicFilter(),
          if (_current.isEmpty)
            const Padding(padding: EdgeInsets.all(40),
                child: Center(child: Text('No ayahs found.',
                    style: TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey))))
          else
            ..._current.map(_buildAyahCard),
          _buildDeepDiveBanner(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(fit: StackFit.expand, children: [
            Image.asset('assets/images/mosque.png', fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFF2D5A3D), Color(0xFF0D2818)],
                  )),
                )),
            Container(decoration: const BoxDecoration(gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0x44000000), Color(0xBB0D2818)]))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Words of Allah', style: TextStyle(fontFamily: 'Cairo',
                        fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.gold)),
                    const SizedBox(height: 4),
                    const Text('Find solace and guidance in the divine revelations of the Noble Quran.',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textCream, height: 1.5)),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildTopicFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Explore by Topic', style: TextStyle(fontFamily: 'Cairo',
            fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(children: List.generate(_topics.length, (i) {
            final a = _topicIndex == i;
            return GestureDetector(
              onTap: () => setState(() => _topicIndex = i),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                decoration: BoxDecoration(
                  color: a ? AppColors.gold : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: a ? AppColors.gold : AppColors.borderLight),
                ),
                child: Text(_topics[i], style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: a ? AppColors.primaryDarkest : AppColors.textGrey)),
              ),
            );
          })),
        ),
      ]),
    );
  }

  Widget _buildAyahCard(Map<String, String> a) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
            blurRadius: 6, offset: const Offset(0, 1))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: Text(a['ref']!, style: const TextStyle(fontFamily: 'Cairo', fontSize: 10,
                  fontWeight: FontWeight.w700, color: AppColors.goldDark)),
            ),
            const Spacer(),
            const Icon(Icons.bookmark_outline, size: 18, color: AppColors.textGrey),
            const SizedBox(width: 10),
            const Icon(Icons.share_outlined, size: 18, color: AppColors.textGrey),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
          child: Text(a['a']!, textDirection: TextDirection.rtl, textAlign: TextAlign.right,
              style: const TextStyle(fontFamily: 'Amiri', fontSize: 26,
                  color: AppColors.textDark, height: 2.0)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Container(height: 1, color: AppColors.borderLight),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
          child: Text(a['t']!, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13,
              color: AppColors.textGrey, height: 1.6, fontStyle: FontStyle.italic)),
        ),
      ]),
    );
  }

  Widget _buildDeepDiveBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.primaryDarkest]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: [
        const Text('Deepen Your\nConnection', textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w800,
                color: AppColors.gold, height: 1.3)),
        const SizedBox(height: 10),
        const Text('Access our full library of tafsir, word-by-word translations, and high-quality recitations.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textCream, height: 1.55)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(28)),
          child: const Text('Explore Full Quran', style: TextStyle(fontFamily: 'Cairo',
              fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryDarkest)),
        ),
      ]),
    );
  }
}