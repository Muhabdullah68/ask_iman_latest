// lib/features/community/groups/groups_tab.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/community_service.dart';

class GroupsTab extends StatefulWidget {
  final AppUser currentUser;
  const GroupsTab({super.key, required this.currentUser});

  @override
  State<GroupsTab> createState() => _GroupsTabState();
}

class _GroupsTabState extends State<GroupsTab> {
  final _svc = CommunityService.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GroupModel>>(
      stream: _svc.watchMyGroups(),
      builder: (context, snapshot) {
        final groups = snapshot.data ?? [];

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              if (groups.isEmpty)
                _buildEmptyState()
              else
                _buildGroupsList(groups),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Groups & Circles',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          GestureDetector(
            onTap: _showCreateGroupDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add, color: AppColors.gold, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Create',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
        child: Column(
          children: [
            Icon(
              Icons.group_outlined,
              size: 64,
              color: AppColors.textLightGrey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No groups joined yet',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a group with friends to share streaks and notification reminders.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupsList(List<GroupModel> groups) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groups.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final group = groups[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.groups, color: AppColors.gold),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${group.members.length} members',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textLightGrey),
            ],
          ),
        );
      },
    );
  }

  void _showCreateGroupDialog() {
    final nameCtrl = TextEditingController();
    Map<String, bool> notifConfig = {
      'namaz': true,
      'tasbeeh': true,
      'quran': false,
    };

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Create New Group',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Group Name',
                    hintStyle: TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Custom Notifications',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                CheckboxListTile(
                  title: const Text(
                    'Namaz Reminders',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 14),
                  ),
                  value: notifConfig['namaz'],
                  activeColor: AppColors.primaryDark,
                  onChanged: (v) =>
                      setDialogState(() => notifConfig['namaz'] = v!),
                ),
                CheckboxListTile(
                  title: const Text(
                    'Tasbeeh Reminders',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 14),
                  ),
                  value: notifConfig['tasbeeh'],
                  activeColor: AppColors.primaryDark,
                  onChanged: (v) =>
                      setDialogState(() => notifConfig['tasbeeh'] = v!),
                ),
                CheckboxListTile(
                  title: const Text(
                    'Quran Study Alerts',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 14),
                  ),
                  value: notifConfig['quran'],
                  activeColor: AppColors.primaryDark,
                  onChanged: (v) =>
                      setDialogState(() => notifConfig['quran'] = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx2),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textGrey,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                try {
                  await _svc.createGroup(name, notifConfig);
                  if (ctx2.mounted) Navigator.pop(ctx2);
                } catch (e) {
                  if (ctx2.mounted) {
                    ScaffoldMessenger.of(ctx2).showSnackBar(
                      SnackBar(content: Text('Failed to create group: $e')),
                    );
                  }
                }
              },
              child: const Text(
                'Create',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
