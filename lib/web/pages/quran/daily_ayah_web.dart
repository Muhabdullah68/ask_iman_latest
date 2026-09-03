// lib/web/pages/quran/daily_ayah_web.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — QURAN · DAILY AYAH
//
// A featured ayah of the day plus a library of curated āyāt, with per-ayah
// recitation, copy and a "random ayah" refresh.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/data/daily_data.dart';
import '../../../core/services/quran_audio_service.dart';
import '../../../core/theme/figma_tokens.dart';
import '../../../features/quran/data/quran_api_service.dart';
import 'quran_web_widgets.dart';

class DailyAyahWeb extends StatefulWidget {
  const DailyAyahWeb({super.key});

  @override
  State<DailyAyahWeb> createState() => _DailyAyahWebState();
}

class _DailyAyahWebState extends State<DailyAyahWeb> {
  QuranAyah? _random;
  bool _loadingRandom = false;

  Map<String, String> get _daily => DailyData.getDailyAyahs(5).first;

  List<Map<String, String>> get _more => DailyData.getDailyAyahs(5).skip(1).toList();

  Future<void> _randomize() async {
    setState(() => _loadingRandom = true);
    final ayah = await QuranApiService.getRandomAyah();
    if (!mounted) return;
    setState(() {
      _loadingRandom = false;
      _random = ayah;
    });
    if (ayah == null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text('Could not fetch a random ayah. Try again shortly.'),
        ),
      );
    }
  }

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(content: Text('Ayah copied to clipboard.')),
    );
  }

  void _playRef(String reference) {
    final parts = reference.trim().split(' ').last.split(':');
    final s = int.tryParse(parts.first);
    final a = parts.length > 1 ? int.tryParse(parts[1].split('-').first) : null;
    if (s != null && a != null) {
      QuranAudioService().playAyah(s, a);
    }
  }

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    final daily = _daily;
    final featuredArabic = _random?.arabic ?? daily['arabic'] ?? '';
    final featuredTranslation =
        _random?.translation ?? daily['translation'] ?? '';
    final featuredRef = _random == null
        ? (daily['reference'] ?? '')
        : 'Random Ayah';

    return QuranPaneScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Daily Ayah',
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyDisplaySerif,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: figma.textHeading,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'A fresh verse each day, with recitation and a share of reflection.',
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 14.5,
              color: figma.textBody,
            ),
          ),
          const SizedBox(height: 24),
          _FeaturedCard(
            arabic: featuredArabic,
            translation: featuredTranslation,
            reference: featuredRef,
            loading: _loadingRandom,
            onPlay: () => _playRef(featuredRef),
            onCopy: () => _copy('$featuredTranslation\n($featuredRef)'),
            onRandom: _randomize,
          ),
          const SizedBox(height: 34),
          Text(
            'More Āyāt to Reflect On',
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyDisplaySerif,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: figma.textHeading,
            ),
          ),
          const SizedBox(height: 14),
          for (final a in _more)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MoreAyahCard(
                ayah: a,
                onPlay: () => _playRef(a['reference'] ?? ''),
                onCopy: () => _copy(
                  '${a['translation']}\n(${a['reference']})',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final String arabic;
  final String translation;
  final String reference;
  final bool loading;
  final VoidCallback onPlay;
  final VoidCallback onCopy;
  final VoidCallback onRandom;

  const _FeaturedCard({
    required this.arabic,
    required this.translation,
    required this.reference,
    required this.loading,
    required this.onPlay,
    required this.onCopy,
    required this.onRandom,
  });

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [FigmaTokens.brandDeepGreen, FigmaTokens.brandMidGreen],
        ),
        boxShadow: figma.cardShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: figma.accentGoldAmber,
                  borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
                ),
                child: const Text(
                  'DAILY AYAH',
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                    color: FigmaTokens.textOnDark,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                reference,
                style: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyUiSans,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: figma.accentGoldLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              loading ? '…' : arabic,
              textAlign: TextAlign.center,
              softWrap: true,
              style: const TextStyle(
                fontFamily: FigmaTokens.fontFamilyArabicMushaf,
                fontSize: 28,
                height: 1.9,
                color: FigmaTokens.textOnDark,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 72,
              height: 3,
              decoration: BoxDecoration(
                color: figma.accentGoldAmber,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            loading ? '' : translation,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 16,
              height: 1.6,
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 26),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: onPlay,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Play'),
                style: FilledButton.styleFrom(
                  backgroundColor: figma.accentGoldAmber,
                  foregroundColor: FigmaTokens.textOnDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FigmaTokens.radiusButton),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onCopy,
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copy'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FigmaTokens.radiusButton),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: loading ? null : onRandom,
                icon: const Icon(Icons.shuffle_rounded, size: 18),
                label: const Text('Random ayah'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FigmaTokens.radiusButton),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoreAyahCard extends StatelessWidget {
  final Map<String, String> ayah;
  final VoidCallback onPlay;
  final VoidCallback onCopy;
  const _MoreAyahCard({
    required this.ayah,
    required this.onPlay,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: figma.surfaceCard,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCardSm),
        border: Border.all(color: figma.borderHairline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    ayah['arabic'] ?? '',
                    textAlign: TextAlign.right,
                    softWrap: true,
                    style: TextStyle(
                      fontFamily: FigmaTokens.fontFamilyArabicMushaf,
                      fontSize: 19,
                      height: 1.8,
                      color: figma.textHeading,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ayah['translation'] ?? '',
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 13.5,
                    height: 1.55,
                    color: figma.textBody,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ayah['reference'] ?? '',
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
          const SizedBox(width: 12),
          Column(
            children: [
              _IconBtn(icon: Icons.play_arrow_rounded, onTap: onPlay, filled: true),
              const SizedBox(height: 8),
              _IconBtn(icon: Icons.copy_rounded, onTap: onCopy, filled: false),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  const _IconBtn({
    required this.icon,
    required this.onTap,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled
              ? FigmaTokens.brandMidGreen
              : FigmaTokens.brandMidGreen.withValues(alpha: 0.08),
        ),
        child: Icon(
          icon,
          size: 19,
          color: filled
              ? FigmaTokens.textOnDark
              : FigmaTokens.brandMidGreen,
        ),
      ),
    );
  }
}
