import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Display ─────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: AppColors.textWhite,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
    height: 1.3,
  );

  // ── Headlines ───────────────────────────────────
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    height: 1.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    height: 1.4,
  );

  // ── Titles ──────────────────────────────────────
  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    height: 1.4,
  );

  // ── Body ────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textGrey,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textLightGrey,
    height: 1.4,
  );

  // ── Labels ──────────────────────────────────────
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textLightGrey,
    letterSpacing: 0.3,
  );

  // ── On Dark ─────────────────────────────────────
  static const TextStyle onDarkHeadline = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
    height: 1.3,
  );

  static const TextStyle onDarkBody = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textCream,
    height: 1.5,
  );

  static const TextStyle onDarkMuted = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textGreenMuted,
    height: 1.5,
  );

  // ── Gold ────────────────────────────────────────
  static const TextStyle goldTitle = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.gold,
  );

  static const TextStyle goldLabel = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.gold,
    letterSpacing: 0.3,
  );

  static const TextStyle goldSmall = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.gold,
  );

  // ── Arabic (Amiri) ───────────────────────────────
  static const TextStyle arabicLarge = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 30,
    fontWeight: FontWeight.w400,
    color: AppColors.textWhite,
    height: 2.2,
  );

  static const TextStyle arabicMedium = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.textWhite,
    height: 2.0,
  );

  static const TextStyle arabicSmall = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textWhite,
    height: 1.9,
  );

  // ── App Bar ─────────────────────────────────────
  static const TextStyle appBarTitle = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.gold,
    letterSpacing: 0.5,
  );

  // ── Bottom Nav ───────────────────────────────────
  static const TextStyle navLabelActive = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.gold,
  );

  static const TextStyle navLabelInactive = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textGreenMuted,
  );
}