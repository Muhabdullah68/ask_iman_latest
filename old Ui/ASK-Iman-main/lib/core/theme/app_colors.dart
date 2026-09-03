import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary Greens ──────────────────────────────
  static const Color primaryDarkest = Color(0xFF0D2818);
  static const Color primaryDark = Color(0xFF1B4332);
  static const Color primaryMid = Color(0xFF2D5A3D);
  static const Color primaryLight = Color(0xFF3A7D55);
  static const Color primarySurface = Color(0xFF1F3A2A);

  // ── Gold Accent ─────────────────────────────────
  static const Color gold = Color(0xFFC9A84C);
  static const Color goldLight = Color(0xFFE2C46A);
  static const Color goldDark = Color(0xFFA07C30);
  static const Color goldSurface = Color(0xFFFAEEDA);

  // ── Backgrounds ─────────────────────────────────
  static const Color bgCream = Color(0xFFF5F0E8);
  static const Color bgWhite = Color(0xFFFFFFFF);
  static const Color bgDarkCard = Color(0xFF1F3A2A);
  static const Color bgDarkest = Color(0xFF0A1F12);
  // Quran screen specific - Using app consistent cream background
  static const Color quranBgLightGreen = Color(0xFFF5F0E8); // Matches bgCream
  static const Color quranCardBg = Color(0xFFFFFFFF); // White cards on cream bg

  // ── Text ────────────────────────────────────────
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textCream = Color(0xFFF5F0E8);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color textLightGrey = Color(0xFF9CA3AF);
  static const Color textGreenMuted = Color(0xFF6B9E7A);

  // ── Status ──────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color streakOrange = Color(0xFFFF6B35);

  // ── Borders ─────────────────────────────────────
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderGold = Color(0xFFC9A84C);
  static const Color borderGreen = Color(0xFF2D5A3D);
}
