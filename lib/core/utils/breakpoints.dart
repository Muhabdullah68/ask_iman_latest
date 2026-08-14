// lib/core/utils/breakpoints.dart
// ─────────────────────────────────────────────────────────────────────────────
// RESPONSIVE BREAKPOINTS UTILITY
//
// Three viewport tiers matching the design system:
//   • mobile  — < 768px        (original phone-first layout)
//   • tablet  — 768–1199px     (2-column where sensible)
//   • desktop — ≥ 1200px       (multi-column + sidebars)
//
// Usage:
//   final isDesktop = context.isDesktop;
//   ResponsiveBuilder(
//     mobile: (...) => ...,
//     tablet: (...) => ...,
//     desktop: (...) => ...,
//   );
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

enum ScreenType { mobile, tablet, desktop }

extension BuildContextScreen on BuildContext {
  /// Full logical screen width.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Full logical screen height.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  ScreenType get screenType {
    final w = screenWidth;
    if (w >= 1200) return ScreenType.desktop;
    if (w >= 768) return ScreenType.tablet;
    return ScreenType.mobile;
  }

  bool get isMobile => screenType == ScreenType.mobile;
  bool get isTablet => screenType == ScreenType.tablet;
  bool get isDesktop => screenType == ScreenType.desktop;
}

/// Builds the appropriate child layout for the current viewport.
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) mobile;
  final Widget Function(BuildContext context)? tablet;
  final Widget Function(BuildContext context)? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final type = context.screenType;
    if (type == ScreenType.desktop && desktop != null) {
      return desktop!(context);
    }
    if (type == ScreenType.tablet && tablet != null) {
      return tablet!(context);
    }
    return mobile(context);
  }
}

/// Constrains content to a comfortable reading width on wide screens,
/// centered on the viewport (max ~1200px).
class ContentContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double maxWidth;

  const ContentContainer({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.maxWidth = 1200,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
