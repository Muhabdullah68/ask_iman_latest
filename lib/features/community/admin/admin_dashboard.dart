import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/charity/charity_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    final doc = await _firestore.collection('users').doc(user.uid).get();
    final role = doc.data()?['role'] as String?;
    setState(() {
      _isAdmin = role == 'admin';
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: AppColors.gold),
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
        bottom: _isAdmin
            ? TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: AppColors.gold,
                labelColor: AppColors.gold,
                unselectedLabelColor: AppColors.textGreenMuted,
                tabs: const [
                  Tab(text: 'Approvals'),
                  Tab(text: 'Charity'),
                  Tab(text: 'Classes'),
                  Tab(text: 'Groups'),
                  Tab(text: 'Users'),
                  Tab(text: 'Registrations'),
                ],
              )
            : null,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      );
    }
    if (!_isAdmin) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: AppColors.textGrey),
            const SizedBox(height: 16),
            Text(
              'Admin access required',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('Sign in with an admin account to continue.'),
          ],
        ),
      );
    }
    return TabBarView(
      controller: _tabController,
      children: [
        _ApprovalsTab(),
        _CharityTab(),
        _ClassesTab(),
        _FamilyGroupsTab(),
        _UsersTab(),
        _RegistrationsTab(),
      ],
    );
  }
}

// ── Approvals Tab ──────────────────────────────────────────────────────────────

class _ApprovalsTab extends StatefulWidget {
  @override
  State<_ApprovalsTab> createState() => _ApprovalsTabState();
}

class _ApprovalsTabState extends State<_ApprovalsTab>
    with SingleTickerProviderStateMixin {
  late TabController _subTabController;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.primaryDarkest,
          child: TabBar(
            controller: _subTabController,
            isScrollable: true,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.textGreenMuted,
            tabs: const [
              Tab(text: 'Users'),
              Tab(text: 'Classes'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: [_PendingUsersTab(), _PendingClassesTab()],
          ),
        ),
      ],
    );
  }
}

