import 'package:flutter/material.dart';

/// MoneyLens Design System (MLDS) Dialog Component interface.
///
/// Prompts confirmation or critical alerts.
class MLDialog {
  MLDialog._();

  /// Shows a confirmation dialog with standard action triggers.
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) {
    // Placeholder architecture stub
    return Future.value(false);
  }

  /// Shows an alert dialog for notifications or errors.
  static Future<void> alert({
    required BuildContext context,
    required String title,
    required String message,
    String buttonLabel = 'OK',
  }) {
    // Placeholder architecture stub
    return Future.value();
  }
}
