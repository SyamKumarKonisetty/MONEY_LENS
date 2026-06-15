import 'package:flutter/material.dart';
import 'app_colors.dart';

/// MoneyLens shadow system.
///
/// Subtle, Apple-inspired shadows that add depth without visual noise.
/// Avoid harsh shadows — use very low opacity and spread.
class AppShadows {
  AppShadows._();

  // ─── Light theme shadows ───────────────────────────────────────────────────

  /// Ultra-subtle shadow for cards on white backgrounds
  static List<BoxShadow> get cardLight => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  /// Medium shadow for floating elements (FAB, modals)
  static List<BoxShadow> get floatingLight => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 32,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// Large shadow for bottom sheets and dialogs
  static List<BoxShadow> get elevatedLight => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.18),
      blurRadius: 48,
      offset: const Offset(0, 16),
      spreadRadius: 0,
    ),
  ];

  // ─── Dark theme shadows ───────────────────────────────────────────────────

  /// Glow effect for cards on dark background
  static List<BoxShadow> get cardDark => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Medium dark shadow for floating elements
  static List<BoxShadow> get floatingDark => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.6),
      blurRadius: 40,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  // ─── Colored accent shadows ────────────────────────────────────────────────

  /// Primary blue glow for action buttons
  static List<BoxShadow> get primaryGlow => [
    BoxShadow(
      color: AppColors.primaryLight.withValues(alpha: 0.35),
      blurRadius: 20,
      offset: const Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  /// Dark mode primary glow
  static List<BoxShadow> get primaryGlowDark => [
    BoxShadow(
      color: AppColors.primaryDark.withValues(alpha: 0.45),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  // ─── Context-aware helpers ─────────────────────────────────────────────────

  /// Returns the correct card shadow for the current brightness.
  static List<BoxShadow> card(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? cardDark
        : cardLight;
  }

  /// Returns the correct floating shadow for the current brightness.
  static List<BoxShadow> floating(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? floatingDark
        : floatingLight;
  }

  /// Returns the correct glow shadow for the current brightness.
  static List<BoxShadow> primaryAccent(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? primaryGlowDark
        : primaryGlow;
  }
}
