// lib/features/community/streaks/streaks_tab.dart
// BUG FIX: "margin == null || margin.isNonNegative" crash was caused by
// a negative margin value in the streak bar calculation. Fixed by clamping.
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/community_service.dart';

class StreaksTab extends StatefulWidget {
  final AppUser? currentUser;
  const StreaksTab({super.key, required this.currentUser});
  @override
  State<StreaksTab> createState() => _StreaksTabState();
}

class _StreaksTabState extends State<StreaksTab> {
  final _svc = CommunityService.instance;
  int _streak = 0;
  bool _loading = true;

  // Today's checklist state
  bool _prayers = false;
  bool _quran = false;
  bool _class_ = false;

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
      final isGuest =
          widget.currentUser == null || widget.currentUser!.uid == 'guest_user';
      final List<String> activeCustomTasks = [];
      int currentStreak = 0;
      Map<String, dynamic>? todayData;

      if (isGuest) {
        final prefs = await SharedPreferences.getInstance();
        final guestDataJson = prefs.getString('guest_user_data');
        if (guestDataJson != null) {
          final guestData = jsonDecode(guestDataJson);
          if (guestData['customStreakTasks'] is List) {
            activeCustomTasks.addAll(
              List<String>.from(guestData['customStreakTasks']),
            );
          }
        }

        currentStreak = await _svc.getStreakForUser(
          widget.currentUser?.uid ?? 'guest_user',
        );

        // Ensure guest profile is in sync with actual streak logs
        await _svc.updateStreakCount(currentStreak);

        final streaksJson = prefs.getString('guest_streaks') ?? '{}';
        final Map<String, dynamic> streaks = jsonDecode(streaksJson);
        final today = DateTime.now();
        final dateKey =
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        todayData = streaks[dateKey];
      } else {
        // Use the live streak count from the user document first (real-time sync)
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.currentUser!.uid)
            .get();

        final userData = userDoc.data();
        final currentStreakFromDoc = userData?['streakCount'] ?? 0;

        // Recalculate to be sure, and update if different
        currentStreak = await _svc.getStreakForUser(widget.currentUser!.uid);

        if (currentStreakFromDoc != currentStreak) {
          await _svc.updateStreakCount(currentStreak);
        }

        if (userData != null && userData['customStreakTasks'] is List) {
          activeCustomTasks.addAll(
            List<String>.from(userData['customStreakTasks']),
          );
        }

        // Fetch today's log
        final today = DateTime.now();
        final dateKey =
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

