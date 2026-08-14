import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart' as theme;
import 'core/services/notification_service.dart';
import 'core/services/prayer_service.dart';
import 'core/services/quran_download_service.dart';
import 'core/services/alarm_service.dart';
import 'core/services/tutorial_service.dart';
import 'core/services/fcm_service.dart';
import 'core/l10n/app_localizations.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  debugPrint('MAIN: Starting...');
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('MAIN: Widgets initialized');

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  debugPrint('MAIN: Orientation set');

  try {
    await Firebase.initializeApp();
    debugPrint('MAIN: Firebase initialized');
  } catch (e) {
    debugPrint('MAIN: Firebase error: $e');
  }

  tz_data.initializeTimeZones();
  debugPrint('MAIN: Timezones initialized');

  try {
    PrayerService().initialize(NotificationService.plugin).ignore();
    debugPrint('MAIN: PrayerService initialized');
  } catch (e) {
    debugPrint('MAIN: PrayerService error: $e');
  }

  try {
    await QuranDownloadService().init();
    debugPrint('MAIN: QuranDownloadService initialized');
  } catch (e) {
    debugPrint('MAIN: QuranDownloadService error: $e');
  }

  try {
    await initializeDateFormatting('ur');
    await initializeDateFormatting('ps');
    debugPrint('MAIN: Date formatting initialized');
  } catch (e) {
    debugPrint('MAIN: Date formatting error: $e');
  }

  try {
    await TutorialService.instance.initialize();
    debugPrint('MAIN: TutorialService initialized');
  } catch (e) {
    debugPrint('MAIN: TutorialService error: $e');
  }

  try {
    final fcm = FcmService.instance;
    fcm.setLocalNotificationPlugin(NotificationService.plugin);
    fcm.setNavigatorKey(AlarmService.instance.navigatorKey);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    await fcm.initialize(uid: uid);
    debugPrint('MAIN: FcmService initialized');
  } catch (e) {
    debugPrint('MAIN: FcmService error: $e');
  }

  debugPrint('MAIN: Running app...');
  runApp(const AskImanApp());
  debugPrint('MAIN: App running');
}

class AskImanApp extends StatelessWidget {
  const AskImanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AlarmService.instance),
        ChangeNotifierProvider(create: (_) => PrayerService()),
        ChangeNotifierProvider(create: (_) => QuranDownloadService()),
        ChangeNotifierProvider(create: (_) => TutorialService.instance),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'ASK Iman',
            themeMode: themeProvider.themeMode,
            theme: AppTheme.getLightTheme(localeProvider.locale),
            darkTheme: AppTheme.getDarkTheme(localeProvider.locale),
            navigatorKey: AlarmService.instance.navigatorKey,
            locale: localeProvider.locale,
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('ur'), Locale('ps')],
            home: const SplashScreen(),
            onUnknownRoute: (settings) => MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: theme.AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Oops! Page not found.',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil('/', (route) => false),
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
