// lib/features/community/admin/admin_dashboard.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/community_service.dart';
import '../../../shared/widgets/ask_iman_app_bar.dart';
import '../chat/dm_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _svc     = CommunityService.instance;
  int _section   = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: const AskImanAppBar(),
      body: Column(
        children: [
          _buildAdminHeader(),
          _buildSectionTabs(),
          Expanded(
            child: IndexedStack(
              index: _section,
              children: [
                _ApprovalsSection(svc: _svc),
                _MembersSection(svc: _svc),
                _InspectionSection(svc: _svc),
                _AnalyticsSection(svc: _svc),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      color: AppColors.primaryDark,
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.admin_panel_settings_rounded,
                color: AppColors.gold, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Admin Dashboard', style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 17,
                  fontWeight: FontWeight.w800, color: AppColors.gold,
                )),
                Text('Ask Iman Community Management', style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 11,
                  color: AppColors.textGreenMuted,
                )),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => FirebaseAuth.instance.signOut(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text('Sign out', style: TextStyle(
                fontFamily: 'Cairo', fontSize: 11,
                color: AppColors.gold,
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTabs() {
    // Show live pending count badge on Approvals tab
    return StreamBuilder<QuerySnapshot>(
      stream: _svc.watchPendingApprovals(),
      builder: (ctx, snap) {
        final pendingCount = snap.data?.docs.length ?? 0;
        final tabs = ['Approvals', 'Members', 'Inspection', 'Analytics'];
        return Container(
          color: AppColors.bgWhite,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(tabs.length, (i) {
                final active = _section == i;
                return GestureDetector(
                  onTap: () => setState(() => _section = i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primaryDark : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: active
                            ? AppColors.primaryDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(tabs[i], style: TextStyle(
                          fontFamily: 'Cairo', fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: active ? AppColors.gold : AppColors.textGrey,
                        )),
                        // Badge on Approvals tab when pending > 0
                        if (i == 0 && pendingCount > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 18, height: 18,
                            decoration: const BoxDecoration(
                              color: AppColors.warning,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text('$pendingCount',
                                  style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// APPROVALS SECTION
// Shows all pending teacher / class / charity approvals with full detail
// ══════════════════════════════════════════════════════════════════════════════
class _ApprovalsSection extends StatelessWidget {
  final CommunityService svc;
  const _ApprovalsSection({required this.svc});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: svc.watchPendingApprovals(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.gold));
        }
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Error loading approvals:\n${snap.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: AppColors.error)),
            ),
          );
        }

        final docs = snap.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 36),
                ),
                const SizedBox(height: 16),
                const Text('All caught up!',
                    style: TextStyle(
                      fontFamily: 'Cairo', fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    )),
                const SizedBox(height: 6),
                const Text('No pending approvals.',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: AppColors.textGrey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (_, i) => _ApprovalCard(
            docId: docs[i].id,
            data:  docs[i].data() as Map<String, dynamic>,
            svc:   svc,
          ),
        );
      },
    );
  }
}

class _ApprovalCard extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;
  final CommunityService svc;
  const _ApprovalCard({
    required this.docId,
    required this.data,
    required this.svc,
  });

  @override
  State<_ApprovalCard> createState() => _ApprovalCardState();
}

class _ApprovalCardState extends State<_ApprovalCard> {
  bool _busy = false;

  Future<void> _act(bool approve) async {
    setState(() => _busy = true);
    try {
      final type  = widget.data['type']  as String? ?? '';
      final refId = widget.data['refId'] as String? ?? '';
      if (approve) {
        await widget.svc.approveItem(widget.docId, type, refId);
      } else {
        await widget.svc.rejectItem(widget.docId, type, refId);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d    = widget.data;
    final type = (d['type'] as String? ?? '').toLowerCase();

    // Display name: teacher → applicantName, class/charity → title
    final displayName = (type == 'teacher')
        ? (d['applicantName'] as String? ?? 'Unknown Teacher')
        : (d['title']         as String? ?? 'Untitled');

    final ts   = d['createdAt'] as Timestamp?;
    final date = ts != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(ts.toDate())
        : '';

    // Extra detail rows depending on type
    final details = <String, String>{};
    if (type == 'teacher') {
      if ((d['qualification']  as String? ?? '').isNotEmpty)
        details['Qualification']  = d['qualification'];
      if ((d['specialization'] as String? ?? '').isNotEmpty)
        details['Specialization'] = d['specialization'];
      if ((d['refId']          as String? ?? '').isNotEmpty)
        details['User UID']       = d['refId'];
    } else if (type == 'class') {
      if ((d['teacherId'] as String? ?? '').isNotEmpty)
        details['Teacher UID'] = d['teacherId'];
    } else if (type == 'charity') {
      if (d['goal'] != null)
        details['Goal'] = 'PKR ${d['goal']}';
    }

    Color typeColor;
    IconData typeIcon;
    switch (type) {
      case 'teacher':
        typeColor = AppColors.primaryLight;
        typeIcon  = Icons.auto_stories_outlined;
        break;
      case 'class':
        typeColor = AppColors.gold;
        typeIcon  = Icons.school_outlined;
        break;
      case 'charity':
        typeColor = AppColors.success;
        typeIcon  = Icons.volunteer_activism_outlined;
        break;
      default:
        typeColor = AppColors.warning;
        typeIcon  = Icons.pending_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header stripe ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft:  Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(date,
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10,
                              color: AppColors.textGrey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(type.toUpperCase(),
                      style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.warning)),
                ),
              ],
            ),
          ),

          // ── Detail rows ──
          if (details.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
              child: Column(
                children: details.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 110,
                        child: Text(e.key,
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                color: AppColors.textGrey)),
                      ),
                      Expanded(
                        child: Text(e.value,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            )),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),

          // ── Action buttons ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
            child: _busy
                ? const Center(
              child: SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(
                    color: AppColors.gold, strokeWidth: 2),
              ),
            )
                : Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _act(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text('✓  Approve',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            )),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _act(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.error.withOpacity(0.35)),
                      ),
                      child: const Center(
                        child: Text('✕  Reject',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.error,
                            )),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MEMBERS SECTION
// ══════════════════════════════════════════════════════════════════════════════
class _MembersSection extends StatelessWidget {
  final CommunityService svc;
  const _MembersSection({required this.svc});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // FIX: removed orderBy('createdAt') — some docs (seed data) lack the
      // field and the query crashes. Sort client-side instead.
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.gold));
        }
        if (snap.hasError) {
          return Center(
            child: Text('Error: ${snap.error}',
                style: const TextStyle(
                    fontFamily: 'Cairo', color: AppColors.error)),
          );
        }

        final docs = snap.data?.docs ?? [];
        // Client-side sort: newest first (nulls last)
        docs.sort((a, b) {
          final ad = a.data() as Map<String, dynamic>;
          final bd = b.data() as Map<String, dynamic>;
          final at = ad['createdAt'] as Timestamp?;
          final bt = bd['createdAt'] as Timestamp?;
          if (at == null && bt == null) return 0;
          if (at == null) return 1;
          if (bt == null) return -1;
          return bt.compareTo(at);
        });

        // Deduplicate by email
        final seenEmails = <String>{};
        final uniqueDocs = <DocumentSnapshot>[];
        for (var doc in docs) {
          final d = doc.data() as Map<String, dynamic>;
          final email = (d['email'] as String? ?? '').trim().toLowerCase();
          if (email.isEmpty) {
            uniqueDocs.add(doc);
          } else if (!seenEmails.contains(email)) {
            seenEmails.add(email);
            uniqueDocs.add(doc);
          }
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: uniqueDocs.length,
          itemBuilder: (_, i) {
            final u = AppUser.fromDoc(uniqueDocs[i]);
            return _MemberRow(user: u, svc: svc);
          },
        );
      },
    );
  }
}

