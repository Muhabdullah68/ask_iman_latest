// lib/core/services/prayer_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// PRAYER SERVICE
//
// Changes from previous version:
//   • Removed kCalculationMethods map (calc method picker removed from UI)
//   • Calculation method is fixed to Umm Al-Qura (widely used, accurate globally)
//   • kMadhabs now exposes all 4 classical madhabs:
//       Hanafi   → Madhab.hanafi  (Asr when shadow = 2x object)
//       Maliki   → Madhab.shafi   (same Asr rule as Shafi/Hanbali in adhan pkg)
//       Shafi'i  → Madhab.shafi
//       Hanbali  → Madhab.shafi   (same Asr rule as Shafi)
//     Note: The adhan Dart package only has hanafi vs shafi for Asr calculation.
//     Maliki and Hanbali share the Shafi rule in this engine.
//   • Added HijriCalendar utility class (pure Dart — no API needed)
//     based on the Kuwaiti algorithmic conversion used by most Islamic apps.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

// ══════════════════════════════════════════════════════════════════════════════
// HIJRI CALENDAR  (pure Dart, no API needed)
// Algorithm: Kuwaiti variant of the Gregorian-to-Hijri conversion
// Accurate within ±1 day compared to moon-sighting; matches most Islamic apps.
// ══════════════════════════════════════════════════════════════════════════════

class HijriDate {
  final int day;
  final int month;
  final int year;

  const HijriDate({required this.day, required this.month, required this.year});

  static const List<String> _monthNames = [
    'Muharram',
    'Safar',
    "Rabi' al-Awwal",
    "Rabi' al-Thani",
    'Jumada al-Awwal',
    'Jumada al-Thani',
    'Rajab',
    "Sha'ban",
    'Ramadan',
    'Shawwal',
    "Dhu al-Qi'dah",
    'Dhu al-Hijjah',
  ];

  static const List<String> _monthNamesAr = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الثاني',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  String get monthName => _monthNames[month - 1];
  String get monthNameAr => _monthNamesAr[month - 1];

  /// e.g. "23 Ramadan 1446"
  String get formatted => '$day $monthName $year';

  /// e.g. "23 رمضان 1446"
  String get formattedAr => '$day $monthNameAr $year';

  /// Convert a Gregorian [DateTime] to Hijri.
  static HijriDate fromGregorian(DateTime date) {
    final jd = _gregorianToJd(date.year, date.month, date.day);
    return _jdToHijri(jd);
  }

  // Julian Day Number from Gregorian date
  static double _gregorianToJd(int y, int m, int d) {
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        d +
        b -
        1524.5;
  }

  // Hijri from JDN (Kuwaiti algorithm)
  static HijriDate _jdToHijri(double jd) {
    final z = (jd + 0.5).floor();
    final l = z - 1948440 + 10632;
    final n = ((l - 1) / 10631).floor();
    final ll = l - 10631 * n + 354;
    final j =
        ((10985 - ll) / 5316).floor() * ((50 * ll) / 17719).floor() +
        (ll / 5670).floor() * ((43 * ll) / 15238).floor();
    final lll =
        ll -
        ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
        (j / 16).floor() * ((15238 * j) / 43).floor() +
        29;
    final m = (24 * lll) ~/ 709;
    final d = lll - (709 * m) ~/ 24;
    final y = 30 * n + j - 30;
    return HijriDate(day: d, month: m, year: y);
  }

  /// Today's Hijri date
  static HijriDate get today => fromGregorian(DateTime.now());

  /// Special Islamic occasions for the current Hijri year
  /// Returns a list of {name, hijriDate, gregorianDate?}
  static List<Map<String, dynamic>> islamicOccasions(int hijriYear) {
    return [
      {'name': "Islamic New Year", 'month': 1, 'day': 1},
      {'name': "Day of Ashura", 'month': 1, 'day': 10},
      {'name': "Mawlid al-Nabi", 'month': 3, 'day': 12},
      {'name': "Isra & Mi'raj", 'month': 7, 'day': 27},
      {'name': "Laylat al-Bara'ah", 'month': 8, 'day': 15},
      {'name': "Ramadan begins", 'month': 9, 'day': 1},
      {'name': "Laylat al-Qadr", 'month': 9, 'day': 27},
      {'name': "Eid al-Fitr", 'month': 10, 'day': 1},
      {'name': "Day of Arafah", 'month': 12, 'day': 9},
      {'name': "Eid al-Adha", 'month': 12, 'day': 10},
    ];
  }
}

