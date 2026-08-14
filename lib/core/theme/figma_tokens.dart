import 'package:flutter/material.dart';

class FigmaTokens {
  FigmaTokens._();

  // ─────────────────────────────────────────────────────────────
  // CORE 13 COLOR TOKENS — pixel-extracted from the 5 Figma screens
  // These values take PRIORITY over legacy AppColors on web.
  // ─────────────────────────────────────────────────────────────

  // Brand Greens
  static const Color brandDeepGreen = Color(0xFF0F3D2E);
  static const Color brandMidGreen = Color(0xFF134832);
  static const Color brandAccentSageStart = Color(0xFF1B5E42);
  static const Color brandAccentSageEnd = Color(0xFF2F7A54);

  // Surfaces
  static const Color surfaceBackground = Color(0xFFF2F7F3);
  static const Color surfaceBackgroundAlt = Color(0xFFEAF3EC);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfacePanelMint = Color(0xFFE9F3EC);

  // Golds
  static const Color accentGoldAmber = Color(0xFFC9962C);
  static const Color accentGoldLight = Color(0xFFE8D28A);
  static const Color accentGoldSurface = Color(0xFFFAEEDA);

  // Text
  static const Color textHeading = Color(0xFF12251C);
  static const Color textBody = Color(0xFF5B6B62);
  static const Color textMuted = Color(0xFF8A9A90);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textCreamLight = Color(0xFFF5F0E8);

  // Borders / Dividers
  static const Color borderHairline = Color(0xFFE3ECE6);
  static const Color borderDark = Color(0xFF2A4A35);

