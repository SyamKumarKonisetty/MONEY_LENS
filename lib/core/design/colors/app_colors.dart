import 'package:flutter/material.dart';

/// Centralized premium color system for MoneyLens V2 NEXT.
/// Implements the "Midnight Sapphire" design language.
class AppColors {
  AppColors._();

  // ── Backgrounds & Surfaces ──────────────────────────────────────────
  /// Absolute darkest background for the application.
  static const Color midnightSapphire = Color(0xFF050608);
  static const Color background = midnightSapphire;

  /// Dark layered surfaces for cards and panels.
  static const Color surface1 = Color(0xFF0B1017);
  static const Color surface2 = Color(0xFF101826);
  static const Color surface3 = Color(0xFF162131);


  static const Color surface = surface1;
  static const Color card = surface2;
  static const Color divider = Color(0xFF23262F);

  // ── Brand & Highlights ──────────────────────────────────────────────
  /// Primary brand color.
  static const Color sapphireBlue = Color(0xFF1677FF);
  static const Color primary = sapphireBlue;
  
  /// Bright cyan for accents, glows, and ambient light.
  static const Color cyanHighlight = Color(0xFF06B6D4);
  static const Color primaryLight = cyanHighlight;

  // ── Status & Semantic ───────────────────────────────────────────────
  /// Professional green for income and success.
  static const Color incomeGreen = Color(0xFF10B981);
  static const Color income = incomeGreen;
  static const Color success = incomeGreen;

  /// Premium coral red for expenses and destructive actions.
  static const Color expenseCoral = Color(0xFFEF4444);
  static const Color expense = expenseCoral;
  static const Color error = expenseCoral;

  /// Amber for warnings and alerts.
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color warning = warningAmber;

  // ── Typography ──────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF5F7FA);
  static const Color textSecondary = Color(0xFFB7C4D6);
  static const Color textMuted = Color(0xFF7D8FA7);
  static const Color textHint = textMuted;

  // ── Gradients ───────────────────────────────────────────────────────
  static const LinearGradient sapphireGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [sapphireBlue, Color(0xFF0050E6)],
  );

  static const LinearGradient cyanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cyanHighlight, sapphireBlue],
  );

  static const LinearGradient incomeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [incomeGreen, Color(0xFF059669)],
  );

  static const LinearGradient expenseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [expenseCoral, Color(0xFFDC2626)],
  );

  // ── Apple Theme Compatibility Fallbacks (Legacy) ────────────────────
  static const Color primaryDark = primary;
  static const Color backgroundLight = Color(0xFFF5F5F7);
  static const Color backgroundDark = background;
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = surface;
  static const Color surfaceVariantLight = Color(0xFFF2F2F7);
  static const Color surfaceVariantDark = card;
  static const Color textPrimaryLight = Colors.black;
  static const Color textPrimaryDark = textPrimary;
  static const Color textSecondaryLight = textSecondary;
  static const Color textSecondaryDark = textSecondary;
  static const Color separatorLight = Color(0xFFC6C6C8);
  static const Color separatorDark = divider;
  static const Color successLight = income;
  static const Color successDark = income;
  static const Color warningLight = warning;
  static const Color warningDark = warning;
  static const Color errorLight = error;
  static const Color errorDark = error;
  static const Color glassLight = Color(0xB3FFFFFF);
  static const Color glassDark = Color(0x80111317);

  // ── Category Palette (Visual Charts) ────────────────────────────────
  static const Color categoryFood = Color(0xFFFF6B35);
  static const Color categoryTransport = Color(0xFF6366F1);
  static const Color categoryShopping = Color(0xFFEC4899);
  static const Color categoryHealthcare = incomeGreen;
  static const Color categoryEntertainment = Color(0xFF8B5CF6);
  static const Color categoryUtilities = cyanHighlight;
  static const Color categoryEducation = warningAmber;
  static const Color categorySalary = incomeGreen;
  static const Color categoryFreelance = sapphireBlue;

  static const List<Color> categoryPalette = [
    categoryFood,
    categoryTransport,
    categoryShopping,
    categoryHealthcare,
    categoryEntertainment,
    categoryUtilities,
    categoryEducation,
    sapphireBlue,
    cyanHighlight,
    incomeGreen,
    expenseCoral,
    warningAmber,
  ];
}
