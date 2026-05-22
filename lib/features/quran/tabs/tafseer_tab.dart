import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/ask_iman_app_bar.dart';
import '../data/curated_data.dart';
import '../data/surahs_data.dart';
import '../data/quran_api_service.dart';

class TafseerTab extends StatefulWidget {
  final String searchQuery;
  final bool useUrduFont;
  final String? arabicFont;
  const TafseerTab({super.key, this.searchQuery = '', this.useUrduFont = false, this.arabicFont});

  @override
  State<TafseerTab> createState() => _TafseerTabState();
}

class _TafseerTabState extends State<TafseerTab> with SingleTickerProviderStateMixin {
  late TabController _sub;
  bool _isUrdu = false;
  final _sources = [
    {'id': 'ibn-kathir', 'name': 'Ibn Kathir', 'arabic': 'تفسیر ابنِ کثیر'},
    {'id': 'maariful-quran', 'name': "Ma'ariful Quran", 'arabic': 'معارف القرآن'},
    {'id': 'al-jalalayn', 'name': 'Al-Jalalayn', 'arabic': 'تفسیر جلالین'},
  ];
  final String _selectedTopic = 'Character';

  @override
  void initState() {
    super.initState();
    _sub = TabController(length: 2, vsync: this);
    _isUrdu = widget.useUrduFont;
  }

