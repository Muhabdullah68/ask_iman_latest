// lib/features/quran/tabs/ayah_tab.dart
// ─────────────────────────────────────────────────────────────────────────────
// AYAAT TAB — Topic-based curated Quran ayahs
// Topics: Mercy, Patience, Tawbah, Forgiveness, Gratitude, Hope, Prayer, Death
// Each ayah: Arabic + Sahih International translation + Surah reference
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/breakpoints.dart';
import '../data/curated_data.dart';

class AyahTab extends StatefulWidget {
  final String searchQuery;
  final bool useUrduFont;
  final String? arabicFont;
  const AyahTab({
    super.key,
    this.searchQuery = '',
    this.useUrduFont = false,
    this.arabicFont,
  });
  @override
  State<AyahTab> createState() => _AyahTabState();
}

class _AyahTabState extends State<AyahTab> with SingleTickerProviderStateMixin {
  late TabController _topicController;
  bool _isUrdu = false;

  @override
  void initState() {
    super.initState();
    _topicController = TabController(
      length: CuratedData.topics.length,
      vsync: this,
    );
    _isUrdu = widget.useUrduFont;
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildLanguageToggle(),
          _buildTopicBar(),
          Expanded(
            child: TabBarView(
              controller: _topicController,
              children: CuratedData.topics
                  .map(
                    (topic) => _TopicContent(
                      topic: topic,
                      useUrduFont: _isUrdu,
                      arabicFont: widget.arabicFont,
                      showTafseer: false,
                      searchQuery: widget.searchQuery,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _toggleBtn(
            'ENGLISH',
            !_isUrdu,
            () => setState(() => _isUrdu = false),
          ),
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
          border: Border.all(
            color: active ? AppColors.gold : AppColors.borderLight,
          ),
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

  Widget _buildTopicBar() {
    return Container(
      height: 60,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TabBar(
        controller: _topicController,
        isScrollable: true,
        indicator: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(24),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textGrey,
        labelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w400,
          fontSize: 13,
        ),
        tabs: CuratedData.topics
            .map(
              (t) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Tab(text: t),
              ),
            )
            .toList(),
      ),
    );
  }
}

// Re-defining for now to keep files independent or I could move them to shared widgets
class _TopicContent extends StatelessWidget {
  final String topic;
  final bool useUrduFont;
  final String? arabicFont;
  final bool showTafseer;
  final String searchQuery;

  const _TopicContent({
    required this.topic,
    required this.useUrduFont,
    this.arabicFont,
    required this.showTafseer,
    this.searchQuery = '',
  });

  List<Map<String, dynamic>> _filterAyats(List<Map<String, dynamic>> ayats) {
    if (searchQuery.isEmpty) return ayats;
    final q = searchQuery.toLowerCase();
    return ayats.where((a) {
      final ref = a['ref']?.toString().toLowerCase() ?? '';
      final englishTrans = a['english_trans']?.toString().toLowerCase() ?? '';
      final urduTrans = a['urdu_trans']?.toString().toLowerCase() ?? '';
      final arabicText = a['arabic']?.toString() ?? '';
      return ref.contains(q) ||
          englishTrans.contains(q) ||
          urduTrans.contains(q) ||
          arabicText.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ayats = CuratedData.topicAyats[topic] ?? [];
    if (ayats.isEmpty) {
      return const Center(
        child: Text('Coming Soon...', style: TextStyle(fontFamily: 'Cairo')),
      );
    }

    final daily = CuratedData.getDailyAyat(topic);
    final filteredAyats = _filterAyats(
      ayats.where((a) => a['ref'] != daily['ref']).toList(),
    );
    final filteredDaily = _filterAyats([daily]).isNotEmpty ? daily : null;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        if (filteredDaily != null) ...[
          _buildDailyHeader(),
          _AyahTafseerCard(
            item: filteredDaily,
            useUrduFont: useUrduFont,
            arabicFont: arabicFont,
            showTafseer: showTafseer,
            isDaily: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'EXPLORE MORE',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textLightGrey,
                    ),
                  ),
                ),
                Expanded(child: Divider()),
              ],
            ),
          ),
        ],
        if (context.isTablet || context.isDesktop)
          LayoutBuilder(
            builder: (ctx, c) {
              final itemW = (c.maxWidth - 16) / 2;
              return Wrap(
                spacing: 16,
                runSpacing: 0,
                children: [
                  for (final item in filteredAyats)
                    SizedBox(
                      width: itemW,
                      child: _AyahTafseerCard(
                        item: item,
                        useUrduFont: useUrduFont,
                        arabicFont: arabicFont,
                        showTafseer: showTafseer,
                      ),
                    ),
                ],
              );
            },
          )
        else
          ...filteredAyats.map(
            (item) => _AyahTafseerCard(
              item: item,
              useUrduFont: useUrduFont,
              arabicFont: arabicFont,
              showTafseer: showTafseer,
            ),
          ),
        if (searchQuery.isNotEmpty &&
            filteredAyats.isEmpty &&
            filteredDaily == null)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text(
                'No ayats found for your search.',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textGrey,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDailyHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.gold, size: 18),
          const SizedBox(width: 8),
          const Text(
            'DAILY INSPIRATION',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AyahTafseerCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool useUrduFont;
  final String? arabicFont;
  final bool showTafseer;
  final bool isDaily;

  const _AyahTafseerCard({
    required this.item,
    required this.useUrduFont,
    this.arabicFont,
    required this.showTafseer,
    this.isDaily = false,
  });

  @override
  Widget build(BuildContext context) {
    final actualArabicFont =
        arabicFont ?? (useUrduFont ? 'NotoNastaliq' : 'AlQalam');
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDaily
            ? AppColors.primaryDark.withValues(alpha: 0.02)
            : AppColors.bgWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDaily
              ? AppColors.gold.withValues(alpha: 0.5)
              : AppColors.gold.withValues(alpha: 0.2),
          width: isDaily ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item['ref']?.toString() ?? '',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.goldDark,
                  letterSpacing: 0.5,
                ),
              ),
              if (isDaily)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'TODAY',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDarkest,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item['arabic']?.toString() ?? '',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: actualArabicFont,
              fontSize: useUrduFont ? 18 : 24,
              color: AppColors.textDark,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 16),
          if (!useUrduFont)
            _buildLanguageSection(
              'English',
              item['english_trans']?.toString() ?? '',
              item['english_tafseer']?.toString(),
            ),
          if (useUrduFont)
            _buildLanguageSection(
              'Urdu',
              item['urdu_trans']?.toString() ?? '',
              item['urdu_tafseer']?.toString(),
            ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(String lang, String trans, String? tafseer) {
    final isUrdu = lang == 'Urdu';
    return Column(
      crossAxisAlignment: isUrdu
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          lang,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        _renderMixedText(
          trans,
          isUrdu,
          fontSize: isUrdu ? 13 : 14,
          color: AppColors.textDark,
          height: 1.5,
          arabicFont: arabicFont,
        ),
        if (showTafseer && tafseer != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.quranBgLightGreen.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: isUrdu
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  'Tafseer',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.goldDark,
                  ),
                ),
                const SizedBox(height: 4),
                _renderMixedText(
                  tafseer,
                  isUrdu,
                  fontSize: isUrdu ? 12 : 13,
                  color: AppColors.textGrey,
                  height: 1.6,
                  arabicFont: arabicFont,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

Widget _renderMixedText(
  String text,
  bool isUrdu, {
  double? fontSize,
  Color? color,
  double? height,
  String? arabicFont,
}) {
  final arabicRegex = RegExp(
    r'([\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]+)',
  );

  final parts = text.split(arabicRegex);
  final matches = arabicRegex.allMatches(text).map((m) => m.group(0)).toList();

  List<TextSpan> spans = [];

  for (int i = 0; i < parts.length; i++) {
    if (parts[i].isNotEmpty) {
      spans.add(
        TextSpan(
          text: parts[i],
          style: TextStyle(
            fontFamily: isUrdu ? 'NotoNastaliq' : 'Cairo',
            fontSize: fontSize ?? (isUrdu ? 17 : 16),
            color: color ?? AppColors.primaryDarkest,
            height: height ?? 2.2,
          ),
        ),
      );
    }
    if (i < matches.length) {
      spans.add(
        TextSpan(
          text: matches[i],
          style: TextStyle(
            fontFamily: arabicFont ?? 'AlQalam',
            fontSize: (fontSize ?? (isUrdu ? 17 : 16)) * 1.3,
            color: color ?? AppColors.primaryDarkest,
            height: height ?? 2.2,
          ),
        ),
      );
    }
  }

  return RichText(
    textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
    textAlign: isUrdu ? TextAlign.right : TextAlign.left,
    text: TextSpan(children: spans),
  );
}
