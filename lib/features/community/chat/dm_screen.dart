// lib/features/community/chat/dm_screen.dart
// ══════════════════════════════════════════════════════════════════════════════
// DM SCREEN — real-time direct messaging between two users
// Uses CommunityService.watchDmMessages / sendDm (already implemented)
// ══════════════════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/community_service.dart';

class DmScreen extends StatefulWidget {
  final String otherUid;
  final String otherName;

  const DmScreen({
    super.key,
    required this.otherUid,
    required this.otherName,
  });

  @override
  State<DmScreen> createState() => _DmScreenState();
}

class _DmScreenState extends State<DmScreen> {
  final _svc        = CommunityService.instance;
  final _msgCtrl    = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending     = false;

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _msgCtrl.clear();
    try {
      await _svc.sendDm(widget.otherUid, text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryDark,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.gold, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          _avatar(widget.otherName, size: 36),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.otherName,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textWhite,
                ),
              ),
              const Text(
                'Active',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: AppColors.textGreenMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _svc.watchDmMessages(widget.otherUid),
      builder: (ctx, snap) {
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
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded,
                      color: AppColors.primaryDark, size: 30),
                ),
                const SizedBox(height: 12),
                const Text(
                  'No messages yet.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Say salaam to ${widget.otherName}!',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';

        return ListView.builder(
          controller: _scrollCtrl,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final isMe = data['senderId'] == myUid;
            final text = data['text'] as String? ?? '';
            final ts   = data['createdAt'] as Timestamp?;
            final time = ts != null
                ? TimeOfDay.fromDateTime(ts.toDate()).format(context)
                : '';

            return _MessageBubble(
              text: text,
              time: time,
              isMe: isMe,
              senderName: isMe ? 'You' : widget.otherName,
            );
          },
        );
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 10, 12, MediaQuery.of(context).viewInsets.bottom + 12),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
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
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Write a message...',
                  hintStyle: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: AppColors.textLightGrey,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primaryDark,
                shape: BoxShape.circle,
              ),
              child: _sending
                  ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  color: AppColors.gold,
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.send_rounded,
                  color: AppColors.gold, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(String name, {double size = 40}) {
    final initials = name.trim().isEmpty
        ? '?'
        : name.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryMid,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: size * 0.34,
            fontWeight: FontWeight.w700,
            color: AppColors.textWhite,
          ),
        ),
      ),
    );
  }
}

// ── Message bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;
  final String senderName;

  const _MessageBubble({
    required this.text,
    required this.time,
    required this.isMe,
    required this.senderName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            _mini(senderName),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.primaryDark
                        : AppColors.bgWhite,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    border: isMe
                        ? null
                        : Border.all(color: AppColors.borderLight),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: isMe
                          ? AppColors.textWhite
                          : AppColors.textDark,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  time,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    color: AppColors.textLightGrey,
                  ),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget _mini(String name) {
    final initials = name.trim().isEmpty
        ? '?'
        : name.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase();
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.primaryMid,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textWhite,
          ),
        ),
      ),
    );
  }
}
