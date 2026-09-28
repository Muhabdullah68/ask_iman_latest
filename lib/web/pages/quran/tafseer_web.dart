// lib/web/pages/quran/tafseer_web.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — QURAN · TAFSEER (LIST NAVIGATOR)
//
// The Tafseer sub-tab is a list-first reader: pick "By Juzz" to browse the
// 30 supara, or "By Surah" to walk the 114 surahs — then the commentary for
// that surah renders beside the list (or below it on narrow screens) with a
// source selector (Ibn Kathir / Ma'ariful Quran / Al-Jalalayn).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../core/theme/figma_tokens.dart';
import '../../../features/quran/data/quran_api_service.dart';
import '../../../features/quran/data/surahs_data.dart';
import '../../widgets/web_widgets.dart';
import 'juz_data.dart';
import 'quran_reading_state.dart';

const List<String> _sources = ['Ibn Kathir', "Ma'ariful Quran", 'Al-Jalalayn'];

class TafseerWeb extends StatefulWidget {
  const TafseerWeb({super.key});

  @override
  State<TafseerWeb> createState() => _TafseerWebState();
}

class _TafseerWebState extends State<TafseerWeb> {
  String _source = _sources.first;
  bool _byJuzz = true;
  int _selectedJuz = 1;
  int _surah = 1;
  List<Map<String, dynamic>>? _entries;
  List<Map<String, String>>? _ayahs;
  String? _fallback;
  bool _loading = false;
  final GlobalKey _readingKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _surah = QuranReadingState.instance.surahNum.clamp(1, 114);
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
    final ayahFuture = QuranApiService.fetchSurah(
      _surah,
    ).then((d) async => d ?? await QuranApiService.getLocalAyahs(_surah));
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
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _ensureReadingVisible(),
    );
  }

  void _setSource(String s) {
    if (s == _source) return;
    setState(() => _source = s);
    _load();
  }

  void _setSurah(int n) {
    final changed = n != _surah;
    setState(() {
      _surah = n;
      _selectedJuz = _juzForSurah(n);
    });
    QuranReadingState.instance.setSurah(n);
    if (changed) {
      _load();
    } else {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _ensureReadingVisible(),
      );
    }
  }

  void _selectJuzz(int n) {
    final targetSurah = juzStartSurah(n);
    setState(() {
      _byJuzz = true;
      _selectedJuz = n;
    });
    _setSurah(targetSurah);
  }

  void _selectSurah(int n) {
    setState(() => _byJuzz = false);
    _setSurah(n);
  }

  void _ensureReadingVisible() {
    final ctx = _readingKey.currentContext;
    if (ctx != null && mounted) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        alignment: 0.15,
      );
    }
  }

  int _juzForSurah(int n) {
    for (var i = juzStartAyat.length - 1; i >= 0; i--) {
      if (n >= juzStartSurah(i + 1)) return i + 1;
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    final meta = SurahsData.surahs[_surah - 1];

    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ModeToggle(
          byJuzz: _byJuzz,
          onChanged: (byJuzz) {
            setState(() => _byJuzz = byJuzz);
          },
        ),
        const SizedBox(height: 16),
        _TafseerList(
          byJuzz: _byJuzz,
          selectedJuz: _selectedJuz,
          selectedSurah: _surah,
          onSelectJuzz: _selectJuzz,
          onSelectSurah: _selectSurah,
        ),
      ],
    );

    final reading = Column(
      key: _readingKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: figma.surfaceCard,
            borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
            border: Border.all(color: figma.borderHairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _byJuzz
                    ? 'Juz ${arabicNumeral(_selectedJuz)} — ${meta['name']}'
                    : 'Surah ${meta['name']}',
                style: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: figma.textHeading,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${meta['arabic']} · ${meta['meaning']}',
                style: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyUiSans,
                  fontSize: 13,
                  color: figma.textBody,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final s in _sources)
                    _SourcePill(
                      label: s,
                      selected: s == _source,
                      onTap: () => _setSource(s),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
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
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1000;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const WebSectionHeader(
              eyebrow: 'Tafseer',
              title: 'Commentary at a Glance',
              subtitle:
                  "Browse the Qur'an by juz or by surah and read scholarly "
                  'commentary beside the verses.',
            ),
            const SizedBox(height: 26),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 360, child: list),
                  const SizedBox(width: 24),
                  Expanded(child: reading),
                ],
              )
            else ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [list, const SizedBox(height: 28), reading],
              ),
            ],
          ],
        );
      },
    );
  }
}

