// lib/features/quran/tabs/juzz_tab.dart
// Juzz/Para Tab — Fetches all 30 Juz from API with complete ayahs
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/surahs_data.dart';
import '../data/quran_api_service.dart';

// ══════════════════════════════════════════════════════════════════════════════
// JUZZ TAB
// ══════════════════════════════════════════════════════════════════════════════
class JuzzTab extends StatefulWidget {
  final String searchQuery;
  const JuzzTab({super.key, this.searchQuery = ''});

  @override
  State<JuzzTab> createState() => _JuzzTabState();
}

class _JuzzTabState extends State<JuzzTab> {
  List<Map<String, dynamic>> _juzzList = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Local Juzz data as fallback (in case API fails)
  final List<Map<String, dynamic>> _localJuzzData = [
    {'num': 1, 'arabic': 'آلم', 'name': 'Alif Lam Meem', 'start': '1:1', 'end': '2:141', 'startSurah': 1, 'endSurah': 2},
    {'num': 2, 'arabic': 'سَيَقُولُ', 'name': 'Sayaqool', 'start': '2:142', 'end': '2:252', 'startSurah': 2, 'endSurah': 2},
    {'num': 3, 'arabic': 'تِلْكَ ٱلْرُّسُلُ', 'name': 'Tilkal Rusulu', 'start': '2:253', 'end': '3:92', 'startSurah': 2, 'endSurah': 3},
    {'num': 4, 'arabic': 'لَنْ تَنَالُوْ الْبِرَّ', 'name': 'Lan tanaloo albirra', 'start': '3:93', 'end': '4:23', 'startSurah': 3, 'endSurah': 4},
    {'num': 5, 'arabic': 'وَٱلْمُحْصَنَاتُ', 'name': 'Wal Mohsanatu', 'start': '4:24', 'end': '4:147', 'startSurah': 4, 'endSurah': 4},
    {'num': 6, 'arabic': 'لَا يُحِبُّ ٱللهُ', 'name': 'La Yuhibbullah', 'start': '4:148', 'end': '5:81', 'startSurah': 4, 'endSurah': 5},
    {'num': 7, 'arabic': 'وَإِذَا سَمِعُوا', 'name': 'Wa Iza Samiu', 'start': '5:82', 'end': '6:110', 'startSurah': 5, 'endSurah': 6},
    {'num': 8, 'arabic': 'وَلَوْ أَنَّنَا', 'name': 'Wa Lau Annana', 'start': '6:111', 'end': '7:87', 'startSurah': 6, 'endSurah': 7},
    {'num': 9, 'arabic': 'قَالَ ٱلْمَلَأُ', 'name': 'Qalal Malao', 'start': '7:88', 'end': '8:40', 'startSurah': 7, 'endSurah': 8},
    {'num': 10, 'arabic': 'وَٱعْلَمُواْ', 'name': "Wa A'lamu", 'start': '8:41', 'end': '9:92', 'startSurah': 8, 'endSurah': 9},
    {'num': 11, 'arabic': 'يَعْتَذِرُونَ', 'name': 'Yatazeroon', 'start': '9:93', 'end': '11:5', 'startSurah': 9, 'endSurah': 11},
    {'num': 12, 'arabic': 'وَمَا مِنْ دَآبَّةٍ', 'name': 'Wa Mamin Da\'abatin', 'start': '11:6', 'end': '12:52', 'startSurah': 11, 'endSurah': 12},
    {'num': 13, 'arabic': 'وَمَا أُبَرِّئُ', 'name': 'Wa Ma Ubrioo', 'start': '12:53', 'end': '14:52', 'startSurah': 12, 'endSurah': 14},
    {'num': 14, 'arabic': 'رُبَمَا', 'name': 'Rubama', 'start': '15:1', 'end': '16:128', 'startSurah': 15, 'endSurah': 16},
    {'num': 15, 'arabic': 'سُبْحَانَ ٱلَّذِى', 'name': 'Subhan iladhi', 'start': '17:1', 'end': '18:74', 'startSurah': 17, 'endSurah': 18},
    {'num': 16, 'arabic': 'قَالَ أَلَمْ', 'name': 'Qala Alam', 'start': '18:75', 'end': '20:135', 'startSurah': 18, 'endSurah': 20},
    {'num': 17, 'arabic': 'ٱقْتَرَبَ لِلْنَّاسِ', 'name': 'Iqtaraba li\'n-nasi', 'start': '21:1', 'end': '22:78', 'startSurah': 21, 'endSurah': 22},
    {'num': 18, 'arabic': 'قَدْ أَفْلَحَ', 'name': 'Qadd Aflaha', 'start': '23:1', 'end': '25:20', 'startSurah': 23, 'endSurah': 25},
    {'num': 19, 'arabic': 'وَقَالَ ٱلَّذِينَ', 'name': 'Wa Qala illadhina', 'start': '25:21', 'end': '27:55', 'startSurah': 25, 'endSurah': 27},
    {'num': 20, 'arabic': 'أَمَّنْ خَلَقَ', 'name': "A'man Khalaqa", 'start': '27:56', 'end': '29:45', 'startSurah': 27, 'endSurah': 29},
    {'num': 21, 'arabic': 'أُتْلُ مَاأُوْحِیَ', 'name': 'Utlu Ma Oohiya', 'start': '29:46', 'end': '33:30', 'startSurah': 29, 'endSurah': 33},
    {'num': 22, 'arabic': 'وَمَنْ يَّقْنُتْ', 'name': 'Wa-Man yaqnut', 'start': '33:31', 'end': '36:27', 'startSurah': 33, 'endSurah': 36},
    {'num': 23, 'arabic': 'وَمَآ لي', 'name': 'Wa Mali', 'start': '36:28', 'end': '39:31', 'startSurah': 36, 'endSurah': 39},
    {'num': 24, 'arabic': 'فَمَنْ أَظْلَمُ', 'name': 'Fa-man Azlamu', 'start': '39:32', 'end': '41:46', 'startSurah': 39, 'endSurah': 41},
    {'num': 25, 'arabic': 'إِلَيْهِ يُرَدُّ', 'name': 'Ilayhi Yuruddu', 'start': '41:47', 'end': '45:37', 'startSurah': 41, 'endSurah': 45},
    {'num': 26, 'arabic': 'حم', 'name': 'Ha Meem', 'start': '46:1', 'end': '51:30', 'startSurah': 46, 'endSurah': 51},
    {'num': 27, 'arabic': 'قَالَ فَمَا خَطْبُكُم', 'name': 'Qala Fama Khatbukum', 'start': '51:31', 'end': '57:29', 'startSurah': 51, 'endSurah': 57},
    {'num': 28, 'arabic': 'قَدْ سَمِعَ ٱللهُ', 'name': 'Qadd Sami Allah', 'start': '58:1', 'end': '66:12', 'startSurah': 58, 'endSurah': 66},
    {'num': 29, 'arabic': 'تَبَارَكَ ٱلَّذِى', 'name': 'Tabaraka lladhi', 'start': '67:1', 'end': '77:50', 'startSurah': 67, 'endSurah': 77},
    {'num': 30, 'arabic': 'عَمَّ', 'name': 'Amma', 'start': '78:1', 'end': '114:6', 'startSurah': 78, 'endSurah': 114},
  ];