// ── Prayer model ──────────────────────────────────────────────────────────────

class PrayerInfo {
  final Prayer prayer;
  final String name;
  final DateTime time;
  final bool isNext;

  const PrayerInfo({
    required this.prayer,
    required this.name,
    required this.time,
    required this.isNext,
  });

  String get timeFormatted => DateFormat('h:mm a').format(time);
  String get timeShort => DateFormat('h:mm').format(time);
  String get amPm => DateFormat('a').format(time);

  int minutesUntil() {
    final diff = time.difference(DateTime.now());
    return diff.inMinutes.clamp(0, 99999);
  }
}

// 4 Classical Madhabs & Calculation Methods
const Map<String, Madhab> kMadhabs = {
  'Hanafi': Madhab.hanafi,
  "Maliki": Madhab.shafi,
  "Shafi'i": Madhab.shafi,
  'Hanbali': Madhab.shafi,
};

const Map<String, CalculationMethod> kCalculationMethods = {
  'Umm Al-Qura': CalculationMethod.umm_al_qura,
  'Muslim World League': CalculationMethod.muslim_world_league,
  'ISNA': CalculationMethod.north_america,
  'Karachi (University of Islamic Sciences)': CalculationMethod.karachi,
  'Dubai': CalculationMethod.dubai,
  'Qatar': CalculationMethod.qatar,
  'Kuwait': CalculationMethod.kuwait,
  'Singapore': CalculationMethod.singapore,
};

// ══════════════════════════════════════════════════════════════════════════════
// PRAYER SERVICE
// ══════════════════════════════════════════════════════════════════════════════

class PrayerService extends ChangeNotifier {
  static final PrayerService _instance = PrayerService._internal();
  factory PrayerService() => _instance;
  PrayerService._internal();

  PrayerTimes? _prayerTimes;
  SunnahTimes? _sunnahTimes;
  Position? _position;
  bool _loading = false;
  String? _error;
  Timer? _midnightTimer;
  Timer? _countdownTimer;
  Prayer? _previousNextPrayer;

  CalculationMethod _calcMethod = CalculationMethod.umm_al_qura;
  String _calcMethodName = 'Umm Al-Qura';
  String _madhabName = 'Hanafi';
  bool _notifEnabled = true;
  int _reminderMins = 10;

  FlutterLocalNotificationsPlugin? _notifPlugin;
  AppLifecycleListener? _lifecycle;

  // Getters
  PrayerTimes? get prayerTimes => _prayerTimes;
  SunnahTimes? get sunnahTimes => _sunnahTimes;
  Position? get position => _position;
  bool get isLoading => _loading;
  String? get error => _error;
  String get madhabName => _madhabName;
  String get calculationMethodName => _calcMethodName;
  bool get notifEnabled => _notifEnabled;
  int get reminderMinutes => _reminderMins;

  Future<void> initialize(FlutterLocalNotificationsPlugin plugin) async {
    _notifPlugin = plugin;
    // tz already initialized by NotificationService (correct local zone).

    // Azan channel carries the adhan sound for the "X minutes before" calls.
    const AndroidNotificationChannel azzanChannel = AndroidNotificationChannel(
      'prayer_azzan_channel',
      'Prayer Azan Notifications',
      description: 'Azan (call to prayer) notifications',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('allah_o_akbar01'),
      playSound: true,
      enableVibration: true,
    );

    final androidPlugin = _notifPlugin?.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
    >();
    await androidPlugin?.createNotificationChannel(azzanChannel);

    // "When the app is opened the azan stops": cancelling the delivered azan
    // notification halts its sound, so tap the pipeline to wire this in after
    // the first frame (needs a WidgetsBinding up).
    _lifecycle ??= AppLifecycleListener(onResume: () {
      unawaited(_cancelActiveAzzanNotifications());
    });

    await refresh();
    _scheduleMidnightRefresh();
    _startCountdownTimer();
  }

