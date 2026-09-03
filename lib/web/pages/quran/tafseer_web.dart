// lib/web/pages/quran/tafseer_web.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — QURAN · TAFSEER (3-COLUMN LAYOUT)
//
// Spec: 3-column layout — Left (Arabic + Translation), Middle (commentary),
// Right (source selector + notes). On screens <1200px, stacks vertically.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../core/theme/figma_tokens.dart';
import '../../../features/quran/data/quran_api_service.dart';
import '../../../features/quran/data/surahs_data.dart';
import 'quran_web_widgets.dart';

const List<String> _sources = [
  'Ibn Kathir',
  "Ma'ariful Quran",
  'Al-Jalalayn',
];

class TafseerWeb extends StatefulWidget {
  const TafseerWeb({super.key});

  @override
  State<TafseerWeb> createState() => _TafseerWebState();
}

class _TafseerWebState extends State<TafseerWeb> {
  String _source = _sources.first;
  int _surah = 1;
  List<Map<String, dynamic>>? _entries;
  List<Map<String, String>>? _ayahs;
  String? _fallback;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _entries = null;
      _ayahs = null;
      _fallback = null;
    });
    // Load tafseer and ayahs in parallel
    final chapterFuture = QuranApiService.fetchChapterTafseer(_surah, _source);
    final ayahFuture = QuranApiService.fetchSurah(_surah)
        .then((d) async => d ?? await QuranApiService.getLocalAyahs(_surah));
    final chapter = await chapterFuture;
    final ayahData = await ayahFuture;
    if (!mounted) return;
    if (chapter != null && chapter.isNotEmpty) {
      setState(() {
        _loading = false;
        _entries = chapter;
        _ayahs = ayahData;
      });
      return;
    }
    final local = await QuranApiService.getLocalTafseer(_surah, _source);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _fallback = local;
      _ayahs = ayahData;
    });
  }

  void _setSource(String s) {
    if (s == _source) return;
    setState(() => _source = s);
    _load();
  }

  void _setSurah(int n) {
    if (n == _surah) return;
    setState(() => _surah = n);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return QuranPaneContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tafseer',
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyDisplaySerif,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: figma.textHeading,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Scholarly commentary \u2014 Arabic text, translation, and explanation side by side.',
                style: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyUiSans,
                  fontSize: 14.5,
                  color: figma.textBody,
                ),
              ),
              const SizedBox(height: 20),
              // Surah selector + source pills
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: figma.surfaceCard,
                  borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
                  border: Border.all(color: figma.borderHairline),
                ),
                child: Row(
                  children: [
                    Flexible(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          for (final s in _sources)
                            _SourcePill(
                              label: s,
                              selected: s == _source,
                              onTap: () => _setSource(s),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: DropdownButton<int>(
                        value: _surah,
                        underline: const SizedBox.shrink(),
                        borderRadius: BorderRadius.circular(12),
                        isDense: true,
                        isExpanded: true,
                        items: [
                          for (final s in SurahsData.surahs)
                            DropdownMenuItem(
                              value: s['num'] as int,
                              child: Text(
                                '${s['num']}. ${s['name']}',
                                style: TextStyle(
                                  fontFamily: FigmaTokens.fontFamilyUiSans,
                                  fontSize: 14,
                                  color: figma.textHeading,
                                ),
                              ),
                            ),
                        ],
                        onChanged: (v) {
                          if (v != null) _setSurah(v);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              // 3-column or vertical layout
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                _TafseerContent(
                  entries: _entries,
                  fallback: _fallback,
                  ayahs: _ayahs,
                  surahNum: _surah,
                ),
        ],
      ),
    );
  }
}

class _TafseerContent extends StatelessWidget {
  final List<Map<String, dynamic>>? entries;
  final String? fallback;
  final List<Map<String, String>>? ayahs;
  final int surahNum;
  const _TafseerContent({
    required this.entries,
    required this.fallback,
    required this.ayahs,
    required this.surahNum,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1200;

        if (entries == null || entries!.isEmpty) {
          if (fallback != null) {
            return _TafseerEntry(verseKey: '', text: fallback!);
          }
          return const _TafseerEmpty();
        }

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: _ArabicTranslationColumn(ayahs: ayahs),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: _CommentaryColumn(entries: entries!),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: _NotesColumn(
                  entries: entries!,
                  surahNum: surahNum,
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ArabicTranslationColumn(ayahs: ayahs),
            const SizedBox(height: 20),
            _CommentaryColumn(entries: entries!),
            const SizedBox(height: 20),
            _NotesColumn(entries: entries!, surahNum: surahNum),
          ],
        );
      },
    );
  }
}

