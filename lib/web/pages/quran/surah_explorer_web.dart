// lib/web/pages/quran/surah_explorer_web.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — QURAN · TALAWAT (SURAH EXPLORER)
//
// Desktop-friendly two-pane explorer: a searchable 114-surah sidebar (or a
// juz grid when JUZ mode is active) on the left and a reading pane on the
// right. Bounded heights everywhere — the sidebar and the ayah list scroll
// independently, never nested inside an unbounded scroll view.
//
// Spec additions: Basmala above first verse, dividers between verses,
// Next Surah button, sidebar drawer on narrow screens, Juz mode sub-view.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/services/quran_audio_service.dart';
import '../../../core/theme/figma_tokens.dart';
import '../../../features/quran/data/quran_api_service.dart';
import '../../../features/quran/data/surahs_data.dart';
import '../../widgets/web_animations.dart';
import 'quran_web_widgets.dart';

class SurahExplorerWeb extends StatefulWidget {
  final bool juzMode;
  final VoidCallback onToggleJuz;
  final bool drawerOpen;
  final VoidCallback onToggleDrawer;
  const SurahExplorerWeb({
    super.key,
    this.juzMode = false,
    required this.onToggleJuz,
    this.drawerOpen = false,
    required this.onToggleDrawer,
  });

  @override
  State<SurahExplorerWeb> createState() => _SurahExplorerWebState();
}

class _SurahExplorerWebState extends State<SurahExplorerWeb> {
  int _selected = 1;
  String _query = '';

  List<Map<String, dynamic>> get _filtered {
    final all = SurahsData.surahs;
    if (_query.trim().isEmpty) return all;
    final q = _query.trim().toLowerCase();
    return all.where((s) {
      final name = (s['name'] as String).toLowerCase();
      final arabic = (s['arabic'] as String).contains(_query.trim());
      final meaning = (s['meaning'] as String).toLowerCase();
      final num = (s['num'] as int).toString();
      return name.contains(q) || arabic || meaning.contains(q) || num == q;
    }).toList();
  }

