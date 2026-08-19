// lib/web/pages/coming_soon_page.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — COMING SOON
//
// Graceful placeholder for features still under construction.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../core/theme/figma_tokens.dart';
import '../widgets/web_footer.dart';
import '../widgets/web_widgets.dart';

class ComingSoonPage extends StatelessWidget {
  final String title;
  const ComingSoonPage({super.key, this.title = 'Coming Soon'});

  @override
  Widget build(BuildContext context) {
    return WebPageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
            decoration: BoxDecoration(
              gradient: FigmaTokens.heroGradientLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              children: [
                Icon(Icons.construction_rounded,
                    size: 48, color: FigmaTokens.accentGoldAmber),
                SizedBox(height: 16),
                Text(
                  'Under Construction',
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: FigmaTokens.textHeading,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'This section is being crafted with care. Check back soon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 14,
                    color: FigmaTokens.textBody,
                  ),
                ),
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