  // Dark mode surfaces
  static const Color darkBg = Color(0xFF0B1C12);
  static const Color darkCard = Color(0xFF183024);
  static const Color darkSurface = Color(0xFF122A1B);
  static const Color darkTextPrimary = Color(0xFFF5F0E8);
  static const Color darkTextSecondary = Color(0xFFB6C5B7);
  static const Color darkTextMuted = Color(0xFF8CA08D);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Linear Gradient tokens
  static const LinearGradient heroGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surfacePanelMint, surfaceBackgroundAlt],
  );

  static const LinearGradient heroGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D2818), Color(0xFF1B4332)],
  );

  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [brandMidGreen, brandDeepGreen],
  );

  static const LinearGradient progressGradient = LinearGradient(
    colors: [brandAccentSageStart, brandAccentSageEnd],
  );

  static const LinearGradient darkBandGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [brandDeepGreen, Color(0xFF0A2A1E)],
  );

  // ─────────────────────────────────────────────────────────────
  // TYPOGRAPHY TOKENS — Figma font stacks
  // ─────────────────────────────────────────────────────────────

  // Display / Hero headings — Brand Cairo (matches high-end typography preference)
  // Figma intended: Lora/Fraunces (serif) — Cairo ExtraBold provides the same
  // visual weight with consistent brand identity per user's Cairo branding rule.
  static const String fontFamilyDisplaySerif = 'Cairo';
  // UI / Body / Nav / Buttons — Brand Cairo (user's preferred UI font)
  // Figma intended: Inter (sans) — Cairo covers all UI weights 200–900 perfectly.
  static const String fontFamilyUiSans = 'Cairo';
  // Arabic Headings / Dua — Quranic Serif (Naskh style, Figma: Amiri/Scheherazade)
  static const String fontFamilyArabicSerif = 'Amiri';
  // Arabic Mushaf (Uthmani script, Figma: Amiri Quran / KFGQPC Uthman Taha)
  // Resolves to KfgqpcHafs UthmanicScript — the authentic Uthmani Taha variant
  // that exactly matches Figma's diacritic-heavy Mushaf layout.
  static const String fontFamilyArabicMushaf = 'KfgqpcHafs';

  // ─────────────────────────────────────────────────────────────
  // SHAPE / RADIUS / SHADOW TOKENS — Figma shape language
  // ─────────────────────────────────────────────────────────────

  static const double radiusCard = 20;
  static const double radiusCardSm = 16;
  static const double radiusButton = 14;
  static const double radiusPill = 999;
  static const double radiusInput = 14;

  // Soft card shadow (matches Figma subtle mint shadows)
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0F0F3D2E),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> cardShadowSm = [
    BoxShadow(
      color: Color(0x0A0F3D2E),
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  // Elevation values (Material)
  static const double elevationCard = 2;
  static const double elevationButton = 0;

  // Spacing scale (8pt grid)
  static const double spacing1 = 4;
  static const double spacing2 = 8;
  static const double spacing3 = 12;
  static const double spacing4 = 16;
  static const double spacing5 = 20;
  static const double spacing6 = 24;
  static const double spacing8 = 32;
  static const double spacing10 = 40;
  static const double spacing12 = 48;
  static const double spacing16 = 64;

  // ─────────────────────────────────────────────────────────────
  // Left-edge gold accent bar width (on feature cards)
  // Seen in Figma: About Us features, Community campaign cards
  // ─────────────────────────────────────────────────────────────
  static const double accentBarWidth = 4;

  // Responsive breakpoints
  static const double breakpointMobileMax = 767;
  static const double breakpointTabletMax = 1199;
  static const double breakpointDesktopMin = 1200;
}

// ────────────────────────────────────────────────────────────────
// ThemeExtension — access via `Theme.of(context).extension<FigmaDesignTokens>()!`
// ────────────────────────────────────────────────────────────────
class FigmaDesignTokens extends ThemeExtension<FigmaDesignTokens> {
  // Colors
  final Color brandDeepGreen;
  final Color brandMidGreen;
  final Color surfaceBackground;
  final Color surfacePanelMint;
  final Color surfaceCard;
  final Color accentGoldAmber;
  final Color accentGoldLight;
  final Color accentGoldSurface;
  final Color textHeading;
  final Color textBody;
  final Color textMuted;
  final Color borderHairline;
  final Color darkBg;
  final Color darkCard;
  final Color darkTextPrimary;
  final Color darkTextSecondary;

  // Gradients
  final LinearGradient heroGradient;
  final LinearGradient primaryButtonGradient;
  final LinearGradient progressGradient;

  // Shapes
  final double cardRadius;
  final double buttonRadius;
  final double pillRadius;
  final List<BoxShadow> cardShadows;

  // Spacing
  final double spacingSm;
  final double spacingMd;
  final double spacingLg;

  const FigmaDesignTokens({
    required this.brandDeepGreen,
    required this.brandMidGreen,
    required this.surfaceBackground,
    required this.surfacePanelMint,
    required this.surfaceCard,
    required this.accentGoldAmber,
    required this.accentGoldLight,
    required this.accentGoldSurface,
    required this.textHeading,
    required this.textBody,
    required this.textMuted,
    required this.borderHairline,
    required this.darkBg,
    required this.darkCard,
    required this.darkTextPrimary,
    required this.darkTextSecondary,
    required this.heroGradient,
    required this.primaryButtonGradient,
    required this.progressGradient,
    required this.cardRadius,
    required this.buttonRadius,
    required this.pillRadius,
    required this.cardShadows,
    required this.spacingSm,
    required this.spacingMd,
    required this.spacingLg,
  });

  factory FigmaDesignTokens.light() => FigmaDesignTokens(
    brandDeepGreen: FigmaTokens.brandDeepGreen,
    brandMidGreen: FigmaTokens.brandMidGreen,
    surfaceBackground: FigmaTokens.surfaceBackground,
    surfacePanelMint: FigmaTokens.surfacePanelMint,
    surfaceCard: FigmaTokens.surfaceCard,
    accentGoldAmber: FigmaTokens.accentGoldAmber,
    accentGoldLight: FigmaTokens.accentGoldLight,
    accentGoldSurface: FigmaTokens.accentGoldSurface,
    textHeading: FigmaTokens.textHeading,
    textBody: FigmaTokens.textBody,
    textMuted: FigmaTokens.textMuted,
    borderHairline: FigmaTokens.borderHairline,
    darkBg: FigmaTokens.darkBg,
    darkCard: FigmaTokens.darkCard,
    darkTextPrimary: FigmaTokens.darkTextPrimary,
    darkTextSecondary: FigmaTokens.darkTextSecondary,
    heroGradient: FigmaTokens.heroGradientLight,
    primaryButtonGradient: FigmaTokens.primaryButtonGradient,
    progressGradient: FigmaTokens.progressGradient,
    cardRadius: FigmaTokens.radiusCard,
    buttonRadius: FigmaTokens.radiusButton,
    pillRadius: FigmaTokens.radiusPill,
    cardShadows: FigmaTokens.cardShadow,
    spacingSm: FigmaTokens.spacing2,
    spacingMd: FigmaTokens.spacing4,
    spacingLg: FigmaTokens.spacing6,
  );

  factory FigmaDesignTokens.dark() => FigmaDesignTokens(
    brandDeepGreen: FigmaTokens.brandDeepGreen,
    brandMidGreen: FigmaTokens.brandMidGreen,
    surfaceBackground: FigmaTokens.darkBg,
    surfacePanelMint: FigmaTokens.brandDeepGreen,
    surfaceCard: FigmaTokens.darkCard,
    accentGoldAmber: FigmaTokens.accentGoldAmber,
    accentGoldLight: FigmaTokens.accentGoldLight,
    accentGoldSurface: FigmaTokens.accentGoldSurface,
    textHeading: FigmaTokens.darkTextPrimary,
    textBody: FigmaTokens.darkTextSecondary,
    textMuted: FigmaTokens.darkTextMuted,
    borderHairline: FigmaTokens.borderDark,
    darkBg: FigmaTokens.darkBg,
    darkCard: FigmaTokens.darkCard,
    darkTextPrimary: FigmaTokens.darkTextPrimary,
    darkTextSecondary: FigmaTokens.darkTextSecondary,
    heroGradient: FigmaTokens.heroGradientDark,
    primaryButtonGradient: FigmaTokens.primaryButtonGradient,
    progressGradient: FigmaTokens.progressGradient,
    cardRadius: FigmaTokens.radiusCard,
    buttonRadius: FigmaTokens.radiusButton,
    pillRadius: FigmaTokens.radiusPill,
    cardShadows: const [],
    spacingSm: FigmaTokens.spacing2,
    spacingMd: FigmaTokens.spacing4,
    spacingLg: FigmaTokens.spacing6,
  );

  @override
  ThemeExtension<FigmaDesignTokens> copyWith({
    Color? brandDeepGreen,
    Color? brandMidGreen,
    Color? surfaceBackground,
    Color? surfacePanelMint,
    Color? surfaceCard,
    Color? accentGoldAmber,
    Color? accentGoldLight,
    Color? accentGoldSurface,
    Color? textHeading,
    Color? textBody,
    Color? textMuted,
    Color? borderHairline,
    Color? darkBg,
    Color? darkCard,
    Color? darkTextPrimary,
    Color? darkTextSecondary,
    LinearGradient? heroGradient,
    LinearGradient? primaryButtonGradient,
    LinearGradient? progressGradient,
    double? cardRadius,
    double? buttonRadius,
    double? pillRadius,
    List<BoxShadow>? cardShadows,
    double? spacingSm,
    double? spacingMd,
    double? spacingLg,
  }) => FigmaDesignTokens(
    brandDeepGreen: brandDeepGreen ?? this.brandDeepGreen,
    brandMidGreen: brandMidGreen ?? this.brandMidGreen,
    surfaceBackground: surfaceBackground ?? this.surfaceBackground,
    surfacePanelMint: surfacePanelMint ?? this.surfacePanelMint,
    surfaceCard: surfaceCard ?? this.surfaceCard,
    accentGoldAmber: accentGoldAmber ?? this.accentGoldAmber,
    accentGoldLight: accentGoldLight ?? this.accentGoldLight,
    accentGoldSurface: accentGoldSurface ?? this.accentGoldSurface,
    textHeading: textHeading ?? this.textHeading,
    textBody: textBody ?? this.textBody,
    textMuted: textMuted ?? this.textMuted,
    borderHairline: borderHairline ?? this.borderHairline,
    darkBg: darkBg ?? this.darkBg,
    darkCard: darkCard ?? this.darkCard,
    darkTextPrimary: darkTextPrimary ?? this.darkTextPrimary,
    darkTextSecondary: darkTextSecondary ?? this.darkTextSecondary,
    heroGradient: heroGradient ?? this.heroGradient,
    primaryButtonGradient: primaryButtonGradient ?? this.primaryButtonGradient,
    progressGradient: progressGradient ?? this.progressGradient,
    cardRadius: cardRadius ?? this.cardRadius,
    buttonRadius: buttonRadius ?? this.buttonRadius,
    pillRadius: pillRadius ?? this.pillRadius,
    cardShadows: cardShadows ?? this.cardShadows,
    spacingSm: spacingSm ?? this.spacingSm,
    spacingMd: spacingMd ?? this.spacingMd,
    spacingLg: spacingLg ?? this.spacingLg,
  );

  @override
  ThemeExtension<FigmaDesignTokens> lerp(
    ThemeExtension<FigmaDesignTokens>? other,
    double t,
  ) {
    if (other is! FigmaDesignTokens) return this;
    return FigmaDesignTokens(
      brandDeepGreen: Color.lerp(brandDeepGreen, other.brandDeepGreen, t)!,
      brandMidGreen: Color.lerp(brandMidGreen, other.brandMidGreen, t)!,
      surfaceBackground: Color.lerp(surfaceBackground, other.surfaceBackground, t)!,
      surfacePanelMint: Color.lerp(surfacePanelMint, other.surfacePanelMint, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      accentGoldAmber: Color.lerp(accentGoldAmber, other.accentGoldAmber, t)!,
      accentGoldLight: Color.lerp(accentGoldLight, other.accentGoldLight, t)!,
      accentGoldSurface: Color.lerp(accentGoldSurface, other.accentGoldSurface, t)!,
      textHeading: Color.lerp(textHeading, other.textHeading, t)!,
      textBody: Color.lerp(textBody, other.textBody, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      borderHairline: Color.lerp(borderHairline, other.borderHairline, t)!,
      darkBg: Color.lerp(darkBg, other.darkBg, t)!,
      darkCard: Color.lerp(darkCard, other.darkCard, t)!,
      darkTextPrimary: Color.lerp(darkTextPrimary, other.darkTextPrimary, t)!,
      darkTextSecondary: Color.lerp(darkTextSecondary, other.darkTextSecondary, t)!,
      heroGradient: t < 0.5 ? heroGradient : other.heroGradient,
      primaryButtonGradient: t < 0.5 ? primaryButtonGradient : other.primaryButtonGradient,
      progressGradient: progressGradient,
      cardRadius: cardRadius,
      buttonRadius: buttonRadius,
      pillRadius: pillRadius,
      cardShadows: t < 0.5 ? cardShadows : other.cardShadows,
      spacingSm: spacingSm,
      spacingMd: spacingMd,
      spacingLg: spacingLg,
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Convenience BuildContext extension for Figma tokens
// ────────────────────────────────────────────────────────────────
extension FigmaContextExtension on BuildContext {
  FigmaDesignTokens get figma {
    final ext = Theme.of(this).extension<FigmaDesignTokens>();
    if (ext == null) {
      // Fallback to light theme tokens if extension missing
      return FigmaDesignTokens.light();
    }
    return ext;
  }

  bool get isFigmaDark => Theme.of(this).brightness == Brightness.dark;
}
