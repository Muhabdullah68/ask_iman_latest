// lib/features/quran/quran_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'tabs/talawat_tab.dart';
import 'tabs/translation_tab.dart';
import 'tabs/tafseer_tab.dart';
import 'tabs/ayah_tab.dart';
import 'tabs/ahadees_tab.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});
  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tc;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const _tabs = [
    'Talawat', 'Tarjuma', 'Tafseer', 'Ayat', 'Ahadees',
  ];

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: _tabs.length, vsync: this);    _tc.addListener(() => setState(() {})); // rebuild on tab change for search hint
  }

  @override
  void dispose() {
    _tc.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Search hint text per tab ───────────────────────────────────────────────
  String get _searchHint {
    switch (_tc.index) {
      case 0: return 'Search Surah or Juz...';
      case 1: return 'Search Surah or Juz...';
      case 2: return 'Search Surah...';
      case 3: return 'Search Ayah by topic...';
      case 4: return 'Search Hadith or topic...';
      case 5: return 'Search Juz by name or number...';
      default: return 'Search...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.quranBgLightGreen,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tc,
              physics: const BouncingScrollPhysics(),
              children: [
                TalawatTab(searchQuery: _searchQuery),
                TranslationTab(searchQuery: _searchQuery),
                TafseerTab(searchQuery: _searchQuery),
                AyahTab(searchQuery: _searchQuery),
                AhadeesTab(searchQuery: _searchQuery),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.quranBgLightGreen,
      elevation: 0,
      title: const Text(
        'Al-Quran',
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryDarkest,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: () {},
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.bookmark_outline,
                color: AppColors.primaryDark, size: 22),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ── Always-visible search bar ─────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      color: AppColors.quranBgLightGreen,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _searchQuery.isNotEmpty
                ? AppColors.gold.withOpacity(0.5)
                : AppColors.borderLight,
            width: _searchQuery.isNotEmpty ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _searchQuery.isNotEmpty
                  ? AppColors.gold.withOpacity(0.10)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(
              Icons.search,
              color: _searchQuery.isNotEmpty
                  ? AppColors.gold
                  : AppColors.textLightGrey,
              size: 20,
            ),
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
                decoration: InputDecoration(
                  hintText: _searchHint,
                  hintStyle: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: AppColors.textLightGrey,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            // Clear button — appears only when typing
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                  FocusScope.of(context).unfocus();
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.textLightGrey.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close,
                      size: 14, color: AppColors.textGrey),
                ),
              )
            else
              const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }

  // ── Tab bar ────────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      color: AppColors.quranBgLightGreen,
      padding: const EdgeInsets.only(bottom: 6),
      child: TabBar(
        controller: _tc,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
        indicator: BoxDecoration(
          color: const Color(0xFF2D6A4F),   // readable deep mint-green
          borderRadius: BorderRadius.circular(30),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 4),
        labelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelColor: Colors.white,                 // white on green — readable
        unselectedLabelColor: AppColors.textGrey,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
    );
  }
}