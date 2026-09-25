// lib/web/pages/community_page.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — PAGE 4 · COMMUNITY & CHARITY
//
// Web-native community experience: a deep-green hero band with the interactive
// Ka'aba 3D model and gold ornamentation, above the embedded app Community
// screen (Classes, Family & Friends, Groups, Charity). The charity sub-page
// gets matching ornament treatment.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/figma_tokens.dart';
import '../web_router.dart' show WebRoutes;
import '../widgets/web_animations.dart';
import '../widgets/web_model3d.dart';
import '../widgets/web_ornaments.dart';
import '../widgets/web_widgets.dart';
import '../../core/utils/seo_meta.dart';
import '../../features/community/community_screen.dart';
import '../../features/charity/charity_list_screen.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    setPageTitle('Community — Classes, Groups & Charity · Ask Iman');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _CommunityHero(),
        Expanded(child: CommunityScreen(embedded: true)),
      ],
    );
  }
}

/// Deep-green hero with the Ka'aba 3D model and gold ornamentation.
class _CommunityHero extends StatelessWidget {
  const _CommunityHero();

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Container(
      decoration: const BoxDecoration(gradient: FigmaTokens.heroGradientDark),
      padding: const EdgeInsets.fromLTRB(24, 44, 24, 44),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 880;
              final copy = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      KhatamOrnament(
                        size: 12,
                        alpha: 0.9,
                        strokeWidth: 1.2,
                        color: figma.accentGoldAmber,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'COMMUNITY & CHARITY',
                        style: TextStyle(
                          fontFamily: FigmaTokens.fontFamilyUiSans,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.2,
                          color: figma.accentGoldLight.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Connect, learn, and grow together.',
                    style: TextStyle(
                      fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                      fontSize: 38,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                      color: FigmaTokens.textOnDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Classes, family & friends, mosque groups and charity '
                    'campaigns — the whole family in one place.',
                    style: TextStyle(
                      fontFamily: FigmaTokens.fontFamilyUiSans,
                      fontSize: 15,
                      height: 1.55,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      WebButton(
                        label: 'Explore the Community',
                        icon: Icons.people_outline_rounded,
                        onPressed: () => context.go(WebRoutes.community),
                      ),
                      WebButton(
                        label: 'Support a Cause',
                        outlined: true,
                        icon: Icons.volunteer_activism_outlined,
                        onPressed: () => context.go(WebRoutes.charity),
                      ),
                    ],
                  ),
                ],
              );
              final model = SizedBox(
                width: 258,
                height: 258,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: FigmaTokens.ornamentGold.withValues(
                              alpha: 0.45,
                            ),
                            width: 1.5,
                          ),
                          gradient: RadialGradient(
                            colors: [
                              FigmaTokens.ornamentGold.withValues(alpha: 0.18),
                              FigmaTokens.ornamentGold.withValues(alpha: 0.02),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: const Model3D(
                          src: 'assets/3D/kaaba_polished_detailed.glb',
                          borderRadius: BorderRadius.all(Radius.circular(110)),
                        ),
                      ),
                    ),
                  ],
                ),
              );
              if (!wide) {
                return Column(
                  children: [
                    copy,
                    const SizedBox(height: 28),
                    Center(
                      child: FittedBox(fit: BoxFit.scaleDown, child: model),
                    ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: copy),
                  const SizedBox(width: 48),
                  FittedBox(fit: BoxFit.scaleDown, child: model),
                ],
              );
            },
          ),
        ),
      ),
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
                  decoration: BoxDecoration(gradient: figma.heroGradient),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          KhatamOrnament(
                            size: 12,
                            alpha: 0.9,
                            strokeWidth: 1.2,
                            color: figma.accentGoldAmber,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'SADAQAH · ZAKAT · RELIEF',
                            style: TextStyle(
                              fontFamily: FigmaTokens.fontFamilyUiSans,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.2,
                              color: figma.accentGoldAmber,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Charity',
                        style: TextStyle(
                          fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: FigmaTokens.textHeading,
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
                      const SizedBox(height: 16),
                      const GoldRule(height: 1.5, alpha: 0.35, khatamSize: 18),
                    ],
                  ),
                ),
                const CharityListScreen(showScaffold: false),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
