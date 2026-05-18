// lib/features/community/community_auth_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// COMMUNITY GATE — full auth + role routing
//
// Flow:
//   1. Not signed in to Firebase Auth
//        → _LoginScreen  (email/password sign-in OR create account)
//   2. Signed in, no Firestore profile yet
//        → CommunityAuthScreen  (choose Student / Teacher, fill form)
//        SPECIAL CASE: if email == admin credential → auto-create admin profile
//   3. Signed in + profile exists:
//        role == admin              → AdminDashboard
//        role == teacher, !approved → _TeacherPendingScreen
//        isBlocked                  → _BlockedScreen
//        otherwise                  → CommunityScreen(currentUser)
//
// Test credentials (create these in Firebase Auth console OR via the app):
//   Admin   : admin@askiman.admin  / Admin@1234
//   Teacher : teacher@test.com     / Teacher@1234
//   Student : student@test.com     / Student@1234
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/community_service.dart';
import 'community_screen.dart';
import 'admin/admin_dashboard.dart';

// ── Admin email pattern ───────────────────────────────────────────────────────
bool _isAdminEmail(String email) =>
    email.toLowerCase().endsWith('@askiman.admin');

// ══════════════════════════════════════════════════════════════════════════════
// COMMUNITY GATE  — top-level router, never needs rebuilding manually
// ══════════════════════════════════════════════════════════════════════════════
class CommunityGate extends StatelessWidget {
  const CommunityGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Outer stream: Firebase Auth state
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return _loadingScaffold();
        }

        // Not logged in → show login screen
        if (authSnap.data == null) return const _LoginScreen();

        // Logged in → watch Firestore profile
        return StreamBuilder<AppUser?>(
          stream: CommunityService.instance.watchCurrentUser(),
          builder: (ctx2, profileSnap) {
            if (profileSnap.connectionState == ConnectionState.waiting) {
              return _loadingScaffold();
            }

            final user = profileSnap.data;

            // No profile yet → registration (or auto-admin seed)
            if (user == null) {
              return _FirstTimeRegistration(
                  firebaseUser: authSnap.data!);
            }

            // Route by role/status
            if (user.role == UserRole.admin) return const AdminDashboard();

            if (user.role == UserRole.teacher && !user.isApproved) {
              return const _TeacherPendingScreen();
            }

            if (user.isBlocked) return const _BlockedScreen();

            return CommunityScreen(currentUser: user);
          },
        );
      },
    );
  }

  static Widget _loadingScaffold() => const Scaffold(
    backgroundColor: AppColors.bgCream,
    body: Center(
        child: CircularProgressIndicator(color: AppColors.gold)),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// LOGIN SCREEN  — email / password  +  create account
// ══════════════════════════════════════════════════════════════════════════════
class _LoginScreen extends StatefulWidget {
  const _LoginScreen();

  @override
  State<_LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<_LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loading    = false;
  bool _isRegister = false; // toggle between Sign In / Create Account
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email    = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter email and password.');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      if (_isRegister) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email, password: password);
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email, password: password);
      }
      // StreamBuilder above will automatically re-route
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error   = _friendlyAuthError(e.code);
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String _friendlyAuthError(String code) {
    switch (code) {
      case 'user-not-found':    return 'No account found. Try creating one.';
      case 'wrong-password':    return 'Incorrect password.';
      case 'email-already-in-use': return 'Account already exists. Sign in instead.';
      case 'weak-password':     return 'Password must be at least 6 characters.';
      case 'invalid-email':     return 'Please enter a valid email.';
      default:                  return 'Authentication error. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _field('Email address', _emailCtrl,
                        keyboard: TextInputType.emailAddress),
                    const SizedBox(height: 14),
                    _field('Password', _passCtrl, obscure: true),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(_error!,
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              color: AppColors.error)),
                    ],
                    const SizedBox(height: 24),
                    _primaryButton(
                      label: _isRegister ? 'Create Account' : 'Sign In',
                      onTap: _loading ? null : _submit,
                      loading: _loading,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _isRegister = !_isRegister;
                          _error = null;
                        }),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                color: AppColors.textGrey),
                            children: [
                              TextSpan(
                                  text: _isRegister
                                      ? 'Already have an account? '
                                      : "Don't have an account? "),
                              TextSpan(
                                text: _isRegister ? 'Sign in' : 'Create one',
                                style: const TextStyle(
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // ── test credentials hint (remove in production) ──
                    _credentialsHint(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('☽  ASK IMAN',
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                  letterSpacing: 2)),
          const SizedBox(height: 16),
          Text(
            _isRegister ? 'Create your account' : 'Welcome back',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Connect with the global Ummah.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: AppColors.textGreenMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String hint, TextEditingController ctrl,
      {bool obscure = false,
        TextInputType keyboard = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboard,
        style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: AppColors.textLightGrey),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _primaryButton(
      {required String label,
        required VoidCallback? onTap,
        bool loading = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: onTap == null ? AppColors.textGrey : AppColors.primaryDark,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Center(
          child: loading
              ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  color: AppColors.gold, strokeWidth: 2))
              : Text(label,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.gold,
              )),
        ),
      ),
    );
  }

  Widget _credentialsHint() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Test Credentials',
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          SizedBox(height: 6),
          _CredRow(role: 'Admin',   email: 'admin@askiman.admin', pass: 'Admin@1234'),
          _CredRow(role: 'Teacher', email: 'teacher@test.com',    pass: 'Teacher@1234'),
          _CredRow(role: 'Student', email: 'student@test.com',    pass: 'Student@1234'),
        ],
      ),
    );
  }
}

