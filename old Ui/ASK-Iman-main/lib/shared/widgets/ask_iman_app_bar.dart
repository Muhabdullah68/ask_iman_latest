import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/community_service.dart';

class AskImanAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final List<Widget>? actions;
  final String? title; // Added for dynamic titles
  final bool showLogo; // Added to toggle logo

  const AskImanAppBar({
    super.key,
    this.showBackButton = false,
    this.actions,
    this.title,
    this.showLogo = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final svc = CommunityService.instance;
    final auth = FirebaseAuth.instance;

    return Container(
      color: AppColors.primaryDark,
      padding: EdgeInsets.only(top: topPadding, left: 4, right: 8),
      height: preferredSize.height + topPadding,
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () => Navigator.maybePop(context),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            )
          else
            const SizedBox(width: 8),

          // Title / Logo Area
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showLogo) ...[
                  Image.asset(
                    'assets/images/applogo.png',
                    height: 28,
                    width: 28,
                    errorBuilder: (ctx, err, stack) => const Icon(
                      Icons.mosque,
                      color: AppColors.gold,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: title != null
                      ? Text(
                          title!,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gold,
                            letterSpacing: 0.5,
                          ),
                        )
                      : RichText(
                          overflow: TextOverflow.ellipsis,
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'ASK ',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.gold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              TextSpan(
                                text: 'ایمان',
                                style: TextStyle(
                                  fontFamily: 'NotoNastaliq',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textWhite,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),

          if (actions != null) ...actions!,

          const SizedBox(width: 4),

          // Streak badge (Wrapped in Flexible or Fixed width to prevent overflow)
          StreamBuilder<User?>(
            stream: auth.authStateChanges(),
            builder: (context, authSnap) {
              if (authSnap.data == null) return const SizedBox.shrink();
              return StreamBuilder<AppUser?>(
                stream: svc.watchCurrentUser(),
                builder: (context, profileSnap) {
                  final streak = profileSnap.data?.streakCount ?? 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMid,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '$streak DAY STREAK',
                      maxLines: 1,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textWhite,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
