// lib/features/quran/tabs/translation_tab.dart
// TARJUMA TAB — Arabic + English translation (Sahih International)
// Sub-tabs: Surah | Juzz → tap → ArabicReadScreen(showTranslation: true)
//
// NOTE: All Bismillah-duplication fixes and Mushaf-style layout are handled
// inside ArabicReadScreen in talawat_tab.dart. No changes needed here beyond
// reusing those widgets.

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../data/surahs_data.dart';
import 'talawat_tab.dart'; // SharedSurahCard, SharedJuzCard, ArabicReadScreen, kJuzList, SharedSubTabBar

// ══════════════════════════════════════════════════════════════════════════════
// TRANSLATION TAB
// ══════════════════════════════════════════════════════════════════════════════
class TranslationTab extends StatefulWidget {
  final String searchQuery;
  const TranslationTab({super.key, this.searchQuery = ''});
  @override
  State<TranslationTab> createState() => _TranslationTabState();
}

class _TranslationTabState extends State<TranslationTab>
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
            _TransSurahList(searchQuery: widget.searchQuery),
            _TransJuzList(searchQuery: widget.searchQuery),
          ],
        ),
      ),
    ]);
  }
}

// ── Surah list ────────────────────────────────────────────────────────────────
class _TransSurahList extends StatelessWidget {
  final String searchQuery;
  const _TransSurahList({this.searchQuery = ''});

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
    if (list.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.search_off, size: 56, color: AppColors.textLightGrey),
          const SizedBox(height: 12),
          Text('No results for "$searchQuery"',
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 15,
                  fontWeight: FontWeight.w600, color: AppColors.textGrey)),
        ]),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final s = list[i];
        return SharedSurahCard(
          surah: s,
          onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => ArabicReadScreen(surah: s, showTranslation: true))),
        );
      },
    );
  }
}

// ── Juz list ──────────────────────────────────────────────────────────────────
class _TransJuzList extends StatelessWidget {
  final String searchQuery;
  const _TransJuzList({this.searchQuery = ''});

  List<JuzMeta> get _filtered {
    if (searchQuery.isEmpty) return kJuzList;
    final q = searchQuery.toLowerCase();
    return kJuzList.where((j) =>
    j.name.toLowerCase().contains(q) ||
        j.ar.contains(q) ||
        '${j.num}'.contains(q) ||
        'juz ${j.num}'.contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    if (list.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.search_off, size: 56, color: AppColors.textLightGrey),
          const SizedBox(height: 12),
          Text('No results for "$searchQuery"',
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 15,
                  fontWeight: FontWeight.w600, color: AppColors.textGrey)),
        ]),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: list.length,
      itemBuilder: (_, i) => SharedJuzCard(
        meta: list[i],
        onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => ArabicReadScreen.juz(
                meta: list[i], showTranslation: true))),
      ),
    );
  }
}
