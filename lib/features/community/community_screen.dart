// lib/features/community/community_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// COMMUNITY SCREEN — 4 sub-tabs, role-aware content
//
// Bug fixes from screenshots:
//   • Streaks tab: negative margin crash fixed (was margin: -X)
//   • Classes tab: teacher overflow fixed (Expanded wrapping)
//   • Charity tab: button overflow fixed (clipped height)
//
// Each tab receives the currentUser so it can adapt UI to role.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/community_service.dart';
import '../../shared/widgets/ask_iman_app_bar.dart';
import 'groups/groups_tab.dart';
import 'friends/friends_tab.dart';
import 'streaks/streaks_tab.dart';
import 'classes/classes_tab.dart';
import 'charity/charity_tab.dart';

class CommunityScreen extends StatefulWidget {
  final AppUser currentUser;
  const CommunityScreen({super.key, required this.currentUser});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _tabIndex = 0;
  final _tabs = ['Friends', 'Groups', 'Streaks', 'Classes', 'Charity'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: const AskImanAppBar(),
      body: Column(
        children: [
          _buildTabRow(),
          Expanded(
            child: IndexedStack(
              index: _tabIndex,
              children: [
                FriendsTab(currentUser: widget.currentUser),
                GroupsTab(currentUser: widget.currentUser),
                StreaksTab(currentUser: widget.currentUser),
                ClassesTab(currentUser: widget.currentUser),
                CharityTab(currentUser: widget.currentUser),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabRow() {
    return Container(
      color: AppColors.bgCream,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final active = _tabIndex == i;
                  return GestureDetector(
                    onTap: () => setState(() => _tabIndex = i),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 9),
                      decoration: BoxDecoration(
                        color: active ? AppColors.primaryDark : Colors.transparent,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: active
                              ? AppColors.primaryDark
                              : AppColors.borderLight,
                        ),
                      ),
                      child: Text(
                        _tabs[i],
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: active ? AppColors.gold : AppColors.textGrey,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.bgCream,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('Sign Out', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                  content: const Text('Are you sure you want to sign out from the community?', style: TextStyle(fontFamily: 'Cairo')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Sign Out', style: TextStyle(fontFamily: 'Cairo', color: AppColors.error, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await CommunityService.instance.signOut();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withOpacity(0.2)),
              ),
              child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}