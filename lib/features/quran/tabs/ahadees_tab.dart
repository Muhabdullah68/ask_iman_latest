// lib/features/quran/tabs/ahadees_tab.dart
// ─────────────────────────────────────────────────────────────────────────────
// AHADEES TAB — Working API: api.hadith.gading.dev (no key required)
// 4 Books: Sahih Bukhari, Sahih Muslim, Jami Tirmidhi, Sunan Abu Dawud
// - Hadith of the Day banner (deterministic daily pick)
// - 4 book cards → "Read Full Book" (paginates via API)
// - "Filter by Topic" (local curated data)
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_colors.dart';
import '../data/ahadees_data.dart';

// ── API base ──────────────────────────────────────────────────────────────────
const _kBase = 'https://api.hadith.gading.dev';

// ── Book slugs for api.hadith.gading.dev ─────────────────────────────────────
class _BookInfo {
  final String slug;     // gading.dev slug
  final String name;
  final String arabic;
  final int    total;
  final String grade;
  const _BookInfo(this.slug, this.name, this.arabic, this.total, this.grade);
}

const _books = [
  _BookInfo('bukhari',   'Sahih al-Bukhari', 'صحيح البُخاري', 7563, 'SAHIH'),
  _BookInfo('muslim',    'Sahih Muslim',     'صحيح مُسلم',    3032, 'SAHIH'),
  _BookInfo('tirmidhi',  'Jami at-Tirmidhi', 'جامع الترمذي',  3956, 'SAHIH'),
  _BookInfo('abu-dawud', 'Sunan Abu Dawud',  'سنن أبي داود',  4341, 'SAHIH'),
];

const _topics = [
  'All', 'Faith', 'Prayer', 'Charity', 'Fasting',
  'Patience', 'Marriage', 'Character', 'Knowledge',
];

// ══════════════════════════════════════════════════════════════════════════════
// AHADEES TAB
// ══════════════════════════════════════════════════════════════════════════════
class AhadeesTab extends StatefulWidget {
  final String searchQuery;
  const AhadeesTab({super.key, this.searchQuery = ''});
  @override State<AhadeesTab> createState() => _AhadeesTabState();
}

class _AhadeesTabState extends State<AhadeesTab> {
  int _view = 0; // 0=home, 1=book reader, 2=topic filter
  _BookInfo? _selectedBook;
  String _selectedTopic = 'All';

  Map<String, dynamic>? _dailyHadith;
  bool _loadingDaily = true;

  @override
  void initState() { super.initState(); _fetchDailyHadith(); }

  // ── Daily hadith — deterministic by day of year ────────────────────────────
  Future<void> _fetchDailyHadith() async {
    setState(() => _loadingDaily = true);
    try {
      final day = DateTime.now()
          .difference(DateTime(DateTime.now().year, 1, 1)).inDays + 1;
      final num = (day % 100) + 1;
      // GET /books/bukhari/{num}
      final r = await http
          .get(Uri.parse('$_kBase/books/bukhari/$num'))
          .timeout(const Duration(seconds: 8));
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body)['data'];
        if (data != null && mounted) {
          setState(() { _dailyHadith = data as Map<String, dynamic>; _loadingDaily = false; });
          return;
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingDaily = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_view == 1 && _selectedBook != null) {
      return _BookReadScreen(
          book: _selectedBook!, onBack: () => setState(() => _view = 0));
    }
    if (_view == 2) {
      return _TopicFilterScreen(
          topic: _selectedTopic,
          onBack: () => setState(() => _view = 0),
          onTopicChanged: (t) => setState(() => _selectedTopic = t));
    }
    return _buildHome();
  }

