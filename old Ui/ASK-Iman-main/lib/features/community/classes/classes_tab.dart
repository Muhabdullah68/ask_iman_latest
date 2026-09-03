// lib/features/community/classes/classes_tab.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/community_service.dart';
import '../enrollment/student_registration_screen.dart';
import '../enrollment/teacher_registration_screen.dart';

class ClassesTab extends StatelessWidget {
  final AppUser currentUser;
  const ClassesTab({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    if (currentUser.role == UserRole.teacher) {
      if (currentUser.isApproved) {
        return _TeacherClassesView(currentUser: currentUser);
      }
      return _TeacherPendingView(currentUser: currentUser);
    }
    return _StudentClassesView(currentUser: currentUser);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TEACHER PENDING VIEW (not yet approved by admin)
// ══════════════════════════════════════════════════════════════════════════════
class _TeacherPendingView extends StatelessWidget {
  final AppUser currentUser;
  const _TeacherPendingView({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final svc = CommunityService.instance;
    return StreamBuilder<Map<String, dynamic>?>(
      stream: svc.watchTeacherApplication(),
      builder: (context, snap) {
        final application = snap.data;

        if (application == null) {
          return _buildNotApplied(context);
        }

        final status = application['status'] as String?;
        if (status == 'pending') {
          return _buildPending();
        }
        if (status == 'rejected') {
          return _buildRejected(application);
        }

        return _TeacherClassesView(currentUser: currentUser);
      },
    );
  }

  Widget _buildNotApplied(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_stories,
                size: 40,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Not Registered Yet',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDarkest,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You need to complete your teacher application to access classes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TeacherRegistrationScreen(),
                ),
              ),
              icon: const Icon(
                Icons.edit_note,
                size: 20,
                color: AppColors.gold,
              ),
              label: const Text(
                'Apply Now',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPending() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_empty,
                size: 40,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Application Pending',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDarkest,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your teacher application is under review. You will get access once approved by the admin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejected(Map<String, dynamic> application) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cancel_outlined,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Application Rejected',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDarkest,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your teacher application was not approved. Please contact the admin for more information.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STUDENT VIEW
// ══════════════════════════════════════════════════════════════════════════════
class _StudentClassesView extends StatelessWidget {
  final AppUser currentUser;
  const _StudentClassesView({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final svc = CommunityService.instance;
    return StreamBuilder<Map<String, dynamic>?>(
      stream: svc.watchMyEnrollment(),
      builder: (context, enrollmentSnap) {
        final enrollment = enrollmentSnap.data;

        if (enrollment == null) {
          return _buildNoEnrollment(context);
        }

        final status = enrollment['status'] as String?;
        if (status == 'pending') {
          return _buildPendingEnrollment();
        }
        if (status == 'rejected') {
          return _buildRejectedEnrollment();
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEnrolledClasses(svc),
              _buildFeaturedTeachers(),
              _buildMasterySection(context, svc),
              _buildAvailableCourses(svc),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoEnrollment(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school_outlined,
                size: 40,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Not Enrolled Yet',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDarkest,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You need to register and be approved before accessing classes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const StudentRegistrationScreen(),
                ),
              ),
              icon: const Icon(
                Icons.edit_note,
                size: 20,
                color: AppColors.gold,
              ),
              label: const Text(
                'Register Now',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingEnrollment() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_empty,
                size: 40,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Application Pending',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDarkest,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your enrollment is being reviewed. You\'ll get access once approved.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectedEnrollment() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cancel_outlined,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Application Rejected',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDarkest,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your enrollment was not approved. Please contact the admin for more information.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrolledClasses(CommunityService svc) {
    return StreamBuilder<List<ClassModel>>(
      stream: svc.watchEnrolledClasses(),
      builder: (ctx, snap) {
        final enrolled = snap.data ?? [];
        if (enrolled.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'My Enrolled Classes',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${enrolled.length} ACTIVE',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...enrolled.map(
                (c) => _CourseRow(
                  cls: c,
                  isEnrolled: true,
                  onLeave: () async {
                    try {
                      await svc.leaveClass(c.id);
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text('Failed to leave: $e')),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturedTeachers() {
    // Live query: pull approved teachers from Firestore
    return StreamBuilder(
      stream: CommunityService.instance.watchApprovedTeachers(),
      builder: (ctx, snap) {
        final teachers = snap.data ?? <AppUser>[];
        if (teachers.isEmpty) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Featured Teachers',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'See All',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: teachers
                    .take(3)
                    .map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primaryDark,
                                    AppColors.primaryMid,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  t.name.trim().isEmpty
                                      ? '?'
                                      : t.name
                                            .trim()
                                            .split(' ')
                                            .take(2)
                                            .map((w) => w[0])
                                            .join()
                                            .toUpperCase(),
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.gold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              t.name.split(' ').first,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryDark.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Teacher',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 9,
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMasterySection(BuildContext context, CommunityService svc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Row(
            children: [
              const Text(
                'Mastery Classes',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              const Text(
                'EXPLORE',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<ClassModel>>(
          stream: svc.watchActiveClasses(),
          builder: (ctx, snap) {
            final classes = snap.data ?? [];
            if (classes.isEmpty) {
              return const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  'No classes available yet.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textGrey,
                  ),
                ),
              );
            }
            return SizedBox(
              height: 320,
              child: PageView.builder(
                padEnds: false,
                controller: PageController(viewportFraction: 0.92),
                itemCount: classes.length,
                itemBuilder: (_, i) => _ClassCard(
                  cls: classes[i],
                  isEnrolled: _isEnrolled(classes[i]),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAvailableCourses(CommunityService svc) {
    return StreamBuilder<List<ClassModel>>(
      stream: svc.watchActiveClasses(),
      builder: (ctx, snap) {
        final all = snap.data ?? [];
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Available Courses',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'See All',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (all.isEmpty)
                const Text(
                  'No courses available.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textGrey,
                  ),
                )
              else
                ...all
                    .take(10)
                    .map((c) => _CourseRow(cls: c, isEnrolled: _isEnrolled(c))),
            ],
          ),
        );
      },
    );
  }

  bool _isEnrolled(ClassModel c) =>
      c.studentIds.where((id) => id.isNotEmpty).contains(currentUser.uid);
}

// ══════════════════════════════════════════════════════════════════════════════
// TEACHER VIEW
// ══════════════════════════════════════════════════════════════════════════════
class _TeacherClassesView extends StatelessWidget {
  final AppUser currentUser;
  const _TeacherClassesView({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final svc = CommunityService.instance;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTeacherHero(context),
          _buildStatsRow(svc),
          _buildMyClasses(context, svc),
          _buildCommunityClasses(svc),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Hero banner ──────────────────────────────────────────────────────────

  Widget _buildTeacherHero(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDarkest, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    currentUser.name.trim().isEmpty
                        ? '?'
                        : currentUser.name
                              .trim()
                              .split(' ')
                              .take(2)
                              .map((w) => w[0])
                              .join()
                              .toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUser.name,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textWhite,
                      ),
                    ),
                    const Text(
                      'Teacher · Approved',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: AppColors.textGreenMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () => _showCreateClassSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline_rounded,
                    color: AppColors.primaryDarkest,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Create New Class',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDarkest,
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

  // ── Live stats row ───────────────────────────────────────────────────────

  Widget _buildStatsRow(CommunityService svc) {
    return StreamBuilder<List<ClassModel>>(
      stream: svc.watchMyClasses(),
      builder: (ctx, snap) {
        final all = snap.data ?? [];
        final active = all.where((c) => c.status == 'active').length;
        final pending = all.where((c) => c.status == 'pending').length;
        final enrolled = all.fold(
          0,
          (sum, c) => sum + c.studentIds.where((id) => id.isNotEmpty).length,
        );

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(
            children: [
              _statChip('$active', 'Active', AppColors.success),
              const SizedBox(width: 10),
              _statChip('$pending', 'Pending', AppColors.warning),
              const SizedBox(width: 10),
              _statChip('$enrolled', 'Students', AppColors.gold),
            ],
          ),
        );
      },
    );
  }

  Widget _statChip(String val, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              val,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── My Classes (live, all statuses) ─────────────────────────────────────

  Widget _buildMyClasses(BuildContext context, CommunityService svc) {
    return StreamBuilder<List<ClassModel>>(
      stream: svc.watchMyClasses(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            ),
          );
        }
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              'Error loading classes: ${snap.error}',
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.error,
              ),
            ),
          );
        }

        final classes = snap.data ?? [];

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'My Classes',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${classes.length}',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (classes.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.bgWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        color: AppColors.textLightGrey,
                        size: 40,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'No classes yet.',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tap "Create New Class" above to get started.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...classes.map(
                  (c) => _TeacherClassCard(
                    cls: c,
                    onScheduleMeeting: () =>
                        _showScheduleMeetingSheet(context, c),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ── Community classes (other teachers) ──────────────────────────────────

  Widget _buildCommunityClasses(CommunityService svc) {
    return StreamBuilder<List<ClassModel>>(
      stream: svc.watchActiveClasses(),
      builder: (ctx, snap) {
        final others = (snap.data ?? [])
            .where((c) => c.teacherId != currentUser.uid)
            .toList();
        if (others.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Community Classes',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              ...others
                  .take(5)
                  .map(
                    (c) => _CourseRow(
                      cls: c,
                      isEnrolled: c.studentIds
                          .where((id) => id.isNotEmpty)
                          .contains(currentUser.uid),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  // ── Create class bottom sheet ────────────────────────────────────────────

  void _showCreateClassSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final videoCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '60');
    final reasonCtrl = TextEditingController();
    String category = 'Quran';
    bool submitting = false;
    bool showReason = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setBS) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(ctx2).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Create New Class',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Submitted classes are reviewed by admin before going live.',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 16),
              _sheetField('Class Title', titleCtrl),
              const SizedBox(height: 10),
              _sheetField('Description', descCtrl, maxLines: 3),
              const SizedBox(height: 10),
              _sheetField('Video/Meeting Link', videoCtrl),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _sheetField(
                      'Duration (minutes)',
                      durationCtrl,
                      keyboard: TextInputType.number,
                      onChanged: (v) {
                        final mins = int.tryParse(v) ?? 0;
                        setBS(() => showReason = mins > 120);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.bgWhite,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.borderLight,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.borderLight,
                          ),
                        ),
                      ),
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
                  ),
                ],
              ),
              if (showReason) ...[
                const SizedBox(height: 10),
                _sheetField('Reason for exceeding 2h', reasonCtrl, maxLines: 2),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: submitting
                      ? null
                      : () async {
                          final title = titleCtrl.text.trim();
                          if (title.isEmpty) return;
                          setBS(() => submitting = true);
                          try {
                            await CommunityService.instance.submitNewClass(
                              title: title,
                              description: descCtrl.text.trim(),
                              category: category,
                              teacherName: currentUser.name,
                              videoUrl: videoCtrl.text.trim(),
                              durationMinutes:
                                  int.tryParse(durationCtrl.text) ?? 60,
                            );
                            if (ctx2.mounted) Navigator.pop(ctx2);
                          } catch (e) {
                            if (ctx2.mounted) {
                              setBS(() => submitting = false);
                              ScaffoldMessenger.of(ctx2).showSnackBar(
                                SnackBar(content: Text('Failed to submit: $e')),
                              );
                            }
                          }
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: submitting
                          ? AppColors.textGrey
                          : AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(
                      child: submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.gold,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Submit for Approval',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.gold,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Schedule meeting bottom sheet ────────────────────────────────────────

  void _showScheduleMeetingSheet(BuildContext context, ClassModel cls) {
    final purposeCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    int duration = 60;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setBS) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(ctx2).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Schedule Meeting',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                cls.title,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _sheetField('Meeting Topic / Purpose', purposeCtrl),
              const SizedBox(height: 10),
              _sheetField('Meeting Link (Zoom / Google Meet)', urlCtrl),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Text(
                    'Duration',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  ...[30, 60, 90, 120].map(
                    (d) => GestureDetector(
                      onTap: () => setBS(() => duration = d),
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: duration == d
                              ? AppColors.primaryDark
                              : AppColors.bgWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Text(
                          '${d}m',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: duration == d
                                ? AppColors.gold
                                : AppColors.textGrey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () async {
                  try {
                    await CommunityService.instance.scheduleMeeting(
                      classId: cls.id,
                      className: cls.title,
                      purpose: purposeCtrl.text.trim(),
                      scheduledAt: DateTime.now().add(const Duration(hours: 1)),
                      durationMinutes: duration,
                      meetUrl: urlCtrl.text.trim(),
                    );
                    if (ctx2.mounted) Navigator.pop(ctx2);
                  } catch (e) {
                    if (ctx2.mounted) {
                      ScaffoldMessenger.of(ctx2).showSnackBar(
                        SnackBar(content: Text('Failed to schedule: $e')),
                      );
                    }
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Center(
                    child: Text(
                      'Schedule & Notify Students',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDarkest,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetField(
    String hint,
    TextEditingController ctrl, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboard,
        onChanged: onChanged,
        style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: AppColors.textLightGrey,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

// ── Large card (PageView) ─────────────────────────────────────────────────────
class _ClassCard extends StatelessWidget {
  final ClassModel cls;
  final bool isEnrolled;
  const _ClassCard({required this.cls, required this.isEnrolled});

  static const _catColors = {
    'Quran': Color(0xFF1B4332),
    'Tajweed': Color(0xFF2D3A3A),
    'Fiqh': Color(0xFF2C3E50),
    'Seerah': Color(0xFF4A235A),
    'Arabic': Color(0xFF1A3A4A),
    'Hadith': Color(0xFF2E4A1A),
    'Aqeedah': Color(0xFF3A2A1A),
  };

  Color get _headerColor => _catColors[cls.category] ?? AppColors.primaryDark;

  @override
  Widget build(BuildContext context) {
    final enrolledCount = cls.studentIds.where((id) => id.isNotEmpty).length;
    return Container(
      margin: const EdgeInsets.only(right: 12, left: 16, bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            height: 130,
            decoration: BoxDecoration(
              color: _headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.school_rounded,
                        color: AppColors.gold,
                        size: 42,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          cls.category,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.gold,
                      size: 13,
                    ),
                    const Text(
                      ' 4.8  ',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: AppColors.textGrey,
                      ),
                    ),
                    Text(
                      '$enrolledCount students',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: AppColors.textLightGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  cls.title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  cls.teacherName,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cls.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: AppColors.textGrey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: isEnrolled
                      ? null
                      : () async {
                          try {
                            await CommunityService.instance.joinClass(cls.id);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to join: $e')),
                              );
                            }
                          }
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: isEnrolled
                          ? AppColors.bgCream
                          : AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(26),
                      border: isEnrolled
                          ? Border.all(color: AppColors.borderLight)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        isEnrolled ? '✓  Enrolled' : 'Join Masterclass',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isEnrolled
                              ? AppColors.textGrey
                              : AppColors.gold,
                        ),
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

// ── List row ──────────────────────────────────────────────────────────────────
class _CourseRow extends StatelessWidget {
  final ClassModel cls;
  final bool isEnrolled;
  final VoidCallback? onLeave;
  const _CourseRow({required this.cls, required this.isEnrolled, this.onLeave});

  @override
  Widget build(BuildContext context) {
    final enrolledCount = cls.studentIds.where((id) => id.isNotEmpty).length;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: AppColors.gold,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cls.title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  '${cls.teacherName} · $enrolledCount students',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Live',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: isEnrolled
                ? (onLeave ?? () {})
                : () async {
                    try {
                      await CommunityService.instance.joinClass(cls.id);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to join: $e')),
                        );
                      }
                    }
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isEnrolled ? AppColors.bgCream : AppColors.primaryDark,
                borderRadius: BorderRadius.circular(16),
                border: isEnrolled
                    ? Border.all(color: AppColors.borderLight)
                    : null,
              ),
              child: Text(
                isEnrolled ? 'Leave' : 'Join',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isEnrolled ? AppColors.error : AppColors.gold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Teacher's own class card ──────────────────────────────────────────────────
class _TeacherClassCard extends StatelessWidget {
  final ClassModel cls;
  final VoidCallback onScheduleMeeting;
  const _TeacherClassCard({required this.cls, required this.onScheduleMeeting});

  @override
  Widget build(BuildContext context) {
    final isPending = cls.status == 'pending';
    final isRejected = cls.status == 'rejected';
    final enrolledCount = cls.studentIds.where((id) => id.isNotEmpty).length;

    Color statusColor;
    String statusLabel;
    if (isPending) {
      statusColor = AppColors.warning;
      statusLabel = 'Pending Review';
    } else if (isRejected) {
      statusColor = AppColors.error;
      statusLabel = 'Rejected';
    } else {
      statusColor = AppColors.success;
      statusLabel = 'Live';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending
              ? AppColors.warning.withValues(alpha: 0.3)
              : isRejected
              ? AppColors.error.withValues(alpha: 0.2)
              : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          // Top row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: AppColors.gold,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cls.title,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        '${cls.category} · $enrolledCount enrolled',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Description
          if (cls.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Text(
                cls.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: AppColors.textGrey,
                  height: 1.4,
                ),
              ),
            ),
          // Action strip — only for active classes
          if (!isPending && !isRejected)
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgCream,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  // Enrolled students count chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 13,
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$enrolledCount students',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.goldDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onScheduleMeeting,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.video_call_rounded,
                            color: AppColors.gold,
                            size: 14,
                          ),
                          SizedBox(width: 5),
                          Text(
                            '+ Meeting',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Pending info strip
          if (isPending)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.06),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: const Text(
                '⏳  Awaiting admin approval — class not yet visible to students.',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: AppColors.warning,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
