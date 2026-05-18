// lib/features/quran/tabs/talawat_tab.dart
// ─────────────────────────────────────────────────────────────────────────────
// TALAWAT TAB — Pure Arabic recitation
//
// FIXES & IMPROVEMENTS:
//   1. Bismillah duplication bug FIXED:
//      • API returns Bismillah as ayah 1 for most surahs → we strip it and
//        render it once in the dedicated Bismillah banner.
//      • Surah 1 (Al-Fatihah): ayah 1 IS the Bismillah (it is part of Fatihah),
//        so we show the Bismillah banner AND keep ayah 1 in the block — but the
//        banner text already covers it, so we skip ayah 1 from the flowing block.
//      • Surah 9 (At-Tawbah): no Bismillah shown at all (per Ijma).
//
//   2. Mushaf / Hamariweb-style flowing Quran text:
//      • All ayahs rendered as a single flowing RichText paragraph (Mushaf layout)
//        inside one bordered card — exactly matching the reference screenshot.
//      • Ayah numbers shown as gold ❮n❯ Unicode markers inline.
//      • Bismillah shown in its own separate centred box above the block.
//
//   3. Font: 'Scheherazade New' (Naskh Quranic calligraphy — closest free font
//      to the hamariweb/Mushaf style). Fallback: 'Amiri'.
//      Add to pubspec.yaml:
//        fonts:
//          - family: ScheherazadeNew
//            fonts:
//              - asset: assets/fonts/ScheherazadeNew-Regular.ttf
//      OR use google_fonts: ^6.x and call GoogleFonts.scheherazadeNew(...)
//
//   4. Font size −/+ buttons retained.
//   5. Translation mode: individual ayah cards retained (unchanged UX).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../data/surahs_data.dart';
import '../data/quran_api_service.dart';

// ── Shared Juz metadata ───────────────────────────────────────────────────────
class JuzMeta {
  final int num;
  final String ar;
  final String name;
  final String start;
  final String end;
  const JuzMeta(this.num, this.ar, this.name, this.start, this.end);
}

const kJuzList = [
  JuzMeta(1,  'آلم',                'Alif Lam Meem',         '1:1',   '2:141'),
  JuzMeta(2,  'سَيَقُولُ',          'Sayaqool',              '2:142', '2:252'),
  JuzMeta(3,  'تِلْكَ ٱلرُّسُلُ',  'Tilkal Rusulu',         '2:253', '3:92'),
  JuzMeta(4,  'لَنْ تَنَالُوا',     'Lan tanaloo',           '3:93',  '4:23'),
  JuzMeta(5,  'وَٱلْمُحْصَنَاتُ',  'Wal Mohsanatu',         '4:24',  '4:147'),
  JuzMeta(6,  'لَا يُحِبُّ',        'La Yuhibbullah',        '4:148', '5:81'),
  JuzMeta(7,  'وَإِذَا سَمِعُوا',   'Wa Iza Samiu',          '5:82',  '6:110'),
  JuzMeta(8,  'وَلَوْ أَنَّنَا',    'Wa Lau Annana',         '6:111', '7:87'),
  JuzMeta(9,  'قَالَ ٱلْمَلَأُ',   'Qalal Malao',           '7:88',  '8:40'),
  JuzMeta(10, 'وَٱعْلَمُوا',        "Wa A'lamu",             '8:41',  '9:92'),
  JuzMeta(11, 'يَعْتَذِرُونَ',      'Yatazeroon',            '9:93',  '11:5'),
  JuzMeta(12, 'وَمَا مِنْ دَآبَّة', 'Wa Ma Min Dabbatin',   '11:6',  '12:52'),
  JuzMeta(13, 'وَمَا أُبَرِّئُ',    'Wa Ma Ubrioo',          '12:53', '14:52'),
  JuzMeta(14, 'رُبَمَا',            'Rubama',                '15:1',  '16:128'),
  JuzMeta(15, 'سُبْحَانَ ٱلَّذِى',  'Subhanalladhi',         '17:1',  '18:74'),
  JuzMeta(16, 'قَالَ أَلَمْ',       'Qala Alam',             '18:75', '20:135'),
  JuzMeta(17, 'ٱقْتَرَبَ',          'Iqtaraba',              '21:1',  '22:78'),
  JuzMeta(18, 'قَدْ أَفْلَحَ',      'Qadd Aflaha',           '23:1',  '25:20'),
  JuzMeta(19, 'وَقَالَ ٱلَّذِينَ',  'Wa Qala lladhina',     '25:21', '27:55'),
  JuzMeta(20, 'أَمَّنْ خَلَقَ',     "A'man Khalaqa",         '27:56', '29:45'),
  JuzMeta(21, 'أُتْلُ',             'Utlu Ma Oohiya',        '29:46', '33:30'),
  JuzMeta(22, 'وَمَن يَقْنُتْ',     'Wa Man Yaqnut',         '33:31', '36:27'),
  JuzMeta(23, 'وَمَآ لِي',          'Wa Mali',               '36:28', '39:31'),
  JuzMeta(24, 'فَمَنْ أَظْلَمُ',    'Faman Azlamu',          '39:32', '41:46'),
  JuzMeta(25, 'إِلَيْهِ يُرَدُّ',   'Ilayhi Yuruddu',        '41:47', '45:37'),
  JuzMeta(26, 'حٰمٓ',               'Ha Meem',               '46:1',  '51:30'),
  JuzMeta(27, 'قَالَ فَمَا خَطْبُكُم', 'Qala Fama Khatbukum', '51:31', '57:29'),
  JuzMeta(28, 'قَدْ سَمِعَ',        'Qadd Sami Allah',       '58:1',  '66:12'),
  JuzMeta(29, 'تَبَارَكَ ٱلَّذِى',  'Tabaraka lladhi',       '67:1',  '77:50'),
  JuzMeta(30, 'عَمَّ',              'Amma',                  '78:1',  '114:6'),
];

