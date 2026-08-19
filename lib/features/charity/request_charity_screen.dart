import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'charity_service.dart';

class RequestCharityScreen extends StatefulWidget {
  const RequestCharityScreen({super.key});

  @override
  State<RequestCharityScreen> createState() => _RequestCharityScreenState();
}

class _RequestCharityScreenState extends State<RequestCharityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _fatherNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _customCategoryCtrl = TextEditingController();
  final _customOtherCtrl = TextEditingController();

  bool _loading = false;
  bool _useCustomCategory = false;

  static const _categories = [
    'Education',
    'Health',
    'Food',
    'Housing',
    'Medical',
    'Relief',
    'Orphan',
    'Water',
    'General',
    'Other',
  ];

  static const _categoryImages = <String, String>{
    'Education': 'https://images.unsplash.com/photo-1523050854058-8df90110c7f1?w=400',
    'Health': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
    'Food': 'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=400',
    'Housing': 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=400',
    'Medical': 'https://images.unsplash.com/photo-1631217868264-e5b90bb7e133?w=400',
    'Relief': 'https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?w=400',
    'Orphan': 'https://images.unsplash.com/photo-1594608661623-aa0bd2a0c6a6?w=400',
    'Water': 'https://images.unsplash.com/photo-1538300342682-cf57afb97285?w=400',
    'General': 'https://images.unsplash.com/photo-1469571486292-0ba58a3f068b?w=400',
    'Other': 'https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?w=400',
  };

  String _selectedCategory = 'General';

  Uint8List? _cnicFront;
  Uint8List? _cnicBack;
  final List<Uint8List> _proofImages = [];
  final List<Uint8List> _documents = [];

  final _picker = ImagePicker();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _fatherNameCtrl.dispose();
    _addressCtrl.dispose();
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _amountCtrl.dispose();
    _contactCtrl.dispose();
    _emailCtrl.dispose();
    _customCategoryCtrl.dispose();
    _customOtherCtrl.dispose();
    super.dispose();
  }

  Future<void> _addProofImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1024,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      if (mounted) setState(() => _proofImages.add(bytes));
    }
  }

  Future<void> _addDocument() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1024,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      if (mounted) setState(() => _documents.add(bytes));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_proofImages.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least 2 proof images')),
      );
      return;
    }
    if (_cnicFront == null || _cnicBack == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload both front and back of your CNIC'),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final amount = double.tryParse(_amountCtrl.text) ?? 0;
      final category = _useCustomCategory
          ? _customCategoryCtrl.text
          : _selectedCategory;

      List<String> proofUrls = [];
      for (final bytes in _proofImages) {
        proofUrls.add(base64Encode(bytes));
      }

      List<String> docUrls = [];
      for (final bytes in _documents) {
        docUrls.add(base64Encode(bytes));
      }

      final cnicFrontBytes = _cnicFront!;
      final cnicBackBytes = _cnicBack!;

      await CharityService.instance.createRequest(
        title: _titleCtrl.text,
        description: _descriptionCtrl.text,
        amountNeeded: amount,
        category: _useCustomCategory && !_categories.contains(category)
            ? 'Other'
            : category,
        customCategory: _useCustomCategory ? _customCategoryCtrl.text : '',
        contactInfo: _contactCtrl.text,
        email: _emailCtrl.text,
        firstName: _firstNameCtrl.text,
        lastName: _lastNameCtrl.text,
        fatherName: _fatherNameCtrl.text,
        address: _addressCtrl.text,
        cnicFrontUrl: base64Encode(cnicFrontBytes),
        cnicBackUrl: base64Encode(cnicBackBytes),
        proofImages: proofUrls,
        documents: docUrls,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Help')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section: Personal Info ──
              _sectionTitle('Personal Information'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      'First Name *',
                      _firstNameCtrl,
                      validator: (v) =>
                          v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      'Last Name *',
                      _lastNameCtrl,
                      validator: (v) =>
                          v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildField(
                'Father Name *',
                _fatherNameCtrl,
                validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _buildField(
                'Address *',
                _addressCtrl,
                maxLines: 3,
                validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
              ),

              // ── Section: Request Details ──
              const SizedBox(height: 24),
              _sectionTitle('Request Details'),
              const SizedBox(height: 12),
              _buildField(
                'Title *',
                _titleCtrl,
                validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _buildField(
                'Description *',
                _descriptionCtrl,
                maxLines: 4,
                validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _buildField(
                'Amount Needed (\$) *',
                _amountCtrl,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v?.trim().isEmpty == true) return 'Required';
                  final amt = double.tryParse(v!);
                  if (amt == null || amt <= 0) return 'Enter valid amount';
                  return null;
                },
              ),

              // ── Category ──
              const SizedBox(height: 12),
              Text(
                'Request Type *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 6),
              if (_categoryImages[_selectedCategory] != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    _categoryImages[_selectedCategory]!,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (!_useCustomCategory)
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _selectedCategory = v);
                      if (v == 'Other') {
                        setState(() => _useCustomCategory = true);
                      }
                    }
                  },
                ),
              if (_useCustomCategory) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        'Specify your category *',
                        _customCategoryCtrl,
                        validator: (v) =>
                            v?.trim().isEmpty == true ? 'Required' : null,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _useCustomCategory = false;
                          _customCategoryCtrl.clear();
                        });
                      },
                    ),
                  ],
                ),
              ],

              // ── Section: CNIC ──
              const SizedBox(height: 24),
              _sectionTitle('CNIC (National ID)'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildImageUpload('Front *', _cnicFront, () async {
                      final f = await _picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 70,
                        maxWidth: 1024,
                      );
                      if (f != null) {
                        final bytes = await f.readAsBytes();
                        if (mounted) {
                          setState(() => _cnicFront = bytes);
                        }
                      }
                    }),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildImageUpload('Back *', _cnicBack, () async {
                      final f = await _picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 70,
                        maxWidth: 1024,
                      );
                      if (f != null) {
                        final bytes = await f.readAsBytes();
                        if (mounted) {
                          setState(() => _cnicBack = bytes);
                        }
                      }
                    }),
                  ),
                ],
              ),

              // ── Section: Proof Images ──
              const SizedBox(height: 24),
              _sectionTitle('Proof Images (Minimum 2)'),
              const SizedBox(height: 12),
              _buildFileList(
                _proofImages,
                'Add Proof Image',
                _addProofImage,
                (i) => setState(() => _proofImages.removeAt(i)),
              ),

              // ── Section: Documents ──
              const SizedBox(height: 24),
              _sectionTitle('Relevant Documents (Optional)'),
              const SizedBox(height: 12),
              _buildFileList(
                _documents,
                'Add Document',
                _addDocument,
                (i) => setState(() => _documents.removeAt(i)),
              ),

              // ── Section: Contact ──
              const SizedBox(height: 24),
              _sectionTitle('Contact Information'),
              const SizedBox(height: 12),
              _buildField(
                'Phone Number *',
                _contactCtrl,
                keyboardType: TextInputType.phone,
                validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _buildField(
                'Email (Optional)',
                _emailCtrl,
                keyboardType: TextInputType.emailAddress,
              ),

              // ── Submit ──
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9A84C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Submit Request',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF1A2E35),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctl, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildImageUpload(String label, Uint8List? image, VoidCallback onPick) {
    return GestureDetector(
      onTap: onPick,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: image != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      image,
                      width: double.infinity,
                      height: 130,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        if (label.startsWith('Front')) _cnicFront = null;
                        if (label.startsWith('Back')) _cnicBack = null;
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
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt, color: Colors.grey, size: 32),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFileList(
    List<Uint8List> files,
    String addLabel,
    VoidCallback onAdd,
    void Function(int) onRemove,
  ) {
    return Column(
      children: [
        if (files.isNotEmpty)
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: files.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        files[i],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => onRemove(i),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
          label: Text(addLabel),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFC9A84C),
            side: const BorderSide(color: Color(0xFFC9A84C)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
