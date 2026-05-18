// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'core/services/prayer_service.dart';
import 'features/splash/splash_screen.dart';
// community_auth_screen is reached via the navigation stack, not needed here

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

  runApp(const AskImanApp());
}

class AskImanApp extends StatelessWidget {
  const AskImanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ask Iman',
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}