// ── By Juzz / By Surah segmented toggle ──────────────────────────────────────
class _ModeToggle extends StatelessWidget {
  final bool byJuzz;
  final ValueChanged<bool> onChanged;
  const _ModeToggle({required this.byJuzz, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Container(
      decoration: BoxDecoration(
        color: figma.surfaceBackground,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
        border: Border.all(color: figma.borderHairline),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModePill(
            label: 'By Juzz',
            selected: byJuzz,
            onTap: () => onChanged(true),
          ),
          _ModePill(
            label: 'By Surah',
            selected: !byJuzz,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ModePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? FigmaTokens.brandMidGreen : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: selected ? FigmaTokens.textOnDark : FigmaTokens.textBody,
            ),
          ),
        ),
      ),
    );
  }
}

// ── List of 30 juzz or 114 surahs ────────────────────────────────────────────
class _TafseerList extends StatelessWidget {
  final bool byJuzz;
  final int selectedJuz;
  final int selectedSurah;
  final ValueChanged<int> onSelectJuzz;
  final ValueChanged<int> onSelectSurah;

  const _TafseerList({
    required this.byJuzz,
    required this.selectedJuz,
    required this.selectedSurah,
    required this.onSelectJuzz,
    required this.onSelectSurah,
  });

  @override
  Widget build(BuildContext context) {
    if (byJuzz) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var n = 1; n <= 30; n++)
            _RowListItem(
              key: ValueKey('juz-$n'),
              leading: arabicNumeral(n),
              title: 'Juz ${arabicNumeral(n)}',
              subtitle: _juzLabel(n),
              selected: n == selectedJuz,
              onTap: () => onSelectJuzz(n),
            ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final s in SurahsData.surahs)
          _RowListItem(
            key: ValueKey<String>('surah-${s['num']}'),
            leading: '${s['num']}',
            title: s['name'] as String,
            subtitle:
                '${s['arabic']} · ${s['meaning']} — '
                '${s['ayahs']} \u0101y\u0101t',
            selected: (s['num'] as int) == selectedSurah,
            onTap: () => onSelectSurah(s['num'] as int),
          ),
      ],
    );
  }

  String _juzLabel(int n) {
    final meta = SurahsData.surahs[juzStartSurah(n) - 1];
    final end = n < juzStartAyat.length ? juzStartSurah(n + 1) - 1 : 114;
    final endMeta = SurahsData.surahs[end - 1];
    return '${meta['arabic']} — starts ${juzStartSurah(n)}:${juzStartAyah(n)}'
        ' · through ${endMeta['name']}';
  }
}

class _RowListItem extends StatelessWidget {
  final String leading;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _RowListItem({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Material(
      color: selected ? FigmaTokens.brandMidGreen : Colors.transparent,
      borderRadius: BorderRadius.circular(FigmaTokens.radiusButton),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusButton),
        hoverColor: selected
            ? FigmaTokens.brandMidGreen
            : figma.surfacePanelMint,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? figma.accentGoldAmber
                      : figma.accentGoldSurface,
                ),
                child: Text(
                  leading,
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: selected
                        ? FigmaTokens.textOnDark
                        : figma.accentGoldAmber,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyUiSans,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: selected
                            ? FigmaTokens.textOnDark
                            : figma.textHeading,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyUiSans,
                        fontSize: 11,
                        color: selected
                            ? FigmaTokens.accentGoldLight.withValues(alpha: 0.9)
                            : figma.textMuted,
                      ),
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

// ── Tafseer reading content (3-column or stacked) ────────────────────────────
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
              Expanded(flex: 4, child: _ArabicTranslationColumn(ayahs: ayahs)),
              const SizedBox(width: 16),
              Expanded(flex: 3, child: _CommentaryColumn(entries: entries!)),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: _NotesColumn(entries: entries!, surahNum: surahNum),
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
                        color: figma.textBody.withValues(alpha: 0.9),
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
              'Select another juz or surah from the list to jump straight '
              'to its commentary.',
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
          color: selected ? FigmaTokens.brandMidGreen : figma.surfaceBackground,
          borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
          border: Border.all(
            color: selected ? FigmaTokens.brandMidGreen : figma.borderHairline,
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
