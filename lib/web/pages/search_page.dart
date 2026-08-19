// lib/web/pages/search_page.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — GLOBAL SEARCH
//
// Searches surah names, hadith books/topics and prayer tools, then routes
// into the Quran Explorer. Read from the ?q= query parameter.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/figma_tokens.dart';
import '../../core/utils/seo_meta.dart';
import '../../features/quran/data/ahadees_data.dart';
import '../../features/quran/data/surahs_data.dart';
import '../widgets/web_footer.dart';
import '../widgets/web_widgets.dart';
import '../web_router.dart' show WebRoutes;

class SearchPage extends StatefulWidget {
  final String initialQuery;
  const SearchPage({super.key, this.initialQuery = ''});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _query => _controller.text.trim().toLowerCase();

  @override
  Widget build(BuildContext context) {
    setPageTitle('Search · Ask Iman');
    final q = _query;

    final surahMatches = q.isEmpty
        ? <Map<String, dynamic>>[]
        : SurahsData.surahs
            .where(
              (s) =>
                  (s['name'] as String).toLowerCase().contains(q) ||
                  (s['meaning'] as String).toLowerCase().contains(q),
            )
            .toList();

    final hadithBooks = q.isEmpty
        ? <String>[]
        : AhadeesData.books.where((b) => b.toLowerCase().contains(q)).toList();

    final tools = <(String, String, String)>[
      ('99 Names of Allah', 'Asmaul Husna', '${WebRoutes.calendarTools}/99-names'),
      ('Tasbeeh Counter', 'Digital dhikr', '${WebRoutes.calendarTools}/tasbeeh'),
      ('Prayer Times', 'Daily salah schedule', WebRoutes.calendarTools),
      ('Hijri Calendar', 'Islamic date & events', WebRoutes.calendarTools),
    ];
    final toolMatches =
        q.isEmpty ? <(String, String, String)>[] : tools.where((t) => t.$1.toLowerCase().contains(q)).toList();

    return WebPageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          _buildSearchBar(),
          const SizedBox(height: 28),
          if (q.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Text(
                  'Type above to search the Quran, hadith and tools.',
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 14,
                    color: FigmaTokens.textMuted,
                  ),
                ),
              ),
            )
          else ...[
            Text(
              'Results for “${_controller.text.trim()}”',
              style: const TextStyle(
                fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: FigmaTokens.textHeading,
              ),
            ),
            const SizedBox(height: 20),
            if (surahMatches.isEmpty &&
                hadithBooks.isEmpty &&
                toolMatches.isEmpty)
              _buildNoResults()
            else ...[
              if (surahMatches.isNotEmpty) ...[
                _SectionLabel('Surahs'),
                const SizedBox(height: 10),
                for (final s in surahMatches.take(8))
                  _ResultRow(
                    icon: Icons.menu_book_rounded,
                    title: s['name'] as String,
                    subtitle:
                        '${s['meaning']} · ${s['ayahs']} Ayahs · ${s['type']}',
                    onTap: () => context.go(WebRoutes.quran),
                  ),
                const SizedBox(height: 16),
              ],
              if (hadithBooks.isNotEmpty) ...[
                _SectionLabel('Hadith Books'),
                const SizedBox(height: 10),
                for (final b in hadithBooks.take(8))
                  _ResultRow(
                    icon: Icons.collections_bookmark_rounded,
                    title: b,
                    subtitle: 'Browse hadith from this authentic collection',
                    onTap: () => context.go('${WebRoutes.quran}/hadith'),
                  ),
                const SizedBox(height: 16),
              ],
              if (toolMatches.isNotEmpty) ...[
                _SectionLabel('Tools'),
                const SizedBox(height: 10),
                for (final t in toolMatches.take(8))
                  _ResultRow(
                    icon: Icons.widgets_rounded,
                    title: t.$1,
                    subtitle: t.$2,
                    onTap: () => context.go(t.$3),
                  ),
              ],
            ],
          ],
          const SizedBox(height: 40),
          const WebFooter(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: FigmaTokens.surfaceCard,
              borderRadius: BorderRadius.circular(FigmaTokens.radiusInput),
              border: Border.all(color: FigmaTokens.borderHairline),
              boxShadow: FigmaTokens.cardShadowSm,
            ),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search Quran, surah, hadith or topic…',
                hintStyle: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyUiSans,
                  fontSize: 14,
                  color: FigmaTokens.textMuted,
                ),
                prefixIcon: Icon(Icons.search_rounded,
                    color: FigmaTokens.textMuted),
                suffixIcon: Icon(Icons.shortcut_rounded,
                    color: FigmaTokens.textMuted),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
              style: const TextStyle(
                fontFamily: FigmaTokens.fontFamilyUiSans,
                fontSize: 14.5,
                color: FigmaTokens.textHeading,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoResults() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: FigmaTokens.surfaceCard,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        border: Border.all(color: FigmaTokens.borderHairline),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded,
              size: 40, color: FigmaTokens.textMuted),
          SizedBox(height: 12),
          Text(
            'No results found. Try a different keyword.',
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 14,
              color: FigmaTokens.textBody,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontFamily: FigmaTokens.fontFamilyUiSans,
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
        color: FigmaTokens.accentGoldAmber,
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ResultRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return HoverLift(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: FigmaTokens.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: FigmaTokens.borderHairline),
        ),
        child: Row(
          children: [
            Icon(icon, color: FigmaTokens.brandMidGreen, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: FigmaTokens.textHeading,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: FigmaTokens.fontFamilyUiSans,
                      fontSize: 12,
                      color: FigmaTokens.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: FigmaTokens.accentGoldAmber,
            ),
          ],
        ),
      ),
    );
  }
}
