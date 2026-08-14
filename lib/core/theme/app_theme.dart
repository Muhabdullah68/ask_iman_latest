import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData getTheme(Locale locale, Brightness brightness) {
    String fontFamily = 'Cairo';
    if (locale.languageCode == 'ur') {
      fontFamily = 'Jameel';
    }

    final isDark = brightness == Brightness.dark;

    final scaffoldBg = isDark ? AppColors.darkBg : AppColors.lightBgCream;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextDark;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextGrey;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextLightGrey;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final inputFill = isDark ? AppColors.darkBgSurface : AppColors.lightBgWhite;
    final primary = isDark ? AppColors.primaryLight : AppColors.primaryDark;
    final onPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textWhite;
    final appBarBg = isDark ? AppColors.primaryDarkest : AppColors.primaryDark;
    final appBarFg = AppColors.textWhite;
    final hintColor = isDark ? AppColors.darkTextMuted : AppColors.lightTextGreenMuted;

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
        secondary: AppColors.gold,
        onSecondary: AppColors.primaryDarkest,
        surface: cardBg,
        onSurface: textPrimary,
        error: AppColors.error,
        onError: AppColors.textWhite,
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
        elevation: isDark ? 0 : 2,
        shadowColor: isDark ? Colors.transparent : Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: isDark ? 0.5 : 0),
        ),
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.primaryDarkest,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.gold,
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: AppColors.gold, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
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
        color: borderColor,
        thickness: 1,
        space: 1,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.gold
              : (isDark ? AppColors.darkTextMuted : AppColors.textLightGrey),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.gold.withValues(alpha: 0.3)
              : borderColor,
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.gold;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.primaryDarkest),
        side: BorderSide(color: AppColors.gold, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.primaryDarkest : AppColors.bgWhite,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: textSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500, fontSize: 11),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.gold,
        linearTrackColor: borderColor,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.primaryDarkest : AppColors.primaryDark,
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textWhite,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.gold,
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
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.gold, width: 2),
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
    );
  }

  static ThemeData getLightTheme(Locale locale) => getTheme(locale, Brightness.light);
  static ThemeData getDarkTheme(Locale locale) => getTheme(locale, Brightness.dark);
}
