// lib/features/community/groups/group_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/community_service.dart';

class GroupDetailScreen extends StatefulWidget {
  final GroupModel group;
  final AppUser currentUser;
  const GroupDetailScreen({
    super.key,
    required this.group,
    required this.currentUser,
  });

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _msgCtrl = TextEditingController();
  final _db = FirebaseFirestore.instance;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendGroupMessage(
    String text, {
    Map<String, dynamic>? alertData,
  }) async {
    final msg = text.trim();
    if (msg.isEmpty && alertData == null) return;
    setState(() => _sending = true);

    try {
      await _db
          .collection('family_groups')
          .doc(widget.group.id)
          .collection('messages')
          .add({
            'senderId': widget.currentUser.uid,
            'senderName': widget.currentUser.name,
            'text': msg,
            'alert': alertData,
            'createdAt': FieldValue.serverTimestamp(),
          });

      _msgCtrl.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send: $e')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _pushAlert(String type, String message) async {
    final alertMap = {
      'type': type, // namaz | tasbeeh | quran
      'title': type == 'namaz'
          ? 'ðŸ•‹ Namaz Reminder'
          : type == 'tasbeeh'
          ? 'ðŸ“¿ Tasbeeh Reminder'
          : 'ðŸ“– Quran Study Circle',
      'message': message,
      'pushedBy': widget.currentUser.name,
    };
    await _sendGroupMessage('', alertData: alertMap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.group.name,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ),
            Text(
              '${widget.group.members.length} members',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color: AppColors.textGreenMuted,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.textGreenMuted,
          labelStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Reminders & Chat'),
            Tab(text: 'Streaks'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [_buildChatTab(), _buildStreaksTab(), _buildSettingsTab()],
      ),
    );
  }

  // â”€â”€ Reminders & Chat Tab â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildChatTab() {
    return Column(
      children: [
        // Quick Alert Actions Row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.bgWhite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Send Controlled Alert Reminder:',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _alertBtn('ðŸ•‹ Namaz', () => _showPushAlertModal('namaz')),
                  const SizedBox(width: 8),
                  _alertBtn(
                    'ðŸ“¿ Tasbeeh',
                    () => _showPushAlertModal('tasbeeh'),
                  ),
                  const SizedBox(width: 8),
                  _alertBtn('ðŸ“– Quran', () => _showPushAlertModal('quran')),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderLight),
        // Live Group messages / Alerts Feed
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _db
                .collection('family_groups')
                .doc(widget.group.id)
                .collection('messages')
                .orderBy('createdAt', descending: true)
                .limit(50)
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                );
              }
              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.mark_chat_unread_outlined,
                        size: 48,
                        color: AppColors.textLightGrey.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No messages or reminders yet',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (ctx, index) {
                  final d = docs[index].data() as Map<String, dynamic>;
                  final isMe = d['senderId'] == widget.currentUser.uid;
                  final alert = d['alert'] as Map<String, dynamic>?;

                  if (alert != null) {
                    return _buildAlertBubble(alert);
                  }

                  return _buildChatMessageBubble(d, isMe);
                },
              );
            },
          ),
        ),
        // Text Input Bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          color: AppColors.bgWhite,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgCream,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: TextField(
                    controller: _msgCtrl,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Type a message to the circle...',
                      hintStyle: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sending ? null : () => _sendGroupMessage(_msgCtrl.text),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryDark,
                    shape: BoxShape.circle,
                  ),
                  child: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: AppColors.gold,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send, color: AppColors.gold, size: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _alertBtn(String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryDark.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primaryDark.withValues(alpha: 0.25),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertBubble(Map<String, dynamic> alert) {
    final type = alert['type'] ?? 'namaz';
    final title = alert['title'] ?? 'Reminder';
    final message = alert['message'] ?? '';
    final pusher = alert['pushedBy'] ?? 'Someone';

    Color color;
    IconData icon;
    if (type == 'namaz') {
      color = AppColors.gold;
      icon = Icons.account_balance;
    } else if (type == 'tasbeeh') {
      color = AppColors.primaryLight;
      icon = Icons.touch_app;
    } else {
      color = AppColors.success;
      icon = Icons.menu_book;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppColors.textWhite,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pushed by $pusher',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              color: AppColors.textGreenMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessageBubble(Map<String, dynamic> msg, bool isMe) {
    final name = msg['senderName'] ?? 'Unknown';
    final text = msg['text'] ?? '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryDark : AppColors.bgWhite,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
          border: isMe ? null : Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMe)
              Text(
                name,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryMid,
                ),
              ),
            const SizedBox(height: 2),
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: isMe ? AppColors.textWhite : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPushAlertModal(String type) {
    final alertCtrl = TextEditingController();
    final String typeTitle = type == 'namaz'
        ? 'Namaz Alert'
        : type == 'tasbeeh'
        ? 'Tasbeeh Goal'
        : 'Quran Circle';
    final String typeHint = type == 'namaz'
        ? 'e.g. Asr prayer is in 10 minutes. Let us pray in congregation!'
        : type == 'tasbeeh'
        ? 'e.g. Let us complete 100x Astaghfirullah today.'
        : 'e.g. Quran recitation circle is active in 1 hour!';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Push $typeTitle',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter reminder message:',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: TextField(
                controller: alertCtrl,
                maxLines: 3,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                decoration: InputDecoration(
                  hintText: typeHint,
                  hintStyle: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: AppColors.textLightGrey,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () async {
              if (alertCtrl.text.trim().isNotEmpty) {
                await _pushAlert(type, alertCtrl.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text(
              'Push Alert',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.gold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Streaks Leaderboard Tab â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildStreaksTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db
          .collection('users')
          .where(FieldPath.documentId, whereIn: widget.group.members)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          );
        }
        final docs = snap.data?.docs ?? [];

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (ctx, index) {
            final u = AppUser.fromDoc(docs[index]);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          u.name,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          u.email,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder<int>(
                    // Fetch each member's actual current streak
                    future: CommunityService.instance.getStreakForUser(u.uid),
                    builder: (context, streakSnap) {
                      final s = streakSnap.data ?? 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_fire_department_rounded,
                              color: AppColors.gold,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$s Days',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // â”€â”€ Settings Tab â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Group Preferences',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                _prefSwitch('Mute All Notifications', false),
                _prefSwitch(
                  'Namaz Reminder Alerts',
                  widget.group.notifConfig['namaz'] ?? true,
                ),
                _prefSwitch(
                  'Tasbeeh Reminder Alerts',
                  widget.group.notifConfig['tasbeeh'] ?? true,
                ),
                _prefSwitch(
                  'Quran Study Alerts',
                  widget.group.notifConfig['quran'] ?? false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            onPressed: () async {
              try {
                await _db.collection('family_groups').doc(widget.group.id).update({
                  'memberIds': FieldValue.arrayRemove([widget.currentUser.uid]),
                });
                await _db
                    .collection('users')
                    .doc(widget.currentUser.uid)
                    .update({
                      'groups': FieldValue.arrayRemove([widget.group.id]),
                    });
                if (mounted) Navigator.pop(context);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to leave group: $e')),
                  );
                }
              }
            },
            child: const Text(
              'Leave Group',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _prefSwitch(String label, bool initialVal) {
    bool val = initialVal;
    return StatefulBuilder(
      builder: (ctx, setSwitchState) => SwitchListTile(
        title: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            color: AppColors.textDark,
          ),
        ),
        value: val,
        activeThumbColor: AppColors.gold,
        activeTrackColor: AppColors.primaryDark,
        onChanged: (v) => setSwitchState(() => val = v),
      ),
    );
  }
}