  @override
  void dispose() {
    _sub.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildLanguageToggle(),
        _buildSubTabBar(),
        Expanded(
          child: TabBarView(
            controller: _sub,
            children: [
              _buildBooksHome(),
              _TopicContent(
                topic: _selectedTopic,
                useUrduFont: _isUrdu,
                arabicFont: widget.arabicFont,
                showTafseer: true,
                source: 'Ibn Kathir',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageToggle() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _toggleBtn('ENGLISH', !_isUrdu, () => setState(() => _isUrdu = false)),
          const SizedBox(width: 8),
          _toggleBtn('اردو', _isUrdu, () => setState(() => _isUrdu = true)),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.gold : AppColors.bgCream,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppColors.gold : AppColors.borderLight),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: active ? AppColors.primaryDarkest : AppColors.textGrey,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSubTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: TabBar(
        controller: _sub,
        indicator: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(24),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [Tab(text: 'Books'), Tab(text: 'Topics')],
        labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w400),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textGrey,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
    );
  }

  Widget _buildBooksHome() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDailyBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Text(_isUrdu ? 'مستند کتبِ تفسیر' : 'Authentic Tafseer Books', 
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _sources.length,
              itemBuilder: (ctx, i) => _buildBookCard(_sources[i]),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildBookCard(Map<String, String> book) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => TafseerVolumePicker(book: book, isUrdu: _isUrdu, arabicFont: widget.arabicFont),
        ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_rounded, color: AppColors.gold, size: 32),
            const SizedBox(height: 12),
            Text(book['arabic']!, textDirection: TextDirection.rtl,
                style: TextStyle(fontFamily: widget.arabicFont ?? 'AlQalam', fontSize: 18, color: AppColors.gold)),
            const SizedBox(height: 8),
            Text(_isUrdu && book['name'] == 'Ibn Kathir' ? 'تفسیر ابنِ کثیر' : 
                 _isUrdu && book['name'] == 'Ma\'ariful Quran' ? 'معارف القرآن' :
                 _isUrdu && book['name'] == 'Al-Jalalayn' ? 'تفسیر جلالین' : book['name']!, 
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            image: const DecorationImage(
              image: AssetImage('assets/images/mosque interior.png'),
              fit: BoxFit.cover,
              opacity: 0.15,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 20, left: 20,
                child: Text(_isUrdu ? 'آج کی تفسیر' : 'TAFSEER OF THE DAY', style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.gold, letterSpacing: 1.5)),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(_isUrdu ? '”اور بے شک آپ اخلاق کے بڑے درجے پر ہیں۔“' : '“And indeed, you are of a great moral character.”', 
                      textDirection: _isUrdu ? TextDirection.rtl : TextDirection.ltr,
                      style: TextStyle(fontFamily: _isUrdu ? 'NotoNastaliq' : 'Cairo', fontSize: _isUrdu ? 14 : 15, fontWeight: FontWeight.w600, color: Colors.white, fontStyle: _isUrdu ? FontStyle.normal : FontStyle.italic)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: _isUrdu ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.menu_book_rounded, color: AppColors.gold, size: 14),
                        const SizedBox(width: 6),
                        Text(_isUrdu ? 'ابنِ کثیر • القلم 68:4' : 'Ibn Kathir • Al-Qalam 68:4', 
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.7))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TafseerVolumePicker extends StatelessWidget {
  final Map<String, String> book;
  final bool isUrdu;
  final String? arabicFont;

  const TafseerVolumePicker({
    super.key,
    required this.book,
    required this.isUrdu,
    this.arabicFont,
  });

  @override
  Widget build(BuildContext context) {
    final volumes = _getVolumes(book['name'] ?? '', isUrdu);
    final themeColor = AppColors.primaryDark;

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AskImanAppBar(
        showBackButton: true,
        title: isUrdu ? _urduBookName(book['name'] ?? '') : book['name'],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/mosque interior.png'),
            fit: BoxFit.cover,
            opacity: 0.02,
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUrdu ? 'جلد منتخب کریں' : 'Select Volume',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isUrdu ? 'مطالعہ شروع کرنے کے لیے کسی بھی جلد پر کلک کریں۔' : 'Select a volume to begin continuous scholarly reading of this complete work.',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textGrey, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _buildVolumeCard(context, volumes[i], themeColor),
                  childCount: volumes.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeCard(BuildContext context, Map<String, dynamic> vol, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => TafseerVolumeReader(
            book: book,
            volume: vol,
            isUrdu: isUrdu,
            arabicFont: arabicFont,
          ),
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16)),
              child: Icon(Icons.auto_stories_rounded, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(vol['name'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                  const SizedBox(height: 4),
                  Text(vol['range'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textGrey, letterSpacing: 0.5)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.gold, size: 16),
          ],
        ),
      ),
    );
  }

  String _urduBookName(String name) {
    if (name == 'Ibn Kathir') return 'تفسیر ابنِ کثیر';
    if (name == "Ma'ariful Quran") return 'معارف القرآن';
    if (name == 'Al-Jalalayn') return 'تفسیر جلالین';
    return name;
  }

  List<Map<String, dynamic>> _getVolumes(String bookName, bool isUrdu) {
    if (bookName.contains('Kathir')) {
      return List.generate(10, (i) => {
        'name': isUrdu ? 'جلد ${i + 1}' : 'Volume ${i + 1}',
        'id': i + 1,
        'range': _getRangeForKathir(i + 1),
      });
    }
    if (bookName.contains('Ma\'ariful')) {
      return List.generate(8, (i) => {
        'name': isUrdu ? 'جلد ${i + 1}' : 'Volume ${i + 1}',
        'id': i + 1,
        'range': _getRangeForMaariful(i + 1),
      });
    }
    return [
      {'name': isUrdu ? 'مکمل جلد' : 'Complete Work', 'id': 1, 'range': 'Surah 1 - 114'}
    ];
  }

  String _getRangeForKathir(int vol) {
    final ranges = ['Surah 1 - 2', 'Surah 3 - 4', 'Surah 5 - 7', 'Surah 8 - 12', 'Surah 13 - 18', 'Surah 19 - 25', 'Surah 26 - 33', 'Surah 34 - 45', 'Surah 46 - 66', 'Surah 67 - 114'];
    return ranges[vol - 1];
  }

  String _getRangeForMaariful(int vol) {
    final ranges = ['Surah 1 - 2', 'Surah 3 - 4', 'Surah 5 - 8', 'Surah 9 - 16', 'Surah 17 - 25', 'Surah 26 - 37', 'Surah 38 - 56', 'Surah 57 - 114'];
    return ranges[vol - 1];
  }
}

class TafseerVolumeReader extends StatefulWidget {
  final Map<String, String> book;
  final Map<String, dynamic> volume;
  final bool isUrdu;
  final String? arabicFont;

  const TafseerVolumeReader({
    super.key,
    required this.book,
    required this.volume,
    required this.isUrdu,
    this.arabicFont,
  });

  @override
  State<TafseerVolumeReader> createState() => _TafseerVolumeReaderState();
}

class _TafseerVolumeReaderState extends State<TafseerVolumeReader> {
  final List<Map<String, dynamic>> _loadedSurahs = [];
  bool _isLoading = true;
  String? _error;
  late List<Map<String, dynamic>> _surahsInVolume;
  final ScrollController _scrollController = ScrollController();
  int _currentSurahIndex = 0;

  @override
  void initState() {
    super.initState();
    _parseVolumeRange();
    _loadNextSurah();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _parseVolumeRange() {
    final range = widget.volume['range'] as String;
    final match = RegExp(r'Surah (\d+) - (\d+)').firstMatch(range);
    final start = int.tryParse(match?.group(1) ?? '1') ?? 1;
    final end = int.tryParse(match?.group(2) ?? '114') ?? 114;

    _surahsInVolume = SurahsData.surahs.where((s) {
      final n = s['num'] as int;
      return n >= start && n <= end;
    }).toList();
  }

  Future<void> _loadNextSurah() async {
    if (_currentSurahIndex >= _surahsInVolume.length) return;

    setState(() => _isLoading = true);
    final surah = _surahsInVolume[_currentSurahIndex];
    final num = surah['num'] as int;

    try {
      final content = await QuranApiService.fetchChapterTafseer(
        num, 
        widget.book['name'] ?? '', 
        isUrdu: widget.isUrdu
      );

      if (mounted) {
        setState(() {
          if (content != null) {
            _loadedSurahs.add({
              'info': surah,
              'content': content,
            });
            _currentSurahIndex++;
          } else {
            _error = 'Failed to load content for ${surah['name']}';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 500) {
      if (!_isLoading && _currentSurahIndex < _surahsInVolume.length) {
        _loadNextSurah();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AskImanAppBar(
        showBackButton: true,
        title: widget.volume['name'],
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt_rounded, color: AppColors.gold),
            onPressed: _showTableOfContents,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/mosque interior.png'),
            fit: BoxFit.cover,
            opacity: 0.03,
          ),
        ),
        child: _loadedSurahs.isEmpty && _isLoading 
            ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
            : _error != null && _loadedSurahs.isEmpty
                ? _buildError()
                : _buildReaderList(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(_error ?? 'An error occurred', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo')),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadNextSurah,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, foregroundColor: AppColors.gold),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReaderList() {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 24),
      itemCount: _loadedSurahs.length + (_currentSurahIndex < _surahsInVolume.length ? 1 : 0),
      itemBuilder: (ctx, index) {
        if (index == _loadedSurahs.length) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
          );
        }

        final surahData = _loadedSurahs[index];
        return Column(
          children: [
            _buildSurahHeader(surahData['info']),
            ... (surahData['content'] as List).map((ayah) => _buildAyahTafseerCard(ayah)),
            const SizedBox(height: 40),
          ],
        );
      },
    );
  }

  Widget _buildSurahHeader(Map<String, dynamic> surah) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Text(
            surah['arabic'],
            style: TextStyle(
              fontFamily: widget.arabicFont ?? 'AlQalam',
              fontSize: 32,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isUrdu ? surah['name'] : surah['name'].toString().toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${surah['type']} • ${surah['ayahs']} AYATA',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.gold.withValues(alpha: 0.7),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAyahTafseerCard(Map<String, dynamic> ayah) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: widget.isUrdu ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: widget.isUrdu ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: Text(
                  ayah['ayah_key'],
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _renderMixedText(
            ayah['text'],
            widget.isUrdu,
            arabicFont: widget.arabicFont,
          ),
        ],
      ),
    );
  }

  void _showTableOfContents() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCream,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TABLE OF CONTENTS',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primaryDark, letterSpacing: 1.5),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _surahsInVolume.length,
                itemBuilder: (ctx, i) {
                  final surah = _surahsInVolume[i];
                  final isLoaded = i < _currentSurahIndex;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(surah['name'], style: TextStyle(fontFamily: 'Cairo', fontWeight: isLoaded ? FontWeight.w700 : FontWeight.w400, color: isLoaded ? AppColors.primaryDark : AppColors.textGrey)),
                    trailing: isLoaded ? const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20) : null,
                    onTap: () {
                      Navigator.pop(context);
                      // If already loaded, scroll to it
                      // If not loaded, we might need a jump-to logic (complex for infinite scroll)
                      // For now, just scroll if loaded
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Backward compatibility for single surah access from other tabs
class TafseerReaderScreen extends StatelessWidget {
  final Map<String, dynamic> surah;
  final Map<String, String> book;
  final bool isUrdu;
  final String? arabicFont;

  const TafseerReaderScreen({
    super.key,
    required this.surah,
    required this.book,
    required this.isUrdu,
    this.arabicFont,
  });

  @override
  Widget build(BuildContext context) {
    return TafseerVolumeReader(
      book: book,
      volume: {
        'name': surah['name'],
        'range': 'Surah ${surah['num']} - ${surah['num']}',
      },
      isUrdu: isUrdu,
      arabicFont: arabicFont,
    );
  }
}

class _TopicContent extends StatelessWidget {
  final String topic;
  final bool useUrduFont;
  final String? arabicFont;
  final bool showTafseer;
  final String source;
  const _TopicContent({required this.topic, required this.useUrduFont, this.arabicFont, required this.showTafseer, required this.source});

  @override
  Widget build(BuildContext context) {
    final ayats = CuratedData.topicAyats[topic] ?? [];
    if (ayats.isEmpty) return const Center(child: Text('Coming Soon...', style: TextStyle(fontFamily: 'Cairo')));
    final daily = CuratedData.getDailyAyat(topic);
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        if (daily.isNotEmpty) ...[
          Padding(padding: const EdgeInsets.only(bottom: 12, left: 4), child: Row(children: [const Icon(Icons.auto_awesome, color: AppColors.gold, size: 18), const SizedBox(width: 8), const Text('DAILY INSPIRATION', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryDark, letterSpacing: 0.5))])),
          _AyahTafseerCard(item: daily, useUrduFont: useUrduFont, arabicFont: arabicFont, showTafseer: showTafseer, isDaily: true, source: source),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: AppColors.gold, thickness: 0.5)),
        ],
        ...ayats.map((item) => _AyahTafseerCard(item: item, useUrduFont: useUrduFont, arabicFont: arabicFont, showTafseer: showTafseer, source: source)),
      ],
    );
  }
}

class _AyahTafseerCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool useUrduFont;
  final String? arabicFont;
  final bool showTafseer;
  final bool isDaily;
  final String source;
  const _AyahTafseerCard({required this.item, required this.useUrduFont, this.arabicFont, required this.showTafseer, this.isDaily = false, required this.source});

