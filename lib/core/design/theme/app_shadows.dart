import 'package:flutter/material.dart';
import '../colors/app_colors.dart';

/// Centralized shadows and glow effects for MoneyLens V2.
class AppShadows {
  AppShadows._();

  static final BoxShadow soft = BoxShadow(
    color: Colors.black.withValues(alpha: 0.25),
    blurRadius: 16.0,
    offset: const Offset(0, 8),
  );

  static final BoxShadow primaryGlow = BoxShadow(
    color: AppColors.primary.withValues(alpha: 0.35),
    blurRadius: 16.0,
    offset: const Offset(0, 4),
  );

  static final BoxShadow secondaryGlow = BoxShadow(
    color: AppColors.primaryLight.withValues(alpha: 0.25),
    blurRadius: 12.0,
    offset: const Offset(0, 2),
  );

  static final List<BoxShadow> softList = [soft];
  static final List<BoxShadow> primaryGlowList = [primaryGlow];
  static final List<BoxShadow> secondaryGlowList = [secondaryGlow];
}