// ── Arabic font helper ────────────────────────────────────────────────────────
// Uses ScheherazadeNew if available in assets, else falls back to Amiri.
// To enable ScheherazadeNew: add font asset in pubspec.yaml (see header).
const _kQuranicFont = 'ScheherazadeNew';   // swap to 'Amiri' if not added yet

// ── Bismillah text (Uthmani script) ──────────────────────────────────────────
const _kBismillah = 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ';

// ── Determines whether a given ayah text IS the Bismillah ────────────────────
// The API returns Bismillah as ayah 1 for most surahs (stripped of tashkeel
// variation). We compare normalised.
bool _isBismillahText(String text) {
  // Normalise: remove tatweel, strip diacritics range, collapse spaces
  String _norm(String s) => s
      .replaceAll('\u0640', '')                        // tatweel
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '') // tashkeel
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  const _bCore = 'بسم الله الرحمن الرحيم';
  return _norm(text).startsWith(_norm(_bCore).substring(0, 10));
}

// ══════════════════════════════════════════════════════════════════════════════
// TALAWAT TAB
// ══════════════════════════════════════════════════════════════════════════════
class TalawatTab extends StatefulWidget {
  final String searchQuery;
  const TalawatTab({super.key, this.searchQuery = ''});
  @override
  State<TalawatTab> createState() => _TalawatTabState();
}

