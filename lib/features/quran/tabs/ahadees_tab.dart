// lib/features/quran/tabs/ahadees_tab.dart
// ─────────────────────────────────────────────────────────────────────────────
// AHADEES TAB — Uses local authentic hadith data
// 6 Books: Bukhari, Muslim, Tirmidhi, Abu Dawud, Nasai, Ibn Majah
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../data/ahadees_data.dart';

// ── Book slugs ───────────────────────────────────────────────────────────────
class _BookInfo {
  final String slug;
  final String name;
  final String arabic;
  final int total;
  final String grade;
  const _BookInfo(this.slug, this.name, this.arabic, this.total, this.grade);
}

const _books = [
  _BookInfo('bukhari', 'Sahih al-Bukhari', 'صحيح البخاري', 100, 'SAHIH'),
  _BookInfo('muslim', 'Sahih Muslim', 'صحيح مسلم', 100, 'SAHIH'),
  _BookInfo('tirmidhi', 'Jami at-Tirmidhi', 'جامع الترمذي', 100, 'SAHIH'),
  _BookInfo('abu-dawud', 'Sunan Abu Dawud', 'سنن أبي داود', 100, 'SAHIH'),
  _BookInfo('nasai', 'Sunan an-Nasai', 'سنن النسائي', 100, 'SAHIH'),
  _BookInfo('ibn-majah', 'Sunan Ibn Majah', 'سنن ابن ماجه', 100, 'SAHIH'),
];

const _topics = [
  'All', 'Character', 'Faith', 'Prayer', 'Charity', 'Fasting',
  'Patience', 'Marriage', 'Knowledge', 'Parents',
  'Modesty', 'Truthfulness', 'Anger', 'Jealousy', 'Jihad',
  'Kindness', 'Hospitality', 'Brotherhood', 'Repentance', 'Paradise',
];

// ══════════════════════════════════════════════════════════════════════════════
// AHADEES TAB
// ══════════════════════════════════════════════════════════════════════════════
class AhadeesTab extends StatefulWidget {
  final String searchQuery;
  final String? arabicFont; // Added to sync font
  final bool useUrduFont; // Added for language preference
  const AhadeesTab({super.key, this.searchQuery = '', this.arabicFont, this.useUrduFont = false});
  @override State<AhadeesTab> createState() => _AhadeesTabState();
}

class _AhadeesTabState extends State<AhadeesTab> with SingleTickerProviderStateMixin {
  late TabController _tc;
  int _view = 0; // 0=home, 1=book reader, 2=topic filter
  _BookInfo? _selectedBook;
  String _selectedTopic = 'All';

  Map<String, String>? _dailyHadith;

  @override
  void initState() { 
    super.initState(); 
    _tc = TabController(length: 2, vsync: this);
    _fetchDailyHadith(); 
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  Future<void> _fetchDailyHadith() async {
    // Use local data for daily hadith
    final day = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays + 1;
    final bookHadiths = AhadeesData.bookHadiths['bukhari']!;
    final index = (day % bookHadiths.length);
    
    if (mounted) {
      setState(() {
        _dailyHadith = bookHadiths[index];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_view == 1 && _selectedBook != null) {
      return _BookReadScreen(
          book: _selectedBook!, 
          arabicFont: widget.arabicFont, // Pass font down
          useUrduFont: widget.useUrduFont,
          onBack: () => setState(() => _view = 0));
    }
    if (_view == 2) {
      return _TopicFilterScreen(
          topic: _selectedTopic,
          onBack: () => setState(() => _view = 0),
          onTopicChanged: (t) => setState(() => _selectedTopic = t),
          searchQuery: widget.searchQuery);
    }

    return Column(
      children: [
        _buildSubTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tc,
            children: [
              _buildHome(),
              _TopicFilterScreen(
                topic: _selectedTopic,
                onBack: () {}, // No back needed in tab view
                onTopicChanged: (t) => setState(() => _selectedTopic = t),
                isTabView: true,
                searchQuery: widget.searchQuery,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: TabBar(
        controller: _tc,
        indicator: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(24),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [Tab(text: 'Books'), Tab(text: 'Search Topics')],
        labelStyle: const TextStyle(
            fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(
            fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w400),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textGrey,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
    );
  }

  Widget _buildHome() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildDailyBanner(),
        _buildBookListHeader(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: _books.length,
            itemBuilder: (context, index) => _buildGridBookCard(_books[index]),
          ),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _buildGridBookCard(_BookInfo book) {
    return GestureDetector(
      onTap: () => setState(() { _selectedBook = book; _view = 1; }),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(book.arabic, textDirection: TextDirection.rtl,
                style: TextStyle(fontFamily: widget.arabicFont ?? 'Amiri', fontSize: 16, color: AppColors.gold)),
            const SizedBox(height: 8),
            Text(book.name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textWhite)),
            const SizedBox(height: 4),
            Text('${book.total} Hadiths', 
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textGreenMuted)),
          ],
        ),
      ),
    );
  }

  // ── Hadith of the Day banner ───────────────────────────────────────────────
  Widget _buildDailyBanner() {
    String displayText = '"The best among you are those who have the best manners.';
    String sourceText  = 'Sahih Bukhari';

    if (_dailyHadith != null) {
      final eng = _dailyHadith!['id'] ?? '';
      final ar  = _dailyHadith!['arabic'] ?? '';
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
        Text('6 Authentic Collections', style: TextStyle(
            fontFamily: 'Cairo', fontSize: 13, color: AppColors.textGrey)),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// BOOK READ SCREEN — local hadith data
// ══════════════════════════════════════════════════════════════════════════════
class _BookReadScreen extends StatefulWidget {
  final _BookInfo book;
  final String? arabicFont;
  final bool useUrduFont;
  final VoidCallback onBack;
  const _BookReadScreen({required this.book, this.arabicFont, this.useUrduFont = false, required this.onBack});
  @override State<_BookReadScreen> createState() => _BookReadScreenState();
}

class _BookReadScreenState extends State<_BookReadScreen> {
  List<Map<String, String>> _hadiths = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    // Load from local data
    final bookHadiths = AhadeesData.getBookHadiths(widget.book.slug);
    if (mounted) {
      setState(() {
        _hadiths = bookHadiths;
        _loading = false;
      });
    }
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
        else
          Expanded(child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            itemCount: _hadiths.length,
            itemBuilder: (_, i) {
              return _HadithCard(
                hadith: _hadiths[i], 
                bookName: widget.book.name,
                arabicFont: widget.arabicFont,
                useUrduFont: widget.useUrduFont,
              );
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
                color: AppColors.primaryMid.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_ios_new, color: AppColors.textWhite, size: 14),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.book.name, style: const TextStyle(fontFamily: 'Cairo',
              fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textWhite)),
          Text('${_hadiths.length} Hadiths', style: const TextStyle(
              fontFamily: 'Cairo', fontSize: 11, color: AppColors.textGreenMuted)),
        ])),
        Text(widget.book.arabic, textDirection: TextDirection.rtl,
            style: TextStyle(fontFamily: widget.arabicFont ?? 'Amiri', fontSize: 20, color: AppColors.gold)),
      ]),
    );
  }
}

