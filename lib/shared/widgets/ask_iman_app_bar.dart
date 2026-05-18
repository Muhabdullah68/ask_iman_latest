import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AskImanAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AskImanAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryDark,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
      ),
      height: preferredSize.height + MediaQuery.of(context).padding.top,
      child: Row(
        children: [
          // Logo
          Row(
            children: [
              const Text('☽ ', style: TextStyle(color: AppColors.gold, fontSize: 20)),
              const Text(
                'ASK IMAN',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.gold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Streak badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryMid,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Text(
                  '7 DAY STREAK ',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textWhite,
                  ),
                ),
                Text('🔥', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryMid,
            child: ClipOval(
              child: Container(
                width: 36,
                height: 36,
                color: AppColors.primaryLight,
                child: const Icon(Icons.person, color: AppColors.textCream, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}