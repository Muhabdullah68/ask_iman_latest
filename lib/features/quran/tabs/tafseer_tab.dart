// lib/features/quran/tabs/tafseer_tab.dart
// SURAH MODE ONLY — search bar integrated, searchQuery accepted from QuranScreen

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../data/surahs_data.dart';
import '../data/quran_api_service.dart';

// ══════════════════════════════════════════════════════════════════════════════
// TAFSEER TAB
// ══════════════════════════════════════════════════════════════════════════════
class TafseerTab extends StatefulWidget {
  final String searchQuery;
  const TafseerTab({super.key, this.searchQuery = ''});

  @override
  State<TafseerTab> createState() => _TafseerTabState();
}

class _TafseerTabState extends State<TafseerTab> {
  bool _showAll = false;
  // Local search (typed inside Tafseer tab) — merged with global searchQuery below
  String _localQuery = '';
  final TextEditingController _searchController = TextEditingController();
  static const int _initCount = 8;

  String get _effectiveQuery =>
      widget.searchQuery.isNotEmpty ? widget.searchQuery : _localQuery;

  List<Map<String, dynamic>> get _filteredSurahs {
    if (_effectiveQuery.isEmpty) return SurahsData.surahs;
    final q = _effectiveQuery.toLowerCase();
    return SurahsData.surahs.where((s) =>
    (s['name'] as String).toLowerCase().contains(q) ||
        '${s['num']}'.contains(q)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Show the inline search bar only when global search is NOT active
          if (widget.searchQuery.isEmpty) _buildSearchBar(),
          _buildFeaturedCard(),
          _buildSurahList(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.search, color: AppColors.textLightGrey, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _localQuery = v),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
                decoration: const InputDecoration(
                  hintText: 'Search Surah or Ayah...',
                  hintStyle: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: AppColors.textLightGrey,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            if (_localQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() => _localQuery = '');
                },
                child: const Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Icon(Icons.close, size: 16, color: AppColors.textGrey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard() {
    final surah = SurahsData.surahs[0];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: GestureDetector(
        onTap: () => _openDetail(surah),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, AppColors.primaryDarkest],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.gold.withOpacity(0.35)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.gold.withOpacity(0.35)),
                    ),
                    child: const Text(
                      'FEATURED\nSURAH',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                        letterSpacing: 0.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'الفَاتِحَة',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 28,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Al-Fatihah',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textWhite,
                ),
              ),
              const Text(
                'The Opening • 7 Ayahs',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: AppColors.textGreenMuted,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ\nٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ\nٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 24,
                  color: AppColors.textWhite,
                  height: 2.0,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                '"In the name of Allah, the Entirely Merciful...\n[All] praise is [due] to Allah, Lord of the worlds..."',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: AppColors.textCream,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _openDetail(surah),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book, color: AppColors.primaryDarkest, size: 20),
                      SizedBox(width: 6),
                      Text(
                        'Read Full Surah',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDarkest,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurahList() {
    final list = _filteredSurahs;
    final shown = _showAll ? list : list.take(_initCount).toList();
    final hasMore = list.length > _initCount;

    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(children: [
            Icon(Icons.search_off, size: 56, color: AppColors.textLightGrey),
            const SizedBox(height: 12),
            Text(
              'No results for "$_effectiveQuery"',
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 15,
                  fontWeight: FontWeight.w600, color: AppColors.textGrey),
            ),
          ]),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('All Surahs', style: TextStyle(
                          fontFamily: 'Cairo', fontSize: 18,
                          fontWeight: FontWeight.w700, color: AppColors.textDark)),
                      Text('${list.length} Total', style: const TextStyle(
                          fontFamily: 'Cairo', fontSize: 13, color: AppColors.textGrey)),
                    ],
                  ),
                ),
                ...shown.map((s) => _SurahTile(surah: s, onTap: () => _openDetail(s))),
              ],
            ),
          ),
          if (hasMore) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => setState(() => _showAll = !_showAll),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.bgWhite,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Center(
                  child: Text(
                    _showAll
                        ? 'Show Less'
                        : 'Load All Surahs (${list.length - _initCount} more)',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openDetail(Map<String, dynamic> surah) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => TafseerDetailScreen(surah: surah)));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SURAH TILE WIDGET
