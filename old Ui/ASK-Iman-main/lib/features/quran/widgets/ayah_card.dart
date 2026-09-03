// lib/features/quran/widgets/ayah_card.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Reusable white ayah card widget.
/// Displays a single ayah with its reference, Arabic text, and translation.
class AyahCard extends StatelessWidget {
  final String ref;
  final String arabic;
  final String translation;
  final bool showArabic;
  final bool showTranslation;

  const AyahCard({
    super.key,
    required this.ref,
    required this.arabic,
    required this.translation,
    this.showArabic = true,
    this.showTranslation = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Reference + actions
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ref,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.goldDark,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.bookmark_outline,
                  size: 18,
                  color: AppColors.textGrey,
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.share_outlined,
                  size: 18,
                  color: AppColors.textGrey,
                ),
              ],
            ),
          ),
          // Arabic
          if (showArabic)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
              child: Text(
                arabic,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 26,
                  color: AppColors.textDark,
                  height: 2.0,
                ),
              ),
            ),
          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(height: 1, color: AppColors.borderLight),
          ),
          // Translation
          if (showTranslation)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
              child: Text(
                translation,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: AppColors.textGrey,
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
