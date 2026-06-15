import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';

/// Theme mode state notifier.
///
/// Persists the selected [ThemeMode] to [SharedPreferences].
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier(this._prefs) : super(_loadInitial(_prefs));

  final SharedPreferences _prefs;

  static ThemeMode _loadInitial(SharedPreferences prefs) {
    final stored = prefs.getString(AppConstants.prefThemeMode);
    switch (stored) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Set light theme.
  void setLight() => _setTheme(ThemeMode.light, 'light');

  /// Set dark theme.
  void setDark() => _setTheme(ThemeMode.dark, 'dark');

  /// Follow system theme.
  void setSystem() => _setTheme(ThemeMode.system, 'system');

  void _setTheme(ThemeMode mode, String key) {
    state = mode;
    _prefs.setString(AppConstants.prefThemeMode, key);
  }
}

/// Provides the shared preferences instance.
///
/// Override this in [main.dart] with the initialized instance:
/// ```dart
/// ProviderScope(
///   overrides: [
///     sharedPreferencesProvider.overrideWithValue(prefs),
///   ],
/// )
/// ```
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

/// Provides the current [ThemeMode].
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});
