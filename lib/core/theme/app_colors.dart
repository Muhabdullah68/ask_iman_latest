import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Shared Core Colors ──────────────────────────────
  static const Color primaryDarkest = Color(0xFF0D2818);
  static const Color primaryDark = Color(0xFF1B4332);
  static const Color primaryMid = Color(0xFF2D5A3D);
  static const Color primaryLight = Color(0xFF3A7D55);
  static const Color primarySurface = Color(0xFF1F3A2A);

  static const Color gold = Color(0xFFC9A84C);
  static const Color goldLight = Color(0xFFE2C46A);
  static const Color goldDark = Color(0xFFA07C30);
  static const Color goldSurface = Color(0xFFFAEEDA);

  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color streakOrange = Color(0xFFFF6B35);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textCream = Color(0xFFF5F0E8);
  static const Color borderGold = Color(0xFFC9A84C);
  static const Color borderGreen = Color(0xFF2D5A3D);

  // ── Light Theme Specific Colors ─────────────────────
  static const Color lightBgCream = Color(0xFFF5F0E8);
  static const Color lightBgWhite = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextDark = Color(0xFF1A1A1A);
  static const Color lightTextGrey = Color(0xFF6B7280);
  static const Color lightTextLightGrey = Color(0xFF9CA3AF);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightTextGreenMuted = Color(0xFF6B9E7A);

  // ── Dark Theme Specific Colors ──────────────────────
  static const Color darkBg = Color(0xFF0B1C12);
  static const Color darkBgSurface = Color(0xFF122A1B);
  static const Color darkCard = Color(0xFF183024);
  static const Color darkTextPrimary = Color(0xFFF5F0E8);
  static const Color darkTextSecondary = Color(0xFFB6C5B7);
  static const Color darkTextMuted = Color(0xFF8CA08D);
  static const Color darkBorder = Color(0xFF2A4A35);
  static const Color darkTextGreenMuted = Color(0xFF6B9E7A);

  // ── Legacy Aliases (for backwards compatibility with existing screens) ─────────
  static const Color bgCream = lightBgCream;
  static const Color bgWhite = lightBgWhite;
  static const Color bgDarkCard = primarySurface;
  static const Color bgDarkest = Color(0xFF0A1F12);
  static const Color quranBgLightGreen = lightBgCream;
  static const Color quranCardBg = lightBgWhite;
  static const Color textDark = lightTextDark;
  static const Color textGrey = lightTextGrey;
  static const Color textLightGrey = lightTextLightGrey;
  static const Color textGreenMuted = lightTextGreenMuted;
  static const Color borderLight = lightBorder;
}

// ── Theme Extension for Context-aware Colors ──────────────────────
extension ThemeColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get scaffoldBg => isDark ? AppColors.darkBg : AppColors.lightBgCream;
  Color get cardBg => isDark ? AppColors.darkCard : AppColors.lightCard;
  Color get surfaceBg => isDark ? AppColors.darkBgSurface : AppColors.lightBgWhite;

  Color get textPrimary => isDark ? AppColors.darkTextPrimary : AppColors.lightTextDark;
  Color get textSecondary => isDark ? AppColors.darkTextSecondary : AppColors.lightTextGrey;
  Color get textMuted => isDark ? AppColors.darkTextMuted : AppColors.lightTextLightGrey;
  Color get textGreenMuted => isDark ? AppColors.darkTextGreenMuted : AppColors.lightTextGreenMuted;

  Color get borderColor => isDark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get goldColor => AppColors.gold;
  Color get primaryColor => isDark ? AppColors.primaryLight : AppColors.primaryDark;
  Color get primaryDarkest => AppColors.primaryDarkest;
}