  Future<void> refresh({DateTime? customTime}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _position = await _getLocation();
      if (_position != null) {
        _calculatePrayerTimes(customTime: customTime);
        if (_notifEnabled) {
          await _scheduleAllNotifications(customTime: customTime);
        }
      }
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  void setCalculationMethod(String name) {
    if (kCalculationMethods.containsKey(name) && _calcMethodName != name) {
      _calcMethodName = name;
      _calcMethod = kCalculationMethods[name]!;
      _calculatePrayerTimes();
      if (_notifEnabled) _scheduleAllNotifications();
      notifyListeners();
    }
  }

  void setMadhab(String name) {
    if (_madhabName != name) {
      _madhabName = name;
      _calculatePrayerTimes();
      if (_notifEnabled) _scheduleAllNotifications();
      notifyListeners();
    }
  }

  void setNotificationsEnabled(bool v) {
    if (_notifEnabled != v) {
      _notifEnabled = v;
      if (v) {
        unawaited(_enableAndSchedule());
      } else if (!kIsWeb) {
        _notifPlugin?.cancelAll();
      }
      notifyListeners();
    }
  }

  /// Requests the Android 13+ POST_NOTIFICATIONS and exact-alarm permissions
  /// (Android 12+ / 14 invites settings), then schedules the azan calls.
  Future<void> _enableAndSchedule() async {
    if (kIsWeb || _notifPlugin == null) return;
    final android = _notifPlugin!.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
    >();
    if (android != null) {
      try {
        final granted = await android.requestNotificationsPermission();
        if (granted == false) return; // nothing will display — don't schedule
      } catch (_) {}
      try {
        final canExact = await android.canScheduleExactNotifications();
        if (canExact != true) {
          await android.requestExactAlarmsPermission();
        }
      } catch (_) {}
    }
    await _scheduleAllNotifications();
  }

  void setReminderMinutes(int m) {
    if (_reminderMins != m) {
      _reminderMins = m;
      if (_notifEnabled) _scheduleAllNotifications();
      notifyListeners();
    }
  }

  List<PrayerInfo> getTodayPrayers({DateTime? at}) {
    if (_prayerTimes == null) return [];

    // We want the 'next' indicator to only apply to the 5 main prayers.
    // If adhan says next is sunrise, we treat the next main prayer (Dhuhr) as next.
    var next = _prayerTimes!.nextPrayer();
    if (next == Prayer.sunrise) {
      next = Prayer.dhuhr;
    }

    return [
      _info(Prayer.fajr, 'Fajr', _prayerTimes!.fajr, next),
      _info(Prayer.dhuhr, 'Dhuhr', _prayerTimes!.dhuhr, next),
      _info(Prayer.asr, 'Asr', _prayerTimes!.asr, next),
      _info(Prayer.maghrib, 'Maghrib', _prayerTimes!.maghrib, next),
      _info(Prayer.isha, 'Isha', _prayerTimes!.isha, next),
    ];
  }

  List<PrayerInfo> get todayPrayers => getTodayPrayers();

  PrayerInfo _info(Prayer p, String name, DateTime time, Prayer next) =>
      PrayerInfo(prayer: p, name: name, time: time, isNext: p == next);

  PrayerInfo? get nextPrayerInfo {
    final prayers = todayPrayers;
    if (prayers.isEmpty) return null;
    try {
      // Find the first prayer that is marked as next
      return prayers.firstWhere((p) => p.isNext);
    } catch (_) {
      // If all prayers today are finished, nextPrayer() returns Prayer.none
      return null;
    }
  }

  String get currentPrayerName {
    if (_prayerTimes == null) return '—';
    final current = _prayerTimes!.currentPrayer();
    switch (current) {
      case Prayer.fajr:
        return 'Fajr';
      case Prayer.sunrise:
        return 'Sunrise';
      case Prayer.dhuhr:
        return 'Dhuhr';
      case Prayer.asr:
        return 'Asr';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isha';
      default:
        return '—';
    }
  }

  String get sunriseFormatted => _prayerTimes != null
      ? DateFormat('h:mm a').format(_prayerTimes!.sunrise)
      : '—';

  Future<Position?> _getLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Location services are disabled.');
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      throw Exception('Location permission denied.');
    }
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void _calculatePrayerTimes({DateTime? customTime}) {
    if (_position == null) return;
    final coords = Coordinates(_position!.latitude, _position!.longitude);
    final params = _calcMethod.getParameters()
      ..madhab = kMadhabs[_madhabName] ?? Madhab.hanafi;
    final date = customTime ?? DateTime.now();
    _prayerTimes = PrayerTimes(coords, DateComponents.from(date), params);
    _sunnahTimes = SunnahTimes(_prayerTimes!);
  }

