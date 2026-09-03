import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/alarm_service.dart';
import '../../shared/widgets/ask_iman_app_bar.dart';
import 'family_service.dart';

class CreateReminderScreen extends StatefulWidget {
  final String groupId;
  final FamilyReminder? existing; // null = create, non-null = edit
  const CreateReminderScreen({super.key, required this.groupId, this.existing});

  @override
  State<CreateReminderScreen> createState() => _CreateReminderScreenState();
}

class _CreateReminderScreenState extends State<CreateReminderScreen> {
  final _svc = FamilyService.instance;
  final _titleCtl = TextEditingController();
  final _descCtl = TextEditingController();
  final _customTypeCtl = TextEditingController();
  String _type = 'prayer';
  bool _useCustomType = false;
  bool _recurring = false;
  List<String> _selectedDays = [];
  DateTime? _scheduledAt;
  bool _loading = false;
  String _selectedSound = 'alarm1';
  String? _selectedImage;

  static const _types = ['prayer', 'quran', 'fasting', 'dua', 'mosque', 'zakat', 'hajj', 'general'];
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _sounds = ['alarm1', 'alarm2', 'alarm3', 'alarm4', 'alarm5'];
  static const _soundNames = [
    'Alarm 1',
    'Alarm 2',
    'Alarm 3',
    'Alarm 4',
    'Alarm 5',
  ];

