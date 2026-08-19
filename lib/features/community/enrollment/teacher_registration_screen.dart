import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/community_service.dart';
import '../../auth/pending_approval_screen.dart';

class TeacherRegistrationScreen extends StatefulWidget {
  const TeacherRegistrationScreen({super.key});

  @override
  State<TeacherRegistrationScreen> createState() =>
      _TeacherRegistrationScreenState();
}

class _TeacherRegistrationScreenState extends State<TeacherRegistrationScreen> {
  final _pageCtrl = PageController();
  int _currentStep = 0;

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cnicNumberCtrl = TextEditingController();

  final _picker = ImagePicker();
  final _certNameCtrls = <TextEditingController>[];
  final _certFileCtrls = <Uint8List?>[];

  Uint8List? _cnicFront;
  Uint8List? _cnicBack;
  String _experience = '1-2 years';
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _submitting = false;

  final Set<String> _selectedSubjects = {};
  final Set<String> _selectedTimings = {};

  static const _allSubjects = [
    'Quran',
    'Tajweed',
    'Fiqh',
    'Hadith',
    'Tafsir',
    'Arabic',
    'Islamic History',
    'Aqeedah',
  ];

  static const _allTimings = ['Morning', 'Afternoon', 'Evening', 'Weekend'];

  static const _experienceOptions = [
    '1-2 years',
    '3-5 years',
    '6-10 years',
    '10+ years',
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
    _addressCtrl.dispose();
    _cnicNumberCtrl.dispose();
    for (final c in _certNameCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _canProceedFromStep0 =>
      _emailCtrl.text.trim().isNotEmpty &&
      _passCtrl.text.isNotEmpty &&
      _passCtrl.text.length >= 6 &&
      _passCtrl.text == _confirmPassCtrl.text &&
      _firstNameCtrl.text.trim().isNotEmpty &&
      _lastNameCtrl.text.trim().isNotEmpty &&
      _phoneCtrl.text.trim().isNotEmpty &&
      _addressCtrl.text.trim().isNotEmpty &&
      _cnicNumberCtrl.text.trim().isNotEmpty &&
      _cnicFront != null &&
      _cnicBack != null;

  bool get _canProceedFromStep1 => _selectedSubjects.isNotEmpty;

  void _next() {
    if (_currentStep < 2) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _back() {
    if (_currentStep > 0) {
      _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _pickCnicFront() async {
    final f = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1024,
    );
    if (f != null) {
      final bytes = await f.readAsBytes();
      if (mounted) setState(() => _cnicFront = bytes);
    }
  }

  Future<void> _pickCnicBack() async {
    final f = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1024,
    );
    if (f != null) {
      final bytes = await f.readAsBytes();
      if (mounted) setState(() => _cnicBack = bytes);
    }
  }

  Future<void> _addCertification() async {
    final f = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1024,
    );
    if (f == null) return;
    final bytes = await f.readAsBytes();
    if (!mounted) return;
    setState(() {
      _certNameCtrls.add(TextEditingController());
      _certFileCtrls.add(bytes);
    });
  }

  void _removeCert(int index) {
    setState(() {
      _certNameCtrls[index].dispose();
      _certNameCtrls.removeAt(index);
      _certFileCtrls.removeAt(index);
    });
  }

  List<Map<String, Uint8List>> get _certifications {
    final result = <Map<String, Uint8List>>[];
    for (int i = 0; i < _certNameCtrls.length; i++) {
      final name = _certNameCtrls[i].text.trim();
      if (name.isNotEmpty && _certFileCtrls[i] != null) {
        result.add({name: _certFileCtrls[i]!});
      }
    }
    return result;
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      final uid = cred.user!.uid;

      await CommunityService.instance.createTeacherApplication(
        uid: uid,
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        cnicNumber: _cnicNumberCtrl.text.trim(),
        cnicFront: _cnicFront!,
        cnicBack: _cnicBack!,
        certifications: _certifications,
        experience: _experience,
        subjects: _selectedSubjects.toList(),
        preferredTimings: _selectedTimings.toList(),
      );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const PendingApprovalScreen(role: 'teacher'),
          ),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Registration failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
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
        title: const Text(
          'Teacher Registration',
          style: TextStyle(color: AppColors.gold, fontFamily: 'Cairo'),
        ),
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
              children: [_buildStep0(), _buildStep1(), _buildStep2()],
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
        children: List.generate(3, (i) {
          final isActive = _currentStep >= i;
          final isCurrent = _currentStep == i;
          return Expanded(
            child: Row(
              children: [
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: _currentStep >= i
                          ? AppColors.gold
                          : AppColors.borderLight,
                    ),
                  ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCurrent
                        ? AppColors.primaryDark
                        : isActive
                        ? AppColors.gold
                        : AppColors.borderLight,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: isActive
                            ? AppColors.textWhite
                            : AppColors.textGrey,
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
          const Text(
            'Account & Identity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontFamily: 'Cairo',
              color: AppColors.primaryDarkest,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Create your account and upload required documents',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Cairo',
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Account Credentials',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          _field(
            'Email Address',
            _emailCtrl,
            false,
            TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _field('Password', _passCtrl, true, TextInputType.visiblePassword),
          const SizedBox(height: 12),
          _field(
            'Confirm Password',
            _confirmPassCtrl,
            true,
            TextInputType.visiblePassword,
          ),
          if (_passCtrl.text.isNotEmpty &&
              _confirmPassCtrl.text.isNotEmpty &&
              _passCtrl.text != _confirmPassCtrl.text)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Passwords do not match',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _field(
                  'First Name',
                  _firstNameCtrl,
                  false,
                  TextInputType.name,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _field(
                  'Last Name',
                  _lastNameCtrl,
                  false,
                  TextInputType.name,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _field('Phone Number', _phoneCtrl, false, TextInputType.phone),
          const SizedBox(height: 12),
          _field('Address', _addressCtrl, false, TextInputType.streetAddress),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'CNIC (National ID)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          _field('CNIC Number', _cnicNumberCtrl, false, TextInputType.number),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildImagePicker('Front', _cnicFront, _pickCnicFront),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildImagePicker('Back', _cnicBack, _pickCnicBack),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Certifications',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Cairo',
                  color: AppColors.primaryDark,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _addCertification,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 16, color: AppColors.gold),
                      SizedBox(width: 4),
                      Text(
                        'Add',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
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
          const SizedBox(height: 8),
          const Text(
            'Upload certificates, Ijazah, or degrees',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Cairo',
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 12),
          if (_certNameCtrls.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.borderLight,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Center(
                child: Text(
                  'No certifications added yet. Tap "Add" above.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
            ),
          ...List.generate(_certNameCtrls.length, (i) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _certNameCtrls[i],
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            color: AppColors.primaryDarkest,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Certification name',
                            hintStyle: const TextStyle(
                              fontFamily: 'Cairo',
                              color: AppColors.textGrey,
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _removeCert(i),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.bgCream,
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: MemoryImage(_certFileCtrls[i]!),
                          fit: BoxFit.cover,
                        ),
                      ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Experience',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _experience,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.bgWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: AppColors.primaryDarkest,
            ),
            items: _experienceOptions
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, style: const TextStyle(fontFamily: 'Cairo')),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _experience = v ?? _experience),
          ),
          const SizedBox(height: 24),
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
          const Text(
            'Teaching Preferences',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontFamily: 'Cairo',
              color: AppColors.primaryDarkest,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select the subjects you teach and your preferred timing',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Cairo',
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Subjects You Teach',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select one or more',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Cairo',
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allSubjects.map((s) {
              final sel = _selectedSubjects.contains(s);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (sel) {
                      _selectedSubjects.remove(s);
                    } else {
                      _selectedSubjects.add(s);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primaryDark : AppColors.bgWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel
                          ? AppColors.primaryDark
                          : AppColors.borderLight,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    s,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: sel ? AppColors.textWhite : AppColors.textDark,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          const Divider(),
          const SizedBox(height: 20),
          const Text(
            'Preferred Timing',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Optional — select when you prefer to teach',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Cairo',
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allTimings.map((t) {
              final sel = _selectedTimings.contains(t);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (sel) {
                      _selectedTimings.remove(t);
                    } else {
                      _selectedTimings.add(t);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primaryDark : AppColors.bgWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel
                          ? AppColors.primaryDark
                          : AppColors.borderLight,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    t,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: sel ? AppColors.textWhite : AppColors.textDark,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
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
          const Text(
            'Review & Submit',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontFamily: 'Cairo',
              color: AppColors.primaryDarkest,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Please review your application before submitting',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Cairo',
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 24),
          _reviewCard([
            _reviewItem('Email', _emailCtrl.text),
            _reviewItem('Name', '${_firstNameCtrl.text} ${_lastNameCtrl.text}'),
            _reviewItem('Phone', _phoneCtrl.text),
            _reviewItem('Address', _addressCtrl.text),
            _reviewItem('CNIC', _cnicNumberCtrl.text),
            _reviewItem('Experience', _experience),
            _reviewItem('Subjects', _selectedSubjects.join(', ')),
            _reviewItem(
              'Preferred Timing',
              _selectedTimings.isNotEmpty
                  ? _selectedTimings.join(', ')
                  : 'Not specified',
            ),
            _reviewItem(
              'Certifications',
              _certNameCtrls
                  .where((c) => c.text.trim().isNotEmpty)
                  .map((c) => c.text.trim())
                  .join(', '),
            ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppColors.gold, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your teacher application requires admin approval. You\'ll be notified once reviewed.',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppColors.primaryDarkest,
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

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentStep < 2
                  ? (_currentStep == 0 && !_canProceedFromStep0
                        ? null
                        : _currentStep == 1 && !_canProceedFromStep1
                        ? null
                        : _next)
                  : (_submitting ? null : _submit),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: AppColors.gold,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.gold,
                      ),
                    )
                  : Text(
                      _currentStep < 2 ? 'Continue' : 'Submit Application',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(String label, Uint8List? image, VoidCallback onPick) {
    return GestureDetector(
      onTap: onPick,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: image != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.memory(
                      image,
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        if (label == 'Front') {
                          _cnicFront = null;
                        } else {
                          _cnicBack = null;
                        }
                      }),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.camera_alt,
                    color: AppColors.textGrey,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl,
    bool obscure,
    TextInputType type,
  ) {
    return TextField(
      controller: ctrl,
      obscureText: obscure
          ? (_obscurePass && label == 'Password' ||
                _obscureConfirm && label == 'Confirm Password')
          : false,
      keyboardType: type,
      style: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 15,
        color: AppColors.primaryDarkest,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontFamily: 'Cairo',
          color: AppColors.textGrey,
        ),
        suffixIcon: obscure
            ? IconButton(
                icon: Icon(
                  (label == 'Password' ? _obscurePass : _obscureConfirm)
                      ? Icons.visibility_off
                      : Icons.visibility,
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
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
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: AppColors.primaryDarkest,
            ),
          ),
          if (label != 'Certifications' &&
              label != 'Subjects' &&
              label != 'Preferred Timing')
            const Divider(height: 12),
        ],
      ),
    );
  }
}
