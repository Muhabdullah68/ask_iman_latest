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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz_data;
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
    'Muharram', 'Safar', "Rabi' al-Awwal", "Rabi' al-Thani",
    'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', "Sha'ban",
    'Ramadan', 'Shawwal', "Dhu al-Qi'dah", 'Dhu al-Hijjah',
  ];

  static const List<String> _monthNamesAr = [
    'محرم', 'صفر', 'ربيع الأول', 'ربيع الثاني',
    'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان',
    'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
  ];

  String get monthName  => _monthNames[month - 1];
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
    if (m <= 2) { y -= 1; m += 12; }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        d + b - 1524.5;
  }

  // Hijri from JDN (Kuwaiti algorithm)
  static HijriDate _jdToHijri(double jd) {
    final z  = (jd + 0.5).floor();
    final l  = z - 1948440 + 10632;
    final n  = ((l - 1) / 10631).floor();
    final ll = l - 10631 * n + 354;
    final j  = ((10985 - ll) / 5316).floor() * ((50 * ll) / 17719).floor() +
        (ll / 5670).floor() * ((43 * ll) / 15238).floor();
    final lll = ll -
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
      {'name': "Islamic New Year",  'month': 1,  'day': 1},
      {'name': "Day of Ashura",     'month': 1,  'day': 10},
      {'name': "Mawlid al-Nabi",    'month': 3,  'day': 12},
      {'name': "Isra & Mi'raj",     'month': 7,  'day': 27},
      {'name': "Laylat al-Bara'ah", 'month': 8,  'day': 15},
      {'name': "Ramadan begins",    'month': 9,  'day': 1},
      {'name': "Laylat al-Qadr",    'month': 9,  'day': 27},
      {'name': "Eid al-Fitr",       'month': 10, 'day': 1},
      {'name': "Day of Arafah",     'month': 12, 'day': 9},
      {'name': "Eid al-Adha",       'month': 12, 'day': 10},
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
  String get timeShort     => DateFormat('h:mm').format(time);
  String get amPm          => DateFormat('a').format(time);

  int minutesUntil() {
    final diff = time.difference(DateTime.now());
    return diff.inMinutes.clamp(0, 99999);
  }
}

