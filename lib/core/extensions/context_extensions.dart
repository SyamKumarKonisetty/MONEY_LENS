import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// BuildContext extensions for convenient theme access.
///
/// Usage:
/// ```dart
/// context.colorScheme.primary
/// context.textTheme.titleLarge
/// context.isDark
/// ```
extension BuildContextExtensions on BuildContext {
  // ─── Theme ────────────────────────────────────────────────────────────────

  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDark => true;
  bool get isLight => false;

  // ─── Media ────────────────────────────────────────────────────────────────

  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  // ─── App-specific colors ──────────────────────────────────────────────────

  Color get backgroundColor => AppColors.backgroundDark;

  Color get surfaceColor => AppColors.surfaceDark;

  Color get surfaceVariantColor => AppColors.surfaceVariantDark;

  Color get textPrimaryColor => AppColors.textPrimaryDark;

  Color get textSecondaryColor => AppColors.textSecondaryDark;

  Color get separatorColor => AppColors.separatorDark;

  Color get primaryColor => AppColors.primaryDark;

  Color get successColor => AppColors.successDark;

  Color get warningColor => AppColors.warningDark;

  Color get errorColor => AppColors.errorDark;

  Color get glassColor => AppColors.glassDark;
}
