// lib/web/pages/quran/hadith_web.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — QURAN · AHADITH LIBRARY
//
// Browse the six authentic collections by book or by topic, read the Arabic
// with English rendering in comfortable web cards.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../core/theme/figma_tokens.dart';
import '../../../features/quran/data/ahadees_data.dart';
import 'quran_web_widgets.dart';

const List<({String slug, String name})> _bookSlugs = [
  (slug: 'bukhari', name: 'Sahih al-Bukhari'),
  (slug: 'muslim', name: 'Sahih Muslim'),
  (slug: 'tirmidhi', name: 'Jami\' at-Tirmidhi'),
  (slug: 'abu-dawud', name: 'Sunan Abi Dawud'),
  (slug: 'nasai', name: 'Sunan an-Nasai'),
  (slug: 'ibn-majah', name: 'Sunan Ibn Majah'),
];

class HadithWeb extends StatefulWidget {
  const HadithWeb({super.key});

  @override
  State<HadithWeb> createState() => _HadithWebState();
}

class _HadithWebState extends State<HadithWeb> {
  String _topic = 'All';
  String? _book;

  List<Map<String, String>> get _list {
    if (_book != null) {
      return AhadeesData.getBookHadiths(_book!);
    }
    return AhadeesData.byTopic(_topic).take(15).toList();
  }

  @override
  Widget build(BuildContext context) {
    return QuranPaneScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ahadith Library',
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: FigmaTokens.textHeading,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _book == null
                          ? 'Explore the six authentic collections, or filter the hadith of the day by topic.'
                          : 'Reading: ${_bookTitle(_book!)}',
                      style: const TextStyle(
                        fontFamily: FigmaTokens.fontFamilyUiSans,
                        fontSize: 14.5,
                        color: FigmaTokens.textBody,
                      ),
                    ),
                  ],
                ),
              ),
              if (_book != null)
                OutlinedButton.icon(
                  onPressed: () => setState(() => _book = null),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('All books'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: FigmaTokens.brandMidGreen,
                    side: BorderSide(
                      color: FigmaTokens.brandMidGreen.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        FigmaTokens.radiusButton,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          if (_book == null) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final t in AhadeesData.topics)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _TopicChip(
                        label: t,
                        selected: t == _topic,
                        onTap: () => setState(() => _topic = t),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _BookGrid(
              onOpen: (slug) => setState(() => _book = slug),
            ),
            const SizedBox(height: 30),
            _HadithIntro(label: 'Hadith of the Day — $_topic'),
          ] else
            const SizedBox(height: 6),
          const SizedBox(height: 14),
          for (final h in _list)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _HadithCard(hadith: h),
            ),
        ],
      ),
    );
  }

  String _bookTitle(String slug) {
    for (final b in _bookSlugs) {
      if (b.slug == slug) return b.name;
    }
    return slug;
  }
}

class _HadithIntro extends StatelessWidget {
  final String label;
  const _HadithIntro({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: FigmaTokens.accentGoldAmber,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontFamily: FigmaTokens.fontFamilyDisplaySerif,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: FigmaTokens.textHeading,
          ),
        ),
      ],
    );
  }
}

class _TopicChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TopicChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? FigmaTokens.brandMidGreen : FigmaTokens.surfaceCard,
          borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
          border: Border.all(
            color: selected
                ? FigmaTokens.brandMidGreen
                : FigmaTokens.borderHairline,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: FigmaTokens.fontFamilyUiSans,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: selected
                ? FigmaTokens.textOnDark
                : FigmaTokens.textBody,
          ),
        ),
      ),
    );
  }
}

class _BookGrid extends StatelessWidget {
  final ValueChanged<String> onOpen;
  const _BookGrid({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 560
                ? 2
                : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _bookSlugs.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: cols == 1 ? 4.2 : 2.1,
          ),
          itemBuilder: (context, i) {
            final b = _bookSlugs[i];
            return _BookCard(slug: b.slug, name: b.name, onTap: () => onOpen(b.slug));
          },
        );
      },
    );
  }
}

class _BookCard extends StatelessWidget {
  final String slug;
  final String name;
  final VoidCallback onTap;
  const _BookCard({required this.slug, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final icon = switch (slug) {
      'bukhari' => Icons.menu_book_rounded,
      'muslim' => Icons.book_rounded,
      'tirmidhi' => Icons.auto_stories_rounded,
      'abu-dawud' => Icons.library_books_rounded,
      'nasai' => Icons.collections_bookmark_rounded,
      _ => Icons.import_contacts_rounded,
    };
    return Material(
      color: FigmaTokens.surfaceCard,
      borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
      child: InkWell(
        onTap: onTap,
        hoverColor: FigmaTokens.surfacePanelMint,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
            border: Border.all(color: FigmaTokens.borderHairline),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: FigmaTokens.accentGoldSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: FigmaTokens.accentGoldAmber, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: FigmaTokens.textHeading,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '100 hadiths · Arabic + English',
                      style: const TextStyle(
                        fontFamily: FigmaTokens.fontFamilyUiSans,
                        fontSize: 11.5,
                        color: FigmaTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: FigmaTokens.accentGoldAmber,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HadithCard extends StatelessWidget {
  final Map<String, String> hadith;
  const _HadithCard({required this.hadith});

  @override
  Widget build(BuildContext context) {
    final arabic = hadith['arabic'];
    final text = hadith['id'] ?? hadith['text'] ?? '';
    final number = hadith['number'];
    final narrator = hadith['narrator'];
    final grade = hadith['grade'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FigmaTokens.surfaceCard,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCardSm),
        border: Border.all(color: FigmaTokens.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (arabic != null && arabic.isNotEmpty) ...[
            Text(
              arabic,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: FigmaTokens.fontFamilyArabicSerif,
                fontSize: 20,
                height: 1.8,
                color: FigmaTokens.textHeading,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            text,
            style: const TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 14.5,
              height: 1.65,
              color: FigmaTokens.textBody,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (number != null)
                _MetaChip(text: 'No. $number', color: FigmaTokens.accentGoldAmber),
              if (narrator != null)
                _MetaChip(text: narrator, color: FigmaTokens.brandMidGreen),
              if (grade != null)
                _MetaChip(text: grade, color: FigmaTokens.textMuted),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String text;
  final Color color;
  const _MetaChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: FigmaTokens.fontFamilyUiSans,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
