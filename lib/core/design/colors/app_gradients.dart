import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized gradients for MoneyLens V2.
class AppGradients {
  AppGradients._();

  static const LinearGradient primary = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient dashboard = LinearGradient(
    colors: [
      AppColors.primary.withValues(alpha: 0.15),
      AppColors.background.withValues(alpha: 0.05),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient success = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF4ADE80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expense = LinearGradient(
    colors: [Color(0xFFFF5A5F), Color(0xFFF87171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