  static const _typeImages = <String, String>{
    'prayer':
        'https://images.unsplash.com/photo-1585232003489-7e28b12b8b00?w=400&q=80',
    'quran':
        'https://images.unsplash.com/photo-1609599002809-0f4a0b1a28e3?w=400&q=80',
    'fasting':
        'https://images.unsplash.com/photo-1590674899484-d5640d9a4bb2?w=400&q=80',
    'dua':
        'https://images.unsplash.com/photo-1591604021695-2c1db5f3fc4d?w=400&q=80',
    'mosque':
        'https://images.unsplash.com/photo-1564769625905-4d70b7a0217c?w=400&q=80',
    'zakat':
        'https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?w=400&q=80',
    'hajj':
        'https://images.unsplash.com/photo-1564770066608-bf36c4130ec2?w=400&q=80',
    'general':
        'https://images.unsplash.com/photo-1633425301875-08c6e03a28b5?w=400&q=80',
    'other':
        'https://images.unsplash.com/photo-1633425301875-08c6e03a28b5?w=400&q=80',
  };

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _titleCtl.text = e.title;
      if (e.description != null) _descCtl.text = e.description!;
      if (_types.contains(e.type)) {
        _type = e.type;
      } else {
        _useCustomType = true;
        _customTypeCtl.text = e.type;
      }
      _recurring = e.recurring;
      if (e.recurringDays != null) _selectedDays = List.from(e.recurringDays!);
      _selectedSound = e.sound ?? 'alarm1';
      _selectedImage = e.imageUrl;
    }
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _descCtl.dispose();
    _customTypeCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AskImanAppBar(title: isEdit ? 'Edit Reminder' : 'New Reminder'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit
                  ? 'Update your reminder'
                  : 'Create a reminder for your group',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDarkest,
              ),
            ),
            const SizedBox(height: 20),

            // ── Cover Image ──
            const Text(
              'Cover Image',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDarkest,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _typeImages.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final entry = _typeImages.entries.elementAt(i);
                  final active = _selectedImage == entry.value;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedImage = entry.value),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            entry.value,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 120,
                              height: 120,
                              color: AppColors.primaryDark,
                              child: const Icon(
                                Icons.image,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ),
                        ),
                        if (active)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.gold,
                                  width: 3,
                                ),
                                color: Colors.black26,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.check_circle,
                                  color: AppColors.gold,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              entry.key[0].toUpperCase() +
                                  entry.key.substring(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            _buildField('Title', _titleCtl, hint: 'e.g., Fajr prayer check-in'),
            const SizedBox(height: 14),
            _buildField(
              'Description (optional)',
              _descCtl,
              maxLines: 3,
              hint: 'e.g., Did everyone pray Fajr?',
            ),
            const SizedBox(height: 14),

            // ── Type ──
            const Text(
              'Type',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDarkest,
              ),
            ),
            const SizedBox(height: 8),
            if (!_useCustomType)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._types.map((t) {
                    final active = _type == t;
                    return ChoiceChip(
                      label: Text(
                        t[0].toUpperCase() + t.substring(1),
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: active
                              ? AppColors.primaryDarkest
                              : AppColors.textGrey,
                        ),
                      ),
                      selected: active,
                      selectedColor: AppColors.gold,
                      backgroundColor: AppColors.primaryDark,
                      onSelected: (_) => setState(() => _type = t),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    );
                  }),
                  ActionChip(
                    label: const Text(
                      'Other...',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                    backgroundColor: AppColors.primaryDark,
                    onPressed: () => setState(() => _useCustomType = true),
                  ),
                ],
              ),
            if (_useCustomType)
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      'Custom Type',
                      _customTypeCtl,
                      hint: 'e.g., Family Meeting',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textGrey),
                    onPressed: () {
                      setState(() {
                        _useCustomType = false;
                        _customTypeCtl.clear();
                      });
                    },
                  ),
                ],
              ),
            const SizedBox(height: 14),

            // ── Recurring ──
            Row(
              children: [
                Checkbox(
                  value: _recurring,
                  onChanged: (v) => setState(() => _recurring = v ?? false),
                  activeColor: AppColors.gold,
                  checkColor: AppColors.primaryDarkest,
                ),
                const Text(
                  'Repeat weekly',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
            if (_recurring) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _days.map((d) {
                  final active = _selectedDays.contains(d);
                  return FilterChip(
                    label: Text(
                      d,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: active
                            ? AppColors.primaryDarkest
                            : AppColors.textGrey,
                      ),
                    ),
                    selected: active,
                    selectedColor: AppColors.gold,
                    backgroundColor: AppColors.primaryDark,
                    onSelected: (v) => setState(() {
                      if (v) {
                        _selectedDays.add(d);
                      } else {
                        _selectedDays.remove(d);
                      }
                    }),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 14),

            // ── Date/Time ──
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickDateTime,
                icon: const Icon(Icons.schedule, color: AppColors.gold),
                label: Text(
                  _scheduledAt != null
                      ? _formatDateTime(_scheduledAt!)
                      : 'Set reminder time (optional)',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: AppColors.textWhite,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  side: const BorderSide(color: AppColors.gold),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Sound ──
            const Text(
              'Sound',
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
              children: _sounds.asMap().entries.map((entry) {
                final index = entry.key;
                final sound = entry.value;
                final active = _selectedSound == sound;
                return ChoiceChip(
                  label: Text(
                    _soundNames[index],
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: active
                          ? AppColors.primaryDarkest
                          : AppColors.textGrey,
                    ),
                  ),
                  selected: active,
                  selectedColor: AppColors.gold,
                  backgroundColor: AppColors.primaryDark,
                  onSelected: (_) {
                    setState(() => _selectedSound = sound);
                    final fullPath = 'assets/sounds/$sound.wav';
                    AlarmService.instance.previewSound(fullPath);
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Submit ──
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
                    : Text(
                        isEdit ? 'Update Reminder' : 'Create Reminder',
                        style: const TextStyle(
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
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctl, {
    int maxLines = 1,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDarkest,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctl,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textGrey,
              fontSize: 12,
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
            fontSize: 13,
            color: AppColors.textWhite,
          ),
        ),
      ],
    );
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: _scheduledAt != null
          ? TimeOfDay.fromDateTime(_scheduledAt!)
          : const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null || !mounted) return;
    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  String _formatDateTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year} $h:$m';
  }

  Future<void> _submit() async {
    final title = _titleCtl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }

    final effectiveType = _useCustomType ? _customTypeCtl.text.trim() : _type;
    if (_useCustomType && effectiveType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a custom type')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final e = widget.existing;
      if (e != null) {
        await _svc.updateReminder(
          reminderId: e.id,
          title: title,
          description: _descCtl.text.trim().isEmpty
              ? null
              : _descCtl.text.trim(),
          type: effectiveType,
          recurring: _recurring,
          recurringDays: _recurring && _selectedDays.isNotEmpty
              ? _selectedDays
              : null,
          scheduledAt: _scheduledAt,
          sound: _selectedSound,
          imageUrl: _selectedImage,
        );
      } else {
        await _svc.createReminder(
          groupId: widget.groupId,
          title: title,
          description: _descCtl.text.trim().isEmpty
              ? null
              : _descCtl.text.trim(),
          type: effectiveType,
          recurring: _recurring,
          recurringDays: _recurring && _selectedDays.isNotEmpty
              ? _selectedDays
              : null,
          scheduledAt: _scheduledAt,
          sound: _selectedSound,
          imageUrl: _selectedImage,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
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
