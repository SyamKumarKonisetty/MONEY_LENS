import 'package:flutter/material.dart';

/// MoneyLens Design System (MLDS) custom ThemeExtension for color tokens.
///
/// This provides typesafe semantic colors to the widgets context.
class MLThemeColors extends ThemeExtension<MLThemeColors> {
  const MLThemeColors({
    required this.surface,
    required this.surfaceVariant,
    required this.background,
    required this.primary,
    required this.secondary,
    required this.error,
    required this.warning,
    required this.success,
    required this.income,
    required this.expense,
    required this.budget,
    required this.glass,
    required this.surfaceCard,
    required this.surfaceFloating,
    required this.surfaceDialog,
    required this.surfaceOverlay,
    required this.surfaceBottomSheet,
    required this.surfaceNavigation,
  });

  final Color surface;
  final Color surfaceVariant;
  final Color background;
  final Color primary;
  final Color secondary;
  final Color error;
  final Color warning;
  final Color success;
  final Color income;
  final Color expense;
  final Color budget;
  final Color glass;

  // Expanded Surfaces System
  final Color surfaceCard;
  final Color surfaceFloating;
  final Color surfaceDialog;
  final Color surfaceOverlay;
  final Color surfaceBottomSheet;
  final Color surfaceNavigation;

  @override
  MLThemeColors copyWith({
    Color? surface,
    Color? surfaceVariant,
    Color? background,
    Color? primary,
    Color? secondary,
    Color? error,
    Color? warning,
    Color? success,
    Color? income,
    Color? expense,
    Color? budget,
    Color? glass,
    Color? surfaceCard,
    Color? surfaceFloating,
    Color? surfaceDialog,
    Color? surfaceOverlay,
    Color? surfaceBottomSheet,
    Color? surfaceNavigation,
  }) {
    return MLThemeColors(
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      background: background ?? this.background,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      success: success ?? this.success,
      income: income ?? this.income,
      expense: expense ?? this.expense,
      budget: budget ?? this.budget,
      glass: glass ?? this.glass,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceFloating: surfaceFloating ?? this.surfaceFloating,
      surfaceDialog: surfaceDialog ?? this.surfaceDialog,
      surfaceOverlay: surfaceOverlay ?? this.surfaceOverlay,
      surfaceBottomSheet: surfaceBottomSheet ?? this.surfaceBottomSheet,
      surfaceNavigation: surfaceNavigation ?? this.surfaceNavigation,
    );
  }

  @override
  MLThemeColors lerp(ThemeExtension<MLThemeColors>? other, double t) {
    if (other is! MLThemeColors) {
      return this;
    }
    return MLThemeColors(
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      background: Color.lerp(background, other.background, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      budget: Color.lerp(budget, other.budget, t)!,
      glass: Color.lerp(glass, other.glass, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      surfaceFloating: Color.lerp(surfaceFloating, other.surfaceFloating, t)!,
      surfaceDialog: Color.lerp(surfaceDialog, other.surfaceDialog, t)!,
      surfaceOverlay: Color.lerp(surfaceOverlay, other.surfaceOverlay, t)!,
      surfaceBottomSheet: Color.lerp(
        surfaceBottomSheet,
        other.surfaceBottomSheet,
        t,
      )!,
      surfaceNavigation: Color.lerp(
        surfaceNavigation,
        other.surfaceNavigation,
        t,
      )!,
    );
  }
}