class _CredRow extends StatelessWidget {
  final String role;
  final String email;
  final String pass;
  const _CredRow({required this.role, required this.email, required this.pass});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text('$role: $email  /  $pass',
          style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: AppColors.textGrey)),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FIRST-TIME REGISTRATION  — shown when signed in but no Firestore profile
// Auto-creates admin profile if email matches admin pattern.
// ══════════════════════════════════════════════════════════════════════════════
class _FirstTimeRegistration extends StatefulWidget {
  final User firebaseUser;
  const _FirstTimeRegistration({required this.firebaseUser});

  @override
  State<_FirstTimeRegistration> createState() => _FirstTimeRegistrationState();
}

class _FirstTimeRegistrationState extends State<_FirstTimeRegistration> {
  int _step             = 0;
  UserRole? _selectedRole;
  bool _loading         = false;
  String? _error;

  final _nameCtrl = TextEditingController();
  final _bioCtrl  = TextEditingController();
  final _qualCtrl = TextEditingController();
  final _specCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Auto-handle admin email — skip role chooser
    if (_isAdminEmail(widget.firebaseUser.email ?? '')) {
      _autoCreateAdmin();
    }
  }

  Future<void> _autoCreateAdmin() async {
    setState(() => _loading = true);
    await CommunityService.instance.createUserProfile(
      name:  'Admin',
      email: widget.firebaseUser.email ?? '',
      role:  UserRole.admin,
    );
    // watchCurrentUser stream will pick up the new doc automatically
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _qualCtrl.dispose();
    _specCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your name.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await CommunityService.instance.createUserProfile(
        name:           _nameCtrl.text.trim(),
        email:          widget.firebaseUser.email ?? '',
        role:           _selectedRole!,
        bio:            _bioCtrl.text.trim(),
        qualification:  _qualCtrl.text.trim(),
        specialization: _specCtrl.text.trim(),
      );
      // StreamBuilder in CommunityGate auto-navigates on profile creation
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _step == 0) {
      // Waiting for auto-admin creation
      return const Scaffold(
        backgroundColor: AppColors.bgCream,
        body: Center(
            child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              if (_step == 0) _buildRoleChooser(),
              if (_step == 1) _buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Join the Ummah',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.gold,
              )),
          const SizedBox(height: 8),
          Text(
            _step == 0
                ? 'Choose how you want to participate.'
                : 'Tell us a bit about yourself.',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: AppColors.textGreenMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleChooser() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          _roleCard(
            UserRole.student,
            'Join as Student',
            'Enrol in classes, join study circles, connect with the Ummah.',
            Icons.school_outlined,
          ),
          const SizedBox(height: 16),
          _roleCard(
            UserRole.teacher,
            'Join as Teacher',
            'Create and teach Islamic courses. Requires admin approval.',
            Icons.auto_stories_outlined,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => FirebaseAuth.instance.signOut(),
            child: const Text('Sign out',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: AppColors.textGrey)),
          ),
        ],
      ),
    );
  }

  Widget _roleCard(
      UserRole role, String title, String sub, IconData icon) {
    return GestureDetector(
      onTap: () => setState(() {
        _selectedRole = role;
        _step = 1;
      }),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.gold, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      )),
                  const SizedBox(height: 4),
                  Text(sub,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppColors.textGrey,
                        height: 1.4,
                      )),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textLightGrey),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    final isTeacher = _selectedRole == UserRole.teacher;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _step = 0),
            child: const Row(
              children: [
                Icon(Icons.arrow_back_ios_new,
                    size: 14, color: AppColors.primaryDark),
                SizedBox(width: 6),
                Text('Back',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: AppColors.primaryDark)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _field('Full Name', _nameCtrl),
          const SizedBox(height: 14),
          _field('Short Bio (optional)', _bioCtrl, maxLines: 2),
          if (isTeacher) ...[
            const SizedBox(height: 14),
            _field('Qualification (e.g. BA Islamic Studies)', _qualCtrl),
            const SizedBox(height: 14),
            _field('Specialization (e.g. Tajweed, Fiqh)', _specCtrl),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                Border.all(color: AppColors.gold.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline,
                      color: AppColors.gold, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Teacher accounts require admin approval before access is granted.',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppColors.goldDark,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!,
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: AppColors.error)),
          ],
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _loading ? null : _submit,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _loading
                    ? AppColors.textGrey
                    : AppColors.primaryDark,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(
                child: _loading
                    ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: AppColors.gold, strokeWidth: 2))
                    : Text(
                    isTeacher
                        ? 'Submit for Approval'
                        : 'Join Community',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String hint, TextEditingController ctrl,
      {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: AppColors.textLightGrey),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SUPPORT SCREENS
// ══════════════════════════════════════════════════════════════════════════════

class _TeacherPendingScreen extends StatelessWidget {
  const _TeacherPendingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.hourglass_top_rounded,
                      color: AppColors.gold, size: 40),
                ),
                const SizedBox(height: 24),
                const Text('Application Under Review',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    )),
                const SizedBox(height: 12),
                const Text(
                  'Your teacher application is being reviewed. You will gain access once approved. JazakAllah Khair for your patience.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: AppColors.textGrey,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () => FirebaseAuth.instance.signOut(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderLight),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Sign out',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            color: AppColors.textGrey)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BlockedScreen extends StatelessWidget {
  const _BlockedScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.block_rounded,
                    color: AppColors.error, size: 64),
                const SizedBox(height: 24),
                const Text(
                  'Account Restricted',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your account has been restricted by the admin. Please contact support.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: AppColors.textGrey,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () => FirebaseAuth.instance.signOut(),
                  child: const Text('Sign out',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: AppColors.gold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}