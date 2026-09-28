// lib/web/pages/quran/surah_explorer_web.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — QURAN · SURAH READING PANE
//
// The reusable SurahReadingPane renders one surah as a scrolling list of verse
// cards with Basmala, a header (play / language / next surah) and a footer.
// It backs the dedicated /quran/surah/:id reader. `tarjuma` mode flips the
// emphasis to the translation (English / Urdu) for the Tarjuma experience.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../core/services/quran_audio_service.dart';
import '../../../core/theme/figma_tokens.dart';
import '../../../features/quran/data/quran_api_service.dart';
import '../../../features/quran/data/surahs_data.dart';
import '../../widgets/web_footer.dart';
import '../../widgets/web_ornaments.dart';
import 'quran_web_widgets.dart';

// ── Reading pane ─────────────────────────────────────────────────────────────
class SurahReadingPane extends StatefulWidget {
  final int surahNum;
  final int? initialAyah;
  final bool tarjuma;
  final VoidCallback? onNextSurah;
  final void Function(int surah, int ayah)? onAyahTapped;
  const SurahReadingPane({
    super.key,
    required this.surahNum,
    this.initialAyah,
    this.tarjuma = false,
    this.onNextSurah,
    this.onAyahTapped,
  });

  @override
  State<SurahReadingPane> createState() => _SurahReadingPaneState();
}

class _SurahReadingPaneState extends State<SurahReadingPane> {
  List<Map<String, String>>? _ayahs;
  bool _loading = false;
  String? _error;
  bool _urdu = false;
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SurahReadingPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    final surahChanged = oldWidget.surahNum != widget.surahNum;
    if (surahChanged) {
      _load();
    } else if (widget.initialAyah != null &&
        oldWidget.initialAyah != widget.initialAyah) {
      _scheduleJump();
    }
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
    if (widget.initialAyah != null && data != null) _scheduleJump();
  }

  void _scheduleJump() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToAyah());
  }

  void _jumpToAyah() {
    if (!mounted || !_scroll.hasClients) return;
    final target = widget.initialAyah;
    final ayahs = _ayahs;
    if (target == null ||
        target < 1 ||
        ayahs == null ||
        target > ayahs.length) {
      return;
    }
    final index = _showBasmala ? target : target - 1;
    _applyJump(index * 150.0);
  }

  void _applyJump(double offset) {
    if (_scroll.hasClients) {
      _scroll.jumpTo(offset.clamp(0.0, _scroll.position.maxScrollExtent));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      _scroll.jumpTo(offset.clamp(0.0, _scroll.position.maxScrollExtent));
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
            tarjuma: widget.tarjuma,
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
                : _AyahScrollView(
                    controller: _scroll,
                    surahNum: widget.surahNum,
                    ayahs: _ayahs!,
                    urdu: _urdu,
                    tarjuma: widget.tarjuma,
                    showBasmala: _showBasmala,
                    onAyahTapped: widget.onAyahTapped,
                    onNextSurah: widget.onNextSurah,
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Ayah scroll view (fills viewport; short surahs get a filler banner) ──────
class _AyahScrollView extends StatelessWidget {
  final ScrollController? controller;
  final int surahNum;
  final List<Map<String, String>> ayahs;
  final bool urdu;
  final bool tarjuma;
  final bool showBasmala;
  final void Function(int surah, int ayah)? onAyahTapped;
  final VoidCallback? onNextSurah;
  const _AyahScrollView({
    this.controller,
    required this.surahNum,
    required this.ayahs,
    required this.urdu,
    this.tarjuma = false,
    required this.showBasmala,
    this.onAyahTapped,
    this.onNextSurah,
  });

  @override
  Widget build(BuildContext context) {
    final shortSurah = ayahs.length <= 6;
    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate((context, i) {
            if (showBasmala && i == 0) {
              return const Padding(
                padding: EdgeInsets.fromLTRB(24, 22, 24, 0),
                child: BasmalaWidget(),
              );
            }
            final ayahIndex = showBasmala ? i - 1 : i;
            final a = ayahs[ayahIndex];
            final ayahNum = int.parse(a['num']!);
            return Column(
              children: [
                AyahCard(
                  surahNum: surahNum,
                  ayahNum: ayahNum,
                  arabic: a['a']!,
                  translation: urdu ? (a['tu'] ?? a['t']!) : a['t']!,
                  urdu: urdu,
                  tarjuma: tarjuma,
                  onAyahTapped: onAyahTapped == null
                      ? null
                      : () => onAyahTapped!(surahNum, ayahNum),
                ),
                const VerseDivider(),
              ],
            );
          }, childCount: ayahs.length + (showBasmala ? 1 : 0)),
        ),
        if (shortSurah)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 132),
                child: _ContinueBanner(
                  surahNum: surahNum,
                  onNextSurah: onNextSurah,
                ),
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        const SliverToBoxAdapter(child: WebFooter()),
        const SliverToBoxAdapter(child: SizedBox(height: 72)),
      ],
    );
  }
}

