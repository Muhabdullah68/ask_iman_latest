// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart' as theme;
import 'core/services/notification_service.dart';
import 'core/services/prayer_service.dart';
import 'core/services/quran_download_service.dart';
import 'features/splash/splash_screen.dart';
// community_auth_screen is reached via the navigation stack, not needed here

/*
── ROUTE MAP ──────────────────────────────────────────────────────────────────
1. /splash         → SplashScreen (Entry Point)
2. /main           → MainShell (Home, Quran, Ibadah, Streaks, Profile)
3. /auth_gate      → CommunityGate (Login/Register/Profile Setup)
4. /surah_read     → ArabicReadScreen (via Surah List)
5. /juz_read       → ArabicReadScreen.juz (via Juz List)
6. /qiblah         → QiblahScreen (via Ibadah)
7. /tasbeeh       → TasbeehScreen (via Ibadah)
───────────────────────────────────────────────────────────────────────────────
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── System UI ──────────────────────────────────────────────────────────────
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // ── Firebase ───────────────────────────────────────────────────────────────
  await Firebase.initializeApp();

  // ── Timezone data (required for prayer notifications) ─────────────────────
  tz_data.initializeTimeZones();

  // ── Notifications ──────────────────────────────────────────────────────────
  await NotificationService.initialize();
  await NotificationService.requestPermission();

  // ── Prayer service ─────────────────────────────────────────────────────────
  PrayerService().initialize(NotificationService.plugin).ignore();

  // ── Quran services ─────────────────────────────────────────────────────────
  await QuranDownloadService().init();

  runApp(const AskImanApp());
}

class AskImanApp extends StatelessWidget {
  const AskImanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ASK Iman',
      theme: AppTheme.theme,
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
  }
}
