import 'package:flutter/material.dart';
import 'theme_extensions.dart';
import 'package:money_lens/core/design/design_system.dart';

/// MoneyLens Design System (MLDS) Light Theme definition.
///
/// Implements the Light Mode calibration of the Emotional Color System (ECS):
/// - Soft contrast ratios to reduce cognitive fatigue.
/// - Clear surface elevation hierarchy.
/// - Calibrated functional colors (non-neon, calming status tones).
final ThemeData mldsLightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFFF9F9F9),
  primaryColor: const Color(0xFF007AFF),
  cardColor: AppColors.textPrimary,
  dividerColor: const Color(0x1F000000),
  extensions: const [
    MLThemeColors(
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
      // Surface System
      surfaceCard: AppColors.textPrimary,
      surfaceFloating: AppColors.textPrimary,
      surfaceDialog: AppColors.textPrimary,
      surfaceOverlay: Color(0x0A000000),
      surfaceBottomSheet: AppColors.textPrimary,
      surfaceNavigation: Color(0xFFF9F9F9),
    ),
  ],
);