class _ContinueBanner extends StatelessWidget {
  final int surahNum;
  final VoidCallback? onNextSurah;
  const _ContinueBanner({required this.surahNum, this.onNextSurah});

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    final nextName = surahNum < 114
        ? (SurahsData.surahs[surahNum]['name'] as String)
        : '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: figma.surfacePanelMint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: figma.borderHairline, width: 1),
      ),
      child: Row(
        children: [
          GoldIconBadge(
            icon: Icons.auto_stories_rounded,
            size: 46,
            iconSize: 22,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Continue your recitation',
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: figma.textHeading,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Juz ${_juzForSurah(surahNum)}'
                  '${nextName.isEmpty ? '' : ' · Next: Surah $nextName'}'
                  ' — keep your streak alive.',
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 12.5,
                    height: 1.4,
                    color: figma.textBody,
                  ),
                ),
              ],
            ),
          ),
          if (onNextSurah != null) ...[
            const SizedBox(width: 12),
            Material(
              color: FigmaTokens.brandMidGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
              ),
              child: InkWell(
                onTap: onNextSurah,
                borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Open Next Surah',
                        style: TextStyle(
                          fontFamily: FigmaTokens.fontFamilyUiSans,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: FigmaTokens.textOnDark,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: FigmaTokens.textOnDark,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

int _juzForSurah(int surahNum) {
  const juzStarts = [
    1,
    2,
    2,
    3,
    4,
    4,
    5,
    6,
    7,
    8,
    9,
    11,
    12,
    14,
    16,
    17,
    18,
    21,
    23,
    25,
    27,
    29,
    33,
    36,
    39,
    41,
    45,
    48,
    49,
    58,
  ];
  for (var i = juzStarts.length - 1; i >= 0; i--) {
    if (surahNum >= juzStarts[i]) return i + 1;
  }
  return 1;
}

class _PaneHeader extends StatelessWidget {
  final int surahNum;
  final String name;
  final String arabic;
  final String meaning;
  final String type;
  final int ayahs;
  final bool urdu;
  final bool tarjuma;
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
    this.tarjuma = false,
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
      decoration: const BoxDecoration(gradient: FigmaTokens.heroGradientLight),
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
                      tarjuma
                          ? 'TARJUMA \u2014 ${type.toUpperCase()}'
                          : 'REVELATION \u2014 ${type.toUpperCase()}',
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
                        children: [_Chip(label: '$ayahs \u0101y\u0101t')],
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
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          arabic,
                          textAlign: TextAlign.right,
                          softWrap: true,
                          textHeightBehavior: const TextHeightBehavior(
                            applyHeightToFirstAscent: false,
                            applyHeightToLastDescent: false,
                          ),
                          style: const TextStyle(
                            fontFamily: FigmaTokens.fontFamilyArabicSerif,
                            fontSize: 26,
                            height: 1.45,
                            color: FigmaTokens.brandDeepGreen,
                          ),
                        ),
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
    final color = filled ? FigmaTokens.textOnDark : FigmaTokens.brandMidGreen;
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
            Icon(Icons.cloud_off_rounded, size: 44, color: figma.textMuted),
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
                  borderRadius: BorderRadius.circular(FigmaTokens.radiusButton),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
