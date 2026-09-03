// STUBBED FOR v1.0.5 — Alarm system disabled
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
    this.sound = 'alarm1',
    this.isEnabled = true,
    List<bool>? repeatDays,
  }) : repeatDays = repeatDays ?? List.filled(7, false);
}

class AlarmService extends ChangeNotifier {
  static final AlarmService _instance = AlarmService._internal();
  static AlarmService get instance => _instance;
  AlarmService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static const List<String> availableSounds = [
    'allah_hu_allah_hu',
    'allah_o_akbar01',
    'islamic_alaram',
    'alarm1',
    'alarm2',
  ];

  List<Alarm> get alarms => [];

  Future<void> initialize() async {}

  Future<void> previewSound(String soundName) async {}

  Future<void> addAlarm(Alarm alarm) async {}

  Future<void> updateAlarm(Alarm oldAlarm, Alarm newAlarm) async {}

  Future<void> deleteAlarm(String id) async {}

  Future<void> toggleAlarm(String id, bool enabled) async {}

  Future<void> stopAlarm() async {}

  static Future<void> onNotificationResponse(
    NotificationResponse response,
  ) async {}
}
