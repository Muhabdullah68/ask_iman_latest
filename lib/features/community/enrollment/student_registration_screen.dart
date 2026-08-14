import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/community_service.dart';
import 'pending_enrollment_screen.dart';

class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  State<StudentRegistrationScreen> createState() => _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  final _pageCtrl = PageController();
  int _currentStep = 0;

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _customCourseCtrl = TextEditingController();

  final Set<String> _selectedCourses = {};
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _submitting = false;

  static const _suggestedCourses = [
    'Tajweed (Quran Recitation)',
    'Hifz (Quran Memorization)',
    'Tafseer (Quran Translation)',
    'Noorani Qaida (Beginners)',
    'Arabic Language',
    'Islamic Studies',
    'Fiqh (Islamic Jurisprudence)',
    'Hadith Studies',
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _customCourseCtrl.dispose();
    super.dispose();
  }

  bool get _canProceedFromStep0 =>
      _emailCtrl.text.trim().isNotEmpty &&
      _passCtrl.text.isNotEmpty &&
      _passCtrl.text.length >= 6 &&
      _passCtrl.text == _confirmPassCtrl.text;

  bool get _canProceedFromStep1 =>
      _firstNameCtrl.text.trim().isNotEmpty &&
      _lastNameCtrl.text.trim().isNotEmpty &&
      _phoneCtrl.text.trim().isNotEmpty &&
      _locationCtrl.text.trim().isNotEmpty;

  bool get _canProceedFromStep2 => _selectedCourses.isNotEmpty;

  void _next() {
    if (_currentStep < 3) {
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _back() {
    if (_currentStep > 0) {
      _pageCtrl.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _addCustomCourse() {
    final text = _customCourseCtrl.text.trim();
    if (text.isNotEmpty && !_selectedCourses.contains(text)) {
      setState(() => _selectedCourses.add(text));
      _customCourseCtrl.clear();
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      final uid = cred.user!.uid;

      await CommunityService.instance.createStudentEnrollment(
        uid: uid,
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        selectedCourses: _selectedCourses.toList(),
      );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PendingEnrollmentScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message ?? 'Registration failed'),
          backgroundColor: AppColors.error,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: const Text('Student Registration', style: TextStyle(color: AppColors.gold, fontFamily: 'Cairo')),
        iconTheme: const IconThemeData(color: AppColors.gold),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildStepper(),
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentStep = i),
              children: [
                _buildStep0(),
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
              ],
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: AppColors.bgWhite,
      child: Row(
        children: List.generate(4, (i) {
          final isActive = _currentStep >= i;
          final isCurrent = _currentStep == i;
          return Expanded(
            child: Row(
              children: [
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: _currentStep >= i ? AppColors.gold : AppColors.borderLight,
                    ),
                  ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCurrent ? AppColors.primaryDark : isActive ? AppColors.gold : AppColors.borderLight,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: isActive ? AppColors.textWhite : AppColors.textGrey,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep0() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text('Create Account', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, fontFamily: 'Cairo', color: AppColors.primaryDarkest)),
          const SizedBox(height: 4),
          const Text('Enter your email and create a password', style: TextStyle(fontSize: 13, fontFamily: 'Cairo', color: AppColors.textGrey)),
          const SizedBox(height: 24),
          _field('Email Address', _emailCtrl, false, TextInputType.emailAddress),
          const SizedBox(height: 16),
          _field('Password', _passCtrl, true, TextInputType.visiblePassword),
          const SizedBox(height: 16),
          _field('Confirm Password', _confirmPassCtrl, true, TextInputType.visiblePassword),
          if (_passCtrl.text.isNotEmpty && _confirmPassCtrl.text.isNotEmpty && _passCtrl.text != _confirmPassCtrl.text)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Passwords do not match', style: TextStyle(color: AppColors.error, fontSize: 12, fontFamily: 'Cairo')),
            ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text('Personal Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, fontFamily: 'Cairo', color: AppColors.primaryDarkest)),
          const SizedBox(height: 4),
          const Text('Tell us about yourself', style: TextStyle(fontSize: 13, fontFamily: 'Cairo', color: AppColors.textGrey)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _field('First Name', _firstNameCtrl, false, TextInputType.name)),
              const SizedBox(width: 12),
              Expanded(child: _field('Last Name', _lastNameCtrl, false, TextInputType.name)),
            ],
          ),
          const SizedBox(height: 16),
          _field('Phone Number', _phoneCtrl, false, TextInputType.phone),
          const SizedBox(height: 16),
          _field('Location / Country', _locationCtrl, false, TextInputType.streetAddress),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text('Select Courses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, fontFamily: 'Cairo', color: AppColors.primaryDarkest)),
          const SizedBox(height: 4),
          const Text('Choose courses you want to study. You can also add your own.', style: TextStyle(fontSize: 13, fontFamily: 'Cairo', color: AppColors.textGrey)),
          const SizedBox(height: 20),
          const Text('Suggested Courses', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Cairo', color: AppColors.primaryDark)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestedCourses.map((course) {
              final selected = _selectedCourses.contains(course);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selected) {
                      _selectedCourses.remove(course);
                    } else {
                      _selectedCourses.add(course);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryDark : AppColors.bgWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? AppColors.primaryDark : AppColors.borderLight,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    course,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.textWhite : AppColors.textDark,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text('Add Your Own Course', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Cairo', color: AppColors.primaryDark)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customCourseCtrl,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.primaryDarkest),
                  decoration: InputDecoration(
                    hintText: 'Type a course name...',
                    hintStyle: const TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey),
                    filled: true,
                    fillColor: AppColors.bgWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onSubmitted: (_) => _addCustomCourse(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _addCustomCourse,
                  icon: const Icon(Icons.add, color: AppColors.gold),
                ),
              ),
            ],
          ),
          if (_selectedCourses.where((c) => !_suggestedCourses.contains(c)).isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Custom Courses', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Cairo', color: AppColors.textGrey)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedCourses.where((c) => !_suggestedCourses.contains(c)).map((course) {
                return Chip(
                  label: Text(course, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.primaryDarkest)),
                  backgroundColor: AppColors.goldSurface,
                  deleteIcon: const Icon(Icons.close, size: 16, color: AppColors.textGrey),
                  onDeleted: () => setState(() => _selectedCourses.remove(course)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text('Review & Submit', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, fontFamily: 'Cairo', color: AppColors.primaryDarkest)),
          const SizedBox(height: 4),
          const Text('Please review your information before submitting', style: TextStyle(fontSize: 13, fontFamily: 'Cairo', color: AppColors.textGrey)),
          const SizedBox(height: 24),
          _reviewCard([
            _reviewItem('Email', _emailCtrl.text),
            _reviewItem('Name', '${_firstNameCtrl.text} ${_lastNameCtrl.text}'),
            _reviewItem('Phone', _phoneCtrl.text),
            _reviewItem('Location', _locationCtrl.text),
            _reviewItem('Courses', _selectedCourses.join(', ')),
          ]),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.goldSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.gold, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your enrollment will be reviewed by our admin team. You\'ll be notified once approved and assigned to classes.',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.primaryDarkest),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _back,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryDark,
                  side: const BorderSide(color: AppColors.primaryDark),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentStep < 3
                  ? (_currentStep == 0 && !_canProceedFromStep0 ? null
                      : _currentStep == 1 && !_canProceedFromStep1 ? null
                      : _currentStep == 2 && !_canProceedFromStep2 ? null
                      : _next)
                  : (_submitting ? null : _submit),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: AppColors.gold,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold))
                  : Text(
                      _currentStep < 3 ? 'Continue' : 'Submit Application',
                      style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, fontSize: 15),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, bool obscure, TextInputType type) {
    return TextField(
      controller: ctrl,
      obscureText: obscure ? (_obscurePass && label == 'Password' || _obscureConfirm && label == 'Confirm Password') : false,
      keyboardType: type,
      style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, color: AppColors.primaryDarkest),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey),
        suffixIcon: obscure
            ? IconButton(
                icon: Icon(
                  (label == 'Password' ? _obscurePass : _obscureConfirm) ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textGrey,
                ),
                onPressed: () => setState(() {
                  if (label == 'Password') {
                    _obscurePass = !_obscurePass;
                  } else {
                    _obscureConfirm = !_obscureConfirm;
                  }
                }),
              )
            : null,
        filled: true,
        fillColor: AppColors.bgWhite,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gold, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _reviewCard(List<Widget> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items,
      ),
    );
  }

  Widget _reviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textGrey)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.primaryDarkest)),
          if (label != 'Courses') const Divider(height: 12),
        ],
      ),
    );
  }
}
