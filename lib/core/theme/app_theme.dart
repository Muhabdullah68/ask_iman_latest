import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'figma_tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData getTheme(Locale locale, Brightness brightness) {
    String fontFamily = 'Cairo';
    if (locale.languageCode == 'ur') {
      fontFamily = 'Jameel';
    }

    final isDark = brightness == Brightness.dark;
    final figmaTokens = isDark ? FigmaDesignTokens.dark() : FigmaDesignTokens.light();

    // Figma tokens take priority for web-facing surfaces.
    // For backwards compat, we keep AppColors for screens that haven't been migrated yet.
    final scaffoldBg = isDark
        ? FigmaTokens.darkBg
        : FigmaTokens.surfaceBackground;
    final cardBg = isDark ? FigmaTokens.darkCard : FigmaTokens.surfaceCard;
    final textPrimary = isDark
        ? FigmaTokens.darkTextPrimary
        : FigmaTokens.textHeading;
    final textSecondary = isDark
        ? FigmaTokens.darkTextSecondary
        : FigmaTokens.textBody;
    final textMuted = isDark ? FigmaTokens.darkTextMuted : FigmaTokens.textMuted;
    final borderColor = isDark
        ? FigmaTokens.borderDark
        : FigmaTokens.borderHairline;
    final inputFill = isDark ? FigmaTokens.darkSurface : FigmaTokens.surfaceCard;

    // ── Figma-tokenized primaries (EXACT match to changes.txt §token table) ──
    // brandDeepGreen (#0F3D2E) is the primary button / app-bar / heading color.
    // accentGoldAmber (#C9962C) is the SECONDARY accent — chips, left-edge bars,
    // checkmarks, hover outlines, progress indicators. NEVER for primary fill.
    final primary = FigmaTokens.brandDeepGreen;
    final primaryHover = isDark ? FigmaTokens.brandMidGreen : FigmaTokens.brandMidGreen;
    final accentGold = FigmaTokens.accentGoldAmber;
    final onPrimary = FigmaTokens.textOnDark;
    final appBarBg = FigmaTokens.brandDeepGreen;
    final appBarFg = FigmaTokens.textOnDark;
    final hintColor = textMuted;

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBg,
      primaryColor: primary,

      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: onPrimary,
        secondary: accentGold,
        onSecondary: FigmaTokens.brandDeepGreen,
        surface: cardBg,
        onSurface: textPrimary,
        error: FigmaTokens.error,
        onError: FigmaTokens.textOnDark,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: appBarBg,
        foregroundColor: appBarFg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: appBarFg,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      cardTheme: CardThemeData(
        color: cardBg,
        elevation: isDark ? 0 : FigmaTokens.elevationCard,
        shadowColor: isDark ? Colors.transparent : const Color(0x0F0F3D2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
          side: BorderSide(color: borderColor, width: isDark ? 0.5 : 0),
        ),
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        // Figma: PRIMARY buttons = brandDeepGreen (#0F3D2E) filled.
        // Gold is NEVER used as a button BG — only chip / highlight / outline.
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          disabledBackgroundColor: primaryHover.withValues(alpha: 0.5),
          disabledForegroundColor: onPrimary.withValues(alpha: 0.6),
          elevation: FigmaTokens.elevationButton,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          // Figma: 14px pill/large-rect — NEVER sharp
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FigmaTokens.radiusButton),
          ),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        // Figma: Text links use brandMidGreen to stand out against mint surface.
        style: TextButton.styleFrom(
          foregroundColor: FigmaTokens.brandMidGreen,
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        // Figma: Outline buttons = hairline gold border + deep-green text.
        // Used for "Verify a Donation" / "Our Vision" secondary CTAs.
        style: OutlinedButton.styleFrom(
          foregroundColor: FigmaTokens.brandDeepGreen,
          side: BorderSide(color: accentGold, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FigmaTokens.radiusButton),
          ),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          // Figma: 14px input radius, hairline borderHairline
          borderRadius: BorderRadius.circular(FigmaTokens.radiusInput),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FigmaTokens.radiusInput),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          // Figma: focus = gold amber 1.5px accent
          borderRadius: BorderRadius.circular(FigmaTokens.radiusInput),
          borderSide: BorderSide(color: accentGold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FigmaTokens.radiusInput),
          borderSide: BorderSide(color: FigmaTokens.error, width: 1),
        ),
        hintStyle: TextStyle(
          fontFamily: fontFamily,
          color: hintColor,
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          color: textSecondary,
          fontSize: 14,
        ),
      ),

      dividerTheme: DividerThemeData(
        // Figma: borderHairline (#E3ECE6 light / #2A4A35 dark) — 1px, hairline only
        color: borderColor,
        thickness: 1,
        space: 1,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? accentGold
              : (isDark ? FigmaTokens.darkTextMuted : FigmaTokens.textMuted),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? accentGold.withValues(alpha: 0.3)
              : borderColor,
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          // Figma: checked fill = deep green (primary), checkmark = white
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(FigmaTokens.textOnDark),
        side: BorderSide(color: accentGold, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? FigmaTokens.brandDeepGreen : FigmaTokens.surfaceCard,
        selectedItemColor: accentGold,   // Figma: gold is active-nav accent
        unselectedItemColor: textSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500, fontSize: 11),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        // Figma: progress bars use sage gradient. Single-color theme uses the start token.
        color: FigmaTokens.brandAccentSageStart,
        linearTrackColor: borderColor,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        ),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: primary,      // Figma: deep-green toasts on all surfaces
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: FigmaTokens.textOnDark,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FigmaTokens.radiusButton),
        ),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: accentGold,        // Figma: selected-tab text = gold amber
        unselectedLabelColor: textSecondary,
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        // Figma: active-nav underline = brandMidGreen (nav hover rule).
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: FigmaTokens.brandMidGreen, width: 2),
        ),
        dividerColor: Colors.transparent,
      ),

      textTheme: TextTheme(
        displayLarge: TextStyle(fontFamily: fontFamily, color: textPrimary, fontWeight: FontWeight.w700),
        displayMedium: TextStyle(fontFamily: fontFamily, color: textPrimary, fontWeight: FontWeight.w700),
        displaySmall: TextStyle(fontFamily: fontFamily, color: textPrimary, fontWeight: FontWeight.w700),
        headlineLarge: TextStyle(fontFamily: fontFamily, color: textPrimary, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(fontFamily: fontFamily, color: textPrimary, fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(fontFamily: fontFamily, color: textPrimary, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontFamily: fontFamily, color: textPrimary, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontFamily: fontFamily, color: textPrimary, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontFamily: fontFamily, color: textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontFamily: fontFamily, color: textPrimary, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(fontFamily: fontFamily, color: textPrimary, fontWeight: FontWeight.w500, fontSize: 14),
        bodySmall: TextStyle(fontFamily: fontFamily, color: textSecondary, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(fontFamily: fontFamily, color: textPrimary, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(fontFamily: fontFamily, color: textSecondary, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(fontFamily: fontFamily, color: textMuted, fontWeight: FontWeight.w500),
      ),
      extensions: [figmaTokens],
    );
  }

  static ThemeData getLightTheme(Locale locale) => getTheme(locale, Brightness.light);
  static ThemeData getDarkTheme(Locale locale) => getTheme(locale, Brightness.dark);
}
