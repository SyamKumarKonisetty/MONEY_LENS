import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/// Provides the current [ThemeMode]. Legacy notifier removed.
final themeNotifierProvider = Provider<ThemeMode>((ref) {
  return ThemeMode.dark;
});