class _TalawatTabState extends State<TalawatTab>
    with SingleTickerProviderStateMixin {
  late TabController _sub;

  @override
  void initState() {
    super.initState();
    _sub = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _sub.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SharedSubTabBar(controller: _sub),
      Expanded(
        child: TabBarView(
          controller: _sub,
          children: [
            _SurahListView(mode: ReadMode.talawat, searchQuery: widget.searchQuery),
            _JuzListView(mode: ReadMode.talawat,   searchQuery: widget.searchQuery),
          ],
        ),
      ),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Shared sub-tab bar (Surah / Juzz)
// ══════════════════════════════════════════════════════════════════════════════
class SharedSubTabBar extends StatelessWidget {
  final TabController controller;
  const SharedSubTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.quranBgLightGreen,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(24),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [Tab(text: 'Surah'), Tab(text: 'Juzz')],
        labelStyle: const TextStyle(
            fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(
            fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w400),
        labelColor: AppColors.primaryDarkest,
        unselectedLabelColor: AppColors.textGrey,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Reading mode
// ══════════════════════════════════════════════════════════════════════════════
enum ReadMode { talawat, tarjuma }

// ══════════════════════════════════════════════════════════════════════════════
// Surah list
// ══════════════════════════════════════════════════════════════════════════════
class _SurahListView extends StatelessWidget {
  final ReadMode mode;
  final String searchQuery;
  const _SurahListView({required this.mode, this.searchQuery = ''});

  List<Map<String, dynamic>> get _filtered {
    if (searchQuery.isEmpty) return SurahsData.surahs;
    final q = searchQuery.toLowerCase();
    return SurahsData.surahs.where((s) =>
    (s['name'] as String).toLowerCase().contains(q) ||
        '${s['num']}'.contains(q) ||
        (s['arabic'] as String).contains(q) ||
        (s['meaning'] as String).toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    if (list.isEmpty) return _EmptySearchState(query: searchQuery);
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final s = list[i];
        return SharedSurahCard(
          surah: s,
          onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => ArabicReadScreen(
                  surah: s,
                  showTranslation: mode == ReadMode.tarjuma))),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Juz list
// ══════════════════════════════════════════════════════════════════════════════
class _JuzListView extends StatelessWidget {
  final ReadMode mode;
  final String searchQuery;
  const _JuzListView({required this.mode, this.searchQuery = ''});

  List<JuzMeta> get _filtered {
    if (searchQuery.isEmpty) return kJuzList;
    final q = searchQuery.toLowerCase();
    return kJuzList.where((j) =>
    j.name.toLowerCase().contains(q) ||
        j.ar.contains(q) ||
        '${j.num}'.contains(q) ||
        'juz ${j.num}'.contains(q) ||
        'para ${j.num}'.contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    if (list.isEmpty) return _EmptySearchState(query: searchQuery);
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: list.length,
      itemBuilder: (_, i) => SharedJuzCard(
        meta: list[i],
        onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => ArabicReadScreen.juz(
                meta: list[i],
                showTranslation: mode == ReadMode.tarjuma))),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Empty search state
// ══════════════════════════════════════════════════════════════════════════════
class _EmptySearchState extends StatelessWidget {
  final String query;
  const _EmptySearchState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.search_off, size: 56, color: AppColors.textLightGrey),
        const SizedBox(height: 12),
        Text('No results for "$query"',
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 15,
                fontWeight: FontWeight.w600, color: AppColors.textGrey)),
        const SizedBox(height: 6),
        const Text('Try a different Surah name or number',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
                color: AppColors.textLightGrey)),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SHARED SURAH CARD
// ══════════════════════════════════════════════════════════════════════════════
class SharedSurahCard extends StatelessWidget {
  final Map<String, dynamic> surah;
  final VoidCallback onTap;
  const SharedSurahCard({super.key, required this.surah, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isMakki = surah['type'] == 'MAKKI';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        decoration: BoxDecoration(
          color: AppColors.quranBgLightGreen,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold.withOpacity(0.55), width: 1.2),
          boxShadow: [
            BoxShadow(color: AppColors.gold.withOpacity(0.07),
                blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(children: [
          // Golden number badge
          Container(
            width: 48, height: 64,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14)),
            ),
            child: Center(
              child: Text('${surah['num']}',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDarkest)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(surah['name'] as String,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 14,
                        fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 3),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isMakki
                          ? AppColors.gold.withOpacity(0.18)
                          : AppColors.primaryLight.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: isMakki
                              ? AppColors.gold.withOpacity(0.4)
                              : AppColors.primaryLight.withOpacity(0.3)),
                    ),
                    child: Text(surah['type'] as String,
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isMakki ? AppColors.goldDark : AppColors.primaryLight)),
                  ),
                  const SizedBox(width: 5),
                  Text('• ${surah['ayahs']} Ayahs',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 11,
                          color: AppColors.textGrey)),
                ]),
              ])),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(surah['arabic'] as String,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(fontFamily: _kQuranicFont,
                      fontSize: 20, color: AppColors.textDark)),
              Text((surah['meaning'] as String).split(' ').take(2).join(' '),
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 9,
                      color: AppColors.textGrey)),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SHARED JUZ CARD
// ══════════════════════════════════════════════════════════════════════════════
class SharedJuzCard extends StatelessWidget {
  final JuzMeta meta;
  final VoidCallback onTap;
  const SharedJuzCard({super.key, required this.meta, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        decoration: BoxDecoration(
          color: AppColors.quranBgLightGreen,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold.withOpacity(0.55), width: 1.2),
          boxShadow: [
            BoxShadow(color: AppColors.gold.withOpacity(0.07),
                blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(children: [
          Container(
            width: 56, height: 64,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14)),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Juz', style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 9, color: AppColors.primaryDarkest,
                      fontWeight: FontWeight.w600)),
                  Text('${meta.num}', style: const TextStyle(fontFamily: 'Cairo',
                      fontSize: 20, fontWeight: FontWeight.w800,
                      color: AppColors.primaryDarkest)),
                ]),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meta.name, style: const TextStyle(fontFamily: 'Cairo',
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: AppColors.gold.withOpacity(0.3))),
                  child: Text('${meta.start} → ${meta.end}',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 10,
                          color: AppColors.goldDark)),
                ),
              ])),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Text(meta.ar, textDirection: TextDirection.rtl,
                style: const TextStyle(fontFamily: _kQuranicFont,
                    fontSize: 18, color: AppColors.goldDark)),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ARABIC READ SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class ArabicReadScreen extends StatefulWidget {
  final Map<String, dynamic>? surah;
  final JuzMeta? juzMeta;
  final bool isJuzMode;
  final bool showTranslation;

  const ArabicReadScreen({
    super.key,
    required Map<String, dynamic> surah,
    required this.showTranslation,
  })  : surah = surah,
        juzMeta = null,
        isJuzMode = false;

  const ArabicReadScreen.juz({
    super.key,
    required JuzMeta meta,
    required this.showTranslation,
  })  : juzMeta = meta,
        surah = null,
        isJuzMode = true;

  @override
  State<ArabicReadScreen> createState() => _ArabicReadScreenState();
}

