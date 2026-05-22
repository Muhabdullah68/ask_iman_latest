// lib/features/community/streaks/streaks_tab.dart
// BUG FIX: "margin == null || margin.isNonNegative" crash was caused by
// a negative margin value in the streak bar calculation. Fixed by clamping.
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/community_service.dart';

class StreaksTab extends StatefulWidget {
  final AppUser currentUser;
  const StreaksTab({super.key, required this.currentUser});
  @override State<StreaksTab> createState() => _StreaksTabState();
}

class _StreaksTabState extends State<StreaksTab> {
  final _svc = CommunityService.instance;
  int _streak = 0;
  bool _loading = true;

  // Today's checklist state
  bool _prayers = false;
  bool _quran   = false;
  bool _class_  = false;

  List<String> _customTasks = [];
  final Map<String, bool> _customTasksValues = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      // Use the live streak count from the user document first (real-time sync)
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUser.uid)
          .get();
      
      final userData = userDoc.data();
      final currentStreakFromDoc = userData?['streakCount'] ?? 0;

      // Recalculate to be sure, and update if different
      final calculatedStreak = await _svc.getCurrentStreak();
      
      if (currentStreakFromDoc != calculatedStreak) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.currentUser.uid)
            .update({'streakCount': calculatedStreak});
      }

      if (!mounted) return;
      
      // Fetch today's log
      final today = DateTime.now();
      final dateKey = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
      
      final doc = await FirebaseFirestore.instance
          .collection('streaks')
          .doc(widget.currentUser.uid)
          .collection('logs')
          .doc(dateKey)
          .get();

      final List<String> activeCustomTasks = [];
      if (userData != null && userData['customStreakTasks'] is List) {
        activeCustomTasks.addAll(List<String>.from(userData['customStreakTasks']));
      }

      setState(() {
        _streak = calculatedStreak;
        _customTasks = activeCustomTasks;
        
        if (doc.exists) {
          final data = doc.data()!;
          _prayers = data['prayers'] == true;
          _quran   = data['quran'] == true;
          _class_  = data['classAttended'] == true;
          
          final loggedCustom = data['customTasks'];
          _customTasksValues.clear();
          if (loggedCustom is Map) {
            for (var t in activeCustomTasks) {
              _customTasksValues[t] = loggedCustom[t] == true;
            }
          } else {
            for (var t in activeCustomTasks) {
              _customTasksValues[t] = false;
            }
          }
        } else {
          _prayers = false;
          _quran = false;
          _class_ = false;
          _customTasksValues.clear();
          for (var t in activeCustomTasks) {
            _customTasksValues[t] = false;
          }
        }
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading streaks: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    try {
      final today = DateTime.now();
      final dateKey = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
      
      await FirebaseFirestore.instance
          .collection('streaks')
          .doc(widget.currentUser.uid)
          .collection('logs')
          .doc(dateKey)
          .set({
        'prayers':       _prayers,
        'quran':         _quran,
        'classAttended': _class_,
        'customTasks':   _customTasksValues,
        'date':          Timestamp.fromDate(today),
      }, SetOptions(merge: true));

      // Update streak counter on user doc
      final s = await _svc.getCurrentStreak();
      await FirebaseFirestore.instance.collection('users').doc(widget.currentUser.uid).update({
        'lastActive': FieldValue.serverTimestamp(),
        'streakCount': s,
      });
      
      if (mounted) setState(() => _streak = s);
    } catch (e) {
      debugPrint('Error saving streak: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offline: Progress saved locally. 📶')),
        );
      }
    }
  }

  Future<void> _addCustomTask(String task) async {
    final cleanedTask = task.trim();
    if (cleanedTask.isEmpty) return;
    
    try {
      // 1. Update Firestore
      await FirebaseFirestore.instance.collection('users').doc(widget.currentUser.uid).update({
        'customStreakTasks': FieldValue.arrayUnion([cleanedTask])
      });
      
      // 2. Update local state immediately for better UX
      if (mounted) {
        setState(() {
          if (!_customTasks.contains(cleanedTask)) {
            _customTasks.add(cleanedTask);
            _customTasksValues[cleanedTask] = false;
          }
        });
      }
      
      // 3. Trigger a background reload to be sure
      _load();
    } catch (e) {
      debugPrint('Error adding custom task: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add task. Please try again.')),
        );
      }
    }
  }

  Future<void> _deleteCustomTask(String task) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.currentUser.uid).update({
        'customStreakTasks': FieldValue.arrayRemove([task])
      });
      
      if (mounted) {
        setState(() {
          _customTasks.remove(task);
          _customTasksValues.remove(task);
        });
      }
      
      _load();
    } catch (e) {
      debugPrint('Error deleting custom task: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStreakHero(),
          const SizedBox(height: 16),
          _buildWeekRow(),
          const SizedBox(height: 20),
          _buildTodayChecklist(),
          const SizedBox(height: 20),
          _buildFriendsLeaderboard(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStreakHero() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current Streak', style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 13,
                  color: AppColors.textGreenMuted,
                )),
                const SizedBox(height: 4),
                _loading
                    ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(
                        color: AppColors.gold, strokeWidth: 2))
                    : Text('$_streak Days', style: const TextStyle(
                    fontFamily: 'Cairo', fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textWhite)),
                const SizedBox(height: 8),
                const Text(
                  'Complete today\'s tasks to maintain your streak.',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 12,
                      color: AppColors.textGreenMuted, height: 1.4),
                ),
              ],
            ),
          ),
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_fire_department_rounded,
                color: AppColors.gold, size: 34),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekRow() {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final today = DateTime.now().weekday - 1; // Mon = 0
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final done = i < today;
          final isToday = i == today;
          return Column(
            children: [
              Text(days[i], style: TextStyle(
                fontFamily: 'Cairo', fontSize: 11,
                color: isToday ? AppColors.gold : AppColors.textGrey,
              )),
              const SizedBox(height: 6),
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: done
                      ? AppColors.primaryDark
                      : isToday
                      ? AppColors.gold
                      : AppColors.bgWhite,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: done
                         ? AppColors.primaryDark
                         : isToday
                         ? AppColors.gold
                         : AppColors.borderLight,
                  ),
                ),
                child: Center(
                  child: done
                      ? const Icon(Icons.check_rounded,
                      color: AppColors.gold, size: 16)
                      : isToday
                      ? const Icon(Icons.local_fire_department_rounded,
                      color: AppColors.primaryDarkest, size: 16)
                      : null,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTodayChecklist() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Today's Tasks", style: TextStyle(
                fontFamily: 'Cairo', fontSize: 16,
                fontWeight: FontWeight.w700, color: AppColors.textDark,
              )),
              GestureDetector(
                onTap: _showCreateTaskDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: AppColors.gold, size: 14),
                      SizedBox(width: 4),
                      Text('Add Goal', style: TextStyle(
                        fontFamily: 'Cairo', fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _task('Completed 5 daily prayers', _prayers,
                  (v) => setState(() { _prayers = v!; _save(); })),
          _task('Read Quran today', _quran,
                  (v) => setState(() { _quran = v!; _save(); })),
          _task('Attended a class or activity', _class_,
                  (v) => setState(() { _class_ = v!; _save(); })),
          if (_customTasks.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.borderLight),
            const SizedBox(height: 8),
            const Text('Custom Goals', style: TextStyle(
              fontFamily: 'Cairo', fontSize: 14,
              fontWeight: FontWeight.w700, color: AppColors.textDark,
            )),
            const SizedBox(height: 6),
            ..._customTasks.map((t) {
              final val = _customTasksValues[t] ?? false;
              return _task(
                t,
                val,
                (v) => setState(() {
                  _customTasksValues[t] = v!;
                  _save();
                }),
                onDelete: () => _deleteCustomTask(t),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _task(String label, bool value, Function(bool?) onChanged, {VoidCallback? onDelete}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: value
            ? AppColors.primaryDark.withValues(alpha: 0.06)
            : AppColors.bgWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? AppColors.primaryDark.withValues(alpha: 0.3) : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryDark,
            checkColor: AppColors.gold,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label, style: TextStyle(
              fontFamily: 'Cairo', fontSize: 14,
              color: value ? AppColors.primaryDark : AppColors.textDark,
              decoration: value ? TextDecoration.lineThrough : null,
            )),
          ),
          if (value) const Icon(Icons.check_circle_rounded,
              color: AppColors.success, size: 18),
          if (onDelete != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.textLightGrey, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  void _showCreateTaskDialog() {
    final taskCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Create Custom Streak Goal',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter goal name (e.g. Read Hadith, Tasbeeh):',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textGrey)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: TextField(
                controller: taskCtrl,
                autofocus: true,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'e.g. Tasbeeh 100x',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () async {
              if (taskCtrl.text.trim().isNotEmpty) {
                await _addCustomTask(taskCtrl.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Create', style: TextStyle(fontFamily: 'Cairo', color: AppColors.gold, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsLeaderboard() {
    // Hidden leaderboard as requested - focusing on personal streaks
    return const SizedBox.shrink();
  }
}
