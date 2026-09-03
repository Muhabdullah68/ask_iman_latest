// lib/web/pages/names_of_allah_page.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — 99 NAMES EXPLORER (Asmaul Husna)
//
// Grid of the 99 Beautiful Names with Arabic, transliteration, meaning and
// search. Tapping a name card (or its speaker icon) recites the Arabic name
// via the browser's speech synthesis; a Play All button queues all 99 with a
// live "now reciting" highlight.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/figma_tokens.dart';
import '../../core/utils/seo_meta.dart';
import '../data/asmaul_husna_data.dart';
import '../services/speech_service.dart';
import '../widgets/web_footer.dart';
import '../widgets/web_widgets.dart';

class NamesOfAllahPage extends StatefulWidget {
  const NamesOfAllahPage({super.key});

  @override
  State<NamesOfAllahPage> createState() => _NamesOfAllahPageState();
}

class _NamesOfAllahPageState extends State<NamesOfAllahPage> {
  String _query = '';
  int? _selected;
  int? _pulseIndex;
  bool _playing = false;
  int? _playingIndex;

  List<AsmaulHusnaName> get _filtered {
    if (_query.trim().isEmpty) return asmaulHusna;
    final q = _query.trim().toLowerCase();
    return asmaulHusna
        .where(
          (n) =>
              n.transliteration.toLowerCase().contains(q) ||
              n.meaning.toLowerCase().contains(q) ||
              n.arabic.contains(_query.trim()),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    ensureSpeechVoices();
  }

  @override
  void dispose() {
    stopSpeech();
    super.dispose();
  }

  void _speakName(AsmaulHusnaName name) {
    if (!speechSupported) {
      _flashUnsupported();
      return;
    }
    setState(() => _pulseIndex = name.number);
    speakText(name.arabic, onEnd: () {
      if (mounted) setState(() => _pulseIndex = null);
    });
  }

  void _togglePlayAll() {
    if (!speechSupported) {
      _flashUnsupported();
      return;
    }
    if (_playing) {
      stopSpeech();
      setState(() {
        _playing = false;
        _playingIndex = null;
      });
      return;
    }
    setState(() {
      _playing = true;
      _playingIndex = 0;
    });
    _reciteAt(0);
  }

  void _reciteAt(int i) {
    if (!_playing || !mounted) return;
    final names = _filtered;
    if (i >= names.length) {
      setState(() {
        _playing = false;
        _playingIndex = null;
      });
      return;
    }
    setState(() => _playingIndex = i);
    final name = names[i];
    setState(() => _pulseIndex = name.number);
    speakText(name.arabic, onEnd: () {
      if (mounted) {
        setState(() => _pulseIndex = null);
        _reciteAt(i + 1);
      }
    });
  }

  void _flashUnsupported() {
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Audio needs a browser with speech synthesis. Please use Chrome, Edge or Safari.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    setPageTitle('99 Names of Allah — Asmaul Husna · Ask Iman');
    final names = _filtered;
    final reciting = (_playing && _playingIndex != null)
        ? names[_playingIndex!]
        : null;

    return WebPageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          _buildHeader(),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(child: _buildSearch()),
              const SizedBox(width: 16),
              _buildPlayAllButton(),
            ],
          ),
          const SizedBox(height: 28),
          if (reciting != null) _buildRecitingBar(reciting),
          if (reciting != null) const SizedBox(height: 16),
          if (_selected != null) ...[
            _buildDetail(names[_selected!]),
            const SizedBox(height: 28),
          ],
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth >= 1100
                  ? 4
                  : (constraints.maxWidth >= 760 ? 3 : 2);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                ),
                itemCount: names.length,
                itemBuilder: (_, i) {
                  final name = names[i];
                  final isSelected =
                      _selected != null && names[_selected!] == name;
                  final isReciting = _playingIndex == i && _playing;
                  final isPulsing = _pulseIndex == name.number;
                  return HoverLift(
                    onTap: () {
                      setState(() => _selected = i);
                      _speakName(name);
                    },
                    child: _NameCard(
                      name: name,
                      isSelected: isSelected,
                      isReciting: isReciting,
                      isPulsing: isPulsing,
                      onSpeak: () => _speakName(name),
                    ),
                  ).animate(delay: Duration(milliseconds: (i.clamp(0, 30)) * 30)).fadeIn(duration: 350.ms).slideY(begin: 0.08);
                },
              );
            },
          ),
          const SizedBox(height: 40),
          const WebFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final figma = context.figma;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: FigmaTokens.heroGradientLight,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: figma.accentGoldSurface,
              shape: BoxShape.circle,
              border: Border.all(
                color: figma.accentGoldAmber.withValues(alpha: 0.5),
              ),
            ),
            child: Icon(
              Icons.stars_rounded,
              size: 32,
              color: figma.accentGoldAmber,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asmaul Husna — 99 Names of Allah',
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: figma.textHeading,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '"Allah has ninety-nine names — whoever memorises them will enter Paradise."',
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 13.5,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    color: figma.textBody,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '— Prophet Muhammad ﷺ (Sahih al-Bukhari 6410)',
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: figma.accentGoldAmber,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    final figma = context.figma;
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: figma.surfaceCard,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusInput),
        border: Border.all(color: figma.borderHairline),
      ),
      child: TextField(
        onChanged: (v) => setState(() => _query = v),
        decoration: InputDecoration(
          hintText: 'Search a name or meaning…',
          hintStyle: TextStyle(
            fontFamily: FigmaTokens.fontFamilyUiSans,
            fontSize: 14,
            color: figma.textMuted,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: figma.textMuted),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Text(
                '${_filtered.length} / 99',
                style: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyUiSans,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: figma.accentGoldAmber,
                ),
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
        style: TextStyle(
          fontFamily: FigmaTokens.fontFamilyUiSans,
          fontSize: 14.5,
          color: figma.textHeading,
        ),
      ),
    );
  }

  Widget _buildPlayAllButton() {
    final figma = context.figma;
    return ElevatedButton.icon(
      onPressed: _togglePlayAll,
      style: ElevatedButton.styleFrom(
        backgroundColor: _playing
            ? figma.accentGoldAmber
            : FigmaTokens.brandDeepGreen,
        foregroundColor: FigmaTokens.textOnDark,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FigmaTokens.radiusButton),
        ),
      ),
      icon: Icon(
        _playing ? Icons.stop_rounded : Icons.play_arrow_rounded,
        size: 20,
      ),
      label: Text(
        _playing ? 'Stop' : 'Play All 99',
        style: const TextStyle(
          fontFamily: FigmaTokens.fontFamilyUiSans,
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    ).animate().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 300.ms, curve: Curves.easeOut);
  }

  Widget _buildRecitingBar(AsmaulHusnaName name) {
    final figma = context.figma;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        gradient: FigmaTokens.darkBandGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: figma.accentGoldLight,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Reciting #${name.number} — ${name.transliteration}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: FigmaTokens.fontFamilyUiSans,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: FigmaTokens.textOnDark,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              stopSpeech();
              setState(() {
                _playing = false;
                _playingIndex = null;
                _pulseIndex = null;
              });
            },
            icon: Icon(
              Icons.stop_circle_outlined,
              color: figma.accentGoldLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetail(AsmaulHusnaName name) {
    final figma = context.figma;
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: FigmaTokens.darkBandGradient,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.arabic,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: FigmaTokens.fontFamilyArabicSerif,
                    fontSize: 40,
                    height: 1.4,
                    color: FigmaTokens.textOnDark,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name.transliteration,
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: figma.accentGoldLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name.meaning,
                  style: const TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 14.5,
                    color: FigmaTokens.textOnDark,
                  ),
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: () => _speakName(name),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: figma.accentGoldLight,
                    side: BorderSide(
                      color: figma.accentGoldAmber.withValues(alpha: 0.6),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.volume_up_rounded, size: 18),
                  label: const Text(
                    'Hear Name',
                    style: TextStyle(
                      fontFamily: FigmaTokens.fontFamilyUiSans,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Text(
            '#${name.number}',
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyDisplaySerif,
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: figma.accentGoldAmber.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _NameCard extends StatelessWidget {
  final AsmaulHusnaName name;
  final bool isSelected;
  final bool isReciting;
  final bool isPulsing;
  final VoidCallback onSpeak;

  const _NameCard({
    required this.name,
    required this.isSelected,
    required this.isReciting,
    required this.isPulsing,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isPulsing
            ? figma.accentGoldSurface
            : figma.surfaceCard,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        border: Border.all(
          color: isReciting || isSelected
              ? figma.accentGoldAmber
              : figma.borderHairline,
          width: (isReciting || isSelected) ? 2 : 1,
        ),
        boxShadow: isReciting ? figma.cardShadows : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${name.number}',
                style: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyUiSans,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: figma.accentGoldAmber,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onSpeak,
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Icon(
                      isReciting
                          ? Icons.graphic_eq_rounded
                          : Icons.volume_up_rounded,
                      size: 14,
                      color: isReciting
                          ? figma.accentGoldAmber
                          : figma.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            name.arabic,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontFamily: FigmaTokens.fontFamilyArabicSerif,
              fontSize: 24,
              color: FigmaTokens.brandDeepGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name.transliteration,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: figma.textHeading,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            name.meaning,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 11,
              color: figma.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
