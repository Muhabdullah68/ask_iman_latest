// lib/features/community/friends/friends_tab.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/community_service.dart';
import '../chat/dm_screen.dart';

class FriendsTab extends StatefulWidget {
  final AppUser currentUser;
  const FriendsTab({super.key, required this.currentUser});
  @override State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  final _svc = CommunityService.instance;
  final _searchCtrl = TextEditingController();
  String _query = '';
  List<AppUser> _searchResults = [];

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  void _onSearch(String q) {
    setState(() => _query = q);
    if (q.length >= 2) {
      _svc.searchUsers(q).first.then((r) {
        if (mounted) setState(() => _searchResults = r);
      });
    } else {
      setState(() => _searchResults = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FriendshipModel>>(
      stream: _svc.watchFriends(),
      builder: (ctx, snap) {
        final all      = snap.data ?? [];
        final accepted = _svc.filterAccepted(all);
        final pending  = _svc.filterPending(all);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInsightCard(),
              _buildSearchBar(),
              if (_query.isNotEmpty) _buildSearchResults(),
              if (_query.isEmpty) ...[
                if (accepted.isNotEmpty) _buildActiveFriends(accepted),
                if (pending.isNotEmpty)  _buildPendingRequests(pending),
                _buildSuggestedFriends(),
                _buildYourCircle(accepted),
              ],
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInsightCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DAILY INSIGHT', style: TextStyle(
            fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.w700,
            color: AppColors.gold, letterSpacing: 1.5,
          )),
          const SizedBox(height: 10),
          const Text(
            '"The best of people are those that are most useful to others."',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 16,
                fontWeight: FontWeight.w700, color: AppColors.textWhite,
                height: 1.4),
          ),
          const SizedBox(height: 6),
          const Text('Hadith | Prophet Muhammad (PBUH)',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 12,
                  color: AppColors.textGreenMuted)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gold),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('REFLECT NOW →',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12,
                    fontWeight: FontWeight.w700, color: AppColors.gold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search, color: AppColors.textLightGrey, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearch,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Find people in the Ummah...',
                  hintStyle: TextStyle(fontFamily: 'Cairo', fontSize: 14,
                      color: AppColors.textLightGrey),
                  border: InputBorder.none, isDense: true,
                ),
              ),
            ),
            if (_query.isNotEmpty)
              GestureDetector(
                onTap: () { _searchCtrl.clear(); setState(() { _query = ''; _searchResults = []; }); },
                child: const Padding(padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.close, size: 16, color: AppColors.textGrey)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('No users found',
            style: TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey))),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: _searchResults.map((u) => _UserRow(
          name: u.name,
          sub: u.role.name,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.report_problem_outlined, color: AppColors.error, size: 20),
                onPressed: () => _showReportDialog(u.uid),
              ),
              GestureDetector(
                onTap: () => _svc.sendFriendRequest(u),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('Add', style: TextStyle(fontFamily: 'Cairo',
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: AppColors.gold)),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  void _showReportDialog(String targetId) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report User', style: TextStyle(fontFamily: 'Cairo')),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(hintText: 'Reason for reporting'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (reasonCtrl.text.isNotEmpty) {
                await _svc.reportUser(targetId, reasonCtrl.text);
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Report', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFriends(List<FriendshipModel> friends) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: friends.take(3).map((f) {
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => DmScreen(
                      otherUid: f.toUid == widget.currentUser.uid
                          ? f.fromUid : f.toUid,
                      otherName: f.otherName,
                    ),
                  )),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        _avatar(f.otherName, size: 38),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(f.otherName, style: const TextStyle(
                                  fontFamily: 'Cairo', fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textWhite)),
                              const Text('Active', style: TextStyle(
                                  fontFamily: 'Cairo', fontSize: 11,
                                  color: AppColors.textGreenMuted)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chat_bubble_outline,
                            color: AppColors.textGreenMuted, size: 18),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingRequests(List<FriendshipModel> pending) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pending Requests', style: TextStyle(
              fontFamily: 'Cairo', fontSize: 15,
              fontWeight: FontWeight.w700, color: AppColors.textDark,
            )),
            const SizedBox(height: 10),
            ...pending.take(3).map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  _avatar(f.otherName, size: 36),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.otherName, style: const TextStyle(
                            fontFamily: 'Cairo', fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark)),
                        const Text('Wants to connect', style: TextStyle(
                            fontFamily: 'Cairo', fontSize: 11,
                            color: AppColors.textGrey)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _svc.acceptFriendRequest(f.id),
                    child: Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.15),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded,
                          color: AppColors.success, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _svc.declineFriendRequest(f.id),
                    child: Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded,
                          color: AppColors.error, size: 18),
                    ),
                  ),
                ],
              ),
            )),
            if (pending.length > 3)
              Center(
                child: Text('VIEW ALL REQUESTS', style: const TextStyle(
                  fontFamily: 'Cairo', fontSize: 11,
                  fontWeight: FontWeight.w700, color: AppColors.gold,
                )),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedFriends() {
    // In production: query friends-of-friends via Cloud Function
    // For now: show random verified users
    return StreamBuilder<List<AppUser>>(
      stream: _svc.watchSuggestedFriends(),
      builder: (ctx, snap) {
        final users = (snap.data ?? []).take(4).toList();
        if (users.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Suggested for you', style: TextStyle(
                fontFamily: 'Cairo', fontSize: 16,
                fontWeight: FontWeight.w700, color: AppColors.textDark,
              )),
              const SizedBox(height: 10),
              Row(
                children: users.take(2).map((u) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.bgWhite,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        _avatar(u.name, size: 48),
                        const SizedBox(height: 8),
                        Text(u.name, textAlign: TextAlign.center,
                            style: const TextStyle(fontFamily: 'Cairo',
                                fontSize: 13, fontWeight: FontWeight.w700,
                                color: AppColors.textDark)),
                        Text(u.role.name, style: const TextStyle(
                            fontFamily: 'Cairo', fontSize: 11,
                            color: AppColors.textGrey)),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => _svc.sendFriendRequest(u),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(child: Text('Add Friend',
                                style: TextStyle(fontFamily: 'Cairo',
                                    fontSize: 12, fontWeight: FontWeight.w600,
                                    color: AppColors.textWhite))),
                          ),
                        ),
                      ],
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildYourCircle(List<FriendshipModel> friends) {
    if (friends.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Your Circle', style: TextStyle(
                fontFamily: 'Cairo', fontSize: 16,
                fontWeight: FontWeight.w700, color: AppColors.textDark,
              )),
              const Spacer(),
              Text('${friends.length} ACTIVE', style: const TextStyle(
                fontFamily: 'Cairo', fontSize: 11,
                fontWeight: FontWeight.w700, color: AppColors.gold,
              )),
            ],
          ),
          const SizedBox(height: 10),
          ...friends.map((f) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _avatar(f.otherName, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.otherName, style: const TextStyle(
                          fontFamily: 'Cairo', fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textWhite)),
                      const Text('Friend', style: TextStyle(
                          fontFamily: 'Cairo', fontSize: 11,
                          color: AppColors.textGreenMuted)),
                    ],
                  ),
                ),
                const Icon(Icons.remove_red_eye_outlined,
                    color: AppColors.textGreenMuted, size: 18),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _avatar(String name, {double size = 40}) {
    final initials = name.trim().isEmpty ? '?' :
    name.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase();
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryMid,
        shape: BoxShape.circle,
      ),
      child: Center(child: Text(initials, style: TextStyle(
        fontFamily: 'Cairo', fontSize: size * 0.34,
        fontWeight: FontWeight.w700, color: AppColors.textWhite,
      ))),
    );
  }
}


class _UserRow extends StatelessWidget {
  final String name;
  final String sub;
  final Widget trailing;
  const _UserRow({required this.name, required this.sub, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryMid.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: AppColors.textWhite, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontFamily: 'Cairo',
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
                Text(sub, style: const TextStyle(fontFamily: 'Cairo',
                    fontSize: 11, color: AppColors.textGrey)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}