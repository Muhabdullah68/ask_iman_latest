// lib/features/quran/widgets/hadith_card.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Reusable dark-green hadith card widget.
/// Used by AhadeesTab to render each hadith entry.
class HadithCard extends StatelessWidget {
  final Map<String, String> hadith;

  const HadithCard({super.key, required this.hadith});

  @override
  Widget build(BuildContext context) {
    final isSahih = hadith['grade'] == 'SAHIH';
    final book = hadith['book'] ?? 'Unknown Source';
    final grade = hadith['grade'] ?? 'Unrated';
    final text = hadith['text'] ?? 'No text available';
    final narrator = hadith['narrator'] ?? 'Unknown Narrator';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source + grade + actions
          Row(
            children: [
              Text(
                book,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isSahih
                      ? AppColors.success.withValues(alpha: 0.2)
                      : AppColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  grade,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSahih ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.share_outlined,
                  size: 16, color: AppColors.textGreenMuted),
              const SizedBox(width: 12),
              const Icon(Icons.bookmark_outline,
                  size: 16, color: AppColors.textGreenMuted),
            ],
          ),
          const SizedBox(height: 14),
          // Text
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              color: AppColors.textWhite,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          Container(
              height: 1, color: AppColors.primaryMid.withValues(alpha: 0.6)),
          const SizedBox(height: 10),
          // Narrator
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person,
                    size: 12, color: AppColors.gold),
              ),
              const SizedBox(width: 8),
              Text(
                narrator,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: AppColors.textGreenMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
