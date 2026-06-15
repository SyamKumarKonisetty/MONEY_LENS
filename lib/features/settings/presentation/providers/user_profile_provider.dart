import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/user_profile.dart';
import 'settings_provider.dart';

/// Notifier that manages the user profile name and persists it to SharedPreferences.
class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier(this._prefs) : super(_loadInitial(_prefs));

  final SharedPreferences _prefs;

  static const String _prefNameKey = 'profile_name';
  static const String _defaultName = 'Syam';

  static UserProfile _loadInitial(SharedPreferences prefs) {
    final name = prefs.getString(_prefNameKey) ?? _defaultName;
    return UserProfile(name: name);
  }

  /// Updates the user profile name and persists it.
  Future<void> updateName(String newName) async {
    final trimmedName = newName.trim();
    if (trimmedName.isEmpty) return;

    final updated = state.copyWith(name: trimmedName);
    state = updated;
    await _prefs.setString(_prefNameKey, trimmedName);
  }
}

/// Provides the current [UserProfile] state and exposes the notifier.
final userProfileNotifierProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return UserProfileNotifier(prefs);
    });
