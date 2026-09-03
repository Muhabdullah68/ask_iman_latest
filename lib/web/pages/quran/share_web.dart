// lib/web/pages/quran/share_web.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — QURAN · SHARE TAB
//
// Share the Quran explorer page, current surah, or individual verses via
// social media, copy link, or native share API.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/figma_tokens.dart';
import 'quran_web_widgets.dart';

class QuranShareWeb extends StatelessWidget {
  const QuranShareWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return QuranPaneContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share',
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyDisplaySerif,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: figma.textHeading,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Share the Qur\'ān with family and friends.',
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 14.5,
              color: figma.textBody,
            ),
          ),
          const SizedBox(height: 28),
          _ShareCard(
            title: 'Share Quran Explorer',
            subtitle: 'Send a link to the Quran Explorer so others can read and listen.',
            url: 'https://askiman.com/quran',
            icon: Icons.share_rounded,
          ),
          const SizedBox(height: 16),
          _ShareCard(
            title: 'Share Al-Fatihah',
            subtitle: 'Send the opening surah — a beautiful gift for anyone.',
            url: 'https://askiman.com/quran/surah/1',
            icon: Icons.auto_stories_rounded,
          ),
          const SizedBox(height: 16),
          _ShareCard(
            title: 'Share Ayah of the Day',
            subtitle: 'Inspire someone with today\'s featured verse.',
            url: 'https://askiman.com/quran/tarjuma',
            icon: Icons.auto_awesome_rounded,
          ),
        ],
      ),
    );
  }
}

class _ShareCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String url;
  final IconData icon;
  const _ShareCard({
    required this.title,
    required this.subtitle,
    required this.url,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: figma.surfaceCard,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        border: Border.all(color: figma.borderHairline),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: figma.surfacePanelMint,
            ),
            child: Icon(icon, size: 22, color: FigmaTokens.brandMidGreen),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: figma.textHeading,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 13,
                    color: figma.textBody,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: FigmaTokens.brandMidGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
            ),
            child: InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                  SnackBar(
                    content: Text('Link copied: $url'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.link_rounded, size: 16, color: FigmaTokens.textOnDark),
                    SizedBox(width: 6),
                    Text(
                      'Copy Link',
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyUiSans,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: FigmaTokens.textOnDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
