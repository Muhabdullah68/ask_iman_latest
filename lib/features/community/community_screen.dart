import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/community_service.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/ask_iman_app_bar.dart';
import '../auth/sign_in_screen.dart';
import 'streaks/streaks_tab.dart';
import 'classes/classes_tab.dart';
import 'friends/family_and_friends_tab.dart';
import 'groups/groups_tab.dart';
import '../charity/charity_list_screen.dart';
import 'admin/admin_dashboard.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  final _svc = CommunityService.instance;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return _buildGuestView();

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: const AskImanAppBar(),
      body: StreamBuilder<AppUser?>(
        stream: _svc.watchCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildCommunityContent(snapshot.data!);
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            );
          }
          final authUser = FirebaseAuth.instance.currentUser;
          final fallback = AppUser(
            uid: authUser!.uid,
            name: authUser.email?.split('@').first ?? 'User',
            email: authUser.email ?? '',
            role: UserRole.student,
            isApproved: false,
          );
          return _buildCommunityContent(fallback);
        },
      ),
    );
  }

  Widget _buildGuestView() {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: const AskImanAppBar(),
      body: Column(
        children: [
          _buildGuestBanner(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline, size: 80, color: AppColors.gold),
                  const SizedBox(height: 16),
                  const Text(
                    'Community Hub',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDarkest,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Connect, learn, and grow together.',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: AppColors.textGrey,
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

  Widget _buildGuestBanner() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SignInScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: AppColors.gold,
        child: const Text(
          'Sign in to access all community features',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDarkest,
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityContent(AppUser user) {
    return Column(
      children: [
        _buildHeader(user),
        TabBar(
          controller: _tabController,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.textGrey,
          indicatorColor: AppColors.gold,
          tabs: const [
            Tab(text: 'Streaks'),
            Tab(text: 'Classes'),
            Tab(text: 'Family & Friends'),
            Tab(text: 'Groups'),
            Tab(text: 'Charity'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              StreaksTab(currentUser: user),
              ClassesTab(currentUser: user),
              FamilyAndFriendsTab(currentUser: user),
              GroupsTab(currentUser: user),
              const CharityListScreen(showScaffold: false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(AppUser user) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Community',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDarkest,
                  ),
                ),
                Text(
                  user.role == UserRole.teacher
                      ? 'Manage your classes and connect'
                      : 'Learn, connect, and grow together',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          if (user.role == UserRole.admin)
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminDashboard()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Admin',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
