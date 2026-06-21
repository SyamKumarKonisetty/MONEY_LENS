import 'package:flutter/material.dart';
import '../foundations/colors.dart';
import '../theme/theme_extensions.dart';

/// Extension helpers on [BuildContext] to simplify design token consumption.
extension MLDSHelpers on BuildContext {
  /// Resolves theme color tokens.
  MLThemeColors get mldsColors => MLColors.of(this);

  /// Checks if dark mode is active.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
