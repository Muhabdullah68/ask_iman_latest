// lib/web/pages/coming_soon_page.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — COMING SOON
//
// Graceful placeholder for features still under construction.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/figma_tokens.dart';
import '../widgets/web_footer.dart';
import '../widgets/web_widgets.dart';

class ComingSoonPage extends StatelessWidget {
  final String title;
  const ComingSoonPage({super.key, this.title = 'Coming Soon'});

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return WebPageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
            decoration: BoxDecoration(
              gradient: figma.heroGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Icon(Icons.construction_rounded,
                    size: 48, color: figma.accentGoldAmber)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .slideY(begin: 0, end: -0.05, duration: 1500.ms, curve: Curves.easeInOut),
                const SizedBox(height: 16),
                Text(
                  'Under Construction',
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: figma.textHeading,
                  ),
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 8),
                Text(
                  'This section is being crafted with care. Check back soon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 14,
                    color: figma.textBody,
                  ),
                ).animate(delay: const Duration(milliseconds: 150)).fadeIn(duration: 400.ms),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const WebFooter(),
        ],
      ),
    );
  }
}