  @override
  Widget build(BuildContext context) {
    final aFont = arabicFont ?? (useUrduFont ? 'NotoNastaliq' : 'AlQalam');
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: isDaily ? AppColors.primaryDark.withValues(alpha: 0.02) : AppColors.bgWhite, borderRadius: BorderRadius.circular(20), border: Border.all(color: isDaily ? AppColors.gold.withValues(alpha: 0.5) : AppColors.gold.withValues(alpha: 0.2), width: isDaily ? 1.5 : 1), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(item['ref']?.toString() ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.goldDark, letterSpacing: 0.5)),
            if (isDaily) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(4)), child: const Text('TODAY', style: TextStyle(fontFamily: 'Cairo', fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.primaryDarkest))),
          ]),
          const SizedBox(height: 12),
          Text(item['arabic']?.toString() ?? '', textDirection: TextDirection.rtl, style: TextStyle(fontFamily: aFont, fontSize: useUrduFont ? 18 : 24, color: AppColors.textDark, height: 1.8)),
          const SizedBox(height: 16),
          if (!useUrduFont) _buildLangSection('English', item['english_trans']?.toString() ?? '', item['english_tafseer']?.toString(), source),
          if (useUrduFont) _buildLangSection('Urdu', item['urdu_trans']?.toString() ?? '', item['urdu_tafseer']?.toString(), source),
        ],
      ),
    );
  }

  Widget _buildLangSection(String lang, String trans, String? tafseer, String source) {
    final isU = lang == 'Urdu';
    return Column(
      crossAxisAlignment: isU ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(lang, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primaryDark.withValues(alpha: 0.5))),
        const SizedBox(height: 4),
        _renderMixedText(trans, isU, fontSize: isU ? 13 : 14, color: AppColors.textDark, height: 1.5, arabicFont: arabicFont),
        if (showTafseer && tafseer != null) ...[
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.quranBgLightGreen.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: isU ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
            Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.menu_book_rounded, size: 12, color: AppColors.goldDark), const SizedBox(width: 4), Text('Tafseer: $source', style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.goldDark))]),
            const SizedBox(height: 4),
            _renderMixedText(tafseer, isU, fontSize: isU ? 12 : 13, color: AppColors.textGrey, height: 1.6, arabicFont: arabicFont),
          ])),
        ],
      ],
    );
  }
}