  Widget _buildHome() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildDailyBanner(),
        _buildBookListHeader(),
        ..._books.map(_buildBookCard),
        const SizedBox(height: 32),
      ]),
    );
  }

  // ── Hadith of the Day banner ───────────────────────────────────────────────
  Widget _buildDailyBanner() {
    // api.hadith.gading.dev returns: {id, arab, id} — 'id' is the English/Indonesian text
    String displayText = '"The best among you are those who have the best manners."';
    String sourceText  = 'Sahih Bukhari';

    if (!_loadingDaily && _dailyHadith != null) {
      // Try English field first, then arabic as fallback
      final eng = _dailyHadith!['id'] as String? ?? '';
      final ar  = _dailyHadith!['arab'] as String? ?? '';
      if (eng.isNotEmpty) {
        displayText = eng.length > 220 ? '"${eng.substring(0, 220)}..."' : '"$eng"';
      } else if (ar.isNotEmpty) {
        displayText = ar.length > 150 ? '${ar.substring(0, 150)}...' : ar;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(60), topRight: Radius.circular(60),
          bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20),
        ),
        child: SizedBox(
          height: 280,
          child: Stack(fit: StackFit.expand, children: [
            Image.asset('assets/images/mosque interior.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.primaryDarkest)),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Color(0x44000000), Color(0xF00A1F12)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                const Text('HADITH OF THE DAY', style: TextStyle(
                    fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700,
                    color: AppColors.gold, letterSpacing: 2.5)),
                const SizedBox(height: 12),
                if (_loadingDaily)
                  const SizedBox(height: 32,
                      child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2))
                else
                  Text(displayText, textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14,
                          fontWeight: FontWeight.w600, color: AppColors.textWhite,
                          fontStyle: FontStyle.italic, height: 1.55)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
                  decoration: BoxDecoration(
                      color: AppColors.gold, borderRadius: BorderRadius.circular(24)),
                  child: Text(sourceText, style: const TextStyle(fontFamily: 'Cairo',
                      fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryDarkest)),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildBookListHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 22, 16, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Hadith Books', style: TextStyle(fontFamily: 'Cairo',
            fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        Text('4 Authentic Collections', style: TextStyle(
            fontFamily: 'Cairo', fontSize: 13, color: AppColors.textGrey)),
      ]),
    );
  }

  Widget _buildBookCard(_BookInfo book) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          ),
          child: Row(children: [
            Container(
              width: 70, height: 52,
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.gold.withOpacity(0.3)),
              ),
              child: Center(child: Text(book.arabic, textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Amiri', fontSize: 13,
                      color: AppColors.gold, height: 1.4))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(book.name, style: const TextStyle(fontFamily: 'Cairo',
                  fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textWhite)),
              Text('${book.total} Hadiths', style: const TextStyle(
                  fontFamily: 'Cairo', fontSize: 12, color: AppColors.textGreenMuted)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(book.grade, style: const TextStyle(fontFamily: 'Cairo',
                  fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
            ),
          ]),
        ),
        // Action buttons
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(child: _actionBtn(
              icon: Icons.menu_book_rounded, label: 'Read Full Book', dark: true,
              onTap: () => setState(() { _selectedBook = book; _view = 1; }),
            )),
            const SizedBox(width: 10),
            Expanded(child: _actionBtn(
              icon: Icons.filter_list, label: 'Filter by Topic', dark: false,
              onTap: () => setState(() { _selectedBook = book; _view = 2; }),
            )),
          ]),
        ),
      ]),
    );
  }

  Widget _actionBtn({required IconData icon, required String label,
    required bool dark, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: dark ? AppColors.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: dark ? AppColors.primaryDark : AppColors.borderLight),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 16, color: dark ? AppColors.textWhite : AppColors.textGrey),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
              fontWeight: FontWeight.w600,
              color: dark ? AppColors.textWhite : AppColors.textGrey)),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// BOOK READ SCREEN — paginated via api.hadith.gading.dev/books/{slug}?range=1-20
// ══════════════════════════════════════════════════════════════════════════════
class _BookReadScreen extends StatefulWidget {
  final _BookInfo book;
  final VoidCallback onBack;
  const _BookReadScreen({required this.book, required this.onBack});
  @override State<_BookReadScreen> createState() => _BookReadScreenState();
}