class _ArabicTranslationColumn extends StatelessWidget {
  final List<Map<String, String>>? ayahs;
  const _ArabicTranslationColumn({required this.ayahs});

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: figma.surfaceBackground,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        border: Border.all(color: figma.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Arabic & Translation',
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: figma.accentGoldAmber,
            ),
          ),
          const SizedBox(height: 14),
          if (ayahs == null || ayahs!.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Text(
                  'No verse data available.',
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 13,
                    color: figma.textMuted,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ayahs!.length,
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Divider(
                  height: 1,
                  thickness: 0.6,
                  color: figma.borderHairline,
                ),
              ),
              itemBuilder: (context, i) {
                final a = ayahs![i];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        a['a'] ?? '',
                        textAlign: TextAlign.right,
                        softWrap: true,
                        style: TextStyle(
                          fontFamily: FigmaTokens.fontFamilyArabicMushaf,
                          fontSize: 20,
                          height: 1.85,
                          color: figma.textHeading,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      a['t'] ?? '',
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyUiSans,
                        fontSize: 13,
                        height: 1.55,
                        color:
                            figma.textBody.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _CommentaryColumn extends StatelessWidget {
  final List<Map<String, dynamic>> entries;
  const _CommentaryColumn({required this.entries});

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: figma.surfaceCard,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        border: Border.all(color: figma.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Commentary',
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: FigmaTokens.brandMidGreen,
            ),
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, i) {
              final e = entries[i];
              return _TafseerEntry(
                verseKey: e['ayah_key'] as String? ?? '',
                text: e['text'] as String? ?? '',
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NotesColumn extends StatelessWidget {
  final List<Map<String, dynamic>> entries;
  final int surahNum;
  const _NotesColumn({required this.entries, required this.surahNum});

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    final meta = SurahsData.surahs[surahNum - 1];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: figma.surfacePanelMint,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Surah Info',
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: FigmaTokens.brandMidGreen,
            ),
          ),
          const SizedBox(height: 14),
          _InfoRow(label: 'Name', value: '${meta['name']}'),
          _InfoRow(label: 'Meaning', value: '${meta['meaning']}'),
          _InfoRow(label: 'Type', value: '${meta['type']}'),
          _InfoRow(label: 'Ayahs', value: '${meta['ayahs']}'),
          _InfoRow(label: 'Verses Commented', value: '${entries.length}'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: figma.accentGoldSurface,
              borderRadius: BorderRadius.circular(FigmaTokens.radiusButton),
            ),
            child: Text(
              'Tap any verse in the Arabic column to see its commentary highlighted.',
              style: TextStyle(
                fontFamily: FigmaTokens.fontFamilyUiSans,
                fontSize: 12,
                color: figma.textBody,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: figma.textMuted,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: FigmaTokens.fontFamilyUiSans,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: figma.textHeading,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourcePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SourcePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? FigmaTokens.brandMidGreen
              : figma.surfaceBackground,
          borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
          border: Border.all(
            color: selected
                ? FigmaTokens.brandMidGreen
                : figma.borderHairline,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: FigmaTokens.fontFamilyUiSans,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: selected ? FigmaTokens.textOnDark : figma.textBody,
          ),
        ),
      ),
    );
  }
}

class _TafseerEntry extends StatelessWidget {
  final String verseKey;
  final String text;
  const _TafseerEntry({required this.verseKey, required this.text});

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: figma.surfaceCard,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCardSm),
        border: Border.all(color: figma.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (verseKey.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: figma.accentGoldSurface,
                borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
              ),
              child: Text(
                '\u0100yah $verseKey',
                style: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyUiSans,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: figma.accentGoldAmber,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            text,
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 14,
              height: 1.75,
              color: figma.textBody.withValues(alpha: 0.95),
            ),
          ),
        ],
      ),
    );
  }
}

class _TafseerEmpty extends StatelessWidget {
  const _TafseerEmpty();

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: figma.surfaceCard,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
      ),
      child: Column(
        children: [
          Icon(Icons.notes_rounded, size: 40, color: figma.textMuted),
          const SizedBox(height: 12),
          Text(
            'No tafseer available for this selection yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 14,
              color: figma.textBody,
            ),
          ),
        ],
      ),
    );
  }
}
