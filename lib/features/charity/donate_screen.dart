import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/ask_iman_app_bar.dart';
import 'charity_service.dart';

class DonateScreen extends StatefulWidget {
  final String? causeId;
  final String? causeTitle;
  const DonateScreen({super.key, this.causeId, this.causeTitle});

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  final _svc = CharityService.instance;
  final _amountCtl = TextEditingController();
  final _messageCtl = TextEditingController();
  final _picker = ImagePicker();
  bool _anonymous = false;
  bool _loading = false;
  String? _selectedCauseId;
  String? _selectedCauseTitle;
  Uint8List? _screenshotBytes;

  final _presets = [5, 10, 25, 50, 100];

  @override
  void initState() {
    super.initState();
    _selectedCauseId = widget.causeId;
    _selectedCauseTitle = widget.causeTitle;
  }

  @override
  void dispose() {
    _amountCtl.dispose();
    _messageCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: const AskImanAppBar(title: 'Donate'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedCauseId == null) _buildCausePicker(),
            if (_selectedCauseId != null) ...[
              _buildSelectedCause(),
              const SizedBox(height: 20),
              const Text(
                'Select Amount',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDarkest,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _presets.map((amt) {
                  final active = _amountCtl.text == amt.toString();
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _amountCtl.text = amt.toString()),
                    child: Container(
                      width: 64,
                      height: 48,
                      decoration: BoxDecoration(
                        color: active ? AppColors.gold : AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(10),
                        border: active
                            ? Border.all(color: AppColors.gold, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '\$$amt',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: active
                                ? AppColors.primaryDarkest
                                : AppColors.textWhite,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountCtl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Custom amount',
                  prefixText: '\$ ',
                  hintStyle: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textGrey,
                  ),
                  filled: true,
                  fillColor: AppColors.primaryDark,
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
                  fontSize: 15,
                  color: AppColors.textWhite,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _messageCtl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add a message (optional)',
                  hintStyle: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textGrey,
                  ),
                  filled: true,
                  fillColor: AppColors.primaryDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: AppColors.textWhite,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: _anonymous,
                    onChanged: (v) => setState(() => _anonymous = v ?? false),
                    activeColor: AppColors.gold,
                    checkColor: AppColors.primaryDarkest,
                  ),
                  const Text(
                    'Donate anonymously',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickScreenshot,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _screenshotBytes != null
                            ? Icons.check_circle
                            : Icons.camera_alt_outlined,
                        color: _screenshotBytes != null
                            ? AppColors.gold
                            : AppColors.textGrey,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _screenshotBytes != null
                              ? 'Screenshot selected'
                              : 'Upload payment screenshot (required)',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            color: _screenshotBytes != null
                                ? AppColors.gold
                                : AppColors.textGrey,
                          ),
                        ),
                      ),
                      if (_screenshotBytes != null)
                        GestureDetector(
                          onTap: () => setState(() => _screenshotBytes = null),
                          child: const Icon(
                            Icons.close,
                            color: AppColors.error,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  // ignore: sort_child_properties_last
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryDarkest,
                          ),
                        )
                      : const Text(
                          'Complete Donation',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.primaryDarkest,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCausePicker() {
    return StreamBuilder<List<CharityCause>>(
      stream: _svc.watchActiveCauses(),
      builder: (ctx, snap) {
        final causes = snap.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a Cause',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDarkest,
              ),
            ),
            const SizedBox(height: 12),
            ...causes.map(
              (c) => Card(
                color: AppColors.primaryDark,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    c.title,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textWhite,
                    ),
                  ),
                  subtitle: Text(
                    c.category,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: AppColors.textGrey,
                    ),
                  ),
                  trailing: Text(
                    '\$${c.goal.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppColors.gold,
                    ),
                  ),
                  onTap: () => setState(() {
                    _selectedCauseId = c.id;
                    _selectedCauseTitle = c.title;
                  }),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSelectedCause() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite, color: AppColors.gold, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _selectedCauseTitle ?? '',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textWhite,
              ),
            ),
          ),
          TextButton(
            onPressed: () => setState(() {
              _selectedCauseId = null;
              _selectedCauseTitle = null;
            }),
            child: const Text(
              'Change',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: AppColors.gold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickScreenshot() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
    );
    if (file != null) {
      final bytes = await file.readAsBytes();
      if (mounted) setState(() => _screenshotBytes = bytes);
    }
  }

  Future<String> _uploadScreenshot() async {
    if (_screenshotBytes == null) throw Exception('No screenshot selected');
    return base64Encode(_screenshotBytes!);
  }

  Future<void> _submit() async {
    final amountText = _amountCtl.text.trim();
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }
    if (_selectedCauseId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a cause')));
      return;
    }
    if (_screenshotBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a payment screenshot')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final screenshotUrl = await _uploadScreenshot();
      await _svc.donate(
        causeId: _selectedCauseId!,
        amount: amount,
        anonymous: _anonymous,
        message: _messageCtl.text.trim().isEmpty
            ? null
            : _messageCtl.text.trim(),
        screenshotUrl: screenshotUrl,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Donation submitted for review! JazakAllah Khair.'),
          backgroundColor: AppColors.primaryDarkest,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
