import 'package:flutter/foundation.dart';

/// Logging filter interceptor that redacts sensitive PII details.
class MLSensitiveDataFilter {
  MLSensitiveDataFilter._();

  static final RegExp _amountRegex = RegExp(
    r'₹\s*\d+(?:\.\d{2})?|\b\d+(?:\.\d{2})\b',
  );
  static final RegExp _phoneRegex = RegExp(r'\+?\d{10,12}');
  static final RegExp _accountRegex = RegExp(r'\b[A-Za-z]*\d{4,}[A-Za-z\d]*\b');

  /// Redacts amounts, phone numbers, and account handles.
  static String redact(String message) {
    var result = message;
    result = result.replaceAllMapped(_amountRegex, (m) => '₹[REDACTED]');
    result = result.replaceAllMapped(_phoneRegex, (m) => '[PHONE_REDACTED]');
    result = result.replaceAllMapped(_accountRegex, (m) => '[SECURE_REDACTED]');
    return result;
  }

  /// Prints redacted statements safely to the debug console.
  static void log(String message) {
    debugPrint(redact(message));
  }
}
