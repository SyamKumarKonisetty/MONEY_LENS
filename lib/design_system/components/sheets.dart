import 'package:flutter/material.dart';

/// MoneyLens Design System (MLDS) Bottom Sheet Component interface.
///
/// Under MLDS, bottom sheets scale the parent down by 0.95 and dim the background.
class MLSheet {
  MLSheet._();

  /// Displays a modal bottom sheet.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget builder,
    bool isScrollControlled = true,
    bool enableDrag = true,
  }) {
    // Placeholder architecture stub
    return Future.value(null);
  }
}
