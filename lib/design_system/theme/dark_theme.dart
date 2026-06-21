import 'package:flutter/material.dart';
import 'theme_extensions.dart';

/// MoneyLens Design System (MLDS) Dark Theme definition.
///
/// Implements the Dark Mode calibration of the Emotional Color System (ECS):
/// - OLED-friendly pure blacks (0xFF000000) for screen backdrops.
/// - Calibrated charcoal surfaces to build depth without distracting glow.
/// - Calibrated status colors that remain highly readable without inducing anxiety.
final ThemeData mldsDarkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFF000000),
  primaryColor: const Color(0xFF0A84FF),
  cardColor: const Color(0xFF1C1C1E),
  dividerColor: const Color(0x1FFFFFFF),
  extensions: const [
    MLThemeColors(
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
      // Surface System
      surfaceCard: Color(0xFF121212),
      surfaceFloating: Color(0xFF1E1E1E),
      surfaceDialog: Color(0xFF1E1E1E),
      surfaceOverlay: Color(0x80000000),
      surfaceBottomSheet: Color(0xFF1C1C1E),
      surfaceNavigation: Color(0xFF121212),
    ),
  ],
);