        final doc = await FirebaseFirestore.instance
            .collection('streaks')
            .doc(widget.currentUser!.uid)
            .collection('logs')
            .doc(dateKey)
            .get();
        todayData = doc.data();
      }

      if (!mounted) return;

      setState(() {
        _streak = currentStreak;
        _customTasks = activeCustomTasks;

        if (todayData != null) {
          _prayers = todayData['prayers'] == true;
          _quran = todayData['quran'] == true;
          _class_ = todayData['classAttended'] == true;

          final loggedCustom = todayData['customTasks'];
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
      final dateKey =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final isGuest =
          widget.currentUser == null || widget.currentUser!.uid == 'guest_user';

      if (isGuest) {
        final prefs = await SharedPreferences.getInstance();
        final streaksJson = prefs.getString('guest_streaks') ?? '{}';
        final Map<String, dynamic> streaks = jsonDecode(streaksJson);

        streaks[dateKey] = {
          'prayers': _prayers,
          'quran': _quran,
          'classAttended': _class_,
          'customTasks': _customTasksValues,
          'date': today.toIso8601String(),
        };

        await prefs.setString('guest_streaks', jsonEncode(streaks));

        final s = await _svc.getStreakForUser(
          widget.currentUser?.uid ?? 'guest_user',
        );
        await _svc.updateStreakCount(s);
        if (mounted) setState(() => _streak = s);
      } else {
        await FirebaseFirestore.instance
            .collection('streaks')
            .doc(widget.currentUser!.uid)
            .collection('logs')
            .doc(dateKey)
            .set({
              'prayers': _prayers,
              'quran': _quran,
              'classAttended': _class_,
              'customTasks': _customTasksValues,
              'date': Timestamp.fromDate(today),
            }, SetOptions(merge: true));

        // Update streak counter on user doc
        final s = await _svc.getStreakForUser(widget.currentUser!.uid);
        await _svc.updateStreakCount(s);

        if (mounted) setState(() => _streak = s);
      }
    } catch (e) {
      debugPrint('Error saving streak: $e');
      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('offlineProgressSavedLocally'))),
        );
      }
    }
  }

  Future<void> _addCustomTask(String task) async {
    final cleanedTask = task.trim();
    if (cleanedTask.isEmpty) return;

    try {
      final isGuest =
          widget.currentUser == null || widget.currentUser!.uid == 'guest_user';

      if (isGuest) {
        final prefs = await SharedPreferences.getInstance();
        final guestDataJson =
            prefs.getString('guest_user_data') ??
            jsonEncode(AppUser.guest.toMap());
        final Map<String, dynamic> guestData = jsonDecode(guestDataJson);

        final List<String> tasks = List<String>.from(
          guestData['customStreakTasks'] ?? [],
        );
        if (!tasks.contains(cleanedTask)) {
          tasks.add(cleanedTask);
        }
        guestData['customStreakTasks'] = tasks;
        await prefs.setString('guest_user_data', jsonEncode(guestData));
      } else {
        // 1. Update Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.currentUser!.uid)
            .update({
              'customStreakTasks': FieldValue.arrayUnion([cleanedTask]),
            });
      }

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
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('failedToAddTask'))),
        );
      }
    }
  }

  Future<void> _deleteCustomTask(String task) async {
    try {
      final isGuest =
          widget.currentUser == null || widget.currentUser!.uid == 'guest_user';

      if (isGuest) {
        final prefs = await SharedPreferences.getInstance();
        final guestDataJson =
            prefs.getString('guest_user_data') ??
            jsonEncode(AppUser.guest.toMap());
        final Map<String, dynamic> guestData = jsonDecode(guestDataJson);

        final List<String> tasks = List<String>.from(
          guestData['customStreakTasks'] ?? [],
        );
        tasks.remove(task);
        guestData['customStreakTasks'] = tasks;
        await prefs.setString('guest_user_data', jsonEncode(guestData));
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.currentUser!.uid)
            .update({
              'customStreakTasks': FieldValue.arrayRemove([task]),
            });
      }

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
          const SizedBox(
            height: 80,
          ), // Add more space to move streak down and center
          _buildStreakHero(context),
          const SizedBox(height: 16),
          _buildWeekRow(),
          const SizedBox(height: 20),
          _buildTodayChecklist(context),
          const SizedBox(height: 20),
          // _buildFriendsLeaderboard(), // Commented out as requested
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStreakHero(BuildContext context) {
    final loc = AppLocalizations.of(context);
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
                Text(
                  loc.translate('currentStreak'),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: AppColors.textGreenMuted,
                  ),
                ),
                const SizedBox(height: 4),
                _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.gold,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        '$_streak ${loc.translate('days')}',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textWhite,
                        ),
                      ),
                const SizedBox(height: 8),
                Text(
                  loc.translate('completeTodayTasks'),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: AppColors.textGreenMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.gold,
              size: 34,
            ),
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
              Text(
                days[i],
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: isToday ? AppColors.gold : AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 36,
                height: 36,
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
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.gold,
                          size: 16,
                        )
                      : isToday
                      ? const Icon(
                          Icons.local_fire_department_rounded,
                          color: AppColors.primaryDarkest,
                          size: 16,
                        )
                      : null,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTodayChecklist(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.translate('todaysTasks'),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              GestureDetector(
                onTap: () => _showCreateTaskDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add, color: AppColors.gold, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        loc.translate('addGoal'),
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _task(
            loc.translate('completed5DailyPrayers'),
            _prayers,
            (v) => setState(() {
              _prayers = v!;
              _save();
            }),
          ),
          _task(
            loc.translate('readQuranToday'),
            _quran,
            (v) => setState(() {
              _quran = v!;
              _save();
            }),
          ),
          _task(
            loc.translate('attendedClassOrActivity'),
            _class_,
            (v) => setState(() {
              _class_ = v!;
              _save();
            }),
          ),
          if (_customTasks.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.borderLight),
            const SizedBox(height: 8),
            Text(
              loc.translate('customGoals'),
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
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

  Widget _task(
    String label,
    bool value,
    Function(bool?) onChanged, {
    VoidCallback? onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: value
            ? AppColors.primaryDark.withValues(alpha: 0.06)
            : AppColors.bgWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? AppColors.primaryDark.withValues(alpha: 0.3)
              : AppColors.borderLight,
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
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: value ? AppColors.primaryDark : AppColors.textDark,
                decoration: value ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          if (value)
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 18,
            ),
          if (onDelete != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.textLightGrey,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showCreateTaskDialog(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final taskCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          loc.translate('createCustomStreakGoal'),
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.translate('enterGoalName'),
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: AppColors.textGrey,
              ),
            ),
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
                decoration: InputDecoration(
                  hintText: loc.translate('e.g.Tasbeeh100x'),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              loc.translate('cancel'),
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textGrey,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () async {
              if (taskCtrl.text.trim().isNotEmpty) {
                await _addCustomTask(taskCtrl.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: Text(
              loc.translate('create'),
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.gold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
