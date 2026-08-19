// lib/web/widgets/web_widgets.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — Reusable page primitives
//
// Small building blocks shared across the website pages: mint page background,
// section headers with eyebrow chips, feature tiles, pill stats, primary /
// outline buttons, hover-lift cards and a scroll-to-top CTA.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../core/theme/figma_tokens.dart';

// ── Mint page background ──────────────────────────────────────────────────
class WebPageScaffold extends StatelessWidget {
  final Widget child;
  final Widget? top;
  final double maxWidth;

  const WebPageScaffold({
    super.key,
    required this.child,
    this.top,
    this.maxWidth = 1200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            ?top,
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────
class WebSectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const WebSectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: FigmaTokens.accentGoldSurface,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            eyebrow.toUpperCase(),
            style: const TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
              color: FigmaTokens.accentGoldAmber,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  color: FigmaTokens.textHeading,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(width: 16),
              InkWell(
                onTap: onAction,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        actionLabel!,
                        style: const TextStyle(
                          fontFamily: FigmaTokens.fontFamilyUiSans,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: FigmaTokens.accentGoldAmber,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: FigmaTokens.accentGoldAmber,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: const TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 14.5,
              height: 1.55,
              color: FigmaTokens.textBody,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Feature tile (white card + mint circular icon) ────────────────────────
class WebFeatureTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  const WebFeatureTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return HoverLift(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: FigmaTokens.surfaceCard,
          borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
          border: Border.all(color: FigmaTokens.borderHairline),
          boxShadow: FigmaTokens.cardShadowSm,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: (iconColor ?? FigmaTokens.surfacePanelMint),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: FigmaTokens.brandDeepGreen,
                size: 26,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: FigmaTokens.textHeading,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: FigmaTokens.fontFamilyUiSans,
                  fontSize: 11.5,
                  color: FigmaTokens.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Primary / outline buttons ─────────────────────────────────────────────
class WebButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outlined;
  final bool fullWidth;
  final bool loading;

  const WebButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.outlined = false,
    this.fullWidth = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: FigmaTokens.brandDeepGreen,
          foregroundColor: FigmaTokens.textOnDark,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FigmaTokens.radiusButton),
          ),
        ),
        child: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: FigmaTokens.textOnDark,
          ),
        ),
      );
    }

    final child = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: fullWidth
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 17),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: const TextStyle(
            fontFamily: FigmaTokens.fontFamilyUiSans,
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );

    if (outlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: FigmaTokens.brandDeepGreen,
          side: const BorderSide(color: FigmaTokens.brandMidGreen, width: 1.4),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FigmaTokens.radiusButton),
          ),
        ),
        child: child,
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: FigmaTokens.brandDeepGreen,
        foregroundColor: FigmaTokens.textOnDark,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FigmaTokens.radiusButton),
        ),
      ),
      child: child,
    );
  }
}

// ── Pill stat ─────────────────────────────────────────────────────────────
class WebStatPill extends StatelessWidget {
  final String value;
  final String label;

  const WebStatPill({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: FigmaTokens.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: FigmaTokens.cardShadowSm,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: FigmaTokens.fontFamilyDisplaySerif,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: FigmaTokens.brandDeepGreen,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: FigmaTokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hover lift (desktop pointer only) ─────────────────────────────────────
class HoverLift extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double lift;

  const HoverLift({
    super.key,
    required this.child,
    this.onTap,
    this.lift = 1.02,
  });

  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? widget.lift : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// ── Dark section band ─────────────────────────────────────────────────────
class WebDarkBand extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const WebDarkBand({super.key, required this.child, this.maxWidth = 1200});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: FigmaTokens.darkBandGradient,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: child,
          ),
        ),
      ),
    );
  }
}
