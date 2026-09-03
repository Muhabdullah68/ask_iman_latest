// lib/web/pages/quran/quran_web_widgets.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — QURAN SHARED WEB WIDGETS
//
// Reusable pieces for the web-native Quran pages: a scrollable pane wrapper
// that keeps a footer and clears the sticky audio bar, a rich ayah card with
// context menu, a Basmala header, and verse dividers.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/web_animations.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/figma_tokens.dart';
import '../../../core/services/quran_audio_service.dart';
import '../../widgets/web_footer.dart';

/// Bounded scrollable wrapper for standalone tab panes (e.g. Hadith, Juzz,
/// Daily Ayah) that are rendered outside the main Quran page. Always ends
/// with a full-width site footer and leaves bottom padding so the sticky
/// [QuranAudioBar] never covers content. Never nests an unbounded scrollable
/// (web blank-page rule).
class QuranPaneScaffold extends StatelessWidget {
  final Widget child;
  const QuranPaneScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.sizeOf(context).width < 600 ? 80.0 : 132.0;
    return SingleChildScrollView(
      physics: webScrollPhysics,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24, 28, 24, 0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: child,
              ),
            ),
          ),
          const SizedBox(height: 44),
          const WebFooter(),
          SizedBox(height: bottomPad),
        ],
      ),
    );
  }
}

/// Non-scrolling, footer-less content wrapper used for the five tab panes
/// *inside* the main [QuranPage]. The QuranPage provides the unified outer
/// scroll and the single shared [WebFooter] at the very bottom of the page.
class QuranPaneContent extends StatelessWidget {
  final Widget child;
  const QuranPaneContent({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: child,
        ),
      ),
    );
  }
}

/// Centered Basmala displayed above the first verse of every surah.
class BasmalaWidget extends StatelessWidget {
  const BasmalaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 18),
      child: Center(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyArabicSerif,
              fontSize: 30,
              height: 1.6,
              color: FigmaTokens.brandDeepGreen,
            ),
          ),
        ),
      ),
    );
  }
}

/// A thin divider between verse cards, matching the Figma spec.
class VerseDivider extends StatelessWidget {
  const VerseDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Divider(
        height: 1,
        thickness: 0.8,
        color: figma.borderHairline,
      ),
    );
  }
}

/// A single ayah — Arabic (RTL), English/Urdu translation, number badge and a
/// per-ayah play button that drives the shared [QuranAudioService].
/// Tapping the card shows a context menu (copy, share, bookmark, play).
class AyahCard extends StatelessWidget {
  final int surahNum;
  final int ayahNum;
  final String arabic;
  final String translation;
  final bool urdu;
  final bool showBasmala;

  const AyahCard({
    super.key,
    required this.surahNum,
    required this.ayahNum,
    required this.arabic,
    required this.translation,
    this.urdu = false,
    this.showBasmala = false,
  });

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _VerseContextMenu(
        surahNum: surahNum,
        ayahNum: ayahNum,
        arabic: arabic,
        translation: translation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return GestureDetector(
      onTap: () => _showContextMenu(context),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
        decoration: BoxDecoration(
          color: figma.surfaceBackground,
          borderRadius: BorderRadius.circular(FigmaTokens.radiusCardSm),
          border: Border.all(color: figma.borderHairline),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      arabic,
                      textAlign: TextAlign.right,
                      softWrap: true,
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyArabicMushaf,
                        fontSize: 24,
                        height: 1.95,
                        color: figma.textHeading,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    translation,
                    style: TextStyle(
                      fontFamily: FigmaTokens.fontFamilyUiSans,
                      fontSize: 14.5,
                      height: 1.6,
                      color: figma.textBody.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: figma.accentGoldSurface,
                  ),
                  child: Text(
                    '$ayahNum',
                    style: TextStyle(
                      fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: figma.accentGoldAmber,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _PlayAyahButton(
                  surahNum: surahNum,
                  ayahNum: ayahNum,
                ).animate().fadeIn(duration: 200.ms, curve: Curves.easeOut),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom-sheet context menu shown when a verse card is tapped.
class _VerseContextMenu extends StatelessWidget {
  final int surahNum;
  final int ayahNum;
  final String arabic;
  final String translation;
  const _VerseContextMenu({
    required this.surahNum,
    required this.ayahNum,
    required this.arabic,
    required this.translation,
  });

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: figma.surfaceCard,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        boxShadow: figma.cardShadows,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: figma.surfacePanelMint,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(FigmaTokens.radiusCard),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: figma.accentGoldSurface,
                  ),
                  child: Text(
                    '$ayahNum',
                    style: TextStyle(
                      fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: figma.accentGoldAmber,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Verse $ayahNum · Surah $surahNum',
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
          ),
          _ContextAction(
            icon: Icons.copy_rounded,
            label: 'Copy Arabic',
            onTap: () {
              Clipboard.setData(ClipboardData(text: arabic));
              Navigator.pop(context);
              ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                const SnackBar(content: Text('Arabic text copied.')),
              );
            },
          ),
          _ContextAction(
            icon: Icons.translate_rounded,
            label: 'Copy Translation',
            onTap: () {
              Clipboard.setData(ClipboardData(text: translation));
              Navigator.pop(context);
              ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                const SnackBar(content: Text('Translation copied.')),
              );
            },
          ),
          _ContextAction(
            icon: Icons.share_rounded,
            label: 'Share',
            onTap: () {
              Navigator.pop(context);
              final url = Uri.parse(
                'https://askiman.com/quran/surah/$surahNum',
              );
              launchUrl(url, mode: LaunchMode.platformDefault);
            },
          ),
          _ContextAction(
            icon: Icons.bookmark_outline_rounded,
            label: 'Bookmark',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                const SnackBar(content: Text('Verse bookmarked.')),
              );
            },
          ),
          _ContextAction(
            icon: Icons.play_arrow_rounded,
            label: 'Play from this verse',
            onTap: () {
              Navigator.pop(context);
              QuranAudioService().playAyah(surahNum, ayahNum);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ContextAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ContextAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Icon(icon, size: 20, color: FigmaTokens.brandMidGreen),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyUiSans,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: figma.textHeading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayAyahButton extends StatefulWidget {
  final int surahNum;
  final int ayahNum;
  const _PlayAyahButton({required this.surahNum, required this.ayahNum});

  @override
  State<_PlayAyahButton> createState() => _PlayAyahButtonState();
}

class _PlayAyahButtonState extends State<_PlayAyahButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final audio = QuranAudioService();
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Tooltip(
        message: 'Play ayah ${widget.ayahNum}',
        child: ListenableBuilder(
          listenable: audio,
          builder: (context, _) {
            final active = _hover || audio.isPlaying;
            return InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => audio.playAyah(widget.surahNum, widget.ayahNum),
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active
                      ? FigmaTokens.brandMidGreen
                      : FigmaTokens.brandDeepGreen.withValues(alpha: 0.06),
                ),
                child: Icon(
                  active
                      ? Icons.volume_up_rounded
                      : Icons.volume_up_outlined,
                  size: 19,
                  color: active
                      ? FigmaTokens.textOnDark
                      : FigmaTokens.brandMidGreen,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