// ── Hadith card for local response ─────────────────────────────────────────────
class _HadithCard extends StatelessWidget {
  final Map<String, String> hadith;
  final String bookName;
  final String? arabicFont;
  final bool useUrduFont;
  const _HadithCard({required this.hadith, required this.bookName, this.arabicFont, this.useUrduFont = false});

  @override
  Widget build(BuildContext context) {
    final num    = hadith['number'] ?? '';
    final arabic = hadith['arabic'] ?? '';
    final eng    = hadith['id'] ?? '';

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
                color: AppColors.success.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6)),
            child: const Text('SAHIH', style: TextStyle(fontFamily: 'Cairo',
                fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success)),
          ),
        ]),
        // Arabic
        if (arabic.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(arabic, textDirection: TextDirection.rtl, textAlign: TextAlign.right,
              style: TextStyle(fontFamily: arabicFont ?? 'Amiri', fontSize: 20,
                  color: AppColors.textWhite, height: 2.0)),
          const SizedBox(height: 8),
          Container(height: 1, color: AppColors.primaryMid.withValues(alpha: 0.5)),
        ],
        // English/Urdu/text
        if (eng.isNotEmpty) ...[
          const SizedBox(height: 12),
          if (useUrduFont)
            const Text('(Urdu translation for Hadiths coming soon)', 
                style: TextStyle(fontFamily: 'Cairo', fontSize: 11, 
                    color: AppColors.textGreenMuted, fontStyle: FontStyle.italic))
          else
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
  final bool isTabView;
  final String searchQuery;
  const _TopicFilterScreen({
    required this.topic, required this.onBack, required this.onTopicChanged, this.isTabView = false, this.searchQuery = ''});
  @override State<_TopicFilterScreen> createState() => _TopicFilterScreenState();
}

class _TopicFilterScreenState extends State<_TopicFilterScreen> {
  late String _topic;

  @override
  void initState() { super.initState(); _topic = widget.topic; }

  List<Map<String, String>> _filterHadiths(List<Map<String, String>> hadiths) {
    if (widget.searchQuery.isEmpty) return hadiths;
    final q = widget.searchQuery.toLowerCase();
    return hadiths.where((h) {
      final text = h['text']?.toLowerCase() ?? '';
      final narrator = h['narrator']?.toLowerCase() ?? '';
      final book = h['book']?.toLowerCase() ?? '';
      return text.contains(q) || narrator.contains(q) || book.contains(q);
    }).toList();
  }

  List<Map<String, String>> get _filtered => _filterHadiths(AhadeesData.byTopic(_topic));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: Column(children: [
        if (!widget.isTabView) _buildHeader(),
        _buildTopicChips(),
        Expanded(child: _filtered.isEmpty
            ? Center(child: Text(widget.searchQuery.isEmpty ? 'No hadiths found for this topic.' : 'No hadiths found for your search.',
            style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey)))
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
                color: AppColors.primaryMid.withValues(alpha: 0.6),
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
                color: active ? AppColors.primaryDark : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: active ? AppColors.primaryDark : AppColors.borderLight),
              ),
              child: Text(t, style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : AppColors.textGrey)),
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
              color: (isSahih ? AppColors.success : AppColors.warning).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(hadith['grade']!, style: TextStyle(fontFamily: 'Cairo',
                fontSize: 10, fontWeight: FontWeight.w700,
                color: isSahih ? AppColors.success : AppColors.warning)),
          ),
          const Spacer(),
          const Icon(Icons.share_outlined, size: 16, color: AppColors.textGreenMuted),
          const SizedBox(width: 10),
          const Icon(Icons.bookmark_outlined, size: 16, color: AppColors.textGreenMuted),
        ]),
        const SizedBox(height: 14),
        Text(hadith['text']!, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15,
            fontStyle: FontStyle.italic, fontWeight: FontWeight.w600,
            color: AppColors.textWhite, height: 1.6)),
        const SizedBox(height: 14),
        Container(height: 1, color: AppColors.primaryMid.withValues(alpha: 0.5)),
        const SizedBox(height: 10),
        Row(children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.18), shape: BoxShape.circle),
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