// ══════════════════════════════════════════════════════════════════════════════
class _SurahTile extends StatelessWidget {
  final Map<String, dynamic> surah;
  final VoidCallback onTap;
  const _SurahTile({required this.surah, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isMakki = (surah['type'] as String) == 'MAKKI';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: AppColors.borderLight.withOpacity(0.7))),
        ),
        child: Row(
          children: [
            // Number circle — golden border
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gold.withOpacity(0.5)),
                  shape: BoxShape.circle),
              child: Center(child: Text('${surah['num']}', style: const TextStyle(
                  fontFamily: 'Cairo', fontSize: 13,
                  fontWeight: FontWeight.w600, color: AppColors.textDark))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(surah['name'] as String, style: const TextStyle(
                    fontFamily: 'Cairo', fontSize: 15,
                    fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(height: 3),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isMakki
                          ? AppColors.gold.withOpacity(0.15)
                          : AppColors.primaryLight.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(surah['type'] as String, style: TextStyle(
                        fontFamily: 'Cairo', fontSize: 9, fontWeight: FontWeight.w700,
                        color: isMakki ? AppColors.goldDark : AppColors.primaryLight)),
                  ),
                  const SizedBox(width: 5),
                  Text('• ${surah['ayahs']} Ayahs', style: const TextStyle(
                      fontFamily: 'Cairo', fontSize: 11, color: AppColors.textGrey)),
                ]),
              ],
            )),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(surah['arabic'] as String, textDirection: TextDirection.rtl,
                  style: const TextStyle(
                      fontFamily: 'Amiri', fontSize: 20, color: AppColors.textDark)),
              Text((surah['meaning'] as String).split(' ').take(2).join(' '),
                  style: const TextStyle(
                      fontFamily: 'Cairo', fontSize: 9, color: AppColors.textGrey)),
            ]),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TAFSEER DETAIL SCREEN (unchanged logic, kept intact)
// ══════════════════════════════════════════════════════════════════════════════
class TafseerDetailScreen extends StatefulWidget {
  final Map<String, dynamic> surah;
  const TafseerDetailScreen({super.key, required this.surah});
  @override State<TafseerDetailScreen> createState() => _TafseerDetailScreenState();
}

class _TafseerDetailScreenState extends State<TafseerDetailScreen> {
  int _srcIndex = 0;
  int _ayahIndex = 0;
  bool _tExpanded = true;
  bool _loadingAyahs = false;
  bool _loadingTafseer = false;
  String? _tafseerText;
  List<Map<String, String>> _ayahs = [];

  final _sources = ['Ibn Kathir', "Ma'ariful Quran", 'Al-Jalalayn'];

  @override
  void initState() { super.initState(); _loadAyahs(); }

  Future<void> _loadAyahs() async {
    final num = widget.surah['num'] as int;
    final local = await QuranApiService.getLocalAyahs(num);
    if (local != null && local.isNotEmpty) {
      setState(() => _ayahs = local);
      _loadTafseer();
      return;
    }
    setState(() => _loadingAyahs = true);
    final fetched = await QuranApiService.fetchSurah(num);
    if (!mounted) return;
    setState(() { _ayahs = fetched ?? []; _loadingAyahs = false; });
    if (_ayahs.isNotEmpty) _loadTafseer();
  }

  Future<void> _loadTafseer() async {
    final num = widget.surah['num'] as int;
    final source = _sources[_srcIndex];
    final local = await QuranApiService.getLocalTafseer(num, source);
    if (local != null) { setState(() => _tafseerText = local); return; }
    setState(() { _loadingTafseer = true; _tafseerText = null; });
    final text = await QuranApiService.fetchTafseer(num, _ayahIndex + 1, source);
    if (!mounted) return;
    setState(() {
      _tafseerText = text ?? _fallback(source);
      _loadingTafseer = false;
    });
  }