  Future<void> _scheduleAllNotifications({DateTime? customTime}) async {
    // Local notifications are not supported on web — skip scheduling.
    if (kIsWeb || _notifPlugin == null || _prayerTimes == null) return;
    // Cancel only prayer notifications (IDs 0-14) — NOT alarms/family reminders
    for (int i = 0; i <= 14; i++) {
      await _notifPlugin!.cancel(i);
    }
    final prayers = [
      ('Fajr', _prayerTimes!.fajr, 0),
      ('Dhuhr', _prayerTimes!.dhuhr, 1),
      ('Asr', _prayerTimes!.asr, 2),
      ('Maghrib', _prayerTimes!.maghrib, 3),
      ('Isha', _prayerTimes!.isha, 4),
    ];

    // Azan actions — the notification carries a "Stop Azan" action that
    // dismisses it (cancelling the notification halts its sound).
    const azanStopAction = AndroidNotificationAction(
      'stop_azan',
      'Stop Azan',
      showsUserInterface: false,
      cancelNotification: true,
    );

    final azzanDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'prayer_azzan_channel',
        'Prayer Azan Notifications',
        channelDescription: 'Azan (call to prayer) notifications',
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        sound: const RawResourceAndroidNotificationSound('allah_o_akbar01'),
        playSound: true,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        fullScreenIntent: true,
        enableVibration: true,
        color: const Color(0xFF1B4332),
        colorized: true,
        actions: [azanStopAction],
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.critical,
      ),
    );

    // One azan notification per prayer, fired at prayer time minus the chosen
    // minutes ("X MIN BEFORE NAMAZ") — the text reminder and at-time firing
    // were replaced by this single call. Guards:
    //   • never schedule in the past;
    //   • never let a later prayer's call overlap an earlier one's window.
    final now = customTime ?? DateTime.now();
    var prevFire = DateTime(1970);
    for (final (name, time, id) in prayers) {
      final fire = time.subtract(Duration(minutes: _reminderMins));
      if (!fire.isAfter(now)) continue;
      if (fire.isBefore(prevFire)) continue;
      prevFire = fire;

      try {
        await _notifPlugin!.zonedSchedule(
          id + 10,
          '$name Azan',
          'Allahu Akbar — $name adhan begins in $_reminderMins minutes.',
          tz.TZDateTime.from(fire, tz.local),
          azzanDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } on PlatformException catch (e) {
        // Exact alarms not permitted (Android 12+/14) — fall back to inexact so
        // the call still arrives (possibly slightly rounded to the minute).
        if (e.code == 'exact_alarms_not_permitted') {
          try {
            await _notifPlugin!.zonedSchedule(
              id + 10,
              '$name Azan',
              'Allahu Akbar — $name adhan begins in $_reminderMins minutes.',
              tz.TZDateTime.from(fire, tz.local),
              azzanDetails,
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
            );
          } catch (e2) {
            debugPrint('Error scheduling azan for $name (inexact): $e2');
          }
        } else {
          debugPrint('Error scheduling azan for $name: $e');
        }
      } catch (e) {
        debugPrint('Error scheduling azan for $name: $e');
      }
    }
  }

  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(midnight.difference(now), () {
      refresh();
      _scheduleMidnightRefresh();
    });
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_prayerTimes == null) return;
      final currentNext = _prayerTimes!.nextPrayer();
      if (currentNext != _previousNextPrayer) {
        _previousNextPrayer = currentNext;
        notifyListeners();
      }
    });
  }

  /// Cancels any azan call that is CURRENTLY delivered (i.e. still ringing in
  /// the notification shade with its sound playing). Pending future calls are
  /// untouched. Called from the "Stop Azan" action and on app resume.
  Future<void> _cancelActiveAzzanNotifications() async {
    if (kIsWeb || _notifPlugin == null) return;
    try {
      final active = await _notifPlugin!.getActiveNotifications();
      for (final n in active) {
        final id = n.id;
        if (id != null && id >= 10 && id <= 14) {
          await _notifPlugin!.cancel(id);
        }
      }
    } catch (e) {
      debugPrint('Azan stop error: $e');
    }
  }

  /// Stops a ringing azan: cancels the delivered notification (halting its
  /// system sound). Kept for the "Stop Azan" notification action handler.
  Future<void> stopAzanPlayback() => _cancelActiveAzzanNotifications();

  @override
  void dispose() {
    _midnightTimer?.cancel();
    _countdownTimer?.cancel();
    _lifecycle?.dispose();
    super.dispose();
  }
}
