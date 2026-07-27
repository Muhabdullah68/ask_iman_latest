import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/community_service.dart' show UserRole;
import 'auth_service.dart';
import 'pending_approval_screen.dart';

class SignUpScreen extends StatefulWidget {
  final UserRole initialRole;
  const SignUpScreen({super.key, this.initialRole = UserRole.student});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  // Step 1: Basic info
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;

  // Step 2: Role
  UserRole _role = UserRole.student;

  // Step 3a: Student fields
  String _studentAgeGroup = '13-17';
  final List<String> _studentInterests = [];

  // Step 3b: Teacher fields
  final _teacherSubjects = <String>[];
  final _qualCtrl = TextEditingController();
  String _teacherExperience = '1-2 years';
  final _bioCtrl = TextEditingController();
  final _philosophyCtrl = TextEditingController();

  bool _loading = false;

  final _ageGroups = ['Under 13', '13-17', '18-24', '25-34', '35+'];
  final _allSubjects = [
    'Quran',
    'Tajweed',
    'Fiqh',
    'Hadith',
    'Tafsir',
    'Arabic',
    'Islamic History',
    'Aqeedah',
  ];
  final _allInterests = [
    'Quran',
    'Fiqh',
    'Hadith',
    'Arabic',
    'History',
    'Dua',
  ];
  final _experienceYears = ['Less than 1', '1-2 years', '3-5 years', '6-10 years', '10+ years'];

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole;
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _qualCtrl.dispose();
    _bioCtrl.dispose();
    _philosophyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      Map<String, dynamic>? profileData;
      if (_role == UserRole.student) {
        profileData = {
          'ageGroup': _studentAgeGroup,
          'interests': _studentInterests,
        };
      } else {
        profileData = {
          'subjects': _teacherSubjects,
          'qualification': _qualCtrl.text.trim(),
          'experience': _teacherExperience,
          'bio': _bioCtrl.text.trim(),
          'philosophy': _philosophyCtrl.text.trim(),
        };
      }
      await AuthService.instance.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        role: _role,
        profileData: profileData,
      );
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => PendingApprovalScreen(role: _role.name),
          ),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Sign up failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _canAdvance() {
    switch (_page) {
      case 0:
        return _nameCtrl.text.trim().isNotEmpty &&
            _emailCtrl.text.trim().isNotEmpty &&
            _passCtrl.text.trim().isNotEmpty &&
            _confirmCtrl.text.trim().isNotEmpty &&
            _passCtrl.text == _confirmCtrl.text &&
            _passCtrl.text.length >= 6;
      case 1:
        return true;
      case 2:
        if (_role == UserRole.teacher) {
          return _teacherSubjects.isNotEmpty &&
              _qualCtrl.text.trim().isNotEmpty &&
              _bioCtrl.text.trim().isNotEmpty;
        }
        return true;
      case 3:
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _page > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primaryDarkest),
                onPressed: () => _pageCtrl.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
              )
            : null,
        title: _buildStepIndicator(),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _page = i),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
                _buildStep4(),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final active = i <= _page;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 24 : 8,
          height: 6,
          decoration: BoxDecoration(
            color: active ? AppColors.gold : AppColors.textGrey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _loading
                ? null
                : () {
                    if (_page == 3) {
                      _submit();
                    } else {
                      if (_canAdvance()) {
                        _pageCtrl.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: AppColors.gold,
              disabledBackgroundColor: AppColors.primaryDark.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
            ),
            child: _loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.gold,
                    ),
                  )
                : Text(
                    _page == 3 ? 'Submit Application' : 'Continue',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ── Step 1: Basic Info ───────────────────────────────────────────────────────

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.person_add, size: 56, color: AppColors.gold),
          const SizedBox(height: 12),
          const Text(
            'Create Account',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDarkest,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Enter your details to get started',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 28),
          _field('Full Name', _nameCtrl, false, TextInputType.name),
          const SizedBox(height: 14),
          _field('Email', _emailCtrl, false, TextInputType.emailAddress),
          const SizedBox(height: 14),
          _field('Password', _passCtrl, true, TextInputType.visiblePassword),
          const SizedBox(height: 14),
          _field('Confirm Password', _confirmCtrl, true, TextInputType.visiblePassword),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Step 2: Choose Role ──────────────────────────────────────────────────────

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.school, size: 56, color: AppColors.gold),
          const SizedBox(height: 12),
          const Text(
            'Choose Your Role',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDarkest,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'This determines your experience on the platform',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 28),
          _roleCard(
            icon: Icons.menu_book,
            title: 'Student',
            subtitle: 'Access classes, track streaks, connect with friends and family',
            selected: _role == UserRole.student,
            onTap: () => setState(() => _role = UserRole.student),
          ),
          const SizedBox(height: 14),
          _roleCard(
            icon: Icons.auto_stories,
            title: 'Teacher',
            subtitle: 'Create classes, manage students, schedule meetings, share knowledge',
            selected: _role == UserRole.teacher,
            onTap: () => setState(() => _role = UserRole.teacher),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _roleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.borderLight,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.gold.withValues(alpha: 0.2)
                    : AppColors.bgCream,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon,
                color: selected ? AppColors.gold : AppColors.textGrey,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: selected ? AppColors.textWhite : AppColors.primaryDarkest,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: selected ? AppColors.textGreenMuted : AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.gold : AppColors.textGrey,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 3: Role-specific form ───────────────────────────────────────────────

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _role == UserRole.student ? _buildStudentForm() : _buildTeacherForm(),
    );
  }

  Widget _buildStudentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.psychology, size: 56, color: AppColors.gold),
        const SizedBox(height: 12),
        const Text(
          'About You',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryDarkest,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Help us personalize your learning journey',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Age Group',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDarkest,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _studentAgeGroup,
          decoration: _dropdownDecoration(),
          items: _ageGroups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (v) => setState(() => _studentAgeGroup = v ?? _studentAgeGroup),
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.primaryDarkest),
        ),
        const SizedBox(height: 20),
        const Text(
          'Interests (tap to select)',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDarkest,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allInterests.map((s) {
            final sel = _studentInterests.contains(s);
            return ChoiceChip(
              label: Text(s, style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: sel ? AppColors.primaryDarkest : AppColors.textGrey,
              )),
              selected: sel,
              selectedColor: AppColors.gold,
              backgroundColor: AppColors.primaryDarkest,
              onSelected: (v) {
                setState(() {
                  if (v) { _studentInterests.add(s); } else { _studentInterests.remove(s); }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildTeacherForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.auto_stories, size: 56, color: AppColors.gold),
        const SizedBox(height: 12),
        const Text(
          'Teacher Profile',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryDarkest,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Tell us about your teaching background',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Subjects You Teach',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDarkest,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allSubjects.map((s) {
            final sel = _teacherSubjects.contains(s);
            return ChoiceChip(
              label: Text(s, style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: sel ? AppColors.primaryDarkest : AppColors.textGrey,
              )),
              selected: sel,
              selectedColor: AppColors.gold,
              backgroundColor: AppColors.primaryDarkest,
              onSelected: (v) {
                setState(() {
                  if (v) { _teacherSubjects.add(s); } else { _teacherSubjects.remove(s); }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        const Text(
          'Qualifications',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDarkest,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _qualCtrl,
          maxLines: 2,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.primaryDarkest),
          decoration: _textFieldDecoration('e.g. Ijazah, University Degree, etc.'),
        ),
        const SizedBox(height: 20),
        const Text(
          'Years of Teaching Experience',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDarkest,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _teacherExperience,
          decoration: _dropdownDecoration(),
          items: _experienceYears.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
          onChanged: (v) => setState(() => _teacherExperience = v ?? _teacherExperience),
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.primaryDarkest),
        ),
        const SizedBox(height: 20),
        const Text(
          'Bio',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDarkest,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _bioCtrl,
          maxLines: 3,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.primaryDarkest),
          decoration: _textFieldDecoration('Tell us about yourself...'),
        ),
        const SizedBox(height: 20),
        const Text(
          'Teaching Philosophy',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDarkest,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _philosophyCtrl,
          maxLines: 3,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.primaryDarkest),
          decoration: _textFieldDecoration('Your approach to teaching...'),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  InputDecoration _textFieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textGrey),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.gold, width: 2),
      ),
    );
  }

  // ── Step 4: Review & Submit ──────────────────────────────────────────────────

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline, size: 56, color: AppColors.gold),
          const SizedBox(height: 12),
          const Text(
            'Review Your Application',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDarkest,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Please review your information before submitting',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 24),
          _reviewTile('Name', _nameCtrl.text.trim()),
          _reviewTile('Email', _emailCtrl.text.trim()),
          _reviewTile('Role', _role == UserRole.student ? 'Student' : 'Teacher'),
          if (_role == UserRole.student) ...[
            _reviewTile('Age Group', _studentAgeGroup),
            _reviewTile('Interests', _studentInterests.isEmpty ? 'None selected' : _studentInterests.join(', ')),
          ] else ...[
            _reviewTile('Subjects', _teacherSubjects.join(', ')),
            _reviewTile('Qualifications', _qualCtrl.text.trim()),
            _reviewTile('Experience', _teacherExperience),
            _reviewTile('Bio', _bioCtrl.text.trim()),
            if (_philosophyCtrl.text.trim().isNotEmpty)
              _reviewTile('Philosophy', _philosophyCtrl.text.trim()),
          ],
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.gold, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _role == UserRole.student
                        ? 'Your student account will be reviewed by our admin team before you can access classes.'
                        : 'Your teacher application requires admin approval. You\'ll be notified once reviewed.',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppColors.primaryDarkest,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _reviewTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.primaryDarkest,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared field widget ──────────────────────────────────────────────────────

  Widget _field(
    String label,
    TextEditingController ctrl,
    bool obscure,
    TextInputType type,
  ) {
    return TextField(
      controller: ctrl,
      obscureText: obscure ? _obscure : false,
      keyboardType: type,
      style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, color: AppColors.primaryDarkest),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey),
        suffixIcon: obscure
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textGrey,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.gold, width: 2),
        ),
      ),
    );
  }
}
