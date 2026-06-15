import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/providers/settings_provider.dart';

/// MoneyLens — Phase 1 Foundation
///
/// Entry point. Initializes:
/// - SharedPreferences for theme persistence
/// - ProviderScope with sharedPreferencesProvider override
/// - MaterialApp.router with GoRouter + Riverpod theme
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    final themeMode = ref.watch(themeNotifierProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      // App metadata
      title: 'MoneyLens',
      debugShowCheckedModeBanner: false,

      // Themes
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Navigation
      routerConfig: router,

      // Localization support (for currency formatting)
      supportedLocales: const [Locale('en', 'IN'), Locale('en', 'US')],
    );
  }
}
