import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../radius/app_radius.dart';
import '../typography/app_typography.dart';
import '../icons/app_icons.dart';

enum SnackBarType { success, warning, error, info }

/// Floating SnackBars styled to represent Success, Warning, Error, and Info messages.
class FloatingSnackBar {
  FloatingSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color bgColor;
    IconData icon;
    Color iconColor;

    switch (type) {
      case SnackBarType.success:
        bgColor = const Color(0xFF1E291E);
        icon = AppIcons.check;
        iconColor = AppColors.success;
        break;
      case SnackBarType.warning:
        bgColor = const Color(0xFF2C251C);
        icon = AppIcons.warning;
        iconColor = AppColors.warning;
        break;
      case SnackBarType.error:
        bgColor = const Color(0xFF2C1C1E);
        icon = AppIcons.error;
        iconColor = AppColors.error;
        break;
      case SnackBarType.info:
        bgColor = const Color(0xFF1C222C);
        icon = AppIcons.info;
        iconColor = AppColors.primaryLight;
        break;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.clearSnackBars();
    
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTypography.body.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        elevation: 6.0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.small,
          side: BorderSide(
            color: iconColor.withValues(alpha: 0.2),
            width: 1.0,
          ),
        ),
        duration: duration,
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) =>
      show(context, message: message, type: SnackBarType.success);

  static void showWarning(BuildContext context, String message) =>
      show(context, message: message, type: SnackBarType.warning);

  static void showError(BuildContext context, String message) =>
      show(context, message: message, type: SnackBarType.error);

  static void showInfo(BuildContext context, String message) =>
      show(context, message: message, type: SnackBarType.info);
}