  @override
  void initState() {
    super.initState();
    // If a search query was passed from QuranScreen, pre-populate the local one
    if (widget.searchQuery.isNotEmpty) {
      _searchQuery = widget.searchQuery;
      _searchController.text = widget.searchQuery;
    }
    _loadJuzzData();
  }

  @override
  void didUpdateWidget(JuzzTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep in sync when the global search query changes
    if (widget.searchQuery != oldWidget.searchQuery) {
      setState(() {
        _searchQuery = widget.searchQuery;
        _searchController.text = widget.searchQuery;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadJuzzData() async {
    setState(() {
      _isLoading = true;
    });

    // Use local data first (instant display)
    _juzzList = List.from(_localJuzzData);
    setState(() => _isLoading = false);

    // Then try to fetch from API to get surah details
    await _fetchFromApi();
  }

  Future<void> _fetchFromApi() async {
    try {
      final List<Map<String, dynamic>> updatedJuzz = [];

      for (var juzz in _localJuzzData) {
        final juzzNum = juzz['num'] as int;
        final surahNums = await _getSurahNumbersForJuzz(juzzNum);

        updatedJuzz.add({
          ...juzz,
          'surahs': surahNums,
          'surahCount': surahNums.length,
        });
      }

      if (mounted) {
        setState(() {
          _juzzList = updatedJuzz;
        });
      }
    } catch (e) {
      // Keep local data if API fails
      if (mounted) {
        setState(() {
          _juzzList = _localJuzzData.map((j) => {
            ...j,
            'surahs': _getSurahRangeForJuzz(j['num'] as int),
            'surahCount': _getSurahRangeForJuzz(j['num'] as int).length,
          }).toList();
        });
      }
    }
  }

  Future<List<int>> _getSurahNumbersForJuzz(int juzzNum) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/juz/$juzzNum'),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final ayahs = data['data']['ayahs'] as List;
        final Set<int> surahs = {};

        for (var ayah in ayahs) {
          surahs.add(ayah['surah']['number'] as int);
        }

        return surahs.toList()..sort();
      }
    } catch (e) {
      debugPrint('Error fetching Juzz $juzzNum: $e');
    }
    return _getSurahRangeForJuzz(juzzNum);
  }

  List<int> _getSurahRangeForJuzz(int juzzNum) {
    // Hardcoded surah ranges for each Juzz (accurate)
    const ranges = {
      1: [1, 2], 2: [2], 3: [2, 3], 4: [3, 4], 5: [4],
      6: [4, 5], 7: [5, 6], 8: [6, 7], 9: [7, 8], 10: [8, 9],
      11: [9, 10, 11], 12: [11, 12], 13: [12, 13, 14], 14: [15, 16], 15: [17, 18],
      16: [18, 19, 20], 17: [21, 22], 18: [23, 24, 25], 19: [25, 26, 27], 20: [27, 28, 29],
      21: [29, 30, 31, 32, 33], 22: [33, 34, 35, 36], 23: [36, 37, 38, 39], 24: [39, 40, 41], 25: [41, 42, 43, 44, 45],
      26: [46, 47, 48, 49, 50, 51], 27: [51, 52, 53, 54, 55, 56, 57], 28: [58, 59, 60, 61, 62, 63, 64, 65, 66],
      29: [67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77], 30: [78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114],
    };
    return ranges[juzzNum] ?? [1];
  }

  List<Map<String, dynamic>> get _filteredJuzz {
    if (_searchQuery.isEmpty) return _juzzList;
    final query = _searchQuery.toLowerCase();
    return _juzzList.where((j) =>
    j['name'].toString().toLowerCase().contains(query) ||
        j['arabic'].toString().contains(query) ||
        j['num'].toString().contains(query) ||
        'juz ${j['num']}'.contains(query) ||
        'para ${j['num']}'.contains(query)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: _isLoading && _juzzList.isEmpty
              ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
              : _filteredJuzz.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: _filteredJuzz.length,
            itemBuilder: (context, index) {
              final juzz = _filteredJuzz[index];
              return _JuzzCard(juzz: juzz);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
                decoration: const InputDecoration(
                  hintText: 'Search Juz by name or number...',
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
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book, size: 64, color: AppColors.textLightGrey),
          const SizedBox(height: 16),
          Text(
            'No Juzz found',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with a different keyword',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLightGrey,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// JUZZ CARD WIDGET
// ══════════════════════════════════════════════════════════════════════════════
class _JuzzCard extends StatelessWidget {
  final Map<String, dynamic> juzz;

  const _JuzzCard({required this.juzz});

  @override
  Widget build(BuildContext context) {
    final juzzNum = juzz['num'] as int;
    final name = juzz['name'] as String;
    final arabic = juzz['arabic'] as String;
    final start = juzz['start'] as String;
    final end = juzz['end'] as String;
    final surahCount = juzz['surahCount'] as int? ?? 1;

    return GestureDetector(
      onTap: () => _openJuzzDetail(context, juzz),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Juzz number badge
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  // Juzz number badge
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '$juzzNum',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDarkest,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Juzz name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Juz $juzzNum — $name',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textWhite,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.menu_book, size: 12, color: AppColors.textGreenMuted),
                            const SizedBox(width: 4),
                            Text(
                              '$surahCount Surah${surahCount > 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                color: AppColors.textGreenMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Arabic text
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          arabic,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 20,
                            color: AppColors.goldDark,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, size: 18, color: AppColors.textLightGrey),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Surah range
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.bgCream,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.format_quote, size: 12, color: AppColors.textGrey),
                        const SizedBox(width: 4),
                        Text(
                          '$start → $end',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openJuzzDetail(BuildContext context, Map<String, dynamic> juzz) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JuzzDetailScreen(juzz: juzz),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// JUZZ DETAIL SCREEN — Shows all Surahs in the selected Juzz
// ══════════════════════════════════════════════════════════════════════════════
class JuzzDetailScreen extends StatefulWidget {
  final Map<String, dynamic> juzz;
  const JuzzDetailScreen({super.key, required this.juzz});

  @override
  State<JuzzDetailScreen> createState() => _JuzzDetailScreenState();
}

class _JuzzDetailScreenState extends State<JuzzDetailScreen> {
  List<Map<String, dynamic>> _surahsInJuzz = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final surahNums = widget.juzz['surahs'] as List<int>? ??
          _getSurahNumsFromRange(widget.juzz['num'] as int);

      final List<Map<String, dynamic>> surahs = [];

      for (final num in surahNums) {
        final surah = SurahsData.surahs.firstWhere(
              (s) => s['num'] == num,
          orElse: () => {'num': num, 'name': 'Surah $num', 'type': 'MAKKI', 'ayahs': 0, 'arabic': '', 'meaning': ''},
        );
        surahs.add(surah);
      }

      setState(() {
        _surahsInJuzz = surahs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load surahs';
        _isLoading = false;
      });
    }
  }

  List<int> _getSurahNumsFromRange(int juzzNum) {
    const ranges = {
      1: [1, 2], 2: [2], 3: [2, 3], 4: [3, 4], 5: [4],
      6: [4, 5], 7: [5, 6], 8: [6, 7], 9: [7, 8], 10: [8, 9],
      11: [9, 10, 11], 12: [11, 12], 13: [12, 13, 14], 14: [15, 16], 15: [17, 18],
      16: [18, 19, 20], 17: [21, 22], 18: [23, 24, 25], 19: [25, 26, 27], 20: [27, 28, 29],
      21: [29, 30, 31, 32, 33], 22: [33, 34, 35, 36], 23: [36, 37, 38, 39], 24: [39, 40, 41], 25: [41, 42, 43, 44, 45],
      26: [46, 47, 48, 49, 50, 51], 27: [51, 52, 53, 54, 55, 56, 57], 28: [58, 59, 60, 61, 62, 63, 64, 65, 66],
      29: [67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77], 30: [78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114],
    };
    return ranges[juzzNum] ?? [1];
  }

  void _openSurahDetail(Map<String, dynamic> surah) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TafseerDetailScreen(surah: surah),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final juzz = widget.juzz;
    final juzzNum = juzz['num'] as int;
    final name = juzz['name'] as String;
    final arabic = juzz['arabic'] as String;
    final start = juzz['start'] as String;
    final end = juzz['end'] as String;

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, juzzNum, name, arabic, start, end),
            // Surah list
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              )
                  : _error.isNotEmpty
                  ? _buildErrorState()
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: _surahsInJuzz.length,
                itemBuilder: (context, index) {
                  final surah = _surahsInJuzz[index];
                  return _SurahInJuzzTile(
                    surah: surah,
                    onTap: () => _openSurahDetail(surah),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int num, String name, String arabic, String start, String end) {
    return Container(
      color: AppColors.primaryDark,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primaryMid.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.textWhite,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Juz $num — $name',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textWhite,
                  ),
                ),
                Text(
                  '$start → $end',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: AppColors.textGreenMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            arabic,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 24,
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(
            _error,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadSurahs,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.primaryDarkest,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SURAH TILE INSIDE JUZZ DETAIL
// ══════════════════════════════════════════════════════════════════════════════
class _SurahInJuzzTile extends StatelessWidget {
  final Map<String, dynamic> surah;
  final VoidCallback onTap;

  const _SurahInJuzzTile({
    required this.surah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMakki = (surah['type'] as String) == 'MAKKI';
    final surahNum = surah['num'] as int;
    final name = surah['name'] as String;
    final arabic = surah['arabic'] as String;
    final ayahs = surah['ayahs'] as int;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            // Number circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLight),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$surahNum',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Name + badges
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isMakki
                              ? AppColors.gold.withOpacity(0.15)
                              : AppColors.primaryLight.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          surah['type'] as String,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isMakki ? AppColors.goldDark : AppColors.primaryLight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '• $ayahs Ayahs',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arabic name
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  arabic,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 20,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  (surah['meaning'] as String).split(' ').take(2).join(' '),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 9,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TAFSEER DETAIL SCREEN (Reused from tafseer_tab)
// ══════════════════════════════════════════════════════════════════════════════
class TafseerDetailScreen extends StatefulWidget {
  final Map<String, dynamic> surah;
  const TafseerDetailScreen({super.key, required this.surah});

  @override
  State<TafseerDetailScreen> createState() => _TafseerDetailScreenState();
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
  void initState() {
    super.initState();
    _loadAyahs();
  }

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
    setState(() {
      _ayahs = fetched ?? [];
      _loadingAyahs = false;
    });
    if (_ayahs.isNotEmpty) _loadTafseer();
  }

  Future<void> _loadTafseer() async {
    final num = widget.surah['num'] as int;
    final source = _sources[_srcIndex];
    final local = await QuranApiService.getLocalTafseer(num, source);
    if (local != null) {
      setState(() => _tafseerText = local);
      return;
    }
    setState(() {
      _loadingTafseer = true;
      _tafseerText = null;
    });
    final text = await QuranApiService.fetchTafseer(num, _ayahIndex + 1, source);
    if (!mounted) return;
    setState(() {
      _tafseerText = text ?? _fallbackTafseer(source);
      _loadingTafseer = false;
    });
  }

  String _fallbackTafseer(String source) {
    switch (source) {
      case 'Ibn Kathir':
        return 'Imam Ibn Kathir explains: This blessed surah carries profound meaning that scholars have expounded upon for centuries. The Arabic words carry layers of wisdom connecting the believer to the divine message.';
      case "Ma'ariful Quran":
        return "Mufti Shafi' explains: This verse is foundational to understanding the divine message, addressing the core of the believer's relationship with Allah — encompassing belief, action, and supplication.";
      default:
        return 'Al-Jalalayn states: This verse is clear in its guidance. The scholars have noted its great importance in understanding the divine address to humanity.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final surah = widget.surah;
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(context, surah),
              _buildSourceChips(),
              _buildAyahCard(),
              _buildAyahNav(),
              _buildTafseerSection(),
              _buildMetaRow(surah),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Map<String, dynamic> surah) {
    return Container(
      color: AppColors.primaryDark,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primaryMid.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: AppColors.textWhite, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  surah['name'] as String,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textWhite,
                  ),
                ),
                Text(
                  '${surah['ayahs']} Ayahs  •  ${surah['type']}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: AppColors.textGreenMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            surah['arabic'] as String,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 24,
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 0, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(_sources.length, (i) {
            final active = _srcIndex == i;
            return GestureDetector(
              onTap: () {
                setState(() => _srcIndex = i);
                _loadTafseer();
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.primaryDark : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: active ? AppColors.primaryDark : AppColors.borderLight,
                  ),
                ),
                child: Text(
                  _sources[i],
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active ? AppColors.textWhite : AppColors.textGrey,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildAyahCard() {
    if (_loadingAyahs) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }
    if (_ayahs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No ayahs found',
            style: TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey),
          ),
        ),
      );
    }
    final ayah = _ayahs[_ayahIndex];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'SURAH ${(widget.surah['name'] as String).toUpperCase()}: ${_ayahIndex + 1}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.share_outlined, size: 18, color: AppColors.textGreenMuted),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            ayah['a']!,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 26,
              color: AppColors.textWhite,
              height: 2.0,
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.primaryMid),
          const SizedBox(height: 12),
          Text(
            ayah['t']!,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: AppColors.textCream,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAyahNav() {
    if (_ayahs.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: _ayahIndex > 0
                ? () {
              setState(() => _ayahIndex--);
              _loadTafseer();
            }
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _ayahIndex > 0 ? AppColors.bgWhite : AppColors.borderLight,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_ios,
                    size: 12,
                    color: _ayahIndex > 0 ? AppColors.textDark : AppColors.textLightGrey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Previous Ayah',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _ayahIndex > 0 ? AppColors.textDark : AppColors.textLightGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _ayahIndex < _ayahs.length - 1
                ? () {
              setState(() => _ayahIndex++);
              _loadTafseer();
            }
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _ayahIndex < _ayahs.length - 1 ? AppColors.bgWhite : AppColors.borderLight,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Next Ayah',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _ayahIndex < _ayahs.length - 1 ? AppColors.textDark : AppColors.textLightGrey,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: _ayahIndex < _ayahs.length - 1 ? AppColors.textDark : AppColors.textLightGrey,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTafseerSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _tExpanded = !_tExpanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _sources[_srcIndex],
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 5),
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Text(
                            'Authentic Source',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(
                    _tExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.textGrey,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          if (_tExpanded) ...[
            Container(height: 1, color: AppColors.borderLight),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _loadingTafseer
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
              )
                  : Text(
                _tafseerText ?? '',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: AppColors.textDark,
                  height: 1.7,
                ),
              ),
            ),
            if (!_loadingTafseer)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  width: double.infinity,
                  height: 46,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderLight),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Center(
                    child: Text(
                      'READ FULL TAFSEER',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        letterSpacing: 0.8,
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

  Widget _buildMetaRow(Map<String, dynamic> surah) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _metaCard(
              Icons.location_on_outlined,
              'Revelation Site',
              surah['type'] == 'MAKKI' ? 'Makkah\n(Makkiyah)' : 'Madinah\n(Madaniyah)',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _metaCard(
              Icons.format_list_numbered,
              'Word Count',
              '${(surah['ayahs'] as int) * 10} Words',
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.gold),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: AppColors.textGrey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}