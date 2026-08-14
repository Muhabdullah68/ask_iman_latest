import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/alarm_service.dart';
import '../../shared/widgets/ask_iman_app_bar.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> with WidgetsBindingObserver {
  final AlarmService _alarmService = AlarmService.instance;
  bool _isBatteryOptimized = false;
  bool _bannerDismissed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _alarmService.addListener(_onUpdate);
    if (!kIsWeb && Platform.isAndroid) {
      _checkBatteryOptimization();
      _checkPowerSavingMode();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _alarmService.removeListener(_onUpdate);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !kIsWeb && Platform.isAndroid) {
      _checkBatteryOptimization();
      _checkPowerSavingMode();
      setState(() {
        _bannerDismissed = false; // Show banner again when app resumes
      });
    }
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _checkBatteryOptimization() async {
    final status = await Permission.ignoreBatteryOptimizations.status;
    if (mounted) {
      setState(() {
        _isBatteryOptimized = status.isGranted;
      });
    }
  }

  Future<void> _checkPowerSavingMode() async {
    // On Android, we can't directly check power saving mode via permission_handler
    // but we can check battery optimization and inform the user
    // For Samsung specifically, we can show a more prominent warning
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _requestBatteryOptimization() async {
    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      final status = await Permission.ignoreBatteryOptimizations.request();
      if (mounted) {
        setState(() {
          _isBatteryOptimized = status.isGranted;
        });
      }
      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
    }
  }

  void _showBatteryGuideDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final loc = AppLocalizations.of(ctx);
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              const Icon(Icons.battery_alert, color: AppColors.warning),
              const SizedBox(width: 12),
              Text(
                loc.translate('keepAlarmsReliable'),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.translate('batteryGuideIntro'),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  color: AppColors.textDark,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              _guideStep('1', loc.translate('disableBatteryOptimization')),
              const SizedBox(height: 8),
              _guideStep('2', loc.translate('enableAutostart')),
              const SizedBox(height: 8),
              _guideStep('3', loc.translate('samsungBatteryGuide')),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Battery optimization is the #1 reason alarms don\'t work\nwhen the app is closed on Samsung devices.',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: AppColors.textGrey,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                loc.translate('later'),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textGrey,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: AppColors.textCream,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                await _requestBatteryOptimization();
              },
              child: Text(
                loc.translate('fixNow'),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _guideStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textCream,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              color: AppColors.textDark,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openAlarmDialog({Alarm? existingAlarm}) async {
    final result = await showDialog<Alarm?>(
      context: context,
      builder: (context) => AlarmDialog(existingAlarm: existingAlarm),
    );

    if (result != null && mounted) {
      if (existingAlarm != null) {
        await _alarmService.updateAlarm(existingAlarm, result);
      } else {
        await _alarmService.addAlarm(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: const AskImanAppBar(showBackButton: true),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Battery Optimization Banner
            if (!kIsWeb &&
                Platform.isAndroid &&
                !_isBatteryOptimized &&
                !_bannerDismissed)
              _buildBatteryBanner(),

            // Header
            Row(
              children: [
                Text(
                  AppLocalizations.of(context).translate('ibadahReminders'),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const Spacer(),
                if (!kIsWeb)
                  GestureDetector(
                    onTap: () => _openAlarmDialog(),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDark.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        color: AppColors.textCream,
                        size: 28,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Web: local alarms unsupported — show browser-notification info
            if (kIsWeb) ...[
              _buildWebInfoCard(),
              const SizedBox(height: 24),
            ],

            // Alarms List
            if (_alarmService.alarms.isEmpty)
              _buildEmptyState()
            else
              ..._alarmService.alarms.map((alarm) {
                return _buildAlarmCard(alarm);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildWebInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D2818), Color(0xFF1A3D28)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDarkest.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notifications_active_outlined,
                color: AppColors.gold,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Prayer reminders on web',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Local alarm scheduling is only available in the mobile app. '
            'Enable browser notifications to receive prayer time reminders on this device.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Firebase Cloud Messaging (project: ask-iman-prod)',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'VAPID key: Firebase console → Project settings → Cloud Messaging → '
                  'Web Push certificates. Wire it with a service worker to push '
                  'prayer-time notifications from the server.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryBanner() {
    final loc = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.battery_alert_rounded,
              color: AppColors.warning,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.translate('alarmsMayNotWork'),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: _showBatteryGuideDialog,
                  child: Text(
                    loc.translate('tapToFixBatteryOpt'),
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _bannerDismissed = true),
            child: Icon(
              Icons.close,
              size: 20,
              color: AppColors.textGrey.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final loc = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.alarm_add_rounded,
              size: 64,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            loc.translate('noRemindersSet'),
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            loc.translate('setDailyReminders'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              height: 1.5,
              color: AppColors.textGrey.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _openAlarmDialog(),
            icon: const Icon(Icons.add, size: 20),
            label: Text(
              loc.translate('createReminder'),
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: AppColors.textCream,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmCard(Alarm alarm) {
    final loc = AppLocalizations.of(context);
    final formattedTime = _formatTime(alarm.time);
    final soundNumber = AlarmService.availableSounds.indexOf(alarm.sound) + 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: alarm.isEnabled ? AppColors.bgWhite : AppColors.bgCream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: alarm.isEnabled
              ? AppColors.primaryDark.withValues(alpha: 0.12)
              : AppColors.borderLight.withValues(alpha: 0.5),
          width: alarm.isEnabled ? 1.5 : 1,
        ),
        boxShadow: alarm.isEnabled
            ? [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Alarm icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: alarm.isEnabled
                      ? AppColors.primaryDark.withValues(alpha: 0.08)
                      : AppColors.textGrey.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.access_alarm_rounded,
                  color: alarm.isEnabled
                      ? AppColors.primaryDark
                      : AppColors.textGrey,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              // Time and Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedTime,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: alarm.isEnabled
                            ? AppColors.textDark
                            : AppColors.textGrey,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alarm.title,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: alarm.isEnabled
                            ? AppColors.textDark
                            : AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              // Toggle
              Switch(
                value: alarm.isEnabled,
                onChanged: (enabled) =>
                    _alarmService.toggleAlarm(alarm.id, enabled),
                activeTrackColor: AppColors.primaryDark.withValues(alpha: 0.5),
                activeThumbColor: AppColors.primaryDark,
              ),
            ],
          ),
          if (alarm.repeatDays.any((d) => d) || alarm.isEnabled)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Row(
                children: [
                  if (alarm.repeatDays.any((d) => d))
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: alarm.isEnabled
                            ? AppColors.primaryDark.withValues(alpha: 0.06)
                            : AppColors.textGrey.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatRepeatDays(alarm.repeatDays),
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: alarm.isEnabled
                              ? AppColors.primaryDark
                              : AppColors.textGrey,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: alarm.isEnabled
                          ? AppColors.primaryDark.withValues(alpha: 0.06)
                          : AppColors.textGrey.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      loc
                          .translate('soundNumber')
                          .replaceAll('\$number', '$soundNumber'),
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: alarm.isEnabled
                            ? AppColors.primaryDark
                            : AppColors.textGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _actionChip(
                icon: Icons.edit_rounded,
                label: loc.translate('edit'),
                color: AppColors.primaryDark,
                onTap: () => _openAlarmDialog(existingAlarm: alarm),
              ),
              const SizedBox(width: 10),
              _actionChip(
                icon: Icons.delete_outline_rounded,
                label: loc.translate('delete'),
                color: AppColors.error,
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) {
                      final dloc = AppLocalizations.of(ctx);
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: Text(
                          dloc.translate('deleteReminder'),
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                        content: Text(
                          dloc.translate('cannotBeUndone'),
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            color: AppColors.textGrey,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: Text(
                              dloc.translate('cancel'),
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                color: AppColors.textGrey,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: Text(
                              dloc.translate('delete'),
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                color: AppColors.error,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm == true) {
                    await _alarmService.deleteAlarm(alarm.id);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color.withValues(alpha: 0.9), size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: color.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('h:mm a').format(dt);
  }

  String _formatRepeatDays(List<bool> days) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final selected = <String>[];
    for (int i = 0; i < 7; i++) {
      if (days[i]) selected.add(dayNames[i]);
    }
    if (selected.length == 7) return 'Every day';
    return selected.join(', ');
  }
}

class AlarmDialog extends StatefulWidget {
  final Alarm? existingAlarm;

  const AlarmDialog({super.key, this.existingAlarm});

  @override
  State<AlarmDialog> createState() => _AlarmDialogState();
}

class _AlarmDialogState extends State<AlarmDialog> {
  final AlarmService _alarmService = AlarmService.instance;

  late final TextEditingController _titleController;
  late TimeOfDay _selectedTime;
  late String _selectedSound;
  late List<bool> _repeatDays;
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingAlarm;
    _titleController = TextEditingController(
      text: existing?.title ?? 'Ibadah Reminder',
    );
    _selectedTime = existing?.time ?? TimeOfDay.now();
    _selectedSound = existing?.sound ?? AlarmService.availableSounds[0];
    _repeatDays = existing?.repeatDays ?? List.generate(7, (_) => false);
    _isEnabled = existing?.isEnabled ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.95,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bgWhite,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primaryMid],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.goldDark.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.alarm_rounded,
                          color: AppColors.primaryDarkest,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.existingAlarm != null
                                  ? loc.translate('editReminder')
                                  : loc.translate('newReminder'),
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.existingAlarm != null
                                  ? 'Update your reminder'
                                  : 'Create a new reminder',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textCream.withValues(
                                  alpha: 0.85,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Title
                Text(
                  loc.translate('title'),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgCream,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _titleController,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      color: AppColors.textDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter reminder title',
                      hintStyle: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        color: AppColors.textGrey.withValues(alpha: 0.6),
                      ),
                      prefixIcon: const Icon(
                        Icons.edit_note_rounded,
                        color: AppColors.primaryDark,
                        size: 24,
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 52),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Time Picker
                Text(
                  loc.translate('time'),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppColors.primaryDark,
                              onPrimary: Colors.white,
                              surface: AppColors.bgWhite,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (time != null && mounted) {
                      setState(() {
                        _selectedTime = time;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryDark, AppColors.primaryMid],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.gold,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.goldDark.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.schedule_rounded,
                                size: 32,
                                color: AppColors.primaryDarkest,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Text(
                              _formatTime(_selectedTime),
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.gold, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.touch_app_rounded,
                                size: 16,
                                color: AppColors.gold,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                loc.translate('tapToChange'),
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Repeat Days
                Text(
                  loc.translate('repeat'),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgCream,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(7, (index) {
                        const dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        final isSelected = _repeatDays[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            left: index == 0 ? 0 : 4,
                            right: index == 6 ? 0 : 4,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _repeatDays[index] = !_repeatDays[index];
                              });
                            },
                            child: Container(
                              width: 44,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryDark
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.gold
                                      : AppColors.borderLight,
                                  width: isSelected ? 2 : 1.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primaryDark
                                              .withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  dayNames[index],
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textDark,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sound Picker
                Text(
                  loc.translate('sound'),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgCream,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: AlarmService.availableSounds.asMap().entries.map((
                      entry,
                    ) {
                      final index = entry.key + 1;
                      final sound = entry.value;
                      final isSelected = sound == _selectedSound;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: entry.key == 0 ? 0 : 4,
                            right:
                                entry.key ==
                                    AlarmService.availableSounds.length - 1
                                ? 0
                                : 4,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSound = sound;
                              });
                              _alarmService.previewSound(sound);
                            },
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.gold
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.goldDark
                                      : AppColors.borderLight,
                                  width: 2,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.gold.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.play_circle_filled_rounded
                                        : Icons.music_note_rounded,
                                    size: 22,
                                    color: isSelected
                                        ? AppColors.primaryDarkest
                                        : AppColors.primaryDark,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$index',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      color: isSelected
                                          ? AppColors.primaryDarkest
                                          : AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.bgCream,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            loc.translate('cancel'),
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                            foregroundColor: AppColors.textCream,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            shadowColor: AppColors.primaryDark.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          onPressed: () {
                            final alarm = Alarm(
                              id: widget.existingAlarm?.id ?? '',
                              title: _titleController.text.trim(),
                              time: _selectedTime,
                              sound: _selectedSound,
                              isEnabled: _isEnabled,
                              repeatDays: _repeatDays,
                            );
                            Navigator.of(context).pop(alarm);
                          },
                          child: Text(
                            widget.existingAlarm != null
                                ? loc.translate('saveChanges')
                                : loc.translate('save'),
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('h:mm a').format(dt);
  }
}
