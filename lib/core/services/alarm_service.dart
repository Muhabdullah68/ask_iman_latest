
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'notification_service.dart';

class Alarm {
  final String id;
  final String title;
  final TimeOfDay time;
  final String sound;
  final bool isEnabled;
  final List<bool> repeatDays;

  Alarm({
    required this.id,
    required this.title,
    required this.time,
    required this.sound,
    required this.isEnabled,
    required this.repeatDays,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'hour': time.hour,
      'minute': time.minute,
      'sound': sound,
      'isEnabled': isEnabled,
      'repeatDays': repeatDays,
    };
  }

  factory Alarm.fromMap(Map<String, dynamic> map) {
    return Alarm(
      id: map['id'] as String,
      title: map['title'] as String,
      time: TimeOfDay(hour: map['hour'] as int, minute: map['minute'] as int),
      sound: map['sound'] as String,
      isEnabled: map['isEnabled'] as bool,
      repeatDays: List<bool>.from(map['repeatDays']),
    );
  }

  Alarm copyWith({
    String? id,
    String? title,
    TimeOfDay? time,
    String? sound,
    bool? isEnabled,
    List<bool>? repeatDays,
  }) {
    return Alarm(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      sound: sound ?? this.sound,
      isEnabled: isEnabled ?? this.isEnabled,
      repeatDays: repeatDays ?? this.repeatDays,
    );
  }
}

class RingingAlarmDialog extends StatefulWidget {
  final Alarm alarm;

  const RingingAlarmDialog({super.key, required this.alarm});

  @override
  State<RingingAlarmDialog> createState() => _RingingAlarmDialogState();
}

