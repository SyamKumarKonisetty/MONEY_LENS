import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_lens/features/settings/presentation/providers/settings_provider.dart';

class AuthNotifier extends ChangeNotifier {
  final SharedPreferences _prefs;
  bool _sessionAuthenticated = false;

  AuthNotifier(this._prefs);

  bool get isPinSetup => _prefs.getString('auth_pin') != null;
  bool get isSmsSetupCompleted => true;
  bool get isAuthenticated => _sessionAuthenticated;

  String? get selectedBank => _prefs.getString('selected_bank');
  String? get sampleDebitSms => _prefs.getString('sms_sample_debit');
  String? get sampleCreditSms => _prefs.getString('sms_sample_credit');

  bool authenticate(String pin) {
    final storedPin = _prefs.getString('auth_pin');
    if (storedPin == pin) {
      _sessionAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void setupPin(String pin) {
    _prefs.setString('auth_pin', pin);
    _sessionAuthenticated = true; // Auto authenticate on initial setup
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
}

final authNotifierProvider = ChangeNotifierProvider<AuthNotifier>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthNotifier(prefs);
});
