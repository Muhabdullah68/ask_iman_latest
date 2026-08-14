import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../theme/figma_tokens.dart';

/// Responsive breakpoint helpers — consistent with Figma design system.
///
/// Breakpoints:
///  - Mobile:  < 768  (original Flutter app single-column design — untouched)
///  - Tablet:  768–1199 (2-column layouts, chips above content)
///  - Desktop: ≥ 1200 (3-column + sidebar rails, flagship layouts)
class AppResponsive {
  AppResponsive._();

  static const double mobileMax = FigmaTokens.breakpointMobileMax;
  static const double tabletMax = FigmaTokens.breakpointTabletMax;
  static const double desktopMin = FigmaTokens.breakpointDesktopMin;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileMax;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= mobileMax && w <= tabletMax;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopMin;

  /// Returns the right widget variant for current width:
  ///  - desktop or web on large screen → desktop
  ///  - tablet range → tablet
  ///  - else → mobile (default, original app layout)
  static T pick<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }

  /// Preferred horizontal padding around page content
  static double pagePadding(BuildContext context) =>
      isDesktop(context) ? 48 : (isTablet(context) ? 32 : 16);

  /// Max content width to prevent UI stretching on FHD/4K screens
  static const double maxContentWidth = 1400;

  /// Cross-axis count for grids, responsive to breakpoint.
  /// [mobileCount] must be provided, the rest are optional fallbacks.
  static int crossAxisCount(
    BuildContext context, {
    required int mobileCount,
    int? tabletCount,
    int? desktopCount,
  }) {
    if (isDesktop(context) && desktopCount != null) return desktopCount;
    if (isTablet(context) && tabletCount != null) return tabletCount;
    return mobileCount;
  }
}

// ────────────────────────────────────────────────────────────────
// BuildContext convenience extensions
// ────────────────────────────────────────────────────────────────
extension ResponsiveContext on BuildContext {
  bool get isMobileScreen => AppResponsive.isMobile(this);
  bool get isTabletScreen => AppResponsive.isTablet(this);
  bool get isDesktopScreen => AppResponsive.isDesktop(this);

  /// True if running on Flutter Web (any width)
  bool get isWebPlatform => kIsWeb;

  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  double get pagePadding => AppResponsive.pagePadding(this);

  T responsivePick<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) =>
      AppResponsive.pick(
        this,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );
}

// ────────────────────────────────────────────────────────────────
// Responsive Builder — composes layouts by breakpoint.
//
// Example:
//   ResponsiveBuilder(
//     mobile: (ctx) => Column(children: tiles),
//     tablet: (ctx) => GridView.count(crossAxisCount: 2, children: tiles),
//     desktop: (ctx) => Row(children: tiles),
//   )
// ────────────────────────────────────────────────────────────────
class ResponsiveBuilder extends StatelessWidget {
  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (AppResponsive.isDesktop(context) && desktop != null) {
      return desktop!(context);
    }
    if (AppResponsive.isTablet(context) && tablet != null) {
      return tablet!(context);
    }
    return mobile(context);
  }
}

// ────────────────────────────────────────────────────────────────
// Content width limiter — prevents content from stretching on 4K.
// Wraps child with a Center + ConstrainedBox at 1400px max width.
// ────────────────────────────────────────────────────────────────
class PageContentWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const PageContentWidth({
    super.key,
    required this.child,
    this.maxWidth = AppResponsive.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
