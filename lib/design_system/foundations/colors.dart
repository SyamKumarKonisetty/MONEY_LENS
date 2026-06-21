import 'package:flutter/material.dart';
import '../theme/theme_extensions.dart';
import 'package:money_lens/core/design/design_system.dart';

/// Semantic Color Tokens for MoneyLens Design System (MLDS).
///
/// Under MLDS, raw Color hex codes are never used directly in widgets.
/// Instead, colors are resolved contextually from the active theme.
class MLColors {
  MLColors._();

  /// Resolves the semantic color token set for the current theme context.
  static MLThemeColors of(BuildContext context) {
    final colors = Theme.of(context).extension<MLThemeColors>();
    if (colors == null) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return isDark ? _darkFallback : _lightFallback;
    }
    return colors;
  }

  static const _lightFallback = MLThemeColors(
    surface: AppColors.textPrimary,
    surfaceVariant: Color(0xFFF2F2F7),
    background: Color(0xFFF9F9F9),
    primary: Color(0xFF007AFF),
    secondary: Color(0xFF5856D6),
    error: Color(0xFFFF3B30),
    warning: Color(0xFFFF9500),
    success: Color(0xFF34C759),
    income: Color(0xFF34C759),
    expense: Color(0xFFFF3B30),
    budget: Color(0xFF32ADE6),
    glass: Color(0xCCFFFFFF),
    surfaceCard: AppColors.textPrimary,
    surfaceFloating: AppColors.textPrimary,
    surfaceDialog: AppColors.textPrimary,
    surfaceOverlay: Color(0x0A000000),
    surfaceBottomSheet: AppColors.textPrimary,
    surfaceNavigation: Color(0xFFF9F9F9),
  );

  static const _darkFallback = MLThemeColors(
    surface: Color(0xFF1C1C1E),
    surfaceVariant: Color(0xFF2C2C2E),
    background: Color(0xFF000000),
    primary: Color(0xFF0A84FF),
    secondary: Color(0xFF5E5CE6),
    error: Color(0xFFFF453A),
    warning: Color(0xFFFF9F0A),
    success: Color(0xFF30D158),
    income: Color(0xFF30D158),
    expense: Color(0xFFFF453A),
    budget: Color(0xFF64D2FF),
    glass: Color(0xCC1C1C1E),
    surfaceCard: Color(0xFF121212),
    surfaceFloating: Color(0xFF1E1E1E),
    surfaceDialog: Color(0xFF1E1E1E),
    surfaceOverlay: Color(0x80000000),
    surfaceBottomSheet: Color(0xFF1C1C1E),
    surfaceNavigation: Color(0xFF121212),
  );

  // ─── Semantic Getters ─────────────────────────────────────────────────────
  static Color primary(BuildContext context) => of(context).primary;
  static Color secondary(BuildContext context) => of(context).secondary;
  static Color background(BuildContext context) => of(context).background;
  static Color surface(BuildContext context) => of(context).surface;
  static Color surfaceVariant(BuildContext context) =>
      of(context).surfaceVariant;
  static Color error(BuildContext context) => of(context).error;
  static Color warning(BuildContext context) => of(context).warning;
  static Color success(BuildContext context) => of(context).success;
  static Color income(BuildContext context) => of(context).income;
  static Color expense(BuildContext context) => of(context).expense;
  static Color budget(BuildContext context) => of(context).budget;
  static Color glass(BuildContext context) => of(context).glass;

  // ─── Surface System Getters ────────────────────────────────────────────────
  static Color surfaceCard(BuildContext context) => of(context).surfaceCard;
  static Color surfaceFloating(BuildContext context) =>
      of(context).surfaceFloating;
  static Color surfaceDialog(BuildContext context) => of(context).surfaceDialog;
  static Color surfaceOverlay(BuildContext context) =>
      of(context).surfaceOverlay;
  static Color surfaceBottomSheet(BuildContext context) =>
      of(context).surfaceBottomSheet;
  static Color surfaceNavigation(BuildContext context) =>
      of(context).surfaceNavigation;

  // ─── Financial Emotion Scale ──────────────────────────────────────────────

  /// Resolves a color representing budget progression:
  /// - 0% - 40%: Safe (Soft cool blue)
  /// - 40% - 70%: Stable (Calm green-teal)
  /// - 70% - 85%: Attention (Muted amber)
  /// - 85% - 100%: Careful (Deep orange)
  /// - 100%+: Exceeded (Respectful red)
  static Color budgetScaleColor(BuildContext context, double percentage) {
    if (percentage <= 0.40) {
      return const Color(0xFF32ADE6);
    } else if (percentage <= 0.70) {
      return const Color(0xFF30D158);
    } else if (percentage <= 0.85) {
      return const Color(0xFFFF9F0A);
    } else if (percentage <= 1.00) {
      return const Color(0xFFFF9500);
    } else {
      return const Color(0xFFFF453A);
    }
  }

  // ─── Financial Seasons ────────────────────────────────────────────────────

  /// Resolves an overlay tint depending on the active day of the month:
  /// - Days 1-10: Fresh / Cool (Subtle blue-teal overlay)
  /// - Days 11-20: Balanced (Subtle neutral-green overlay)
  /// - Days 21-31: Reflection (Subtle warm amber overlay)
  static Color seasonColor(BuildContext context, DateTime date) {
    final day = date.day;
    if (day <= 10) {
      return const Color(0xFF64D2FF).withAlpha(15);
    } else if (day <= 20) {
      return const Color(0xFF30D158).withAlpha(15);
    } else {
      return const Color(0xFFFF9F0A).withAlpha(15);
    }
  }
}