Widget _renderMixedText(String text, bool isUrdu, {double? fontSize, Color? color, double? height, String? arabicFont}) {
  // Regex for Arabic characters including vowels and markers
  final arabicRegex = RegExp(r'([\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]+)');
  
  final parts = text.split(arabicRegex);
  final matches = arabicRegex.allMatches(text).map((m) => m.group(0)).toList();
  
  List<TextSpan> spans = [];
  
  for (int i = 0; i < parts.length; i++) {
    if (parts[i].isNotEmpty) {
      spans.add(TextSpan(
        text: parts[i],
        style: TextStyle(
          fontFamily: isUrdu ? 'NotoNastaliq' : 'Cairo',
          fontSize: fontSize ?? (isUrdu ? 17 : 16),
          color: color ?? AppColors.primaryDarkest,
          height: height ?? 2.2,
        ),
      ));
    }
    if (i < matches.length) {
      spans.add(TextSpan(
        text: matches[i],
        style: TextStyle(
          fontFamily: arabicFont ?? 'AlQalam',
          fontSize: (fontSize ?? (isUrdu ? 17 : 16)) * 1.3, // Arabic usually needs to be slightly larger
          color: color ?? AppColors.primaryDarkest,
          height: height ?? 2.2,
        ),
      ));
    }
  }
  
  return RichText(
    textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
    textAlign: isUrdu ? TextAlign.right : TextAlign.left,
    text: TextSpan(children: spans),
  );
}
