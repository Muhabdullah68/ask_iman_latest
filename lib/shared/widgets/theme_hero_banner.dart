// lib/shared/widgets/theme_hero_banner.dart
// ─────────────────────────────────────────────────────────────────────────────
// THEME HERO BANNER
//
// A large banner that COMPLETELY changes colour between light and dark mode —
// instant visual proof that the theme toggle worked.
//   • Light:  gold surface (#FAEEDA) with green decorative border
//   • Dark:   deep green gradient (#0D2818 → #1B4332) with gold text accents
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ThemeHeroBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String arabic;
  final double height;

  const ThemeHeroBanner({
    super.key,
    this.title = 'Your Divine Companion',
    this.subtitle = 'Quran, prayer times, tasbeeh and community for your spiritual journey',
    this.arabic = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      height: height,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF0D2818),
                  Color(0xFF1B4332),
                  Color(0xFF2D5A3D),
                ]
              : const [
                  Color(0xFFFFF8EC),
                  Color(0xFFFAEEDA),
                  Color(0xFFF3E2C2),
                ],
        ),
        border: Border.all(
          color: isDark ? AppColors.gold.withValues(alpha: 0.35) : AppColors.primaryMid,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.primaryDark)
                .withValues(alpha: isDark ? 0.35 : 0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 180,
              color: isDark
                  ? AppColors.gold.withValues(alpha: 0.12)
                  : AppColors.primaryDark.withValues(alpha: 0.07),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -50,
            child: Icon(
              Icons.star_rounded,
              size: 140,
              color: isDark
                  ? AppColors.gold.withValues(alpha: 0.10)
                  : AppColors.primaryDark.withValues(alpha: 0.06),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    arabic,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 34,
                      height: 1.6,
                      color: isDark ? AppColors.goldLight : AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textCream : AppColors.primaryDarkest,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      height: 1.4,
                      color: isDark ? const Color(0xFFB6C5B7) : AppColors.primaryMid,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
