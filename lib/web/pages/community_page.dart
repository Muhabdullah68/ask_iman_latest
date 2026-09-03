// lib/web/pages/community_page.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — PAGE 4 · COMMUNITY & CHARITY
//
// Embeds the app's CommunityScreen (Classes, Family & Friends, Groups,
// Charity) inside the website shell. Streaks are excluded on the website.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../core/theme/figma_tokens.dart';
import '../widgets/web_animations.dart';
import '../../core/utils/seo_meta.dart';
import '../../features/community/community_screen.dart';
import '../../features/charity/charity_list_screen.dart';
import '../widgets/web_footer.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    setPageTitle('Community — Classes, Groups & Charity · Ask Iman');
    return Column(
      children: [
        Expanded(
          child: CommunityScreen(embedded: true),
        ),
        const WebFooter(),
      ],
    );
  }
}

/// Charity sub-page — full charity campaign list with footer.
class CharityPage extends StatelessWidget {
  const CharityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    setPageTitle('Charity — Support the Community · Ask Iman');
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: webScrollPhysics,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 26,
                  ),
                  decoration: BoxDecoration(
                    gradient: figma.heroGradient,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Charity',
                        style: TextStyle(
                          fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: figma.textHeading,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Support active campaigns, mosques and relief projects.',
                        style: TextStyle(
                          fontFamily: FigmaTokens.fontFamilyUiSans,
                          fontSize: 14,
                          color: figma.textBody,
                        ),
                      ),
                    ],
                  ),
                ),
                const CharityListScreen(showScaffold: false),
                const SizedBox(height: 24),
                const WebFooter(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
