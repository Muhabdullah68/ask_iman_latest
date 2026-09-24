// lib/core/services/notification_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// AZAN-ONLY NOTIFICATION PIPELINE (azan flow restored; family/FCM remain off)
//
// The plugin is genuinely initialized here so PrayerService can schedule azan
// notifications that fire "X minutes before" each namaz with sound, and that
// can be stopped from the notification shade or by opening the app.
//
// Deliberately NOT restored (matches the v1.0.6 "AZAN-ONLY" decision):
//   • scheduleReminder() / cancelReminder()   — family reminders stay disabled
//   • FCM group-notification display          — main.dart no longer hands the
//     plugin to FcmService, so its show() path stays a no-op
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  static DidReceiveNotificationResponseCallback? _tapHandler;

  static Future<void> initialize({
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
        onDidReceiveBackgroundNotificationResponse,
  }) async {
    if (onDidReceiveNotificationResponse != null) {
      _tapHandler = onDidReceiveNotificationResponse;
    }

    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Fall back to the database default (UTC) — better than failing.
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        _tapHandler?.call(response);
      },
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
    );
  }

  /// Requests POST_NOTIFICATIONS (Android 13+). Returns true when notifications
  /// are allowed to display; other platforms return true (no-op).
  static Future<bool> requestPermission() async {
    if (kIsWeb) return true;
    final android = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
    >();
    if (android == null) return true;
    try {
      final granted = await android.requestNotificationsPermission();
      return granted != false;
    } catch (_) {
      return false;
    }
  }

  // ── Stubbed: family reminders intentionally NOT restored ──────────────
  static Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    String? soundName,
    bool recurring = false,
    List<int>? days,
  }) async {}

  static Future<void> cancelReminder(int notificationId) async {}
}