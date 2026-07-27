import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/ask_iman_app_bar.dart';
import 'family_service.dart';
import 'create_reminder_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  const GroupDetailScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  final _svc = FamilyService.instance;
  late TabController _tabController;
  final _chatCtl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _auth = FirebaseAuth.instance;
  final _broadcastTitleCtl = TextEditingController();
  final _broadcastBodyCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatCtl.dispose();
    _scrollCtrl.dispose();
    _broadcastTitleCtl.dispose();
    _broadcastBodyCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid ?? '';
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AskImanAppBar(
        title: widget.groupName,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textWhite),
            onSelected: (v) {
              if (v == 'broadcast') _showBroadcastDialog();
              if (v == 'signout') _signOut(context);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'broadcast',
                child: ListTile(
                  leading: Icon(Icons.campaign, color: AppColors.gold),
                  title: Text('Notify All Members'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'signout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Sign Out'),
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.textGrey,
            indicatorColor: AppColors.gold,
            tabs: const [
              Tab(text: 'Members'),
              Tab(text: 'Reminders'),
              Tab(text: 'Chat'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMembersTab(uid),
                _buildRemindersTab(uid),
                _buildChatTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBroadcastDialog() {
    _broadcastTitleCtl.clear();
    _broadcastBodyCtl.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Notify All Members'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _broadcastTitleCtl,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g., Important Announcement',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _broadcastBodyCtl,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Your message to all group members...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = _broadcastTitleCtl.text.trim();
              final body = _broadcastBodyCtl.text.trim();
              if (title.isEmpty || body.isEmpty) return;
              await _svc.notifyAllMembers(widget.groupId, title, body);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final nav = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _auth.signOut();
      if (nav.context.mounted) nav.popUntil((r) => r.isFirst);
    }
  }

  // ── Members Tab ──

  Widget _buildMembersTab(String uid) {
    return StreamBuilder<FamilyGroup?>(
      stream: _svc.watchGroup(widget.groupId),
      builder: (ctx, snap) {
        final group = snap.data;
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          );
        }
        if (group == null) {
          return const Center(
            child: Text(
              'Group not found',
              style: TextStyle(color: AppColors.textGrey),
            ),
          );
        }
        final isAdmin = group.creatorId == uid;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textWhite,
                    ),
                  ),
                  if (group.description != null &&
                      group.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      group.description!,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppColors.textGreenMuted,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16, color: AppColors.gold),
                      const SizedBox(width: 6),
                      Text(
                        '${group.memberIds.length} Members',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          if (group.inviteCode != null) {
                            Clipboard.setData(
                              ClipboardData(text: group.inviteCode!),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Invite code copied!'),
                              ),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.copy,
                              size: 14,
                              color: AppColors.gold,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Code: ${group.inviteCode ?? 'N/A'}',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Members',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDarkest,
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(group.memberNames.length, (i) {
              final name = group.memberNames[i];
              final memberId = group.memberIds[i];
              final isCreator = memberId == group.creatorId;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primaryDarkest,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textWhite,
                                ),
                              ),
                              if (isCreator) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Admin',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDarkest,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            memberId,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 9,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.copy,
                        size: 16,
                        color: AppColors.textGrey,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: memberId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Copied UID: $memberId')),
                        );
                      },
                      tooltip: 'Copy User ID',
                    ),
                    if (isAdmin && !isCreator)
                      IconButton(
                        icon: const Icon(
                          Icons.block,
                          size: 16,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          await _svc.removeMember(
                            widget.groupId,
                            memberId,
                            name,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Removed $name')),
                            );
                          }
                        },
                        tooltip: 'Remove Member',
                      ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  // ── Reminders Tab ──

  Widget _buildRemindersTab(String uid) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToCreate(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(
                    'Add Reminder',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.primaryDarkest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: StreamBuilder<List<FamilyReminder>>(
            stream: _svc.watchReminders(widget.groupId),
            builder: (ctx, snap) {
              final reminders = snap.data ?? [];
              if (reminders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.alarm_off,
                        size: 48,
                        color: AppColors.textGrey,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No reminders yet',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: reminders.length,
                itemBuilder: (_, i) => _buildReminderCard(reminders[i], uid),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReminderCard(FamilyReminder r, String uid) {
    final isCreator = r.creatorId == uid;
    final imageUrl = r.imageUrl;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image
          if (imageUrl != null && imageUrl.isNotEmpty)
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 120,
                  color: AppColors.primaryDarkest,
                  child: const Center(
                    child: Icon(
                      Icons.image,
                      color: AppColors.textGrey,
                      size: 36,
                    ),
                  ),
                ),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 120,
                    color: AppColors.primaryDarkest,
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.gold),
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _svc.toggleReminder(r.id, !r.completed),
                      child: Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: r.completed
                              ? AppColors.gold
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: r.completed
                                ? AppColors.gold
                                : AppColors.textGrey,
                            width: 2,
                          ),
                        ),
                        child: r.completed
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: AppColors.primaryDarkest,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.title,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: r.completed
                                  ? AppColors.textGrey
                                  : AppColors.textWhite,
                              decoration: r.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          if (r.description != null &&
                              r.description!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                r.description!,
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  color: AppColors.textGreenMuted,
                                ),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _reminderChip(r.type),
                              if (r.recurring && r.recurringDays != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: Text(
                                    r.recurringDays!.join(', '),
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 9,
                                      color: AppColors.gold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isCreator) ...[
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          size: 18,
                          color: AppColors.gold,
                        ),
                        onPressed: () => _navigateToEdit(r),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.send,
                          size: 18,
                          color: AppColors.gold,
                        ),
                        onPressed: () {
                          _svc.sendReminderNow(r);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reminder sent!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        tooltip: 'Send Now',
                      ),
                    ],
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.textGrey,
                        size: 18,
                      ),
                      onPressed: () => _svc.deleteReminder(r.id),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reminderChip(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryDarkest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: AppColors.gold,
        ),
      ),
    );
  }

  void _navigateToCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateReminderScreen(groupId: widget.groupId),
      ),
    );
  }

  void _navigateToEdit(FamilyReminder r) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CreateReminderScreen(groupId: widget.groupId, existing: r),
      ),
    );
  }

  // ── Chat Tab ──

  Widget _buildChatTab() {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<FamilyGroupMessage>>(
            stream: _svc.watchMessages(widget.groupId),
            builder: (ctx, snap) {
              final messages = snap.data ?? [];
              if (messages.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 48,
                        color: AppColors.textGrey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No messages yet.\nStart a conversation!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (_, i) {
                  final msg = messages[i];
                  final isMe = msg.senderId == _auth.currentUser?.uid;
                  return Align(
                    alignment: isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isMe ? AppColors.gold : AppColors.primaryDark,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(14),
                          topRight: const Radius.circular(14),
                          bottomLeft: isMe
                              ? const Radius.circular(14)
                              : const Radius.circular(4),
                          bottomRight: isMe
                              ? const Radius.circular(4)
                              : const Radius.circular(14),
                        ),
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg.senderName,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isMe
                                  ? AppColors.primaryDarkest
                                  : AppColors.gold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            msg.text,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              color: isMe
                                  ? AppColors.primaryDarkest
                                  : AppColors.textWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: const BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatCtl,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.textGrey,
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: AppColors.primaryDarkest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _sendMessage(),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: AppColors.primaryDarkest,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _sendMessage() async {
    final text = _chatCtl.text.trim();
    if (text.isEmpty) return;
    try {
      await _svc.sendMessage(widget.groupId, text);
      _chatCtl.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
    }
  }
}
