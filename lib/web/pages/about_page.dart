// lib/web/pages/about_page.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — PAGE 5 · ABOUT US
//
// Figma Screen #1: About Ask Iman, our journey, values, impact and the
// contact form (#contact anchor is linked from the site footer).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/figma_tokens.dart';
import '../../core/utils/seo_meta.dart';
import '../widgets/web_animations.dart';
import '../widgets/web_footer.dart';
import '../widgets/web_widgets.dart';
import '../web_router.dart' show WebRoutes;

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    setPageTitle('About Us — Our Mission · Ask Iman');
    return WebPageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const ScrollReveal(child: _AboutHero()),
          const SizedBox(height: 64),
          const ScrollReveal(delay: Duration(milliseconds: 100), child: _MissionSection()),
          const SizedBox(height: 64),
          const ScrollReveal(delay: Duration(milliseconds: 200), child: _JourneySection()),
          const SizedBox(height: 64),
          const ScrollReveal(delay: Duration(milliseconds: 300), child: _ImpactBand()),
          const SizedBox(height: 64),
          const ScrollReveal(delay: Duration(milliseconds: 400), child: _ContactSection()),
          const SizedBox(height: 64),
          const WebFooter(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO
// ─────────────────────────────────────────────────────────────────────────────
class _AboutHero extends StatelessWidget {
  const _AboutHero();

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: figma.heroGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 700;
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: figma.accentGoldAmber,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'ABOUT ASK IMAN',
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: FigmaTokens.textOnDark,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Rooted in faith.\nBuilt for the Ummah.',
                style: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                  color: figma.textHeading,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Ask Iman is a growing digital companion for Muslims around '
                'the world — bringing the Quran, authentic hadith, daily '
                'guidance and community support into one beautiful home.',
                style: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyUiSans,
                  fontSize: 15,
                  height: 1.6,
                  color: figma.textBody,
                ),
              ),
              const SizedBox(height: 22),
              WebButton(
                label: 'Start Exploring',
                icon: Icons.arrow_forward_rounded,
                onPressed: () => context.go(WebRoutes.quran),
              ),
            ],
          );

          final ornament = Container(
            width: 150,
            height: 150,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: figma.accentGoldAmber.withValues(alpha: 0.12),
            ),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '﴿﷽﴾',
                style: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyArabicSerif,
                  fontSize: 30,
                  color: FigmaTokens.brandDeepGreen,
                  height: 1,
                ),
              ),
            ),
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,
                const SizedBox(height: 24),
                Center(child: ornament),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: content),
              const SizedBox(width: 28),
              ornament,
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MISSION / VISION
// ─────────────────────────────────────────────────────────────────────────────
class _MissionSection extends StatelessWidget {
  const _MissionSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        const cards = [
          _InfoCard(
            icon: Icons.visibility_rounded,
            eyebrow: 'Our Vision',
            title: 'Knowledge for every home',
            body:
                'A world where every Muslim can access authentic Islamic '
                'knowledge in their own language — whether at home, in the '
                'mosque, or on the go.',
          ),
          _InfoCard(
            icon: Icons.explore_rounded,
            eyebrow: 'Our Mission',
            title: 'Bridge tradition & technology',
            body:
                'We combine the timeless Quran and Sunnah with modern '
                'technology to help you recite, understand, practice and share.',
          ),
        ];
        if (!wide) {
          return Column(
            children: [
              cards[0],
              const SizedBox(height: 20),
              cards[1],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 20),
            Expanded(child: cards[1]),
          ],
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String eyebrow;
  final String title;
  final String body;
  const _InfoCard({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: figma.surfaceCard,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        border: Border.all(color: figma.borderHairline),
        boxShadow: figma.cardShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: figma.accentGoldAmber),
          const SizedBox(height: 16),
          Text(
            eyebrow.toUpperCase(),
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: figma.accentGoldAmber,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyDisplaySerif,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: figma.textHeading,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 13.5,
              height: 1.6,
              color: figma.textBody,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// JOURNEY / VALUES
// ─────────────────────────────────────────────────────────────────────────────
class _JourneySection extends StatelessWidget {
  const _JourneySection();

  static const _values = [
    ('Authenticity', 'Every source is verified against the Quran and Sunnah.'),
    ('Accessibility', 'Free for everyone, in English, اردو and پښتو.'),
    ('Community', 'Built with and for the global Ummah.'),
    ('Excellence', 'Crafted with care, reviewed by scholars.'),
  ];

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const WebSectionHeader(
          eyebrow: 'Why Ask Iman',
          title: 'Our Journey & Values',
          subtitle:
              'From a simple idea to a companion used across the world — '
              'these values guide everything we build.',
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final cols = constraints.maxWidth >= 900 ? 4 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemCount: _values.length,
              itemBuilder: (_, i) {
                final v = _values[i];
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: figma.surfacePanelMint,
                    borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
                    border: Border.all(color: figma.borderHairline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '0${i + 1}',
                        style: TextStyle(
                          fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: figma.accentGoldAmber,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        v.$1,
                        style: TextStyle(
                          fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: figma.textHeading,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        v.$2,
                        style: TextStyle(
                          fontFamily: FigmaTokens.fontFamilyUiSans,
                          fontSize: 12.5,
                          height: 1.5,
                          color: figma.textBody,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// IMPACT BAND
// ─────────────────────────────────────────────────────────────────────────────
class _ImpactBand extends StatelessWidget {
  const _ImpactBand();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: FigmaTokens.darkBandGradient,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 800;
          final stats = [
            ('1.2B+', 'Muslims worldwide'),
            ('114', 'Surahs in the Mushaf'),
            ('99', 'Names of Allah'),
            ('6', 'Authentic hadith books'),
          ];
          final row = Row(
            children: [
              for (var i = 0; i < stats.length; i++) ...[
                if (i > 0) const SizedBox(width: 20),
                Expanded(
                  child: _ImpactStat(value: stats[i].$1, label: stats[i].$2)
                      .animate(delay: Duration(milliseconds: i * 80))
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1),
                ),
              ],
            ],
          );
          return isWide
              ? row
              : Column(
                  children: [
                    for (var i = 0; i < stats.length; i++) ...[
                      if (i > 0) const SizedBox(height: 18),
                      _ImpactStat(value: stats[i].$1, label: stats[i].$2)
                          .animate(delay: Duration(milliseconds: i * 80))
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.1),
                    ],
                  ],
                );
        },
      ),
    );
  }
}

class _ImpactStat extends StatelessWidget {
  final String value;
  final String label;
  const _ImpactStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: FigmaTokens.fontFamilyDisplaySerif,
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: figma.accentGoldLight,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: FigmaTokens.fontFamilyUiSans,
            fontSize: 13,
            color: FigmaTokens.textOnDark,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CONTACT
// ─────────────────────────────────────────────────────────────────────────────
class _ContactSection extends StatefulWidget {
  const _ContactSection();

  @override
  State<_ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<_ContactSection> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _subject = TextEditingController();
  final _message = TextEditingController();
  bool _sending = false;
  bool _sent = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _sending = true;
    });
    // The form is intentionally non-navigation: we simulate submission for
    // now. Real delivery will land in the ask_iman_admin repo inbox.
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _sending = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const WebSectionHeader(
          eyebrow: 'Get in touch',
          title: 'Reach Out to Us',
          subtitle:
              'Questions, feedback or partnership — we would love to hear '
              'from you. We typically reply within 24 hours.',
        ),
        const SizedBox(height: 24),
        Container(
          key: const Key('about_contact'),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: figma.surfaceCard,
            borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
            border: Border.all(color: figma.borderHairline),
            boxShadow: figma.cardShadows,
          ),
          child: Form(
            key: _formKey,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 720;
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _ContactField(
                            controller: _name,
                            label: 'Your Name',
                            icon: Icons.person_outline_rounded,
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Name required' : null,
                          ),
                        ),
                        if (wide) const SizedBox(width: 16),
                        if (wide)
                          Expanded(
                            child: _ContactField(
                              controller: _email,
                              label: 'Email Address',
                              icon: Icons.email_outlined,
                              validator: (v) =>
                                  (v == null || !v.contains('@')) ? 'Valid email required' : null,
                            ),
                          ),
                      ],
                    ),
                    if (!wide) ...[
                      const SizedBox(height: 16),
                      _ContactField(
                        controller: _email,
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        validator: (v) =>
                            (v == null || !v.contains('@')) ? 'Valid email required' : null,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _ContactField(
                      controller: _subject,
                      label: 'Subject',
                      icon: Icons.subject_rounded,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Subject required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _message,
                      maxLines: 5,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Message required' : null,
                      decoration: InputDecoration(
                        hintText: 'How can we help?',
                        hintStyle: TextStyle(
                          fontFamily: FigmaTokens.fontFamilyUiSans,
                          fontSize: 14,
                          color: figma.textMuted,
                        ),
                        filled: true,
                        fillColor: figma.surfaceBackground,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              BorderSide(color: figma.borderHairline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: figma.accentGoldAmber,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyUiSans,
                        fontSize: 14.5,
                        color: figma.textHeading,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _sent
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    color: FigmaTokens.brandMidGreen),
                                SizedBox(width: 8),
                                Text(
                                  'Message sent! We will get back to you soon.',
                                  style: TextStyle(
                                    fontFamily: FigmaTokens.fontFamilyUiSans,
                                    fontSize: 13,
                                    color: FigmaTokens.brandMidGreen,
                                  ),
                                ),
                              ],
                            )
                          : WebButton(
                              label: 'Send Message',
                              icon: Icons.send_rounded,
                              loading: _sending,
                              onPressed: _submit,
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?) validator;
  const _ContactField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final figma = context.figma;
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: FigmaTokens.fontFamilyUiSans,
          fontSize: 13,
          color: figma.textMuted,
        ),
        prefixIcon: Icon(icon, size: 20, color: figma.textMuted),
        filled: true,
        fillColor: figma.surfaceBackground,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: figma.borderHairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: figma.accentGoldAmber),
        ),
      ),
      style: TextStyle(
        fontFamily: FigmaTokens.fontFamilyUiSans,
        fontSize: 14.5,
        color: figma.textHeading,
      ),
    );
  }
}
