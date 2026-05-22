// lib/core/services/notification_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATION SERVICE
//
// Initializes FlutterLocalNotificationsPlugin.
// Called once in main() before runApp().
// The plugin instance is then injected into PrayerService.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin plugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS     = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: iOS);
    await plugin.initialize(settings);
  }

  /// Request Android 13+ notification permission (call once after init).
  static Future<void> requestPermission() async {
    await plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }
}
