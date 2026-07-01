import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart' as theme;
import 'core/services/notification_service.dart';
import 'core/services/prayer_service.dart';
import 'core/services/quran_download_service.dart';
import 'core/services/alarm_service.dart';
import 'core/l10n/app_localizations.dart';
import 'core/providers/locale_provider.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  await Firebase.initializeApp();

  tz_data.initializeTimeZones();

  await NotificationService.initialize(
    onDidReceiveNotificationResponse: AlarmService.onNotificationResponse,
    onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationResponse,
  );

  await AlarmService.instance.initialize();

  PrayerService().initialize(NotificationService.plugin).ignore();

  await QuranDownloadService().init();

  await initializeDateFormatting('ur');
  await initializeDateFormatting('ps');

  runApp(const AskImanApp());
}

@pragma('vm:entry-point')
void onBackgroundNotificationResponse(NotificationResponse response) async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final plugin = FlutterLocalNotificationsPlugin();
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: android);
  await plugin.initialize(settings);

  try {
    final alarmService = AlarmService.instance;
    alarmService.stopAlarm();
  } catch (_) {}

  if (response.actionId == 'dismiss_alarm') {
    if (response.id != null) {
      await plugin.cancel(response.id!);
      await prefs.setBool('dismissed_notification_${response.id}', true);
    }
  } else if (response.actionId == 'snooze_alarm') {
    if (response.id != null) {
      await plugin.cancel(response.id!);
      await prefs.setBool('dismissed_notification_${response.id}', true);

      tz_data.initializeTimeZones();

      // Look up the original alarm's sound from stored map
      const soundMapKey = 'notification_sound_map';
      final soundMapJson = prefs.getString(soundMapKey) ?? '{}';
      final soundMap = Map<String, dynamic>.from(jsonDecode(soundMapJson));
      final soundNumber = (soundMap[response.id.toString()] as num?)?.toInt() ?? 1;
      final channelId = 'alarm_channel_$soundNumber';
      final channelName = 'Alarms - Sound $soundNumber';

      final now = DateTime.now();
      final snoozeTime = tz.TZDateTime.from(now.add(const Duration(minutes: 5)), tz.local);

      final androidDetails = AndroidNotificationDetails(
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
          AndroidNotificationAction('snooze_alarm', 'Snooze', showsUserInterface: true, cancelNotification: false),
          AndroidNotificationAction('dismiss_alarm', 'Dismiss', showsUserInterface: true, cancelNotification: true),
        ],
      );

      final details = NotificationDetails(android: androidDetails);

      await plugin.zonedSchedule(
        999999,
        'Snoozed Reminder',
        'Your ibadah reminder is ready!',
        snoozeTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  } else if (response.notificationResponseType == NotificationResponseType.selectedNotification) {
    if (response.id != null) {
      await plugin.cancel(response.id!);
      await prefs.setBool('dismissed_notification_${response.id}', true);
    }
  }
}

class AskImanApp extends StatelessWidget {
  const AskImanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AlarmService.instance),
        ChangeNotifierProvider(create: (_) => PrayerService()),
        ChangeNotifierProvider(create: (_) => QuranDownloadService()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'ASK Iman',
            theme: AppTheme.getTheme(localeProvider.locale),
            navigatorKey: AlarmService.instance.navigatorKey,
            locale: localeProvider.locale,
            localizationsDelegates: [
              const AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ur'),
              Locale('ps'),
            ],
            home: const SplashScreen(),
            onUnknownRoute: (settings) => MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Icon(Icons.error_outline, size: 64, color: theme.AppColors.error),
                      const SizedBox(height: 16),
                      const Text('Oops! Page not found.',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false),
                        child: const Text('Go Home'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