class _RingingAlarmDialogState extends State<RingingAlarmDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _bellController;
  final AlarmService _alarmService = AlarmService.instance;

  @override
  void initState() {
    super.initState();
    _bellController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bellController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0A1F12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1B4332).withValues(alpha: 0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC9A84C).withValues(alpha: 0.15),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _bellController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _bellController.value * 0.2 - 0.1,
                    child: child,
                  );
                },
                child: const Icon(
                  Icons.alarm,
                  size: 64,
                  color: Color(0xFFC9A84C),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              widget.alarm.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFFF5F0E8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Time for your ibadah reminder',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFF5F0E8).withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        foregroundColor: const Color(0xFFF5F0E8),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        await _alarmService.triggerSnooze(widget.alarm);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.nightlight_round, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Snooze',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC9A84C),
                        foregroundColor: const Color(0xFF0D2818),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        await _alarmService.triggerDismiss(widget.alarm);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Dismiss',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AlarmService extends ChangeNotifier {
  static final AlarmService _instance = AlarmService._internal();
  static AlarmService get instance => _instance;
  AlarmService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final AudioPlayer _previewPlayer = AudioPlayer();

  static const String _alarmKey = 'alarms';
  static const String _idCounterKey = 'alarm_id_counter';
  static const String _triggeredIdsKey = 'triggered_alarm_ids';
  static const String _notificationSoundMapKey = 'notification_sound_map';
  static const List<String> availableSounds = [
    'assets/sounds/allah_hu_allah_hu.mp3',
    'assets/sounds/allah_o_akbar01.mp3',
    'assets/sounds/file.mp3',
    'assets/sounds/islamic_alaram.mp3',
    'assets/sounds/islamic.mp3',
  ];

  FlutterLocalNotificationsPlugin get _notifications => NotificationService.plugin;
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Alarm> _alarms = [];
  List<Alarm> get alarms => List.unmodifiable(_alarms);
  int _nextId = 1;

  bool _initialized = false;
  Timer? _foregroundTimer;
  final List<String> _triggeredAlarmIds = [];
  bool _foregroundServiceRunning = false;
  Timer? _ringingTimer;
  String? _currentRingingAlarmId;

  static const String actionSnooze = 'snooze_alarm';
  static const String actionDismiss = 'dismiss_alarm';

  static Future<void> onNotificationResponse(NotificationResponse response) async {
    // Handle notification response
    if (response.actionId == actionDismiss) {
      await _handleDismissAction(response);
    } else if (response.actionId == actionSnooze) {
      await _handleSnoozeAction(response);
    } else if (response.notificationResponseType == NotificationResponseType.selectedNotification) {
      await _handleNotificationTap(response);
    }
  }

  static Future<void> _handleDismissAction(NotificationResponse response) async {
    try {
      _instance._stopRinging(_instance._currentRingingAlarmId ?? '');
      final plugin = FlutterLocalNotificationsPlugin();
      if (response.id != null) {
        await plugin.cancel(response.id!);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('dismissed_notification_${response.id}', true);
      }
    } catch (e) {
      // Ignore errors
    }
  }

  static Future<void> _handleSnoozeAction(NotificationResponse response) async {
    try {
      _instance._stopRinging(_instance._currentRingingAlarmId ?? '');
      final plugin = FlutterLocalNotificationsPlugin();
      if (response.id != null) {
        await plugin.cancel(response.id!);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('dismissed_notification_${response.id}', true);

        // Look up the original alarm's sound number from the stored map
        final soundMapJson = prefs.getString(_notificationSoundMapKey) ?? '{}';
        final soundMap = Map<String, dynamic>.from(jsonDecode(soundMapJson));
        final soundNumber = (soundMap[response.id.toString()] as num?)?.toInt() ?? 1;
        final channelId = 'alarm_channel_$soundNumber';
        final channelName = 'Alarms - Sound $soundNumber';

        // Schedule snooze
        final now = DateTime.now();
        final snoozeTime = now.add(const Duration(minutes: 5));
        final tzSnooze = tz.TZDateTime.from(snoozeTime, tz.local);

        final android = AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          actions: [
            AndroidNotificationAction(actionSnooze, 'Snooze', showsUserInterface: true, cancelNotification: false),
            AndroidNotificationAction(actionDismiss, 'Dismiss', showsUserInterface: true, cancelNotification: true),
          ],
        );

        const iOS = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.critical,
        );

        final details = NotificationDetails(android: android, iOS: iOS);

        await plugin.zonedSchedule(
          999999,
          'Snoozed Reminder',
          'Your ibadah reminder is ready!',
          tzSnooze,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (e) {
      // Ignore errors
    }
  }

  static Future<void> _handleNotificationTap(NotificationResponse response) async {
    try {
      _instance._stopRinging(_instance._currentRingingAlarmId ?? '');
      final plugin = FlutterLocalNotificationsPlugin();
      if (response.id != null) {
        await plugin.cancel(response.id!);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('dismissed_notification_${response.id}', true);
      }
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Create notification channels for each sound
    for (int i = 0; i < availableSounds.length; i++) {
      final soundNumber = i + 1;
      final channelId = 'alarm_channel_$soundNumber';
      final channelName = 'Alarms - Sound $soundNumber';
      final channel = AndroidNotificationChannel(
        channelId,
        channelName,
        importance: Importance.max,
      );
      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // Load alarms and ID counter from storage
    final prefs = await SharedPreferences.getInstance();
    _nextId = prefs.getInt(_idCounterKey) ?? 1;
    await _loadAlarms();

    // Load previously triggered alarm IDs (survives restart)
    _triggeredAlarmIds.clear();
    final triggeredJson = prefs.getStringList(_triggeredIdsKey);
    if (triggeredJson != null) {
      _triggeredAlarmIds.addAll(triggeredJson);
    }

    // Re-schedule all enabled alarms (in case app was closed)
    for (final alarm in _alarms) {
      if (alarm.isEnabled) {
        await _scheduleAlarm(alarm);
      }
    }

    // Start foreground service if any alarms are enabled
    await _updateForegroundService();

    // Start foreground timer
    _startForegroundTimer();
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      // Request notification permission
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }

      // Check and request exact alarm permission using permission_handler
      if (await Permission.scheduleExactAlarm.isDenied) {
        final status = await Permission.scheduleExactAlarm.request();
        debugPrint('Exact alarm permission status: $status');
        
        // If still denied, open system settings
        if (status.isDenied || status.isPermanentlyDenied) {
          try {
            await openAppSettings();
          } catch (e) {
            debugPrint('Error opening app settings: $e');
          }
        }
      }

      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }

      // Request ignore battery optimizations
      if (await Permission.ignoreBatteryOptimizations.isDenied) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    }
  }

  bool get hasEnabledAlarms => _alarms.any((a) => a.isEnabled);

  Future<void> _startForegroundService() async {
    if (_foregroundServiceRunning) return;
    if (!hasEnabledAlarms) return;
    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin == null) return;

      const fgChannel = AndroidNotificationChannel(
        'alarm_foreground_service',
        'Alarm Service',
        description: 'Keeps alarms active when app is closed',
        importance: Importance.min,
        playSound: false,
        enableVibration: false,
      );
      await androidPlugin.createNotificationChannel(fgChannel);

      final fgDetails = AndroidNotificationDetails(
        'alarm_foreground_service',
        'Alarm Service',
        importance: Importance.min,
        priority: Priority.min,
        icon: '@mipmap/ic_launcher',
        showWhen: false,
        playSound: false,
        enableVibration: false,
        ongoing: true,
        autoCancel: false,
      );

      await androidPlugin.startForegroundService(
        2147483646,
        'ASK Iman',
        'Alarm service is running',
        notificationDetails: fgDetails,
        foregroundServiceTypes: {AndroidServiceForegroundType.foregroundServiceTypeManifest},
      );
      _foregroundServiceRunning = true;
      debugPrint('Foreground service started');
    } catch (e) {
      debugPrint('Error starting foreground service: $e');
    }
  }

  Future<void> _stopForegroundService() async {
    if (!_foregroundServiceRunning) return;
    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.stopForegroundService();
      _foregroundServiceRunning = false;
      debugPrint('Foreground service stopped');
    } catch (e) {
      debugPrint('Error stopping foreground service: $e');
    }
  }

  Future<void> _updateForegroundService() async {
    if (hasEnabledAlarms) {
      await _startForegroundService();
    } else {
      await _stopForegroundService();
    }
  }

  void _startForegroundTimer() {
    _foregroundTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkForegroundAlarms();
      _checkRingingDismissed();
    });
  }

  void _checkRingingDismissed() async {
    if (_currentRingingAlarmId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final notificationId = int.tryParse(_currentRingingAlarmId!);
    if (notificationId != null) {
      if (prefs.getBool('dismissed_notification_$notificationId') == true) {
        _stopRinging(_currentRingingAlarmId!);
      }
    }
  }

  void _checkForegroundAlarms() async {
    final now = DateTime.now();
    for (final alarm in _alarms) {
      if (!alarm.isEnabled) continue;
      if (_triggeredAlarmIds.contains(alarm.id)) continue;

      // Check if time matches within a 2-second window (handles timer drift)
      final diff = Duration(
        hours: now.hour - alarm.time.hour,
        minutes: now.minute - alarm.time.minute,
        seconds: now.second,
      ).inSeconds.abs();
      if (diff > 2) continue;

      // Check repeat days
      final hasRepeat = alarm.repeatDays.any((d) => d);
      if (hasRepeat) {
        final todayWeekday = now.weekday - 1;
        if (!alarm.repeatDays[todayWeekday]) continue;
      }

      triggerAlarm(alarm);
    }
  }

  Future<void> triggerAlarm(Alarm alarm) async {
    if (_triggeredAlarmIds.contains(alarm.id)) return;

    final prefs = await SharedPreferences.getInstance();
    final notificationId = int.tryParse(alarm.id) ?? 1000;

    final dismissed = prefs.getBool('dismissed_notification_$notificationId') ?? false;
    if (dismissed) {
      _triggeredAlarmIds.add(alarm.id);
      await _persistTriggeredIds();
      return;
    }

    _triggeredAlarmIds.add(alarm.id);
    _currentRingingAlarmId = alarm.id;
    await _persistTriggeredIds();

    await _showAlarmNotification(alarm);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (_triggeredAlarmIds.contains(alarm.id)) {
        _playRingSound(alarm);
      }
    });

    final navContext = navigatorKey.currentContext;
    if (navContext != null && navContext.mounted) {
      showDialog(
        context: navContext,
        barrierDismissible: false,
        builder: (context) => RingingAlarmDialog(alarm: alarm),
      );
    }
  }

  Future<void> _playRingSound(Alarm alarm) async {
    if (!_triggeredAlarmIds.contains(alarm.id)) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setLoopMode(LoopMode.off);
      await _audioPlayer.setAsset(alarm.sound);
      await _audioPlayer.play();
    } catch (e) {
      return;
    }
    _ringingTimer?.cancel();
    _ringingTimer = Timer(const Duration(seconds: 55), () {
      if (_triggeredAlarmIds.contains(alarm.id)) {
        _playRingSound(alarm);
      }
    });
  }

  Future<void> _showAlarmNotification(Alarm alarm) async {
    final notificationId = int.tryParse(alarm.id) ?? 1000;
    final soundNumber = availableSounds.indexOf(alarm.sound) + 1;
    
    final soundName = 'alarm$soundNumber';
    final channelId = 'alarm_channel_$soundNumber';
    final channelName = 'Alarms - Sound $soundNumber';

    final android = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      sound: RawResourceAndroidNotificationSound(soundName),
      playSound: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      autoCancel: false,
      ongoing: true,
      showWhen: true,
      usesChronometer: false,
      channelShowBadge: true,
      enableVibration: true,
      actions: const [
        AndroidNotificationAction(actionSnooze, 'Snooze', showsUserInterface: true, cancelNotification: false),
        AndroidNotificationAction(actionDismiss, 'Dismiss', showsUserInterface: true, cancelNotification: true),
      ],
    );

    const iOS = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    final details = NotificationDetails(android: android, iOS: iOS);

    await _notifications.show(
      notificationId,
      'Ask Iman Reminder',
      alarm.title,
      details,
    );

    // Store notification-to-sound mapping so background dismiss/snooze uses correct channel
    final prefs = await SharedPreferences.getInstance();
    final soundMapJson = prefs.getString(_notificationSoundMapKey) ?? '{}';
    final soundMap = Map<String, dynamic>.from(jsonDecode(soundMapJson));
    soundMap[notificationId.toString()] = soundNumber;
    await prefs.setString(_notificationSoundMapKey, jsonEncode(soundMap));
  }

  Future<void> triggerDismiss(Alarm alarm) async {
    _stopRinging(alarm.id);
    await _cancelAlarm(alarm.id);
    _ringingTimer?.cancel();
    _ringingTimer = null;

    _triggeredAlarmIds.remove(alarm.id);
    await _persistTriggeredIds();

    // Disable one-off alarms
    if (!alarm.repeatDays.any((d) => d)) {
      final index = _alarms.indexWhere((a) => a.id == alarm.id);
      if (index != -1) {
        _alarms[index] = alarm.copyWith(isEnabled: false);
        await _saveAlarms();
        notifyListeners();
      }
    }
  }

  Future<void> triggerSnooze(Alarm alarm) async {
    _stopRinging(alarm.id);
    await _cancelAlarm(alarm.id);

    _triggeredAlarmIds.remove(alarm.id);
    await _persistTriggeredIds();

    // Schedule snoozed alarm for 5 minutes later
    final now = DateTime.now();
    final snoozeTime = now.add(const Duration(minutes: 5));
    final tzSnooze = tz.TZDateTime.from(snoozeTime, tz.local);

    final soundNumber = availableSounds.indexOf(alarm.sound) + 1;
    final tempAlarm = Alarm(
      id: 'snooze_${alarm.id}',
      title: 'Snoozed: ${alarm.title}',
      time: TimeOfDay(hour: snoozeTime.hour, minute: snoozeTime.minute),
      sound: alarm.sound,
      isEnabled: true,
      repeatDays: List.generate(7, (_) => false),
    );

    final details = _notificationDetails(tempAlarm, soundNumber);
    await _notifications.zonedSchedule(
      999999,
      tempAlarm.title,
      'Your ibadah reminder is ready!',
      tzSnooze,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );

    // Store sound mapping for the snooze notification too
    final prefs = await SharedPreferences.getInstance();
    final soundMapJson = prefs.getString(_notificationSoundMapKey) ?? '{}';
    final soundMap = Map<String, dynamic>.from(jsonDecode(soundMapJson));
    soundMap['999999'] = soundNumber;
    await prefs.setString(_notificationSoundMapKey, jsonEncode(soundMap));
  }

  Future<void> _persistTriggeredIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_triggeredIdsKey, _triggeredAlarmIds.toList());
  }

  Future<void> _stopRinging(String alarmId) async {
    _ringingTimer?.cancel();
    _ringingTimer = null;
    if (_currentRingingAlarmId == alarmId) {
      _currentRingingAlarmId = null;
    }
    try {
      await _audioPlayer.stop();
    } catch (e) {
      // Ignore
    }
  }

  Future<void> _loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final String? alarmsJson = prefs.getString(_alarmKey);
    if (alarmsJson != null) {
      final List<dynamic> decoded = jsonDecode(alarmsJson);
      _alarms = decoded.map((e) => Alarm.fromMap(e as Map<String, dynamic>)).toList();
    }
    notifyListeners();
  }

  Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_alarmKey, jsonEncode(_alarms.map((a) => a.toMap()).toList()));
    notifyListeners();
  }

  Future<void> addAlarm(Alarm alarm) async {
    // Generate a unique 32-bit integer ID
    final prefs = await SharedPreferences.getInstance();
    final newId = _nextId;
    _nextId = (_nextId + 1) % (1 << 31); // Keep it within 32-bit int
    await prefs.setInt(_idCounterKey, _nextId);

    final newAlarm = alarm.copyWith(id: newId.toString());

    // Insert new alarm at TOP of the list
    _alarms.insert(0, newAlarm);
    await _saveAlarms();
    notifyListeners(); // Notify UI of change
    if (newAlarm.isEnabled) {
      await _scheduleAlarm(newAlarm);
    }
    await _updateForegroundService();
  }

  Future<void> previewSound(String soundPath) async {
    await _previewPlayer.stop();
    await _previewPlayer.setLoopMode(LoopMode.off);
    try {
      await _previewPlayer.setAsset(soundPath);
      await _previewPlayer.play();
      Future.delayed(const Duration(seconds: 2), () async {
        await _previewPlayer.stop();
      });
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> updateAlarm(Alarm oldAlarm, Alarm newAlarm) async {
    _triggeredAlarmIds.remove(oldAlarm.id);
    final index = _alarms.indexWhere((a) => a.id == oldAlarm.id);
    if (index == -1) return;
    _alarms[index] = newAlarm;
    await _saveAlarms();
    notifyListeners(); // Notify UI
    await _cancelAlarm(oldAlarm.id);
    if (newAlarm.isEnabled) {
      await _scheduleAlarm(newAlarm);
    }
    await _updateForegroundService();
  }

  Future<void> deleteAlarm(String id) async {
    _triggeredAlarmIds.remove(id);
    _alarms.removeWhere((a) => a.id == id);
    await _saveAlarms();
    notifyListeners(); // Notify UI
    await _cancelAlarm(id);
    await _updateForegroundService();
  }

  Future<void> toggleAlarm(String id, bool enabled) async {
    if (!enabled) {
      _triggeredAlarmIds.remove(id);
    }
    final index = _alarms.indexWhere((a) => a.id == id);
    if (index == -1) return;
    final alarm = _alarms[index];
    final newAlarm = alarm.copyWith(isEnabled: enabled);
    _alarms[index] = newAlarm;
    await _saveAlarms();
    notifyListeners(); // Notify UI
    if (enabled) {
      await _scheduleAlarm(newAlarm);
    } else {
      await _cancelAlarm(id);
    }
    await _updateForegroundService();
  }

  Future<void> _scheduleAlarm(Alarm alarm) async {
    try {
      // First check if we can schedule exact alarms before trying to schedule
      if (Platform.isAndroid) {
        final status = await Permission.scheduleExactAlarm.status;
        if (status.isDenied || status.isPermanentlyDenied) {
          debugPrint('Cannot schedule exact alarms - opening settings');
          try {
            await openAppSettings();
          } catch (e) {
            debugPrint('Error opening app settings: $e');
          }
          // Still try to schedule anyway, but it might not work
        }
      }
      
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      debugPrint('Scheduling alarm: ${alarm.title} at ${alarm.time.hour}:${alarm.time.minute}');
      debugPrint('Current time in tz.local: $now');

      final hasRepeat = alarm.repeatDays.any((d) => d);
      final soundIndex = availableSounds.indexOf(alarm.sound);
      final soundNumber = soundIndex + 1;

      if (!hasRepeat) {
        // One-off alarm
        tz.TZDateTime scheduledDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          alarm.time.hour,
          alarm.time.minute,
        );

        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }

        debugPrint('One-off alarm scheduled for: $scheduledDate');

        await _notifications.zonedSchedule(
          int.parse(alarm.id),
          'Ask Iman Reminder',
          alarm.title,
          scheduledDate,
          _notificationDetails(alarm, soundNumber),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      } else {
        // Repeating alarm - schedule for each selected day
        for (int i = 0; i < 7; i++) {
          if (alarm.repeatDays[i]) {
            // weekday: 1 (Mon) to 7 (Sun)
            // our repeatDays: 0 (Mon) to 6 (Sun)
            final weekday = i + 1;

            // Generate a unique ID for each weekday: baseId * 10 + weekday
            final notificationId = int.parse(alarm.id) * 10 + weekday;

            tz.TZDateTime scheduledDate = tz.TZDateTime(
              tz.local,
              now.year,
              now.month,
              now.day,
              alarm.time.hour,
              alarm.time.minute,
            );

            // Adjust to the correct weekday
            while (scheduledDate.weekday != weekday) {
              scheduledDate = scheduledDate.add(const Duration(days: 1));
            }

            // If it's today but already passed, move to next week
            if (scheduledDate.isBefore(now)) {
              scheduledDate = scheduledDate.add(const Duration(days: 7));
            }

            debugPrint('Repeating alarm for weekday $weekday scheduled for: $scheduledDate (ID: $notificationId)');

            await _notifications.zonedSchedule(
              notificationId,
              'Ask Iman Reminder',
              alarm.title,
              scheduledDate,
              _notificationDetails(alarm, soundNumber),
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
              matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error scheduling alarm: $e');
    }
  }

  NotificationDetails _notificationDetails(Alarm alarm, int soundNumber) {
    final soundName = 'alarm$soundNumber';
    final channelId = 'alarm_channel_$soundNumber';
    final channelName = 'Alarms - Sound $soundNumber';
    
    final android = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      sound: RawResourceAndroidNotificationSound(soundName),
      playSound: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      autoCancel: false,
      ongoing: true,
      showWhen: true,
      usesChronometer: false,
      channelShowBadge: true,
      enableVibration: true,
      actions: const [
        AndroidNotificationAction(actionSnooze, 'Snooze', showsUserInterface: true, cancelNotification: false),
        AndroidNotificationAction(actionDismiss, 'Dismiss', showsUserInterface: true, cancelNotification: true),
      ],
    );

    const iOS = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    return NotificationDetails(android: android, iOS: iOS);
  }

  Future<void> stopAlarm() async {
    _ringingTimer?.cancel();
    _ringingTimer = null;
    _currentRingingAlarmId = null;
    try {
      await _audioPlayer.stop();
    } catch (e) {
      // Ignore
    }
  }

  Future<void> _cancelAlarm(String id) async {
    try {
      final parsedId = int.tryParse(id);
      if (parsedId != null) {
        await _notifications.cancel(parsedId);
        for (int i = 1; i <= 7; i++) {
          await _notifications.cancel(parsedId * 10 + i);
        }
      }
      // Clean up dismissed flags and sound map for this alarm
      final prefs = await SharedPreferences.getInstance();
      final soundMapJson = prefs.getString(_notificationSoundMapKey) ?? '{}';
      final soundMap = Map<String, dynamic>.from(jsonDecode(soundMapJson));
      soundMap.remove(parsedId?.toString());
      for (int i = 1; i <= 7; i++) {
        soundMap.remove('${parsedId! * 10 + i}');
      }
      await prefs.setString(_notificationSoundMapKey, jsonEncode(soundMap));
    } catch (e) {
      debugPrint('Error canceling alarm: $e');
    }
  }

  @override
  void dispose() {
    _foregroundTimer?.cancel();
    _ringingTimer?.cancel();
    _stopForegroundService();
    _audioPlayer.dispose();
    _previewPlayer.dispose();
    super.dispose();
  }
}