class _BookReadScreenState extends State<_BookReadScreen> {
  List<dynamic> _hadiths = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int _rangeStart = 1;
  bool _hasMore = true;
  static const int _perPage = 20;

  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetch();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 400
          && !_loadingMore && _hasMore) {
        _fetchMore();
      }
    });
  }

  @override
  void dispose() { _scroll.dispose(); super.dispose(); }

  // GET /books/{slug}?range=1-20
  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    try {
      final url = '$_kBase/books/${widget.book.slug}'
          '?range=$_rangeStart-${_rangeStart + _perPage - 1}';
      final r = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (r.statusCode == 200) {
        final body = jsonDecode(r.body);
        // gading.dev returns: {data: {hadiths: [{arab, id, number}]}}
        final list = (body['data']?['hadiths'] as List?) ?? [];
        if (mounted) setState(() {
          _hadiths = list;
          _loading = false;
          _rangeStart = _perPage + 1;
          _hasMore = list.length >= _perPage;
        });
        return;
      }
    } catch (e) {
      debugPrint('_fetch error: $e');
    }
    if (mounted) setState(() {
      _loading = false;
      _error = 'Could not load hadiths.\nCheck your connection and try again.';
    });
  }

  Future<void> _fetchMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final end = _rangeStart + _perPage - 1;
      final url = '$_kBase/books/${widget.book.slug}?range=$_rangeStart-$end';
      final r = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (r.statusCode == 200) {
        final body = jsonDecode(r.body);
        final list = (body['data']?['hadiths'] as List?) ?? [];
        if (mounted) setState(() {
          _hadiths.addAll(list);
          _rangeStart = end + 1;
          _hasMore = list.length >= _perPage;
          _loadingMore = false;
        });
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SafeArea(child: Column(children: [
        _buildHeader(),
        if (_loading)
          const Expanded(child: Center(
              child: CircularProgressIndicator(color: AppColors.gold)))
        else if (_error != null)
          _buildError()
        else
          Expanded(child: ListView.builder(
            controller: _scroll,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            itemCount: _hadiths.length + (_loadingMore ? 1 : 0),
            itemBuilder: (_, i) {
              if (i == _hadiths.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator(
                      color: AppColors.gold, strokeWidth: 2)),
                );
              }
              return _HadithCard(hadith: _hadiths[i], bookName: widget.book.name);
            },
          )),
      ])),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.primaryDark,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(children: [
        GestureDetector(
          onTap: widget.onBack,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: AppColors.primaryMid.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_ios_new, color: AppColors.textWhite, size: 14),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.book.name, style: const TextStyle(fontFamily: 'Cairo',
              fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textWhite)),
          Text('${widget.book.total} Hadiths', style: const TextStyle(
              fontFamily: 'Cairo', fontSize: 11, color: AppColors.textGreenMuted)),
        ])),
        Text(widget.book.arabic, textDirection: TextDirection.rtl,
            style: const TextStyle(fontFamily: 'Amiri', fontSize: 20, color: AppColors.gold)),
      ]),
    );
  }

  Widget _buildError() {
    return Expanded(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.wifi_off, size: 48, color: AppColors.textLightGrey),
      const SizedBox(height: 12),
      Text(_error!, textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textGrey)),
      const SizedBox(height: 20),
      GestureDetector(
        onTap: _fetch,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(24)),
          child: const Text('Retry', style: TextStyle(fontFamily: 'Cairo',
              fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryDarkest)),
        ),
      ),
    ])));
  }
}

// ── Hadith card for API response ──────────────────────────────────────────────
class _HadithCard extends StatelessWidget {
  final dynamic hadith;
  final String bookName;
  const _HadithCard({required this.hadith, required this.bookName});