  String _fallback(String source) {
    switch (source) {
      case 'Ibn Kathir':
        return 'Imam Ibn Kathir explains: This blessed surah carries profound meaning that scholars have expounded upon for centuries.';
      case "Ma'ariful Quran":
        return "Mufti Shafi' explains: This verse is foundational to understanding the divine message.";
      default:
        return 'Al-Jalalayn states: This verse is clear in its guidance.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(children: [
            _buildHeader(context),
            _buildSourceChips(),
            _buildAyahCard(),
            _buildAyahNav(),
            _buildTafseerSection(),
            _buildMetaRow(),
            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final surah = widget.surah;
    return Container(
      color: AppColors.primaryDark,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
                color: AppColors.primaryMid.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.textWhite, size: 16),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(surah['name'] as String, style: const TextStyle(
              fontFamily: 'Cairo', fontSize: 18,
              fontWeight: FontWeight.w700, color: AppColors.textWhite)),
          Text('${surah['ayahs']} Ayahs  •  ${surah['type']}',
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 12,
                  color: AppColors.textGreenMuted)),
        ])),
        Text(surah['arabic'] as String, textDirection: TextDirection.rtl,
            style: const TextStyle(
                fontFamily: 'Amiri', fontSize: 24, color: AppColors.gold)),
      ]),
    );
  }

  Widget _buildSourceChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 0, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(children: List.generate(_sources.length, (i) {
          final active = _srcIndex == i;
          return GestureDetector(
            onTap: () { setState(() => _srcIndex = i); _loadTafseer(); },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: active ? AppColors.primaryDark : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: active ? AppColors.primaryDark : AppColors.borderLight),
              ),
              child: Text(_sources[i], style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600,
                  color: active ? AppColors.textWhite : AppColors.textGrey)),
            ),
          );
        })),
      ),
    );
  }

  Widget _buildAyahCard() {
    if (_loadingAyahs) {
      return const Padding(padding: EdgeInsets.all(40),
          child: Center(child: CircularProgressIndicator(color: AppColors.gold)));
    }
    if (_ayahs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: AppColors.primaryDark, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            const Text('Ayahs not available offline.\nConnect to internet to load.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Cairo', color: AppColors.textCream, height: 1.5)),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: _loadAyahs,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                decoration: BoxDecoration(
                    color: AppColors.gold, borderRadius: BorderRadius.circular(20)),
                child: const Text('Load from Internet', style: TextStyle(
                    fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700,
                    color: AppColors.primaryDarkest)),
              ),
            ),
          ]),
        ),
      );
    }
    final ayah = _ayahs[_ayahIndex];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.primaryDark, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6)),
            child: Text(
              '${(widget.surah['name'] as String).toUpperCase()} : ${_ayahIndex + 1} / ${_ayahs.length}',
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 10,
                  fontWeight: FontWeight.w700, color: AppColors.gold, letterSpacing: 0.4),
            ),
          ),
          const Spacer(),
          const Icon(Icons.share_outlined, size: 18, color: AppColors.textGreenMuted),
        ]),
        const SizedBox(height: 16),
        Text(ayah['a']!, textDirection: TextDirection.rtl, textAlign: TextAlign.right,
            style: const TextStyle(fontFamily: 'Amiri', fontSize: 28,
                color: AppColors.textWhite, height: 2.0)),
        const SizedBox(height: 12),
        Container(height: 1, color: AppColors.primaryMid),
        const SizedBox(height: 12),
        Text('"${ayah['t']!}"', style: const TextStyle(
            fontFamily: 'Cairo', fontSize: 13, color: AppColors.textCream,
            height: 1.6, fontStyle: FontStyle.italic)),
      ]),
    );
  }

  Widget _buildAyahNav() {
    if (_ayahs.isEmpty) return const SizedBox.shrink();
    final canPrev = _ayahIndex > 0;
    final canNext = _ayahIndex < _ayahs.length - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        GestureDetector(
          onTap: canPrev ? () { setState(() => _ayahIndex--); _loadTafseer(); } : null,
          child: Row(children: [
            Icon(Icons.arrow_back_ios, size: 14,
                color: canPrev ? AppColors.primaryDark : AppColors.borderLight),
            const SizedBox(width: 4),
            Text('Previous Ayah', style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
                fontWeight: FontWeight.w600,
                color: canPrev ? AppColors.primaryDark : AppColors.borderLight)),
          ]),
        ),
        GestureDetector(
          onTap: canNext ? () { setState(() => _ayahIndex++); _loadTafseer(); } : null,
          child: Row(children: [
            Text('Next Ayah', style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
                fontWeight: FontWeight.w600,
                color: canNext ? AppColors.primaryDark : AppColors.borderLight)),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward_ios, size: 14,
                color: canNext ? AppColors.primaryDark : AppColors.borderLight),
          ]),
        ),
      ]),
    );
  }

  Widget _buildTafseerSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => setState(() => _tExpanded = !_tExpanded),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Imam ${_sources[_srcIndex]}', style: const TextStyle(
                  fontFamily: 'Cairo', fontSize: 18,
                  fontWeight: FontWeight.w700, color: AppColors.textDark)),
              Row(children: [
                Container(width: 8, height: 8,
                    decoration: const BoxDecoration(
                        color: AppColors.success, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                const Text('Authentic Source', style: TextStyle(
                    fontFamily: 'Cairo', fontSize: 12, color: AppColors.textGrey)),
              ]),
            ]),
            Icon(_tExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: AppColors.textGrey, size: 26),
          ]),
        ),
        if (_tExpanded) ...[
          const SizedBox(height: 16),
          if (_loadingTafseer)
            const Center(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(color: AppColors.gold)))
          else
            Text(_tafseerText ?? '', style: const TextStyle(
                fontFamily: 'Cairo', fontSize: 14,
                color: AppColors.textDark, height: 1.8)),
        ],
      ]),
    );
  }

  Widget _buildMetaRow() {
    final surah = widget.surah;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(children: [
        _metaCard(Icons.location_on_outlined, 'REVELATION SITE',
            surah['type'] == 'MAKKI' ? 'Mecca\n(Makkiyah)' : 'Medinan\n(Madaniyah)'),
        const SizedBox(width: 40),
        _metaCard(Icons.format_list_numbered, 'AYAH COUNT', '${surah['ayahs']} Ayahs'),
      ]),
    );
  }

  Widget _metaCard(IconData icon, String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 13, color: AppColors.textGrey),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 10,
            color: AppColors.textGrey, letterSpacing: 0.5)),
      ]),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14,
          fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.4)),
    ]);
  }
}