// lib/web/pages/quran/translation_web.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — QURAN · TARJUMA (TRANSLATION)
//
// Web reading layout: pick a surah, then scroll Arabic + English/Urdu
// translation in comfortable reading cards. Includes a "Daily Inspiration"
// banner at the top (from the old Daily Ayah tab). Supports line-for-line
// interleaved mode.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/data/daily_data.dart';
import '../../../core/services/quran_audio_service.dart';
import '../../../core/theme/figma_tokens.dart';
import '../../../features/quran/data/quran_api_service.dart';
import '../../../features/quran/data/surahs_data.dart';
import 'quran_web_widgets.dart';

class TranslationWeb extends StatefulWidget {
  const TranslationWeb({super.key});

  @override
  State<TranslationWeb> createState() => _TranslationWebState();
}

class _TranslationWebState extends State<TranslationWeb> {
  int _selected = 1;
  bool _urdu = false;
  bool _lineForLine = false;
  List<Map<String, String>>? _ayahs;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _ayahs = null;
    });
    var data = await QuranApiService.fetchSurah(_selected);
    data ??= await QuranApiService.getLocalAyahs(_selected);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _ayahs = data;
    });
  }

  void _select(int num) {
    if (num == _selected) return;
    setState(() => _selected = num);
    _load();
  }

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meta = SurahsData.surahs[_selected - 1];
    final name = meta['name'] as String;
    final audio = QuranAudioService();
    final daily = DailyData.getDailyAyahs(5).first;

    return QuranPaneScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Daily Inspiration banner
          _DailyInspirationBanner(
            arabic: daily['arabic'] ?? '',
            translation: daily['translation'] ?? '',
            reference: daily['reference'] ?? '',
            onPlay: () {
              final parts =
                  (daily['reference'] ?? '').trim().split(' ').last.split(':');
              final s = int.tryParse(parts.first);
              final a =
                  parts.length > 1 ? int.tryParse(parts[1].split('-').first) : null;
              if (s != null && a != null) audio.playAyah(s, a);
            },
            onCopy: () => _copy(
              '${daily['translation']}\n(${daily['reference']})',
            ),
          ),
          const SizedBox(height: 24),
          _TabIntro(
            title: 'Tarjuma',
            subtitle:
                'Read the Qur\u0101n with meaning. Switch between English and Urdu as you go.',
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: FigmaTokens.surfaceCard,
              borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
              border: Border.all(color: FigmaTokens.borderHairline),
              boxShadow: FigmaTokens.cardShadowSm,
            ),
            child: Row(
              children: [
                Flexible(
                  child: DropdownButton<int>(
                    value: _selected,
                    underline: const SizedBox.shrink(),
                    borderRadius: BorderRadius.circular(12),
                    isExpanded: true,
                    items: [
                      for (final s in SurahsData.surahs)
                        DropdownMenuItem(
                          value: s['num'] as int,
                          child: SizedBox(
                            width: 220,
                            child: Text(
                              '${s['num']}. ${s['name']}',
                              style: const TextStyle(
                                fontFamily: FigmaTokens.fontFamilyUiSans,
                                fontSize: 14,
                                color: FigmaTokens.textHeading,
                              ),
                            ),
                          ),
                        ),
                    ],
                    onChanged: (v) {
                      if (v != null) _select(v);
                    },
                  ),
                ),
                const Text(
                  '\u00b7',
                  style: TextStyle(
                    color: FigmaTokens.accentGoldAmber,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                _LangToggle(
                  urdu: _urdu,
                  onTap: () => setState(() => _urdu = !_urdu),
                ),
                const SizedBox(width: 8),
                _ModeToggle(
                  lineForLine: _lineForLine,
                  onTap: () => setState(() => _lineForLine = !_lineForLine),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => audio.playSurah(_selected, name),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text('Play $name'),
                  style: FilledButton.styleFrom(
                    backgroundColor: FigmaTokens.brandMidGreen,
                    foregroundColor: FigmaTokens.textOnDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        FigmaTokens.radiusButton,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_ayahs == null)
            _NoData(message: 'Could not load Surah $name. Please retry.')
          else if (_lineForLine)
            for (final a in _ayahs!) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  a['a'] ?? '',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: FigmaTokens.fontFamilyArabicMushaf,
                    fontSize: 22,
                    height: 1.85,
                    color: FigmaTokens.textHeading,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _urdu ? (a['tu'] ?? a['t'] ?? '') : (a['t'] ?? ''),
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 13.5,
                    height: 1.5,
                    color: FigmaTokens.textBody.withValues(alpha: 0.9),
                  ),
                ),
              ),
              const VerseDivider(),
            ]
          else
            for (final a in _ayahs!) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: AyahCard(
                  surahNum: _selected,
                  ayahNum: int.parse(a['num']!),
                  arabic: a['a']!,
                  translation: _urdu ? (a['tu'] ?? a['t']!) : a['t']!,
                  urdu: _urdu,
                ),
              ),
            ],
        ],
      ),
    );
  }
}