class _MemberRow extends StatefulWidget {
  final AppUser user;
  final CommunityService svc;
  const _MemberRow({required this.user, required this.svc});

  @override
  State<_MemberRow> createState() => _MemberRowState();
}

class _MemberRowState extends State<_MemberRow> {
  bool _busy = false;

  Color get _roleColor {
    switch (widget.user.role) {
      case UserRole.admin:   return AppColors.warning;
      case UserRole.teacher: return AppColors.primaryLight;
      default:               return AppColors.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: u.isBlocked
            ? AppColors.error.withOpacity(0.04)
            : AppColors.bgWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: u.isBlocked
              ? AppColors.error.withOpacity(0.2)
              : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryMid.withOpacity(0.35),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                u.name.trim().isEmpty
                    ? '?'
                    : u.name.trim().split(' ')
                    .take(2).map((w) => w[0]).join().toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Cairo', fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textWhite,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(u.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Cairo', fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          )),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _roleColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(u.role.name,
                          style: TextStyle(
                            fontFamily: 'Cairo', fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: _roleColor,
                          )),
                    ),
                    if (u.role == UserRole.teacher && !u.isApproved) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('pending',
                            style: TextStyle(
                              fontFamily: 'Cairo', fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.warning,
                            )),
                      ),
                    ],
                  ],
                ),
                Text(u.email,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        color: AppColors.textGrey)),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // Block / unblock
          if (_busy)
            const SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(
                  color: AppColors.gold, strokeWidth: 2),
            )
          else
            GestureDetector(
              onTap: () async {
                setState(() => _busy = true);
                u.isBlocked
                    ? await widget.svc.unblockUser(u.uid)
                    : await widget.svc.blockUser(u.uid);
                if (mounted) setState(() => _busy = false);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: u.isBlocked
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(u.isBlocked ? 'Unblock' : 'Block',
                    style: TextStyle(
                      fontFamily: 'Cairo', fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: u.isBlocked
                          ? AppColors.success
                          : AppColors.error,
                    )),
              ),
            ),
          const SizedBox(width: 6),
          // Delete
          GestureDetector(
            onTap: () => _confirmDelete(context),
            child: const Icon(Icons.delete_outline_rounded,
                color: AppColors.textLightGrey, size: 18),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete User',
            style: TextStyle(fontFamily: 'Cairo')),
        content: Text('Remove ${widget.user.name} from the community?',
            style: const TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              widget.svc.deleteUser(widget.user.uid);
              Navigator.pop(context);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ANALYTICS SECTION  — live counts from Firestore
// ══════════════════════════════════════════════════════════════════════════════
class _AnalyticsSection extends StatelessWidget {
  final CommunityService svc;
  const _AnalyticsSection({required this.svc});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Live members count
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .snapshots(),
            builder: (_, s) => _statCard(
              'Total Members',
              '${s.data?.docs.length ?? 0}',
              Icons.people_alt_rounded,
            ),
          ),
          const SizedBox(height: 10),
          // Live active classes
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('classes')
                .where('status', isEqualTo: 'active')
                .snapshots(),
            builder: (_, s) => _statCard(
              'Active Classes',
              '${s.data?.docs.length ?? 0}',
              Icons.school_rounded,
            ),
          ),
          const SizedBox(height: 10),
          // Live active charities
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('charities')
                .where('status', isEqualTo: 'active')
                .snapshots(),
            builder: (_, s) => _statCard(
              'Active Charities',
              '${s.data?.docs.length ?? 0}',
              Icons.volunteer_activism_rounded,
            ),
          ),
          const SizedBox(height: 10),
          // Pending approvals
          StreamBuilder<QuerySnapshot>(
            stream: svc.watchPendingApprovals(),
            builder: (_, s) => _statCard(
              'Pending Approvals',
              '${s.data?.docs.length ?? 0}',
              Icons.pending_actions_rounded,
              highlight: (s.data?.docs.length ?? 0) > 0,
            ),
          ),
          const SizedBox(height: 10),
          // Teachers pending approval
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'teacher')
                .where('isApproved', isEqualTo: false)
                .snapshots(),
            builder: (_, s) => _statCard(
              'Teachers Awaiting Approval',
              '${s.data?.docs.length ?? 0}',
              Icons.auto_stories_rounded,
              highlight: (s.data?.docs.length ?? 0) > 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String val, IconData icon,
      {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.warning.withOpacity(0.07)
            : AppColors.bgWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight
              ? AppColors.warning.withOpacity(0.3)
              : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: highlight
                  ? AppColors.warning.withOpacity(0.15)
                  : AppColors.primaryDark.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon,
                color: highlight
                    ? AppColors.warning
                    : AppColors.primaryDark,
                size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: AppColors.textDark)),
          ),
          Text(val,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: highlight
                      ? AppColors.warning
                      : AppColors.primaryDark)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// INSPECTION SECTION — allow admin to join any chat/class