class _PendingUsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fs = FirebaseFirestore.instance;
    return StreamBuilder<QuerySnapshot>(
      stream: fs
          .collection('approvals')
          .where('status', isEqualTo: 'pending')
          .where('type', whereIn: ['student', 'teacher'])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          );
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 64, color: AppColors.success),
                SizedBox(height: 12),
                Text(
                  'No pending user approvals',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final d = docs[index].data() as Map<String, dynamic>;
            final docId = docs[index].id;
            final type = d['type'] ?? 'student';
            final title = d['title'] ?? 'Unknown';
            return Card(
              color: AppColors.bgWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: type == 'teacher'
                      ? AppColors.gold.withValues(alpha: 0.2)
                      : AppColors.success.withValues(alpha: 0.2),
                  child: Icon(
                    type == 'teacher' ? Icons.auto_stories : Icons.person,
                    color: type == 'teacher'
                        ? AppColors.gold
                        : AppColors.success,
                  ),
                ),
                title: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Role: ${type[0].toUpperCase()}${type.substring(1)}\nID: $docId',
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _iconBtn(Icons.check_circle, AppColors.success, () async {
                      await fs.collection('users').doc(docId).update({
                        'isApproved': true,
                      });
                      await fs.collection('approvals').doc(docId).update({
                        'status': 'approved',
                      });
                      _snack(context, 'Approved: $title');
                    }, 'Approve'),
                    const SizedBox(width: 4),
                    _iconBtn(Icons.cancel, AppColors.error, () async {
                      await fs.collection('approvals').doc(docId).update({
                        'status': 'rejected',
                      });
                      _snack(context, 'Rejected: $title');
                    }, 'Reject'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PendingClassesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fs = FirebaseFirestore.instance;
    return StreamBuilder<QuerySnapshot>(
      stream: fs
          .collection('approvals')
          .where('status', isEqualTo: 'pending')
          .where('type', isEqualTo: 'class')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          );
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 64, color: AppColors.success),
                SizedBox(height: 12),
                Text(
                  'No pending class approvals',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final d = docs[index].data() as Map<String, dynamic>;
            final docId = docs[index].id;
            final title = d['title'] ?? 'Unknown';
            final refId = d['refId'] ?? '';
            return Card(
              color: AppColors.bgWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.gold.withValues(alpha: 0.2),
                  child: const Icon(Icons.class_, color: AppColors.gold),
                ),
                title: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('Class approval\nID: $docId'),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _iconBtn(Icons.check_circle, AppColors.success, () async {
                      await fs.collection('classes').doc(refId).update({
                        'status': 'active',
                      });
                      await fs.collection('approvals').doc(docId).update({
                        'status': 'approved',
                      });
                      _snack(context, 'Approved: $title');
                    }, 'Approve'),
                    const SizedBox(width: 4),
                    _iconBtn(Icons.cancel, AppColors.error, () async {
                      await fs.collection('classes').doc(refId).update({
                        'status': 'rejected',
                      });
                      await fs.collection('approvals').doc(docId).update({
                        'status': 'rejected',
                      });
                      _snack(context, 'Rejected: $title');
                    }, 'Reject'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Charity Tab (3 sub-tabs) ──────────────────────────────────────────────────

class _CharityTab extends StatefulWidget {
  @override
  State<_CharityTab> createState() => _CharityTabState();
}

class _CharityTabState extends State<_CharityTab>
    with SingleTickerProviderStateMixin {
  late TabController _subTabController;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.primaryDarkest,
          child: TabBar(
            controller: _subTabController,
            isScrollable: true,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.textGreenMuted,
            tabs: const [
              Tab(text: 'Active Campaigns'),
              Tab(text: 'Donations'),
              Tab(text: 'Requests'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: [_CausesTab(), _DonationsTab(), _RequestsTab()],
          ),
        ),
      ],
    );
  }
}

// ── Donations Tab ─────────────────────────────────────────────────────────────

class _DonationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final charity = CharityService.instance;
    return StreamBuilder<QuerySnapshot>(
      stream: charity.watchAllDonations(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          );
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No donations yet.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton.icon(
                  onPressed: () => _showAddDonationDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Donation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: AppColors.gold,
                  ),
                ),
              );
            }
            final d = docs[index - 1].data() as Map<String, dynamic>;
            final docId = docs[index - 1].id;
            final amount = (d['amount'] ?? 0).toDouble();
            final status = d['status'] ?? 'pending';
            return Card(
              color: AppColors.bgWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.borderLight),
              ),
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primaryDark.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(
                            (d['userName'] as String? ?? 'A')[0].toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d['userName'] ?? 'Anonymous',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                '\$${amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: AppColors.textGreenMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (d['anonymous'] == true)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.textGrey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Anonymous',
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: status == 'completed'
                                ? AppColors.success.withValues(alpha: 0.12)
                                : AppColors.warning.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: status == 'completed'
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Cause: ${d['causeId'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _iconBtn(Icons.copy, AppColors.textGrey, () {
                          Clipboard.setData(ClipboardData(text: docId));
                          _snack(context, 'Copied: $docId');
                        }, 'Copy ID'),
                        _iconBtn(
                          Icons.visibility,
                          AppColors.primaryMid,
                          () => _showDonationDetail(context, d, docId),
                          'View',
                        ),
                        _iconBtn(
                          Icons.delete,
                          AppColors.error,
                          () => _confirmDelete(context, 'donation', docId),
                          'Delete',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDonationDetail(
    BuildContext context,
    Map<String, dynamic> d,
    String docId,
  ) {
    final amount = (d['amount'] ?? 0).toDouble();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Donation Detail',
                style: const TextStyle(color: AppColors.primaryDarkest),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: docId));
                _snack(context, 'Copied: $docId');
              },
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Donor', d['userName'] ?? 'Anonymous'),
              _detailRow('Amount', '\$${amount.toStringAsFixed(2)}'),
              _detailRow('Cause ID', d['causeId'] ?? 'N/A'),
              _detailRow('Status', d['status'] ?? 'pending'),
              _detailRow('Anonymous', d['anonymous'] == true ? 'Yes' : 'No'),
              _detailRow('User ID', d['userId'] ?? 'N/A'),
              if (d['message'] != null && (d['message'] as String).isNotEmpty)
                _detailRow('Message', d['message']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddDonationDialog(BuildContext context) {
    final causeCtrl = TextEditingController();
    final userNameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    bool submitting = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setBS) => AlertDialog(
          backgroundColor: AppColors.bgCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Add Donation',
            style: TextStyle(color: AppColors.primaryDarkest),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(
                causeCtrl,
                'Cause ID',
                hint: 'charity cause document ID',
              ),
              _dialogField(userNameCtrl, 'User Name'),
              _dialogField(
                amountCtrl,
                'Amount',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx2),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
              ),
              onPressed: submitting
                  ? null
                  : () async {
                      final amount = double.tryParse(amountCtrl.text);
                      if (amount == null || amount <= 0) return;
                      setBS(() => submitting = true);
                      await FirebaseFirestore.instance
                          .collection('charity_donations')
                          .add({
                            'causeId': causeCtrl.text,
                            'userId':
                                FirebaseAuth.instance.currentUser?.uid ?? '',
                            'userName': userNameCtrl.text,
                            'amount': amount,
                            'anonymous': false,
                            'status': 'completed',
                            'createdAt': FieldValue.serverTimestamp(),
                          });
                      if (ctx2.mounted) {
                        Navigator.pop(ctx2);
                        _snack(context, 'Donation added');
                      }
                    },
              child: submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.gold,
                      ),
                    )
                  : const Text('Add', style: TextStyle(color: AppColors.gold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Causes Tab ────────────────────────────────────────────────────────────────

class _CausesTab extends StatelessWidget {
  static const _categories = [
    'Education',
    'Health',
    'Medical',
    'Food',
    'Water',
    'Relief',
    'Orphan',
    'Mosque',
    'General',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final charity = CharityService.instance;
    return StreamBuilder<QuerySnapshot>(
      stream: charity.watchAllCauses(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          );
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No causes yet.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton.icon(
                  onPressed: () => _showAddCauseDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Campaign'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: AppColors.gold,
                  ),
                ),
              );
            }
            final d = docs[index - 1].data() as Map<String, dynamic>;
            final docId = docs[index - 1].id;
            final status = d['status'] as String? ?? 'pending';
            final isActive = status == 'active';
            final raised = (d['raised'] ?? 0).toDouble();
            final goal = (d['goal'] ?? 0).toDouble();
            final progress = goal > 0 ? (raised / goal).clamp(0.0, 1.0) : 0.0;

            Color statusColor;
            switch (status) {
              case 'active':
                statusColor = AppColors.success;
                break;
              case 'stopped':
                statusColor = AppColors.warning;
                break;
              case 'rejected':
                statusColor = AppColors.error;
                break;
              default:
                statusColor = AppColors.textGrey;
            }

            return Card(
              color: AppColors.bgWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: AppColors.borderLight),
              ),
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            d['category'] ?? '',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (d['verified'] == true)
                          const Icon(
                            Icons.verified,
                            color: AppColors.gold,
                            size: 16,
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      d['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (d['orgName'] != null &&
                        (d['orgName'] as String).isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        d['orgName'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryMid,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (d['description'] != null &&
                        (d['description'] as String).isNotEmpty)
                      Text(
                        d['description'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.primaryDarkest.withValues(
                          alpha: 0.1,
                        ),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.gold,
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '\$$raised raised',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textGreenMuted,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(progress * 100).round()}% of \$${goal.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                    if (d['bankDetails'] != null &&
                        (d['bankDetails'] as String).isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.account_balance,
                            size: 12,
                            color: AppColors.textGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            d['bankDetails'],
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _iconBtn(
                          Icons.visibility,
                          AppColors.primaryMid,
                          () => _showCampaignDetail(context, d, docId),
                          'View',
                        ),
                        _iconBtn(
                          Icons.edit,
                          AppColors.gold,
                          () => _showEditCampaignDialog(context, d, docId),
                          'Edit',
                        ),
                        _iconBtn(
                          isActive ? Icons.pause_circle : Icons.play_circle,
                          isActive ? AppColors.warning : AppColors.success,
                          () async {
                            await FirebaseFirestore.instance
                                .collection('charity_causes')
                                .doc(docId)
                                .update({
                                  'status': isActive ? 'stopped' : 'active',
                                });
                          },
                          isActive ? 'Stop' : 'Activate',
                        ),
                        _iconBtn(Icons.copy, AppColors.textGrey, () {
                          Clipboard.setData(ClipboardData(text: docId));
                          _snack(context, 'Copied: $docId');
                        }, 'Copy ID'),
                        _iconBtn(
                          Icons.delete,
                          AppColors.error,
                          () => _confirmDelete(context, 'cause', docId),
                          'Delete',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCampaignDetail(
    BuildContext context,
    Map<String, dynamic> d,
    String docId,
  ) {
    final raised = (d['raised'] ?? 0).toDouble();
    final goal = (d['goal'] ?? 0).toDouble();
    final progress = goal > 0 ? (raised / goal).clamp(0.0, 1.0) : 0.0;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Expanded(
              child: Text(
                d['title'] ?? '',
                style: const TextStyle(color: AppColors.primaryDarkest),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: docId));
                _snack(context, 'Copied: $docId');
              },
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Status', d['status'] ?? ''),
              _detailRow('Category', d['category'] ?? ''),
              _detailRow('Organization', d['orgName'] ?? 'N/A'),
              _detailRow('Goal', '\$${goal.toStringAsFixed(0)}'),
              _detailRow('Raised', '\$${raised.toStringAsFixed(0)}'),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.primaryDarkest.withValues(
                    alpha: 0.1,
                  ),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.gold,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(progress * 100).round()}% funded',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textGreenMuted,
                ),
              ),
              const SizedBox(height: 12),
              _detailRow('Verified', d['verified'] == true ? 'Yes' : 'No'),
              _detailRow('Bank Details', d['bankDetails'] ?? 'N/A'),
              _detailRow('Created By', d['createdBy'] ?? 'N/A'),
              const SizedBox(height: 8),
              const Text(
                'Description:',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                d['description'] ?? 'No description',
                style: const TextStyle(fontSize: 12, color: AppColors.textDark),
              ),
              if (d['imageUrl'] != null &&
                  (d['imageUrl'] as String).isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Image:',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    d['imageUrl'],
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditCampaignDialog(
    BuildContext context,
    Map<String, dynamic> d,
    String docId,
  ) {
    final titleCtrl = TextEditingController(text: d['title'] ?? '');
    final descCtrl = TextEditingController(text: d['description'] ?? '');
    final goalCtrl = TextEditingController(text: (d['goal'] ?? 0).toString());
    final raisedCtrl = TextEditingController(
      text: (d['raised'] ?? 0).toString(),
    );
    final orgCtrl = TextEditingController(text: d['orgName'] ?? '');
    final bankCtrl = TextEditingController(text: d['bankDetails'] ?? '');
    String category = d['category'] ?? 'General';
    bool verified = d['verified'] ?? false;
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setBS) => AlertDialog(
          backgroundColor: AppColors.bgCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Edit Campaign',
            style: TextStyle(color: AppColors.primaryDarkest),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(titleCtrl, 'Title', hint: 'Campaign title'),
                const SizedBox(height: 8),
                _dialogField(
                  descCtrl,
                  'Description',
                  maxLines: 3,
                  hint: 'Describe the campaign',
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: _inputDec('Category'),
                  items: _categories
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(
                            c,
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setBS(() => category = v!),
                ),
                const SizedBox(height: 8),
                _dialogField(
                  goalCtrl,
                  'Goal Amount',
                  keyboardType: TextInputType.number,
                  hint: '0',
                ),
                const SizedBox(height: 8),
                _dialogField(
                  raisedCtrl,
                  'Raised Amount',
                  keyboardType: TextInputType.number,
                  hint: '0',
                ),
                const SizedBox(height: 8),
                _dialogField(
                  orgCtrl,
                  'Organization',
                  hint: 'Organization name',
                ),
                const SizedBox(height: 8),
                _dialogField(bankCtrl, 'Bank Details', hint: 'Account info'),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text(
                    'Verified',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                  ),
                  value: verified,
                  activeColor: AppColors.primaryDark,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (v) => setBS(() => verified = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx2),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
              ),
              onPressed: submitting
                  ? null
                  : () async {
                      final goal = double.tryParse(goalCtrl.text);
                      final raised = double.tryParse(raisedCtrl.text);
                      if (goal == null || goal <= 0) return;
                      setBS(() => submitting = true);
                      await FirebaseFirestore.instance
                          .collection('charity_causes')
                          .doc(docId)
                          .update({
                            'title': titleCtrl.text,
                            'description': descCtrl.text,
                            'category': category,
                            'goal': goal,
                            'raised': raised ?? 0.0,
                            'orgName': orgCtrl.text,
                            'bankDetails': bankCtrl.text,
                            'verified': verified,
                          });
                      if (ctx2.mounted) {
                        Navigator.pop(ctx2);
                        _snack(context, 'Campaign updated');
                      }
                    },
              child: submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.gold,
                      ),
                    )
                  : const Text('Save', style: TextStyle(color: AppColors.gold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCauseDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final goalCtrl = TextEditingController();
    final orgCtrl = TextEditingController();
    final bankCtrl = TextEditingController();
    String category = 'General';
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setBS) => AlertDialog(
          backgroundColor: AppColors.bgCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Add Campaign',
            style: TextStyle(color: AppColors.primaryDarkest),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(titleCtrl, 'Title', hint: 'Campaign title'),
                const SizedBox(height: 8),
                _dialogField(
                  descCtrl,
                  'Description',
                  maxLines: 3,
                  hint: 'Describe the campaign',
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: _inputDec('Category'),
                  items: _categories
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(
                            c,
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setBS(() => category = v!),
                ),
                const SizedBox(height: 8),
                _dialogField(
                  goalCtrl,
                  'Goal Amount',
                  keyboardType: TextInputType.number,
                  hint: '0',
                ),
                const SizedBox(height: 8),
                _dialogField(
                  orgCtrl,
                  'Organization',
                  hint: 'Organization name',
                ),
                const SizedBox(height: 8),
                _dialogField(
                  bankCtrl,
                  'Bank Details',
                  hint: 'Account info',
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx2),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
              ),
              onPressed: submitting
                  ? null
                  : () async {
                      final goal = double.tryParse(goalCtrl.text);
                      if (goal == null || goal <= 0) return;
                      setBS(() => submitting = true);
                      await FirebaseFirestore.instance
                          .collection('charity_causes')
                          .add({
                            'title': titleCtrl.text,
                            'description': descCtrl.text,
                            'category': category,
                            'goal': goal,
                            'raised': 0.0,
                            'status': 'active',
                            'verified': true,
                            'createdBy':
                                FirebaseAuth.instance.currentUser?.uid ?? '',
                            'orgName': orgCtrl.text,
                            'bankDetails': bankCtrl.text,
                            'createdAt': FieldValue.serverTimestamp(),
                          });
                      if (ctx2.mounted) {
                        Navigator.pop(ctx2);
                        _snack(context, 'Campaign created');
                      }
                    },
              child: submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.gold,
                      ),
                    )
                  : const Text('Add', style: TextStyle(color: AppColors.gold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Requests Tab ──────────────────────────────────────────────────────────────

class _RequestsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final charity = CharityService.instance;
    return StreamBuilder<QuerySnapshot>(
      stream: charity.watchAllRequests(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          );
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No requests yet.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final d = docs[index].data() as Map<String, dynamic>;
            final docId = docs[index].id;
            final status = d['status'] as String? ?? 'active';
            final proofCount = (d['proofImages'] as List?)?.length ?? 0;

            Color statusColor;
            IconData statusIcon;
            switch (status) {
              case 'approved':
                statusColor = AppColors.success;
                statusIcon = Icons.check_circle;
                break;
              case 'rejected':
                statusColor = AppColors.error;
                statusIcon = Icons.cancel;
                break;
              default:
                statusColor = AppColors.warning;
                statusIcon = Icons.pending;
            }

            return Card(
              color: AppColors.bgWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.borderLight),
              ),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(statusIcon, color: statusColor, size: 28),
                title: Text(
                  d['title'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'By: ${d['firstName'] ?? d['userName'] ?? 'Unknown'}\n'
                  'Category: ${d['category'] ?? 'N/A'} | \$'
                  '${(d['amountNeeded'] ?? 0).toDouble().toStringAsFixed(0)}\n'
                  'Status: $status | $proofCount images',
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _iconBtn(Icons.visibility, AppColors.primaryMid, () {
                      _showRequestDetail(context, d, docId);
                    }, 'View Details'),
                    if (status == 'active') ...[
                      _iconBtn(Icons.check_circle, AppColors.success, () async {
                        await CharityService.instance.approveRequest(docId);
                        if (context.mounted)
                          _snack(
                            context,
                            'Request approved → campaign created',
                          );
                      }, 'Approve'),
                      _iconBtn(Icons.cancel, AppColors.error, () async {
                        await CharityService.instance.rejectRequest(docId);
                        if (context.mounted)
                          _snack(context, 'Request rejected');
                      }, 'Reject'),
                    ],
                    _iconBtn(Icons.copy, AppColors.textGrey, () {
                      Clipboard.setData(ClipboardData(text: docId));
                      _snack(context, 'Copied: $docId');
                    }, 'Copy ID'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showRequestDetail(
    BuildContext context,
    Map<String, dynamic> d,
    String docId,
  ) {
    final proofImages = List<String>.from(d['proofImages'] ?? []);
    final documents = List<String>.from(d['documents'] ?? []);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Expanded(
              child: Text(
                d['title'] ?? '',
                style: const TextStyle(color: AppColors.primaryDarkest),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: docId));
                _snack(context, 'Copied: $docId');
              },
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow(
                'Name',
                '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}',
              ),
              _detailRow('Father Name', d['fatherName'] ?? ''),
              _detailRow('Address', d['address'] ?? ''),
              _detailRow('Category', d['category'] ?? 'N/A'),
              _detailRow(
                'Amount Needed',
                '\$${(d['amountNeeded'] ?? 0).toDouble().toStringAsFixed(0)}',
              ),
              _detailRow(
                'Amount Received',
                '\$${(d['amountReceived'] ?? 0).toDouble().toStringAsFixed(0)}',
              ),
              _detailRow('Contact', d['contactInfo'] ?? 'N/A'),
              _detailRow('Email', d['email'] ?? 'N/A'),
              _detailRow('Account Details', d['accountDetails'] ?? 'N/A'),
              _detailRow('Description', d['description'] ?? ''),
              if (d['cnicFrontUrl'] != null &&
                  (d['cnicFrontUrl'] as String).isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'CNIC Front:',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    d['cnicFrontUrl'],
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 120,
                      color: Colors.grey[200],
                      child: const Center(child: Text('Base64 Image')),
                    ),
                  ),
                ),
              ],
              if (d['cnicBackUrl'] != null &&
                  (d['cnicBackUrl'] as String).isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'CNIC Back:',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    d['cnicBackUrl'],
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 120,
                      color: Colors.grey[200],
                      child: const Center(child: Text('Base64 Image')),
                    ),
                  ),
                ),
              ],
              if (proofImages.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Proof Images (${proofImages.length}):',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: proofImages.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        proofImages[i],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[200],
                          child: const Center(child: Text('Base64 Image')),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              if (documents.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Documents:',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.primaryDark,
                  ),
                ),
                ...documents.map(
                  (url) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      url,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// ── Family Groups Tab ─────────────────────────────────────────────────────────

class _FamilyGroupsTab extends StatefulWidget {
  @override
  State<_FamilyGroupsTab> createState() => _FamilyGroupsTabState();
}

class _FamilyGroupsTabState extends State<_FamilyGroupsTab> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgCream,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search by name, ID, or member...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.bgWhite,
              ),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('family_groups')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  );
                }

                var docs = snapshot.data!.docs;
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((doc) {
                    final d = doc.data() as Map<String, dynamic>;
                    final name = (d['name'] as String? ?? '').toLowerCase();
                    final members = List<String>.from(
                      d['memberIds'] ?? [],
                    ).join(', ');
                    final memberNames = List<String>.from(
                      d['memberNames'] ?? [],
                    ).join(', ');
                    final code = (d['inviteCode'] as String? ?? '')
                        .toLowerCase();
                    return name.contains(_searchQuery) ||
                        doc.id.contains(_searchQuery) ||
                        members.contains(_searchQuery) ||
                        memberNames.contains(_searchQuery) ||
                        code.contains(_searchQuery);
                  }).toList();
                }

                if (docs.isEmpty) {
                  return const Center(child: Text('No groups found.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddGroupDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Family Group'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                            foregroundColor: AppColors.gold,
                          ),
                        ),
                      );
                    }
                    final d = docs[index - 1].data() as Map<String, dynamic>;
                    final docId = docs[index - 1].id;
                    final members = List<String>.from(d['memberIds'] ?? []);
                    final memberNames = List<String>.from(
                      d['memberNames'] ?? [],
                    );
                    return Card(
                      color: AppColors.bgWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppColors.borderLight),
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExpansionTile(
                        title: Text(
                          d['name'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Members: ${members.length} | Code: ${d['inviteCode'] ?? 'N/A'}',
                        ),
                        leading: _iconBtn(Icons.copy, AppColors.textGrey, () {
                          Clipboard.setData(ClipboardData(text: docId));
                          _snack(context, 'Copied: $docId');
                        }, 'Copy Group ID'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _iconBtn(
                              Icons.edit,
                              AppColors.gold,
                              () => _showEditGroupDialog(context, d, docId),
                              'Edit',
                            ),
                            _iconBtn(
                              Icons.delete,
                              AppColors.error,
                              () => _confirmDelete(
                                context,
                                'family_group',
                                docId,
                              ),
                              'Delete',
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Group ID: $docId',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...List.generate(members.length, (i) {
                                  final memberName = i < memberNames.length
                                      ? memberNames[i]
                                      : 'User ${members[i].substring(0, 6)}';
                                  return ListTile(
                                    dense: true,
                                    leading: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AppColors.primaryDark,
                                      child: Text(
                                        memberName.isNotEmpty
                                            ? memberName[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.gold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      memberName,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    subtitle: Text(
                                      members[i],
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _iconBtn(
                                          Icons.copy,
                                          AppColors.textGrey,
                                          () {
                                            Clipboard.setData(
                                              ClipboardData(text: members[i]),
                                            );
                                            _snack(
                                              context,
                                              'Copied UID: ${members[i]}',
                                            );
                                          },
                                          'Copy User ID',
                                        ),
                                        _iconBtn(
                                          Icons.block,
                                          AppColors.error,
                                          () async {
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(members[i])
                                                .update({'isBlocked': true});
                                            if (context.mounted) {
                                              _snack(
                                                context,
                                                'Blocked user: ${members[i].substring(0, 8)}...',
                                              );
                                            }
                                          },
                                          'Block User',
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddGroupDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add Family Group',
          style: TextStyle(color: AppColors.primaryDarkest),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(nameCtrl, 'Group Name'),
            _dialogField(descCtrl, 'Description'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
            ),
            onPressed: () async {
              final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
              final userDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .get();
              final userName = (userDoc.data()?['name'] as String?) ?? 'Admin';
              final code = List.generate(
                6,
                (_) =>
                    'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'[DateTime.now()
                            .microsecondsSinceEpoch %
                        36],
              ).join();
              await FirebaseFirestore.instance.collection('family_groups').add({
                'name': nameCtrl.text,
                'description': descCtrl.text,
                'creatorId': uid,
                'creatorName': userName,
                'memberIds': [uid],
                'memberNames': [userName],
                'inviteCode': code,
                'createdAt': FieldValue.serverTimestamp(),
              });
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add', style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }

  void _showEditGroupDialog(
    BuildContext context,
    Map<String, dynamic> d,
    String docId,
  ) {
    final nameCtrl = TextEditingController(text: d['name'] ?? '');
    final descCtrl = TextEditingController(text: d['description'] ?? '');
    bool submitting = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setBS) => AlertDialog(
          backgroundColor: AppColors.bgCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Edit Family Group',
            style: TextStyle(color: AppColors.primaryDarkest),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(nameCtrl, 'Group Name'),
              const SizedBox(height: 8),
              _dialogField(descCtrl, 'Description', maxLines: 2),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx2),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
              ),
              onPressed: submitting
                  ? null
                  : () async {
                      setBS(() => submitting = true);
                      await FirebaseFirestore.instance
                          .collection('family_groups')
                          .doc(docId)
                          .update({
                            'name': nameCtrl.text,
                            'description': descCtrl.text,
                          });
                      if (ctx2.mounted) {
                        Navigator.pop(ctx2);
                        _snack(context, 'Group updated');
                      }
                    },
              child: submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.gold,
                      ),
                    )
                  : const Text('Save', style: TextStyle(color: AppColors.gold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Classes Tab (Full Management) ──────────────────────────────────────────────

class _ClassesTab extends StatefulWidget {
  @override
  State<_ClassesTab> createState() => _ClassesTabState();
}

class _ClassesTabState extends State<_ClassesTab> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final fs = FirebaseFirestore.instance;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Active', 'Pending', 'Rejected', 'Stopped']
                  .map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          f,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _filter == f
                                ? AppColors.primaryDarkest
                                : AppColors.textGrey,
                          ),
                        ),
                        selected: _filter == f,
                        selectedColor: AppColors.gold,
                        backgroundColor: AppColors.primaryDarkest,
                        onSelected: (_) => setState(() => _filter = f),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: fs
                .collection('classes')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return Center(child: Text('Error: ${snapshot.error}'));
              if (!snapshot.hasData)
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                );

              var docs = snapshot.data!.docs;
              if (_filter != 'All') {
                docs = docs.where((d) {
                  final s =
                      (d.data() as Map<String, dynamic>)['status'] as String? ??
                      'pending';
                  return s == _filter.toLowerCase();
                }).toList();
              }

              if (docs.isEmpty)
                return const Center(child: Text('No classes found.'));

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final d = docs[index].data() as Map<String, dynamic>;
                  final docId = docs[index].id;
                  final status = d['status'] as String? ?? 'pending';
                  final studentIds = List<String>.from(d['studentIds'] ?? []);
                  final enrolledCount = studentIds
                      .where((id) => id.isNotEmpty)
                      .length;

                  Color statusColor;
                  switch (status) {
                    case 'active':
                      statusColor = AppColors.success;
                      break;
                    case 'pending':
                      statusColor = AppColors.warning;
                      break;
                    case 'rejected':
                      statusColor = AppColors.error;
                      break;
                    default:
                      statusColor = AppColors.textGrey;
                  }

                  return Card(
                    color: AppColors.bgWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: AppColors.borderLight),
                    ),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (d['category'] != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    d['category'],
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.gold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            d['title'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.person,
                                size: 14,
                                color: AppColors.textGrey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                d['teacherName'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primaryMid,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.people,
                                size: 14,
                                color: AppColors.textGrey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$enrolledCount enrolled',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ],
                          ),
                          if (d['description'] != null &&
                              (d['description'] as String).isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              d['description'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _iconBtn(
                                Icons.visibility,
                                AppColors.primaryMid,
                                () => _showClassDetail(context, d, docId),
                                'View',
                              ),
                              _iconBtn(
                                Icons.edit,
                                AppColors.gold,
                                () => _showEditClassDialog(context, d, docId),
                                'Edit',
                              ),
                              if (status == 'pending')
                                _iconBtn(
                                  Icons.check_circle,
                                  AppColors.success,
                                  () async {
                                    await fs
                                        .collection('classes')
                                        .doc(docId)
                                        .update({'status': 'active'});
                                  },
                                  'Approve',
                                ),
                              if (status == 'active' || status == 'pending')
                                _iconBtn(
                                  Icons.cancel,
                                  AppColors.error,
                                  () async {
                                    await fs
                                        .collection('classes')
                                        .doc(docId)
                                        .update({'status': 'rejected'});
                                  },
                                  'Reject',
                                ),
                              if (status != 'stopped')
                                _iconBtn(
                                  Icons.pause_circle,
                                  AppColors.warning,
                                  () async {
                                    await fs
                                        .collection('classes')
                                        .doc(docId)
                                        .update({'status': 'stopped'});
                                  },
                                  'Stop',
                                ),
                              _iconBtn(Icons.copy, AppColors.textGrey, () {
                                Clipboard.setData(ClipboardData(text: docId));
                                _snack(context, 'Copied: $docId');
                              }, 'Copy ID'),
                              _iconBtn(
                                Icons.delete,
                                AppColors.error,
                                () => _confirmDelete(context, 'class', docId),
                                'Delete',
                              ),
                            ],
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
      ],
    );
  }

  void _showClassDetail(
    BuildContext context,
    Map<String, dynamic> d,
    String docId,
  ) {
    final studentIds = List<String>.from(d['studentIds'] ?? []);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Expanded(
              child: Text(
                d['title'] ?? '',
                style: const TextStyle(color: AppColors.primaryDarkest),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: docId));
                _snack(context, 'Copied: $docId');
              },
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Status', d['status'] ?? ''),
              _detailRow('Category', d['category'] ?? 'N/A'),
              _detailRow('Teacher', d['teacherName'] ?? 'Unknown'),
              _detailRow(
                'Students',
                '${studentIds.where((id) => id.isNotEmpty).length}',
              ),
              _detailRow('Duration', '${d['durationMinutes'] ?? 60} min'),
              _detailRow('Video URL', d['videoUrl'] ?? 'N/A'),
              if (d['meetUrl'] != null)
                _detailRow('Meeting Link', d['meetUrl']),
              const SizedBox(height: 8),
              const Text(
                'Description:',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                d['description'] ?? 'No description',
                style: const TextStyle(fontSize: 12, color: AppColors.textDark),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditClassDialog(
    BuildContext context,
    Map<String, dynamic> d,
    String docId,
  ) {
    final titleCtrl = TextEditingController(text: d['title'] ?? '');
    final descCtrl = TextEditingController(text: d['description'] ?? '');
    final videoCtrl = TextEditingController(text: d['videoUrl'] ?? '');
    final durationCtrl = TextEditingController(
      text: '${d['durationMinutes'] ?? 60}',
    );
    String category = d['category'] ?? 'Quran';
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setBS) => AlertDialog(
          backgroundColor: AppColors.bgCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Edit Class',
            style: TextStyle(color: AppColors.primaryDarkest),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(titleCtrl, 'Title', hint: 'Class title'),
                const SizedBox(height: 8),
                _dialogField(
                  descCtrl,
                  'Description',
                  maxLines: 3,
                  hint: 'Class description',
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: _inputDec('Category'),
                  items:
                      [
                            'Quran',
                            'Fiqh',
                            'Seerah',
                            'Tajweed',
                            'Arabic',
                            'Hadith',
                            'Aqeedah',
                          ]
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                c,
                                style: const TextStyle(fontFamily: 'Cairo'),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => setBS(() => category = v!),
                ),
                const SizedBox(height: 8),
                _dialogField(
                  videoCtrl,
                  'Video/Meeting Link',
                  hint: 'Zoom / Google Meet URL',
                ),
                const SizedBox(height: 8),
                _dialogField(
                  durationCtrl,
                  'Duration (minutes)',
                  keyboardType: TextInputType.number,
                  hint: '60',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx2),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
              ),
              onPressed: submitting
                  ? null
                  : () async {
                      setBS(() => submitting = true);
                      await FirebaseFirestore.instance
                          .collection('classes')
                          .doc(docId)
                          .update({
                            'title': titleCtrl.text,
                            'description': descCtrl.text,
                            'category': category,
                            'videoUrl': videoCtrl.text,
                            'durationMinutes':
                                int.tryParse(durationCtrl.text) ?? 60,
                          });
                      if (ctx2.mounted) {
                        Navigator.pop(ctx2);
                        _snack(context, 'Class updated');
                      }
                    },
              child: submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.gold,
                      ),
                    )
                  : const Text('Save', style: TextStyle(color: AppColors.gold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Users Tab ─────────────────────────────────────────────────────────────────

class _UsersTab extends StatefulWidget {
  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgCream,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search by name, email, or UID...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.bgWhite,
              ),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  );
                }

                var docs = snapshot.data!.docs;
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((doc) {
                    final d = doc.data() as Map<String, dynamic>;
                    final name = (d['name'] as String? ?? '').toLowerCase();
                    final email = (d['email'] as String? ?? '').toLowerCase();
                    final role = (d['role'] as String? ?? '').toLowerCase();
                    return name.contains(_searchQuery) ||
                        email.contains(_searchQuery) ||
                        doc.id.contains(_searchQuery) ||
                        role.contains(_searchQuery);
                  }).toList();
                }

                if (docs.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final d = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;
                    final isBlocked = d['isBlocked'] == true;
                    return Card(
                      color: AppColors.bgWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppColors.borderLight),
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isBlocked
                              ? AppColors.error.withValues(alpha: 0.2)
                              : AppColors.success.withValues(alpha: 0.2),
                          child: Text(
                            (d['name'] as String?)?[0].toUpperCase() ?? '?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isBlocked
                                  ? AppColors.error
                                  : AppColors.success,
                            ),
                          ),
                        ),
                        title: Text(
                          d['name'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${d['email'] ?? ''}\n'
                          'Role: ${d['role'] ?? 'student'}'
                          '${isBlocked ? ' | BLOCKED' : ''}\n'
                          'ID: $docId',
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _iconBtn(
                              Icons.visibility,
                              AppColors.primaryMid,
                              () => _showUserDetail(context, d, docId),
                              'View',
                            ),
                            _iconBtn(Icons.copy, AppColors.textGrey, () {
                              Clipboard.setData(ClipboardData(text: docId));
                              _snack(context, 'Copied: $docId');
                            }, 'Copy User ID'),
                            _iconBtn(Icons.swap_horiz, AppColors.warning, () {
                              final currentRole = d['role'] ?? 'student';
                              final newRole = currentRole == 'teacher'
                                  ? 'student'
                                  : 'teacher';
                              _confirmRoleChange(
                                context,
                                docId,
                                newRole,
                                d['name'] ?? '',
                              );
                            }, 'Change Role'),
                            _iconBtn(
                              isBlocked ? Icons.lock_open : Icons.lock_outline,
                              isBlocked
                                  ? AppColors.warning
                                  : AppColors.textGrey,
                              () => _toggleBlock(context, docId, !isBlocked),
                              isBlocked ? 'Unblock' : 'Block',
                            ),
                            _iconBtn(
                              Icons.delete,
                              AppColors.error,
                              () => _confirmDelete(context, 'user', docId),
                              'Delete',
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
        ],
      ),
    );
  }

  void _showUserDetail(
    BuildContext context,
    Map<String, dynamic> d,
    String docId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Expanded(
              child: Text(
                d['name'] ?? '',
                style: const TextStyle(color: AppColors.primaryDarkest),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: docId));
                _snack(context, 'Copied: $docId');
              },
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Email', d['email'] ?? 'N/A'),
              _detailRow('Role', d['role'] ?? 'student'),
              _detailRow('Approved', d['isApproved'] == true ? 'Yes' : 'No'),
              _detailRow('Blocked', d['isBlocked'] == true ? 'Yes' : 'No'),
              _detailRow('Streak Count', '${d['streakCount'] ?? 0}'),
              _detailRow('Phone', d['phone'] ?? 'N/A'),
              _detailRow(
                'Family Groups',
                d['familyGroups'] != null
                    ? '${List<String>.from(d['familyGroups']).length} groups'
                    : 'None',
              ),
              if (d['bio'] != null && (d['bio'] as String).isNotEmpty)
                _detailRow('Bio', d['bio']),
              if (d['qualifications'] != null &&
                  (d['qualifications'] as String).isNotEmpty)
                _detailRow('Qualifications', d['qualifications']),
              if (d['subjects'] != null && (d['subjects'] as String).isNotEmpty)
                _detailRow('Subjects', d['subjects']),
              if (d['profileCreatedAt'] != null) ...[
                const SizedBox(height: 8),
                _detailRow(
                  'Profile Created',
                  (d['profileCreatedAt'] as Timestamp?)
                          ?.toDate()
                          .toLocal()
                          .toString()
                          .substring(0, 16) ??
                      '',
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRoleChange(
    BuildContext context,
    String uid,
    String newRole,
    String name,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Change Role',
          style: TextStyle(color: AppColors.primaryDarkest),
        ),
        content: Text(
          'Change $name to ${newRole[0].toUpperCase()}${newRole.substring(1)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Confirm',
              style: TextStyle(color: AppColors.bgWhite),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'role': newRole,
      });
      _snack(
        context,
        'Changed $name to ${newRole[0].toUpperCase()}${newRole.substring(1)}',
      );
    }
  }

  Future<void> _toggleBlock(
    BuildContext context,
    String uid,
    bool block,
  ) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'isBlocked': block,
    });
  }
}

