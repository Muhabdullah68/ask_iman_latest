// lib/web/widgets/web_footer.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — Site-wide footer
//
// Deep-green 4-column footer: brand + socials, Explore links, Community links,
// Support/Contact block + newsletter capture. All links navigate via the router
// (replaces the dead text-links in the app footer).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/figma_tokens.dart';
import '../web_router.dart' show WebRoutes;

class WebFooter extends StatelessWidget {
  const WebFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FigmaTokens.brandDeepGreen,
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 860;
                      if (!wide) return _buildStacked(context);
                      return _buildColumns(context);
                    },
                  ),
                  const SizedBox(height: 32),
                  Divider(color: Colors.white.withValues(alpha: 0.12)),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final bismillah = Text(
                        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 13,
                          color: FigmaTokens.accentGoldLight.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      );
                      if (constraints.maxWidth < 560) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '© ${DateTime.now().year} Ask Iman — BarakAllahu feekum.',
                              style: TextStyle(
                                fontFamily: FigmaTokens.fontFamilyUiSans,
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.55),
                              ),
                            ),
                            const SizedBox(height: 10),
                            bismillah,
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              '© ${DateTime.now().year} Ask Iman — BarakAllahu feekum.',
                              style: TextStyle(
                                fontFamily: FigmaTokens.fontFamilyUiSans,
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.55),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          bismillah,
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColumns(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: _brandBlock(context)),
        const SizedBox(width: 32),
        Expanded(flex: 4, child: _linkColumn('Explore', _exploreLinks, context)),
        const SizedBox(width: 32),
        Expanded(flex: 4, child: _linkColumn('Community', _communityLinks, context)),
        const SizedBox(width: 32),
        Expanded(flex: 5, child: _contactBlock(context)),
      ],
    );
  }

  Widget _buildStacked(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _brandBlock(context),
        const SizedBox(height: 28),
        _linkColumn('Explore', _exploreLinks, context),
        const SizedBox(height: 24),
        _linkColumn('Community', _communityLinks, context),
        const SizedBox(height: 28),
        _contactBlock(context),
      ],
    );
  }

  Widget _brandBlock(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'ASK ',
                style: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: FigmaTokens.accentGoldAmber,
                ),
              ),
              TextSpan(
                text: 'ایمان',
                style: TextStyle(
                  fontFamily: 'NotoNastaliq',
                  fontSize: 19,
                  color: FigmaTokens.textOnDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Your companion for Quran, prayer, knowledge and community — '
          'carrying light into every corner of your day.',
          style: TextStyle(
            fontFamily: FigmaTokens.fontFamilyUiSans,
            fontSize: 13,
            height: 1.6,
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _socialIcon(Icons.facebook_rounded),
            const SizedBox(width: 10),
            _socialIcon(Icons.camera_alt_outlined),
            const SizedBox(width: 10),
            _socialIcon(Icons.smart_display_rounded),
            const SizedBox(width: 10),
            _socialIcon(Icons.mail_outline_rounded),
          ],
        ),
      ],
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Icon(icon, color: FigmaTokens.accentGoldLight, size: 18),
    );
  }

  static const _exploreLinks = [
    (label: 'Quran Explorer', route: WebRoutes.quran),
    (label: 'Translation & Tafseer', route: '${WebRoutes.quran}/tafseer'),
    (label: 'Hadith Library', route: '${WebRoutes.quran}/hadith'),
    (label: 'Calendar & Tools', route: WebRoutes.calendarTools),
    (label: '99 Names', route: '${WebRoutes.calendarTools}/99-names'),
  ];

  static const _communityLinks = [
    (label: 'Community', route: WebRoutes.community),
    (label: 'Charity & Causes', route: WebRoutes.charity),
    (label: 'Family Hub', route: '${WebRoutes.community}/family'),
    (label: 'About Us', route: WebRoutes.about),
    (label: 'Contact', route: '${WebRoutes.about}#contact'),
  ];

  Widget _linkColumn(
    String title,
    List<({String label, String route})> links,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: FigmaTokens.fontFamilyUiSans,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: FigmaTokens.textOnDark,
          ),
        ),
        const SizedBox(height: 14),
        for (final l in links)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () {
                final base = l.route.split('#').first;
                context.go(base);
              },
              borderRadius: BorderRadius.circular(6),
              child: Text(
                l.label,
                style: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyUiSans,
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.62),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _contactBlock(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stay Connected',
          style: TextStyle(
            fontFamily: FigmaTokens.fontFamilyUiSans,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: FigmaTokens.textOnDark,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Join the newsletter for daily ayah, hadith and dua.',
          style: TextStyle(
            fontFamily: FigmaTokens.fontFamilyUiSans,
            fontSize: 12.5,
            color: Colors.white.withValues(alpha: 0.62),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Your email',
                  hintStyle: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(
                  fontFamily: FigmaTokens.fontFamilyUiSans,
                  fontSize: 13,
                  color: FigmaTokens.textOnDark,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: FigmaTokens.accentGoldAmber,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thanks for subscribing — BarakAllahu feekum!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: FigmaTokens.brandDeepGreen,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: () => context.go('${WebRoutes.about}#contact'),
          borderRadius: BorderRadius.circular(8),
          child: const Row(
            children: [
              Icon(
                Icons.contact_mail_outlined,
                color: FigmaTokens.accentGoldLight,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'Contact support',
                style: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyUiSans,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: FigmaTokens.accentGoldLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