// ══════════════════════════════════════════════════════════════════════════════
class _InspectionSection extends StatelessWidget {
  final CommunityService svc;
  const _InspectionSection({required this.svc});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: svc.watchAllConversations(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.gold));
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No conversations found.', style: TextStyle(fontFamily: 'Cairo')));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final docId = docs[i].id;
            final isClass = docId.startsWith('class_');
            final isDm    = docId.startsWith('dm_');
            
            String title = docId;
            if (isClass) title = 'Class Chat: ${docId.replaceFirst('class_', '')}';
            if (isDm)    title = 'Direct Message: ${docId.replaceFirst('dm_', '')}';

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: ListTile(
                leading: Icon(
                  isClass ? Icons.school : Icons.chat_bubble,
                  color: AppColors.primaryMid,
                ),
                title: Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right, size: 18),
                onTap: () {
                   // Navigate to a read-only or admin-access chat view
                   if (isDm) {
                     final parts = docId.replaceFirst('dm_', '').split('_');
                     Navigator.push(context, MaterialPageRoute(
                       builder: (_) => DmScreen(
                         otherUid: parts[1],
                         otherName: 'Conversation ${parts[0]} & ${parts[1]}',
                       ),
                     ));
                   }
                },
              ),
            );
          },
        );
      },
    );
  }
}