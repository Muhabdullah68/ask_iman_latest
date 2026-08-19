// lib/web/pages/calendar_tools_page.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — PAGE 3 · CALENDAR & TOOLS
//
// Embeds the app's IbadahScreen (Hijri calendar, prayer times, tools) inside
// the website shell. Qibla Finder, Alarm and Notifications are intentionally
// excluded from the website.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../core/theme/figma_tokens.dart';
import '../../core/utils/seo_meta.dart';
import '../../features/ibadah/ibadah_screen.dart';
import '../../features/ibadah/tasbeeh_screen.dart';
import '../widgets/web_footer.dart';

class CalendarToolsPage extends StatelessWidget {
  const CalendarToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    setPageTitle('Calendar & Tools — Hijri, Prayer Times · Ask Iman');
    return Column(
      children: [
        Expanded(
          child: IbadahScreen(embedded: true),
        ),
        const WebFooter(),
      ],
    );
  }
}

/// Tasbeeh (dhikr counter) — deep link from the tools page.
class TasbeehPage extends StatelessWidget {
  const TasbeehPage({super.key});

  @override
  Widget build(BuildContext context) {
    setPageTitle('Tasbeeh — Digital Dhikr Counter · Ask Iman');
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 26,
                  ),
                  decoration: BoxDecoration(
                    gradient: FigmaTokens.heroGradientLight,
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tasbeeh',
                        style: TextStyle(
                          fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: FigmaTokens.textHeading,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Count your adhkar with the digital dhikr counter.',
                        style: TextStyle(
                          fontFamily: FigmaTokens.fontFamilyUiSans,
                          fontSize: 14,
                          color: FigmaTokens.textBody,
                        ),
                      ),
                    ],
                  ),
                ),
                const TasbeehScreen(embedded: true),
                const SizedBox(height: 40),
                const WebFooter(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
