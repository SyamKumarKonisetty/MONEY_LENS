import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_lens/features/settings/presentation/providers/settings_provider.dart';
import '../../../core/database/app_database.dart';
import '../../settings/presentation/providers/user_profile_provider.dart';
import '../../expenses/presentation/providers/expense_provider.dart';
import '../../sms_detection/presentation/providers/sms_detection_provider.dart';
import '../../notifications/presentation/providers/notifications_provider.dart';

/// Hashing helper to secure the user passcode.
String hashPin(String pin) {
  final bytes = utf8.encode(pin);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

class AuthNotifier extends ChangeNotifier {
  final SharedPreferences _prefs;
  final Ref? _ref;
  bool _sessionAuthenticated = false;

  AuthNotifier(this._prefs, [this._ref]);

  String? _getStoredPin() {
    final pin = _prefs.getString('auth_pin');
    if (pin != null && pin.length == 4) {
      // Automatic migration from plain text to SHA-256 hash
      final hashed = hashPin(pin);
      _prefs.setString('auth_pin', hashed);
      return hashed;
    }
    return pin;
  }

  bool get isPinSetup =>
      _getStoredPin() != null &&
      _prefs.getString('recovery_answer_hash') != null;
  bool get isSmsSetupCompleted => true;
  bool get isAuthenticated => _sessionAuthenticated;
  bool get hasAcceptedTerms => _prefs.getBool('terms_accepted') ?? false;
  bool get hasCompletedPermissions =>
  _prefs.getBool('permissions_completed') ?? false;
  String? get selectedBank => _prefs.getString('selected_bank');
  String? get sampleDebitSms => _prefs.getString('sms_sample_debit');
  String? get sampleCreditSms => _prefs.getString('sms_sample_credit');
  String? get profileType => _prefs.getString('profile_type');

  bool authenticate(String pin) {
    final storedPin = _getStoredPin();
    if (storedPin == hashPin(pin)) {
      _sessionAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }


  void setupPinAndRecovery(String pin, double recoveryIncome, String profile) {
    _prefs.setString('auth_pin', hashPin(pin));
    _prefs.setString(
      'recovery_answer_hash',
      hashPin(recoveryIncome.toStringAsFixed(2)),
    );
    _prefs.setString('profile_type', profile);
    _sessionAuthenticated = true; // Auto authenticate on initial setup
    notifyListeners();
  }

  bool verifyRecoveryAnswer(String answer) {
    final parsed = double.tryParse(answer.replaceAll(',', '').trim());
    if (parsed == null || parsed <= 1) return false;
    final storedHash = _prefs.getString('recovery_answer_hash');
    return storedHash == hashPin(parsed.toStringAsFixed(2));
  }

  bool resetPinWithRecovery(String newPin) {
    if (newPin.length == 4 && int.tryParse(newPin) != null) {
      _prefs.setString('auth_pin', hashPin(newPin));
      _sessionAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Change the app PIN passcode.
  bool changePin(String currentPin, String newPin) {
    final storedPin = _getStoredPin();
    if (storedPin == hashPin(currentPin)) {
      if (newPin.length == 4 && int.tryParse(newPin) != null) {
        _prefs.setString('auth_pin', hashPin(newPin));
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  /// Full reset of all app configurations and database rows.
  Future<void> clearAllAppData() async {
    await _prefs.clear();
    await AppDatabase.instance.clearAllData();
    _sessionAuthenticated = false;

    final ref = _ref;
    if (ref != null) {
      ref.invalidate(userProfileNotifierProvider);
      ref.invalidate(themeNotifierProvider);
      ref.invalidate(expenseNotifierProvider);
      ref.invalidate(smsPrivacySettingsProvider);
      ref.invalidate(smsScanStatusProvider);
      ref.invalidate(smsDetectionNotifierProvider);
      ref.invalidate(notificationSettingsProvider);
      ref.invalidate(notificationsListProvider);
      ref.invalidate(streakNotifierProvider);
    }

    notifyListeners();
  }

  /// Reset all PIN auth configurations.
  void reset() {
    _prefs.remove('auth_pin');
    _prefs.remove('recovery_answer_hash');
    _prefs.remove('profile_type');
    _prefs.remove('terms_accepted');
    _sessionAuthenticated = false;
    notifyListeners();
  }

  void completeSmsSetup({
    required String bank,
    required String sampleDebit,
    required String sampleCredit,
  }) {
    _prefs.setString('selected_bank', bank);
    _prefs.setString('sms_sample_debit', sampleDebit);
    _prefs.setString('sms_sample_credit', sampleCredit);
    _prefs.setBool('sms_setup_completed', true);
    notifyListeners();
  }

  void logout() {
    _sessionAuthenticated = false;
    notifyListeners();
  }
  void acceptTerms() {
  _prefs.setBool('terms_accepted', true);
  notifyListeners();
}
  void completePermissions() {
  _prefs.setBool('permissions_completed', true);
  notifyListeners();
}

_prefs.remove('permissions_completed');
}

final authNotifierProvider = ChangeNotifierProvider<AuthNotifier>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthNotifier(prefs, ref);
});
