// lib/features/quran/tabs/translation_tab.dart
// TARJUMA TAB — Arabic + English translation (Sahih International)
// Sub-tabs: Surah | Juzz → tap → ArabicReadScreen(showTranslation: true)
//
// NOTE: All Bismillah-duplication fixes and Mushaf-style layout are handled
// inside ArabicReadScreen in talawat_tab.dart. No changes needed here beyond
// reusing those widgets.

import 'package:flutter/material.dart';
import 'talawat_tab.dart'; // To reuse Surah/Juz list components

// ══════════════════════════════════════════════════════════════════════════════
// TRANSLATION TAB
// ══════════════════════════════════════════════════════════════════════════════
class TranslationTab extends StatefulWidget {
  final String searchQuery;
  final bool useUrduFont;
  final String? arabicFont;
  const TranslationTab({super.key, this.searchQuery = '', this.useUrduFont = false, this.arabicFont});

  @override
  State<TranslationTab> createState() => _TranslationTabState();
}

class _TranslationTabState extends State<TranslationTab> with SingleTickerProviderStateMixin {
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
            TalawatSubListView(
              mode: ReadMode.tarjuma,
              searchQuery: widget.searchQuery,
              useUrduFont: widget.useUrduFont,
              arabicFont: widget.arabicFont,
              isJuz: false,
            ),
            TalawatSubListView(
              mode: ReadMode.tarjuma,
              searchQuery: widget.searchQuery,
              useUrduFont: widget.useUrduFont,
              arabicFont: widget.arabicFont,
              isJuz: true,
            ),
          ],
        ),
      ),
    ]);
  }
}