// ── 4 Classical Madhabs ───────────────────────────────────────────────────────
// The adhan package maps Hanafi → longer Asr, Shafi → standard Asr.
// Maliki and Hanbali share the same Asr rule as Shafi'i in this engine.
const Map<String, Madhab> kMadhabs = {
  'Hanafi':  Madhab.hanafi,
  "Maliki":  Madhab.shafi,   // same Asr shadow ratio as Shafi/Hanbali
  "Shafi'i": Madhab.shafi,
  'Hanbali': Madhab.shafi,
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
  Position?    _position;
  bool         _loading = false;
  String?      _error;
  Timer?       _midnightTimer;
  Timer?       _countdownTimer;

  // Fixed calculation method — Umm Al-Qura is accurate and well-tested globally.
  // Users only choose their Madhab (affects Asr time).
  final CalculationMethod _calcMethod = CalculationMethod.umm_al_qura;
  String _madhabName   = 'Hanafi';
  bool   _notifEnabled = true;
  int    _reminderMins = 10;

  FlutterLocalNotificationsPlugin? _notifPlugin;

  // Getters
  PrayerTimes? get prayerTimes    => _prayerTimes;
  SunnahTimes? get sunnahTimes    => _sunnahTimes;
  Position?    get position       => _position;
  bool         get isLoading      => _loading;
  String?      get error          => _error;
  String       get madhabName     => _madhabName;
  bool         get notifEnabled   => _notifEnabled;
  int          get reminderMinutes => _reminderMins;

  Future<void> initialize(FlutterLocalNotificationsPlugin plugin) async {
    _notifPlugin = plugin;
    tz_data.initializeTimeZones();
    await refresh();
    _scheduleMidnightRefresh();
    _startCountdownTimer();
  }

  Future<void> refresh() async {
    _loading = true;
    _error   = null;
    notifyListeners();
    try {
      _position = await _getLocation();
      if (_position != null) {
        _calculatePrayerTimes();
        if (_notifEnabled) await _scheduleAllNotifications();
      }
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  void setMadhab(String name) {
    _madhabName = name;
    _calculatePrayerTimes();
    if (_notifEnabled) _scheduleAllNotifications();
    notifyListeners();
  }

  void setNotificationsEnabled(bool v) {
    _notifEnabled = v;
    if (v) { _scheduleAllNotifications(); }
    else   { _notifPlugin?.cancelAll(); }
    notifyListeners();
  }

  void setReminderMinutes(int m) {
    _reminderMins = m;
    if (_notifEnabled) _scheduleAllNotifications();
    notifyListeners();
  }

  List<PrayerInfo> get todayPrayers {
    if (_prayerTimes == null) return [];
    final next = _prayerTimes!.nextPrayer();
    return [
      _info(Prayer.fajr,    'Fajr',    _prayerTimes!.fajr,    next),
      _info(Prayer.dhuhr,   'Dhuhr',   _prayerTimes!.dhuhr,   next),
      _info(Prayer.asr,     'Asr',     _prayerTimes!.asr,     next),
      _info(Prayer.maghrib, 'Maghrib', _prayerTimes!.maghrib, next),
      _info(Prayer.isha,    'Isha',    _prayerTimes!.isha,    next),
    ];
  }

  PrayerInfo _info(Prayer p, String name, DateTime time, Prayer next) =>
      PrayerInfo(prayer: p, name: name, time: time, isNext: p == next);

  PrayerInfo? get nextPrayerInfo =>
      todayPrayers.where((p) => p.isNext).firstOrNull;

  String get currentPrayerName {
    if (_prayerTimes == null) return '—';
    switch (_prayerTimes!.currentPrayer()) {
      case Prayer.fajr:    return 'Fajr';
      case Prayer.dhuhr:   return 'Dhuhr';
      case Prayer.asr:     return 'Asr';
      case Prayer.maghrib: return 'Maghrib';
      case Prayer.isha:    return 'Isha';
      default:             return '—';
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
        desiredAccuracy: LocationAccuracy.high);
  }

  void _calculatePrayerTimes() {
    if (_position == null) return;
    final coords = Coordinates(_position!.latitude, _position!.longitude);
    final params = _calcMethod.getParameters()
      ..madhab = kMadhabs[_madhabName] ?? Madhab.hanafi;
    _prayerTimes = PrayerTimes.today(coords, params);
    _sunnahTimes = SunnahTimes(_prayerTimes!);
  }

  Future<void> _scheduleAllNotifications() async {
    if (_notifPlugin == null || _prayerTimes == null) return;
    await _notifPlugin!.cancelAll();
    final prayers = [
      ('Fajr',    _prayerTimes!.fajr,    0),
      ('Dhuhr',   _prayerTimes!.dhuhr,   1),
      ('Asr',     _prayerTimes!.asr,     2),
      ('Maghrib', _prayerTimes!.maghrib, 3),
      ('Isha',    _prayerTimes!.isha,    4),
    ];
    final details = NotificationDetails(
      android: const AndroidNotificationDetails(
        'prayer_channel', 'Prayer Reminders',
        channelDescription: 'Adhan and prayer time notifications',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
          presentAlert: true, presentBadge: true, presentSound: true),
    );
    for (final (name, time, id) in prayers) {
      final rem = time.subtract(Duration(minutes: _reminderMins));
      if (rem.isAfter(DateTime.now())) {
        try {
          await _notifPlugin!.zonedSchedule(
            id, '$name Reminder',
            '$_reminderMins minutes until $name prayer',
            tz.TZDateTime.from(rem, tz.local), details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
          );
        } catch (_) {}
      }
      if (time.isAfter(DateTime.now())) {
        try {
          await _notifPlugin!.zonedSchedule(
            id + 10, 'Time for $name',
            'Allahu Akbar — it is time for $name prayer.',
            tz.TZDateTime.from(time, tz.local), details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
          );
        } catch (_) {}
      }
    }
  }

  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel();
    final now      = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(midnight.difference(now), () {
      refresh();
      _scheduleMidnightRefresh();
    });
  }

  void _startCountdownTimer() {
    _countdownTimer =
        Timer.periodic(const Duration(seconds: 30), (_) => notifyListeners());
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
}