  void _selectSurah(int n) {
    setState(() => _selected = n);
    if (widget.drawerOpen) widget.onToggleDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 960;

        final sidebarContent = widget.juzMode
            ? _JuzSidebar(
                onSelectSurah: _selectSurah,
                selectedSurah: _selected,
              )
            : _Sidebar(
                surahs: _filtered,
                selected: _selected,
                query: _query,
                onQueryChanged: (v) => setState(() => _query = v),
                onSelect: _selectSurah,
              );

        final reading = SurahReadingPane(
          surahNum: _selected,
          onNextSurah: () {
            if (_selected < 114) {
              setState(() => _selected++);
            }
          },
        );

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: 316, child: sidebarContent),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: figma.borderHairline,
              ),
              Expanded(child: reading),
            ],
          );
        }

        // Narrow layout: sidebar as drawer when toggled
        return Stack(
          children: [
            reading,
            if (widget.drawerOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: widget.onToggleDrawer,
                  child: Container(
                    color: Colors.black45,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {},
                        child: SizedBox(
                          width: 320,
                          height: double.infinity,
                          child: Material(
                            elevation: 8,
                            child: sidebarContent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ── Juz sidebar (shown when JUZ toggle is active) ────────────────────────────
class _JuzSidebar extends StatelessWidget {
  final ValueChanged<int> onSelectSurah;
  final int selectedSurah;
  const _JuzSidebar({required this.onSelectSurah, required this.selectedSurah});

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Container(
      color: figma.surfaceCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Text(
              'Read by Juz',
              style: TextStyle(
                fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: figma.textHeading,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              itemCount: 30,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, i) => Material(
                color: figma.surfacePanelMint,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(FigmaTokens.radiusButton),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(FigmaTokens.radiusButton),
                  onTap: () {
                    // Navigate to first surah in this juz
                    final firstSurah = _surahForJuz(i + 1);
                    if (firstSurah > 0) onSelectSurah(firstSurah);
                  },
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: FigmaTokens.primaryButtonGradient,
                          ),
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: figma.accentGoldLight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Juz ${i + 1}',
                          style: TextStyle(
                            fontFamily: FigmaTokens.fontFamilyUiSans,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: figma.textBody,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _surahForJuz(int juz) {
    const juzStarts = [
      1, 2, 3, 4, 5, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 20,
      21, 22, 23, 24, 25, 25, 26, 27, 28, 28, 29, 30,
    ];
    if (juz >= 1 && juz <= 30) return juzStarts[juz - 1];
    return 1;
  }
}

// ── Sidebar ──────────────────────────────────────────────────────────────────
class _Sidebar extends StatelessWidget {
  final List<Map<String, dynamic>> surahs;
  final int selected;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<int> onSelect;

  const _Sidebar({
    required this.surahs,
    required this.selected,
    required this.query,
    required this.onQueryChanged,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Container(
      color: figma.surfaceCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: TextField(
              onChanged: onQueryChanged,
              style: TextStyle(
                fontFamily: FigmaTokens.fontFamilyUiSans,
                fontSize: 14,
                color: figma.textHeading,
              ),
              decoration: InputDecoration(
                hintText: 'Search surah\u2026',
                hintStyle: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyUiSans,
                  fontSize: 14,
                  color: figma.textMuted.withValues(alpha: 0.8),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: figma.textMuted,
                ),
                filled: true,
                fillColor: figma.surfaceBackground,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(FigmaTokens.radiusInput),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: surahs.isEmpty
                ? Center(
                    child: Text(
                      'No surahs match your search',
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyUiSans,
                        fontSize: 13,
                        color: figma.textMuted,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: surahs.length,
                    itemBuilder: (context, i) {
                      final s = surahs[i];
                      final n = s['num'] as int;
                      final isSel = n == selected;
                      final tile = _SurahTile(
                        surah: s,
                        selected: isSel,
                        onTap: () => onSelect(n),
                      );
                      if (i >= 30) return tile;
                      return tile
                          .animate(delay: Duration(milliseconds: i * 30))
                          .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                          .slideX(begin: -0.05, duration: 300.ms, curve: Curves.easeOut);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SurahTile extends StatelessWidget {
  final Map<String, dynamic> surah;
  final bool selected;
  final VoidCallback onTap;
  const _SurahTile({
    required this.surah,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Material(
      color: selected ? FigmaTokens.brandMidGreen : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: selected
            ? FigmaTokens.brandMidGreen
            : figma.surfacePanelMint,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? figma.accentGoldAmber
                      : figma.accentGoldSurface,
                ),
                child: Text(
                  '${surah['num']}',
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                    fontSize: 12,
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
                      '${surah['name']}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyUiSans,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? FigmaTokens.textOnDark
                            : figma.textHeading,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${surah['meaning']} \u00b7 ${surah['ayahs']} \u0101y\u0101t',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyUiSans,
                        fontSize: 11,
                        color: selected
                            ? figma.accentGoldLight.withValues(alpha: 0.9)
                            : figma.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Text(
                  '${surah['arabic']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyArabicSerif,
                    fontSize: 16,
                    color: selected
                        ? FigmaTokens.textOnDark
                        : FigmaTokens.brandDeepGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reading pane ─────────────────────────────────────────────────────────────
class SurahReadingPane extends StatefulWidget {
  final int surahNum;
  final VoidCallback? onNextSurah;
  const SurahReadingPane({super.key, required this.surahNum, this.onNextSurah});

  @override
  State<SurahReadingPane> createState() => _SurahReadingPaneState();
}

class _SurahReadingPaneState extends State<SurahReadingPane> {
  List<Map<String, String>>? _ayahs;
  bool _loading = false;
  String? _error;
  bool _urdu = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant SurahReadingPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.surahNum != widget.surahNum) _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _ayahs = null;
    });
    var data = await QuranApiService.fetchSurah(widget.surahNum);
    data ??= await QuranApiService.getLocalAyahs(widget.surahNum);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _ayahs = data;
      _error = data == null
          ? 'Could not load Surah ${widget.surahNum}. Check your connection and try again.'
          : null;
    });
  }

  Map<String, dynamic> get _meta => SurahsData.surahs[widget.surahNum - 1];

  bool get _showBasmala {
    final num = widget.surahNum;
    return num != 1 && num != 9;
  }

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    final meta = _meta;
    final name = meta['name'] as String;
    final audio = QuranAudioService();
    final nextSurah = widget.surahNum < 114 ? widget.surahNum + 1 : -1;

    return Container(
      color: figma.surfaceBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PaneHeader(
            surahNum: widget.surahNum,
            name: name,
            arabic: meta['arabic'] as String,
            meaning: meta['meaning'] as String,
            type: meta['type'] as String,
            ayahs: meta['ayahs'] as int,
            urdu: _urdu,
            onUrduToggle: () => setState(() => _urdu = !_urdu),
            onPlaySurah: () => audio.playSurah(widget.surahNum, name),
            nextSurah: nextSurah,
            onNextSurah: widget.onNextSurah,
          ),
          Divider(height: 1, thickness: 1, color: figma.borderHairline),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _ErrorRetry(message: _error!, onRetry: _load)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 22, 24, 132),
                        itemCount: (_ayahs?.length ?? 0) + (_showBasmala ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (_showBasmala && i == 0) {
                            return const BasmalaWidget();
                          }
                          final ayahIndex = _showBasmala ? i - 1 : i;
                          final a = _ayahs![ayahIndex];
                          return Column(
                            children: [
                              AyahCard(
                                surahNum: widget.surahNum,
                                ayahNum: int.parse(a['num']!),
                                arabic: a['a']!,
                                translation:
                                    _urdu ? (a['tu'] ?? a['t']!) : a['t']!,
                                urdu: _urdu,
                              ),
                              const VerseDivider(),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _PaneHeader extends StatelessWidget {
  final int surahNum;
  final String name;
  final String arabic;
  final String meaning;
  final String type;
  final int ayahs;
  final bool urdu;
  final VoidCallback onUrduToggle;
  final VoidCallback onPlaySurah;
  final int nextSurah;
  final VoidCallback? onNextSurah;

  const _PaneHeader({
    required this.surahNum,
    required this.name,
    required this.arabic,
    required this.meaning,
    required this.type,
    required this.ayahs,
    required this.urdu,
    required this.onUrduToggle,
    required this.onPlaySurah,
    required this.nextSurah,
    this.onNextSurah,
  });

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
      decoration: const BoxDecoration(
        gradient: FigmaTokens.heroGradientLight,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'REVELATION \u2014 ${type.toUpperCase()}',
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyUiSans,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                        color: figma.accentGoldAmber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _Chip(label: '$ayahs \u0101y\u0101t'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: figma.textHeading,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            meaning,
                            style: TextStyle(
                              fontFamily: FigmaTokens.fontFamilyUiSans,
                              fontSize: 12.5,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 0.8,
                              color: figma.textBody,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      arabic,
                      style: const TextStyle(
                        fontFamily: FigmaTokens.fontFamilyArabicSerif,
                        fontSize: 26,
                        height: 1.3,
                        color: FigmaTokens.brandDeepGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _PillButton(
                      icon: Icons.play_arrow_rounded,
                      label: 'Play Surah',
                      filled: true,
                      onTap: onPlaySurah,
                    ),
                    _PillButton(
                      icon: urdu
                          ? Icons.language_rounded
                          : Icons.translate_rounded,
                      label: urdu ? '\u0627\u0631\u062f\u0648' : 'English',
                      filled: false,
                      onTap: onUrduToggle,
                    ),
                    if (nextSurah > 0 && onNextSurah != null)
                      _PillButton(
                        icon: Icons.arrow_forward_rounded,
                        label: 'Next Surah',
                        filled: false,
                        onTap: onNextSurah!,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: figma.surfaceCard.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: FigmaTokens.fontFamilyUiSans,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: figma.textBody,
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;
  const _PillButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        filled ? FigmaTokens.textOnDark : FigmaTokens.brandMidGreen;
    final bg = filled ? FigmaTokens.brandMidGreen : Colors.transparent;
    final border = filled
        ? BorderSide.none
        : BorderSide(
            color: FigmaTokens.brandMidGreen.withValues(alpha: 0.5),
            width: 1.2,
          );
    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
        side: border,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyUiSans,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 44,
              color: figma.textMuted,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: FigmaTokens.fontFamilyUiSans,
                fontSize: 13.5,
                color: figma.textBody,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                backgroundColor: FigmaTokens.brandMidGreen,
                foregroundColor: FigmaTokens.textOnDark,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(FigmaTokens.radiusButton),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
