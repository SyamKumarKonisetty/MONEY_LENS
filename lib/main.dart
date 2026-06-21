import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/routing/app_router.dart';
import 'core/design/design_system.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'core/services/notifications/notification_manager.dart';

/// MoneyLens — Phase 1 Foundation
///
/// Entry point. Initializes:
/// - SharedPreferences for theme persistence
/// - ProviderScope with sharedPreferencesProvider override
/// - MaterialApp.router with GoRouter + Riverpod theme
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global Error Boundary: Prevent grey screen of death
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong.',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                details.exceptionAsString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  };

  // Initialize SharedPreferences for theme persistence
  final prefs = await SharedPreferences.getInstance();

  // Configure system UI overlays
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Enable edge-to-edge rendering
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Initialize Notification Manager asynchronously to avoid blocking startup
  Future.microtask(() async {
    final notificationManager = NotificationManager();
    await notificationManager.init();
    await notificationManager.requestPermissions();
    
    // Reschedule all active notifications on app start
    final masterEnabled = prefs.getBool('notif_master') ?? true;
    if (masterEnabled) {
      // Daily Reminder
      if (prefs.getBool('notif_daily') ?? true) {
        final h = prefs.getInt('notif_daily_h') ?? 20;
        final m = prefs.getInt('notif_daily_m') ?? 30;
        await notificationManager.scheduleDailyReminder(TimeOfDay(hour: h, minute: m));
      }
      // Weekly Summary
      if (prefs.getBool('notif_weekly') ?? true) {
        final d = prefs.getInt('notif_weekly_d') ?? 7;
        final h = prefs.getInt('notif_weekly_h') ?? 20;
        final m = prefs.getInt('notif_weekly_m') ?? 0;
        await notificationManager.scheduleWeeklySummary(d, TimeOfDay(hour: h, minute: m));
      }
      // Monthly Report
      if (prefs.getBool('notif_monthly') ?? true) {
        final d = prefs.getInt('notif_monthly_d') ?? 31;
        final h = prefs.getInt('notif_monthly_h') ?? 21;
        final m = prefs.getInt('notif_monthly_m') ?? 0;
        await notificationManager.scheduleMonthlyReport(d, TimeOfDay(hour: h, minute: m));
      }
      // Inactive Reminder
      if (prefs.getBool('notif_inactive') ?? true) {
        await notificationManager.scheduleInactiveReminder(3);
      }
    } else {
      await notificationManager.cancelAll();
    }
  });

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ProviderScope(
      overrides: [
        // Inject the initialized SharedPreferences instance
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MoneyLensApp(),
    ),
  );
}

/// Root application widget.
///
/// Watches [themeNotifierProvider] to reactively apply theme changes.
class MoneyLensApp extends ConsumerWidget {
  const MoneyLensApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      // App metadata
      title: 'MoneyLens',
      debugShowCheckedModeBanner: false,

      // Themes
      theme: AppTheme.standardTheme,
      darkTheme: AppTheme.standardTheme,
      themeMode: ThemeMode.dark,

      // Navigation
      routerConfig: router,

      // Localization support (for currency formatting)
      supportedLocales: const [Locale('en', 'IN'), Locale('en', 'US')],
    );
  }
}
