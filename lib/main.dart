import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_meta_stub.dart'
  if (dart.library.html) 'admin_meta_web.dart';
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
import 'core/services/community_service.dart';
import 'core/l10n/app_localizations.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'features/splash/splash_screen.dart';
import 'features/community/admin/admin_dashboard.dart';

void main() async {
  debugPrint('MAIN: Starting...');
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('MAIN: Widgets initialized');

  if (!kIsWeb) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
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
            builder: (context, child) => AnimatedTheme(
              data: Theme.of(context),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: child!,
            ),
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
            onGenerateRoute: _adminSecretRouteGuard,
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

// ──────────────────────────────────────────────────────────────
// 🔒 HIDDEN ADMIN ROUTE GUARD — /secret-admin-dashboard
// NEVER link to this route from any UI. Admin must memorize URL.
// Protection layers:
//   1. Signed in check
//   2. Firestore user doc `role == admin` check (double-check with auth UID)
//   3. Fallback: redirect to home with silent snackbar on fail
// Firestore Security Rules must ALSO enforce the role check.
// ──────────────────────────────────────────────────────────────
const String _kHiddenAdminRouteName = '/secret-admin-dashboard';

Route<dynamic>? _adminSecretRouteGuard(RouteSettings settings) {
  if (settings.name == _kHiddenAdminRouteName) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => const _AdminGateWidget(),
      fullscreenDialog: true,
    );
  }
  // Let all other routes fall through to default / onUnknownRoute
  return null;
}

class _AdminGateWidget extends StatefulWidget {
  const _AdminGateWidget();

  @override
  State<_AdminGateWidget> createState() => _AdminGateWidgetState();
}

class _AdminGateWidgetState extends State<_AdminGateWidget> {
  bool _isLoading = true;
  bool _isAuthorized = false;

  @override
  void initState() {
    super.initState();
    AdminMetaWebGuard.applyNoIndex();
    _verifyAdminAccess();
  }

  @override
  void dispose() {
    AdminMetaWebGuard.restoreIndex();
    super.dispose();
  }

  Future<void> _verifyAdminAccess() async {
    // Layer 1: Firebase auth signed in?
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _redirectUnauthorized('Sign in required');
      return;
    }

    // Layer 2: Firestore doc role check
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!doc.exists) {
        _redirectUnauthorized('User profile not found');
        return;
      }
      final role = (doc.data()?['role'] as String?) ?? 'student';
      final parsedRole = _roleFromString(role);
      final ok = parsedRole == UserRole.admin;
      if (!ok) {
        _redirectUnauthorized('Not authorized');
        return;
      }
      // ✅ PASSED — show AdminDashboard
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isAuthorized = true;
        });
      }
    } catch (e) {
      debugPrint('ADMIN_GUARD: Firestore check error: $e');
      _redirectUnauthorized('Access check failed');
    }
  }

  UserRole _roleFromString(String r) {
    switch (r) {
      case 'teacher':
        return UserRole.teacher;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.student;
    }
  }

  void _redirectUnauthorized(String reason) {
    debugPrint('ADMIN_GUARD: BLOCKED — $reason');
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reason),
          backgroundColor: theme.AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    });
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.AppColors.gold),
          ),
        ),
      );
    }
    if (_isAuthorized) {
      return const AdminDashboard();
    }
    return const SizedBox.shrink();
  }
}