  @override
  Widget build(BuildContext context) {
    // gading.dev fields: number, arab, id (Indonesian/English text)
    final num    = hadith['number']?.toString() ?? '';
    final arabic = hadith['arab']   as String? ?? '';
    final eng    = hadith['id']     as String? ?? '';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.primaryDark, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header row
        Row(children: [
          Text(bookName.toUpperCase(), style: const TextStyle(fontFamily: 'Cairo',
              fontSize: 10, fontWeight: FontWeight.w700,
              color: AppColors.gold, letterSpacing: 0.4)),
          const SizedBox(width: 8),
          if (num.isNotEmpty) Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
                color: AppColors.primaryMid, borderRadius: BorderRadius.circular(6)),
            child: Text('#$num', style: const TextStyle(fontFamily: 'Cairo',
                fontSize: 10, color: AppColors.textGreenMuted)),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6)),
            child: const Text('SAHIH', style: TextStyle(fontFamily: 'Cairo',
                fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success)),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.share_outlined, size: 16, color: AppColors.textGreenMuted),
          const SizedBox(width: 10),
          const Icon(Icons.bookmark_outline, size: 16, color: AppColors.textGreenMuted),
        ]),
        // Arabic
        if (arabic.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(arabic, textDirection: TextDirection.rtl, textAlign: TextAlign.right,
              style: const TextStyle(fontFamily: 'Amiri', fontSize: 20,
                  color: AppColors.textWhite, height: 2.0)),
          Container(height: 1, color: AppColors.primaryMid.withOpacity(0.5)),
        ],
        // English/text
        if (eng.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('"$eng"', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14,
              fontStyle: FontStyle.italic, fontWeight: FontWeight.w500,
              color: AppColors.textWhite, height: 1.6)),
        ],
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TOPIC FILTER SCREEN — local curated hadiths from AhadeesData
// ══════════════════════════════════════════════════════════════════════════════
class _TopicFilterScreen extends StatefulWidget {
  final String topic;
  final VoidCallback onBack;
  final ValueChanged<String> onTopicChanged;
  const _TopicFilterScreen({
    required this.topic, required this.onBack, required this.onTopicChanged});
  @override State<_TopicFilterScreen> createState() => _TopicFilterScreenState();
}

class _TopicFilterScreenState extends State<_TopicFilterScreen> {
  late String _topic;

  @override
  void initState() { super.initState(); _topic = widget.topic; }

  List<Map<String, String>> get _filtered => AhadeesData.byTopic(_topic);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SafeArea(child: Column(children: [
        _buildHeader(),
        _buildTopicChips(),
        Expanded(child: _filtered.isEmpty
            ? const Center(child: Text('No hadiths found for this topic.',
            style: TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey)))
            : ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: _filtered.map((h) => _LocalHadithCard(hadith: h)).toList(),
        )),
      ])),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.primaryDark,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(children: [
        GestureDetector(
          onTap: widget.onBack,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: AppColors.primaryMid.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.textWhite, size: 14),
          ),
        ),
        const SizedBox(width: 14),
        const Text('Filter by Topic', style: TextStyle(fontFamily: 'Cairo',
            fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textWhite)),
      ]),
    );
  }

  Widget _buildTopicChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 0, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(children: _topics.map((t) {
          final active = _topic == t;
          return GestureDetector(
            onTap: () { setState(() => _topic = t); widget.onTopicChanged(t); },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                color: active ? AppColors.gold : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: active ? AppColors.gold : AppColors.borderLight),
              ),
              child: Text(t, style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active ? AppColors.primaryDarkest : AppColors.textGrey)),
            ),
          );
        }).toList()),
      ),
    );
  }
}

class _LocalHadithCard extends StatelessWidget {
  final Map<String, String> hadith;
  const _LocalHadithCard({required this.hadith});

  @override
  Widget build(BuildContext context) {
    final isSahih = hadith['grade'] == 'SAHIH';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.primaryDark, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(hadith['book']!, style: const TextStyle(fontFamily: 'Cairo',
              fontSize: 11, fontWeight: FontWeight.w700,
              color: AppColors.gold, letterSpacing: 0.4)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (isSahih ? AppColors.success : AppColors.warning).withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(hadith['grade']!, style: TextStyle(fontFamily: 'Cairo',
                fontSize: 10, fontWeight: FontWeight.w700,
                color: isSahih ? AppColors.success : AppColors.warning)),
          ),
          const Spacer(),
          const Icon(Icons.share_outlined, size: 16, color: AppColors.textGreenMuted),
          const SizedBox(width: 10),
          const Icon(Icons.bookmark_outline, size: 16, color: AppColors.textGreenMuted),
        ]),
        const SizedBox(height: 14),
        Text(hadith['text']!, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15,
            fontStyle: FontStyle.italic, fontWeight: FontWeight.w600,
            color: AppColors.textWhite, height: 1.6)),
        const SizedBox(height: 14),
        Container(height: 1, color: AppColors.primaryMid.withOpacity(0.5)),
        const SizedBox(height: 10),
        Row(children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.18), shape: BoxShape.circle),
            child: const Icon(Icons.person, size: 12, color: AppColors.gold),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(hadith['narrator']!, style: const TextStyle(
              fontFamily: 'Cairo', fontSize: 12, color: AppColors.textGreenMuted))),
        ]),
      ]),
    );
  }
}