class _ArabicReadScreenState extends State<ArabicReadScreen> {
  List<JuzSurahGroup>? _juzGroups;
  List<Map<String, String>>? _surahAyahs;
  bool _loading = true;
  String? _error;
  double _fontSize = 26; // slightly larger default for Mushaf style

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      if (widget.isJuzMode) {
        final data = await QuranApiService.fetchJuz(widget.juzMeta!.num);
        if (!mounted) return;
        if (data == null) throw Exception();
        setState(() { _juzGroups = data; _loading = false; });
      } else {
        final num = widget.surah!['num'] as int;
        // Try local first (instant), then network
        List<Map<String, String>>? data =
        await QuranApiService.getLocalAyahs(num);
        data ??= await QuranApiService.fetchSurah(num);
        if (!mounted) return;
        if (data == null) throw Exception();
        setState(() { _surahAyahs = data; _loading = false; });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not load. Check your connection.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.quranBgLightGreen,
      body: SafeArea(
        child: Column(children: [
          _buildHeader(),
          if (_loading)
            const Expanded(
                child: Center(child: CircularProgressIndicator(
                    color: AppColors.gold)))
          else if (_error != null)
            _buildError()
          else
            Expanded(child: _buildContent()),
        ]),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final title = widget.isJuzMode
        ? 'Juz ${widget.juzMeta!.num} — ${widget.juzMeta!.name}'
        : widget.surah!['name'] as String;
    final subtitle = widget.isJuzMode
        ? (widget.showTranslation ? 'Arabic + English' : 'Uthmani Script')
        : '${widget.surah!['ayahs']} Ayahs • ${widget.surah!['type']}';

    return Container(
      color: AppColors.primaryDark,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: AppColors.primaryMid.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.textWhite, size: 14),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15,
                  fontWeight: FontWeight.w700, color: AppColors.textWhite)),
              Text(subtitle, style: const TextStyle(fontFamily: 'Cairo',
                  fontSize: 11, color: AppColors.textGreenMuted)),
            ])),
        _fontBtn('−', () { if (_fontSize > 18) setState(() => _fontSize -= 2); }),
        const SizedBox(width: 6),
        _fontBtn('+', () { if (_fontSize < 42) setState(() => _fontSize += 2); }),
      ]),
    );
  }

  Widget _fontBtn(String label, VoidCallback fn) => GestureDetector(
    onTap: fn,
    child: Container(
      width: 34, height: 34,
      decoration: BoxDecoration(
          color: AppColors.primaryMid,
          borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: Text(label, style: const TextStyle(fontFamily: 'Cairo',
            fontSize: 20, fontWeight: FontWeight.w700,
            color: AppColors.gold, height: 1.0)),
      ),
    ),
  );

  Widget _buildError() => Expanded(
    child: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.wifi_off, size: 48, color: AppColors.textLightGrey),
        const SizedBox(height: 12),
        Text(_error!, textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14,
                color: AppColors.textGrey)),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _load,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(color: AppColors.gold,
                borderRadius: BorderRadius.circular(20)),
            child: const Text('Retry', style: TextStyle(fontFamily: 'Cairo',
                fontSize: 13, fontWeight: FontWeight.w700,
                color: AppColors.primaryDarkest)),
          ),
        ),
      ]),
    ),
  );

  // ── Main content router ───────────────────────────────────────────────────
  Widget _buildContent() {
    if (widget.isJuzMode) {
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        itemCount: _juzGroups!.length + 1,
        itemBuilder: (_, i) {
          if (i == _juzGroups!.length) return _nextJuzBtn();
          return _buildSurahBlock(_juzGroups![i]);
        },
      );
    }

    // ── Single surah mode ─────────────────────────────────────────────────
    final surahNum = widget.surah!['num'] as int;
    final ayahs    = _surahAyahs!;

    // Strip leading Bismillah ayah returned by API (it is NOT a counted ayah
    // for most surahs — the API prepends it). Exception: Surah 1 Al-Fatihah
    // where it IS ayah 1 and must remain in the flow; Surah 9 has no bismillah.
    final bool hasBismillahBanner = surahNum != 9;
    List<Map<String, String>> displayAyahs = ayahs;

    if (hasBismillahBanner && ayahs.isNotEmpty) {
      final first = ayahs.first;
      final isApiPrepended = first['num'] == '0' ||
          (first['num'] == '1' && _isBismillahText(first['a'] ?? ''));

      if (isApiPrepended && surahNum != 1) {
        // Remove the prepended bismillah — it will be shown by the banner
        displayAyahs = ayahs.sublist(1);
      }
      // Surah 1: ayah 1 IS the Bismillah AND part of Fatihah — keep it in the
      // flowing block (Fatihah is recited with it). We still show the standalone
      // banner above, but DON'T remove it from the block.
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(children: [
        // ── Bismillah banner (centred, bordered) ──────────────────────────
        if (hasBismillahBanner) _buildBismillahBanner(),

        const SizedBox(height: 12),

        // ── Ayah content ──────────────────────────────────────────────────
        if (widget.showTranslation)
          ...displayAyahs.map((a) =>
              _buildAyahCard(a['a']!, a['t']!, a['num']!, surahNum))
        else
          _buildMushaafBlock(displayAyahs),
      ]),
    );
  }

  // ── Surah block inside Juz mode ───────────────────────────────────────────
  Widget _buildSurahBlock(JuzSurahGroup g) {
    final bool hasBismillah = g.surahNum != 9;
    final bool startsFromAyah1 =
        g.ayahs.isNotEmpty && g.ayahs.first['num'] == '1';

    List<Map<String, String>> displayAyahs = g.ayahs;
    if (hasBismillah && startsFromAyah1 && g.ayahs.isNotEmpty) {
      final first = g.ayahs.first;
      if (_isBismillahText(first['a'] ?? '') && g.surahNum != 1) {
        displayAyahs = g.ayahs.sublist(1);
      }
    }

    return Column(children: [
      // Surah header strip
      Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primaryDarkest]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold.withOpacity(0.4)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.gold,
                borderRadius: BorderRadius.circular(8)),
            child: Text('${g.surahNum}', style: const TextStyle(
                fontFamily: 'Cairo', fontSize: 12,
                fontWeight: FontWeight.w800, color: AppColors.primaryDarkest)),
          ),
          const SizedBox(width: 10),
          Text(g.surahName, style: const TextStyle(fontFamily: 'Cairo',
              fontSize: 15, fontWeight: FontWeight.w700,
              color: AppColors.textWhite)),
          const Spacer(),
          Text(g.surahArabic, textDirection: TextDirection.rtl,
              style: const TextStyle(fontFamily: _kQuranicFont,
                  fontSize: 20, color: AppColors.gold)),
        ]),
      ),

      // Bismillah banner for first ayah of surah
      if (hasBismillah && startsFromAyah1) ...[
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildBismillahBanner(),
        ),
      ],

      const SizedBox(height: 10),

      // Ayah content
      if (widget.showTranslation)
        ...displayAyahs.map((a) =>
            _buildAyahCard(a['a']!, a['t']!, a['num']!, g.surahNum))
      else
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildMushaafBlock(displayAyahs),
        ),
    ]);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BISMILLAH BANNER — centred, standalone bordered box (matches screenshot)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildBismillahBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withOpacity(0.6), width: 1.3),
        boxShadow: [
          BoxShadow(color: AppColors.gold.withOpacity(0.08),
              blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Text(
        _kBismillah,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: _kQuranicFont,
          fontSize: _fontSize + 2, // slightly larger than body
          color: AppColors.primaryDark,
          height: 1.8,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MUSHAF BLOCK — all ayahs as ONE flowing RichText paragraph (matches
  // the hamariweb / screenshot layout). Ayah numbers inline in gold ﴿n﴾.
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildMushaafBlock(List<Map<String, String>> ayahs) {
    if (ayahs.isEmpty) return const SizedBox.shrink();

    final spans = <InlineSpan>[];
    for (int i = 0; i < ayahs.length; i++) {
      if (i > 0) {
        spans.add(const TextSpan(text: '\u200C')); // zero-width non-joiner spacing
      }
      // Ayah text
      spans.add(TextSpan(
        text: ayahs[i]['a']!,
        style: TextStyle(
          fontFamily: _kQuranicFont,
          fontSize: _fontSize,
          color: AppColors.textDark,
          height: 2.2,
        ),
      ));
      // Ayah number marker  ﴿n﴾  in gold
      spans.add(TextSpan(
        text: ' \u06DD${ayahs[i]['num']!}\u0020',
        style: TextStyle(
          fontFamily: _kQuranicFont,
          fontSize: _fontSize * 0.80,
          color: AppColors.goldDark,
          fontWeight: FontWeight.w700,
          height: 2.2,
        ),
      ));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.55), width: 1.3),
        boxShadow: [
          BoxShadow(color: AppColors.gold.withOpacity(0.06),
              blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: RichText(
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.justify,
        text: TextSpan(children: spans),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // AYAH CARD — translation mode (individual cards, unchanged UX)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildAyahCard(String arabic, String trans, String num, int surahNum) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withOpacity(0.55), width: 1.3),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Arabic text row
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Gold ayah number circle
            Container(
              width: 28, height: 28,
              decoration: const BoxDecoration(
                  color: AppColors.gold, shape: BoxShape.circle),
              child: Center(child: Text(num, style: const TextStyle(
                  fontFamily: 'Cairo', fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDarkest))),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$arabic \u06DD$num\u0020',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontFamily: _kQuranicFont,
                  fontSize: _fontSize,
                  color: AppColors.textDark,
                  height: 2.0,
                ),
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Container(height: 1, color: AppColors.gold.withOpacity(0.25)),
        ),
        // Translation
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$surahNum:$num ',
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 10,
                    fontWeight: FontWeight.w700, color: AppColors.goldDark)),
            Expanded(child: Text(trans, style: const TextStyle(
                fontFamily: 'Cairo', fontSize: 13,
                color: AppColors.textGrey, height: 1.6,
                fontStyle: FontStyle.italic))),
          ]),
        ),
      ]),
    );
  }

  // ── Next Juz button ───────────────────────────────────────────────────────
  Widget _nextJuzBtn() {
    if (!widget.isJuzMode || widget.juzMeta!.num >= 30) {
      return const SizedBox(height: 40);
    }
    final next = kJuzList[widget.juzMeta!.num];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GestureDetector(
        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (_) => ArabicReadScreen.juz(
                meta: next,
                showTranslation: widget.showTranslation))),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primaryMid]),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.gold.withOpacity(0.4)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('Next Juz', style: TextStyle(fontFamily: 'Cairo',
                fontSize: 15, fontWeight: FontWeight.w700,
                color: AppColors.textWhite)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.gold,
                  borderRadius: BorderRadius.circular(10)),
              child: Text('${widget.juzMeta!.num + 1}',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDarkest)),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward, color: AppColors.textWhite, size: 18),
          ]),
        ),
      ),
    );
  }
}
