import 'package:flutter/material.dart';

/// MoneyLens color system — Apple Human Interface Design inspired.
///
/// Uses a dual-palette approach:
/// - Light colors (suffix `Light`) for light theme.
/// - Dark colors (suffix `Dark`) for dark/OLED theme.
/// - Category colors are shared across both themes.
///
/// Usage: Always access via [AppColors] static constants or
/// the [AppColorsExtension] on [BuildContext].
class AppColors {
  AppColors._();

  // ─── Primary ───────────────────────────────────────────────────────────────
  static const Color primaryLight = Color(0xFF007AFF);
  static const Color primaryDark = Color(0xFF0A84FF);

  // ─── Backgrounds ──────────────────────────────────────────────────────────
  /// Page background — Apple's signature light grey
  static const Color backgroundLight = Color(0xFFF5F5F7);

  /// Pure OLED black — Apple's dark mode background
  static const Color backgroundDark = Color(0xFF000000);

  // ─── Surfaces ─────────────────────────────────────────────────────────────
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1C1C1E);

  static const Color surfaceVariantLight = Color(0xFFF2F2F7);
  static const Color surfaceVariantDark = Color(0xFF2C2C2E);

  static const Color surfaceElevatedLight = Color(0xFFFFFFFF);
  static const Color surfaceElevatedDark = Color(0xFF3A3A3C);

  // ─── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF1D1D1F);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);

  static const Color textSecondaryLight = Color(0xFF86868B);
  static const Color textSecondaryDark = Color(0xFF8E8E93);

  static const Color textTertiaryLight = Color(0xFFC7C7CC);
  static const Color textTertiaryDark = Color(0xFF48484A);

  // ─── Semantic ─────────────────────────────────────────────────────────────
  static const Color successLight = Color(0xFF34C759);
  static const Color successDark = Color(0xFF30D158);

  static const Color warningLight = Color(0xFFFF9F0A);
  static const Color warningDark = Color(0xFFFFD60A);

  static const Color errorLight = Color(0xFFFF3B30);
  static const Color errorDark = Color(0xFFFF453A);

  // ─── Separators ───────────────────────────────────────────────────────────
  static const Color separatorLight = Color(0xFFC6C6C8);
  static const Color separatorDark = Color(0xFF38383A);

  static const Color separatorOpaqueLight = Color(0xFFD1D1D6);
  static const Color separatorOpaqueDark = Color(0xFF545458);

  // ─── Glass / Overlay ──────────────────────────────────────────────────────
  static const Color glassLight = Color(0xB3FFFFFF); // 70% white
  static const Color glassDark = Color(0x801C1C1E); // 50% surface dark

  static const Color overlayLight = Color(0x0F000000); // 6% black
  static const Color overlayDark = Color(0x1AFFFFFF); // 10% white

  // ─── Category Colors (Curated — shared between themes) ────────────────────
  static const Color categoryFood = Color(0xFFFF6B35);
  static const Color categoryTransport = Color(0xFF6366F1);
  static const Color categoryShopping = Color(0xFFEC4899);
  static const Color categoryHealthcare = Color(0xFF10B981);
  static const Color categoryEntertainment = Color(0xFF8B5CF6);
  static const Color categoryUtilities = Color(0xFF06B6D4);
  static const Color categoryEducation = Color(0xFFF59E0B);
  static const Color categorySalary = Color(0xFF34C759);
  static const Color categoryFreelance = Color(0xFF0EA5E9);

  // ─── Static list for chart usage ──────────────────────────────────────────
  static const List<Color> categoryPalette = [
    categoryFood,
    categoryTransport,
    categoryShopping,
    categoryHealthcare,
    categoryEntertainment,
    categoryUtilities,
    categoryEducation,
  ];
}
