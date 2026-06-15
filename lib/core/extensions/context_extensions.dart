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
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  bool get isLight => !isDark;

  // ─── Media ────────────────────────────────────────────────────────────────

  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  // ─── App-specific colors ──────────────────────────────────────────────────

  Color get backgroundColor =>
      isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

  Color get surfaceColor =>
      isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

  Color get surfaceVariantColor =>
      isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;

  Color get textPrimaryColor =>
      isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

  Color get textSecondaryColor =>
      isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

  Color get separatorColor =>
      isDark ? AppColors.separatorDark : AppColors.separatorLight;

  Color get primaryColor =>
      isDark ? AppColors.primaryDark : AppColors.primaryLight;

  Color get successColor =>
      isDark ? AppColors.successDark : AppColors.successLight;

  Color get warningColor =>
      isDark ? AppColors.warningDark : AppColors.warningLight;

  Color get errorColor => isDark ? AppColors.errorDark : AppColors.errorLight;

  Color get glassColor => isDark ? AppColors.glassDark : AppColors.glassLight;
}