// ── Registrations Tab (2 sub-tabs) ─────────────────────────────────────────────

class _RegistrationsTab extends StatefulWidget {
  @override
  State<_RegistrationsTab> createState() => _RegistrationsTabState();
}

class _RegistrationsTabState extends State<_RegistrationsTab>
    with SingleTickerProviderStateMixin {
  late TabController _subTabController;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.primaryDarkest,
          child: TabBar(
            controller: _subTabController,
            isScrollable: true,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.textGreenMuted,
            tabs: const [
              Tab(text: 'Enrollments'),
              Tab(text: 'Teacher Apps'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: [_EnrollmentsTab(), _TeacherApplicationsTab()],
          ),
        ),
      ],
    );
  }
}

// ── Enrollments Sub-Tab ────────────────────────────────────────────────────────

class _EnrollmentsTab extends StatefulWidget {
  @override
  State<_EnrollmentsTab> createState() => _EnrollmentsTabState();
}

class _EnrollmentsTabState extends State<_EnrollmentsTab> {
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterChips(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('enrollments')
                .snapshots(),
            builder: (ctx, snap) {
              if (snap.hasError) {
                return Center(child: Text('Error: ${snap.error}'));
              }
              if (!snap.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                );
              }
              var docs = snap.data!.docs;
              if (_statusFilter != 'all') {
                docs = docs.where((d) {
                  final status =
                      (d.data() as Map<String, dynamic>)['status'] as String?;
                  return status == _statusFilter;
                }).toList();
              }
              if (docs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 48, color: AppColors.textGrey),
                      SizedBox(height: 12),
                      Text(
                        'No enrollments found',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                itemBuilder: (_, i) => _EnrollmentCard(doc: docs[i]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = ['all', 'pending', 'approved', 'rejected'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: AppColors.bgWhite,
      child: Row(
        children: filters.map((f) {
          final active = _statusFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _statusFilter = f),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: active ? AppColors.gold : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  f == 'all' ? 'All' : f[0].toUpperCase() + f.substring(1),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active
                        ? AppColors.primaryDarkest
                        : AppColors.textGrey,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EnrollmentCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  const _EnrollmentCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final d = doc.data() as Map<String, dynamic>;
    final status = d['status'] as String? ?? 'pending';
    final name = '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}'.trim();
    final courses =
        (d['selectedCourses'] as List<dynamic>?)?.cast<String>() ?? [];

    Color statusColor;
    switch (status) {
      case 'approved':
        statusColor = AppColors.success;
      case 'rejected':
        statusColor = AppColors.error;
      default:
        statusColor = AppColors.warning;
    }

    return Card(
      color: AppColors.bgWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDarkest,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status[0].toUpperCase() + status.substring(1),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _infoRow(Icons.email_outlined, d['email'] ?? ''),
            _infoRow(Icons.phone_outlined, d['phone'] ?? ''),
            _infoRow(Icons.location_on_outlined, d['location'] ?? ''),
            const SizedBox(height: 6),
            const Text(
              'Courses',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: courses
                  .map(
                    (c) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        c,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            if (status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _iconBtn(
                    Icons.check_circle,
                    AppColors.success,
                    () => _approve(context),
                    'Approve',
                  ),
                  const SizedBox(width: 8),
                  _iconBtn(
                    Icons.cancel,
                    AppColors.error,
                    () => _reject(context),
                    'Reject',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textGrey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approve(BuildContext context) async {
    final fs = FirebaseFirestore.instance;
    await fs.collection('enrollments').doc(doc.id).update({
      'status': 'approved',
    });
    await fs.collection('users').doc(doc.id).update({'isApproved': true});
    _snack(context, 'Enrollment approved');
  }

  Future<void> _reject(BuildContext context) async {
    final fs = FirebaseFirestore.instance;
    await fs.collection('enrollments').doc(doc.id).update({
      'status': 'rejected',
    });
    _snack(context, 'Enrollment rejected');
  }
}

// ── Teacher Applications Sub-Tab ───────────────────────────────────────────────

class _TeacherApplicationsTab extends StatefulWidget {
  @override
  State<_TeacherApplicationsTab> createState() =>
      _TeacherApplicationsTabState();
}

class _TeacherApplicationsTabState extends State<_TeacherApplicationsTab> {
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterChips(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('teacher_applications')
                .snapshots(),
            builder: (ctx, snap) {
              if (snap.hasError) {
                return Center(child: Text('Error: ${snap.error}'));
              }
              if (!snap.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                );
              }
              var docs = snap.data!.docs;
              if (_statusFilter != 'all') {
                docs = docs.where((d) {
                  final status =
                      (d.data() as Map<String, dynamic>)['status'] as String?;
                  return status == _statusFilter;
                }).toList();
              }
              if (docs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 48, color: AppColors.textGrey),
                      SizedBox(height: 12),
                      Text(
                        'No teacher applications found',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                itemBuilder: (_, i) => _TeacherAppCard(doc: docs[i]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = ['all', 'pending', 'approved', 'rejected'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: AppColors.bgWhite,
      child: Row(
        children: filters.map((f) {
          final active = _statusFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _statusFilter = f),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: active ? AppColors.gold : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  f == 'all' ? 'All' : f[0].toUpperCase() + f.substring(1),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active
                        ? AppColors.primaryDarkest
                        : AppColors.textGrey,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TeacherAppCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  const _TeacherAppCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final d = doc.data() as Map<String, dynamic>;
    final status = d['status'] as String? ?? 'pending';
    final name = '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}'.trim();
    final subjects = (d['subjects'] as List<dynamic>?)?.cast<String>() ?? [];
    final timings =
        (d['preferredTimings'] as List<dynamic>?)?.cast<String>() ?? [];
    final certs =
        (d['certifications'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
        [];

    Color statusColor;
    switch (status) {
      case 'approved':
        statusColor = AppColors.success;
      case 'rejected':
        statusColor = AppColors.error;
      default:
        statusColor = AppColors.warning;
    }

    return Card(
      color: AppColors.bgWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDarkest,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status[0].toUpperCase() + status.substring(1),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _infoRow(Icons.email_outlined, d['email'] ?? ''),
            _infoRow(Icons.phone_outlined, d['phone'] ?? ''),
            _infoRow(Icons.home_outlined, d['address'] ?? ''),
            _infoRow(Icons.badge_outlined, 'CNIC: ${d['cnicNumber'] ?? ''}'),
            _infoRow(
              Icons.work_outlined,
              'Experience: ${d['experience'] ?? ''}',
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildImageThumbnail(
                    context,
                    'CNIC Front',
                    d['cnicFrontUrl'] as String?,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildImageThumbnail(
                    context,
                    'CNIC Back',
                    d['cnicBackUrl'] as String?,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Subjects',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: subjects
                  .map(
                    (s) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        s,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            if (timings.isNotEmpty) ...[
              const SizedBox(height: 6),
              const Text(
                'Preferred Timing',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: timings
                    .map(
                      (t) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          t,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            if (certs.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Certifications',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 4),
              ...certs.map((cert) {
                final certName = cert['name'] as String? ?? 'Certificate';
                final certUrl = cert['url'] as String?;
                return GestureDetector(
                  onTap: certUrl != null
                      ? () => _showImageDialog(context, certName, certUrl)
                      : null,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.borderLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.description_outlined,
                          size: 14,
                          color: AppColors.primaryDark,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            certName,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.open_in_new,
                          size: 14,
                          color: AppColors.textGrey,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
            if (status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _iconBtn(
                    Icons.check_circle,
                    AppColors.success,
                    () => _approve(context),
                    'Approve',
                  ),
                  const SizedBox(width: 8),
                  _iconBtn(
                    Icons.cancel,
                    AppColors.error,
                    () => _reject(context),
                    'Reject',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textGrey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageThumbnail(BuildContext context, String label, String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.borderLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: AppColors.textGrey,
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () => _showImageDialog(context, label, url),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
          border: Border.all(color: AppColors.borderLight),
        ),
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(7),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String label, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(url, fit: BoxFit.contain),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approve(BuildContext context) async {
    final fs = FirebaseFirestore.instance;
    final batch = fs.batch();
    batch.update(fs.collection('teacher_applications').doc(doc.id), {
      'status': 'approved',
    });
    batch.update(fs.collection('users').doc(doc.id), {'isApproved': true});
    batch.update(fs.collection('approvals').doc(doc.id), {
      'status': 'approved',
    });
    await batch.commit();
    _snack(context, 'Teacher application approved');
  }

  Future<void> _reject(BuildContext context) async {
    final fs = FirebaseFirestore.instance;
    final batch = fs.batch();
    batch.update(fs.collection('teacher_applications').doc(doc.id), {
      'status': 'rejected',
    });
    batch.update(fs.collection('approvals').doc(doc.id), {
      'status': 'rejected',
    });
    await batch.commit();
    _snack(context, 'Teacher application rejected');
  }
}

// ── Shared Helpers ────────────────────────────────────────────────────────────

Widget _iconBtn(
  IconData icon,
  Color color,
  VoidCallback onPressed,
  String tooltip,
) {
  return IconButton(
    icon: Icon(icon, size: 18),
    color: color,
    onPressed: onPressed,
    tooltip: tooltip,
    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    padding: const EdgeInsets.all(4),
  );
}

Widget _detailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : 'N/A',
            style: const TextStyle(fontSize: 12, color: AppColors.textDark),
          ),
        ),
      ],
    ),
  );
}

InputDecoration _inputDec(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: AppColors.bgWhite,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.borderLight),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
}

void _snack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

Widget _dialogField(
  TextEditingController ctrl,
  String label, {
  int maxLines = 1,
  TextInputType? keyboardType,
  String? hint,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.bgWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    ),
  );
}

void _confirmDelete(BuildContext context, String type, String docId) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.bgCream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Confirm Delete',
        style: TextStyle(color: AppColors.primaryDarkest),
      ),
      content: Text('Are you sure you want to delete this $type?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () async {
            final collection = switch (type) {
              'donation' => 'charity_donations',
              'cause' => 'charity_causes',
              'request' => 'charity_requests',
              'family_group' => 'family_groups',
              'class' => 'classes',
              'user' => 'users',
              _ => '',
            };
            if (collection.isNotEmpty) {
              await FirebaseFirestore.instance
                  .collection(collection)
                  .doc(docId)
                  .delete();
            }
            if (ctx.mounted) Navigator.pop(ctx);
          },
          child: const Text(
            'Delete',
            style: TextStyle(color: AppColors.bgWhite),
          ),
        ),
      ],
    ),
  );
}