class _DailyInspirationBanner extends StatelessWidget {
  final String arabic;
  final String translation;
  final String reference;
  final VoidCallback onPlay;
  final VoidCallback onCopy;
  const _DailyInspirationBanner({
    required this.arabic,
    required this.translation,
    required this.reference,
    required this.onPlay,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [FigmaTokens.brandDeepGreen, FigmaTokens.brandMidGreen],
        ),
        boxShadow: FigmaTokens.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: FigmaTokens.accentGoldAmber,
                    borderRadius:
                        BorderRadius.circular(FigmaTokens.radiusPill),
                  ),
                  child: const Text(
                    'DAILY INSPIRATION',
                    style: TextStyle(
                      fontFamily: FigmaTokens.fontFamilyUiSans,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                      color: FigmaTokens.textOnDark,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  arabic,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: FigmaTokens.fontFamilyArabicMushaf,
                    fontSize: 22,
                    height: 1.85,
                    color: FigmaTokens.textOnDark,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  translation,
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 13.5,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  reference,
                  style: const TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: FigmaTokens.accentGoldLight,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _BannerBtn(
                      icon: Icons.play_arrow_rounded,
                      label: 'Play',
                      filled: true,
                      onTap: onPlay,
                    ),
                    _BannerBtn(
                      icon: Icons.copy_rounded,
                      label: 'Copy',
                      filled: false,
                      onTap: onCopy,
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

class _BannerBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;
  const _BannerBtn({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? FigmaTokens.accentGoldAmber : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FigmaTokens.radiusButton),
        side: filled
            ? BorderSide.none
            : const BorderSide(color: Colors.white54),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusButton),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: FigmaTokens.fontFamilyUiSans,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabIntro extends StatelessWidget {
  final String title;
  final String subtitle;
  const _TabIntro({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: FigmaTokens.fontFamilyDisplaySerif,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: FigmaTokens.textHeading,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontFamily: FigmaTokens.fontFamilyUiSans,
            fontSize: 14.5,
            color: FigmaTokens.textBody,
          ),
        ),
      ],
    );
  }
}

class _LangToggle extends StatelessWidget {
  final bool urdu;
  final VoidCallback onTap;
  const _LangToggle({required this.urdu, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _lang('English', selected: !urdu),
        const SizedBox(width: 4),
        _lang('\u0627\u0631\u062f\u0648', selected: urdu),
      ],
    );
  }

  Widget _lang(String label, {required bool selected}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? FigmaTokens.brandMidGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
          border: Border.all(
            color: selected
                ? FigmaTokens.brandMidGreen
                : FigmaTokens.brandMidGreen.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: FigmaTokens.fontFamilyUiSans,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: selected ? FigmaTokens.textOnDark : FigmaTokens.brandMidGreen,
          ),
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final bool lineForLine;
  final VoidCallback onTap;
  const _ModeToggle({required this.lineForLine, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: lineForLine ? 'Block mode' : 'Line-for-line mode',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: lineForLine
                ? FigmaTokens.accentGoldAmber
                : FigmaTokens.surfacePanelMint,
            borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
          ),
          child: Icon(
            lineForLine ? Icons.view_agenda_rounded : Icons.view_stream_rounded,
            size: 16,
            color: lineForLine ? FigmaTokens.textOnDark : FigmaTokens.brandMidGreen,
          ),
        ),
      ),
    );
  }
}

class _NoData extends StatelessWidget {
  final String message;
  const _NoData({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: FigmaTokens.surfaceCard,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded,
              size: 40, color: FigmaTokens.textMuted),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
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
