import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../radius/app_radius.dart';
import '../typography/app_typography.dart';

enum StatusType { success, warning, error, info, neutral }

/// A status pill tag indicator (e.g., Success, Warning, Error, Info).
class StatusChip extends StatelessWidget {
  final String label;
  final StatusType type;

  const StatusChip({
    super.key,
    required this.label,
    this.type = StatusType.neutral,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Color bgColor;

    switch (type) {
      case StatusType.success:
        textColor = AppColors.success;
        bgColor = AppColors.success.withValues(alpha: 0.12);
        break;
      case StatusType.warning:
        textColor = AppColors.warning;
        bgColor = AppColors.warning.withValues(alpha: 0.12);
        break;
      case StatusType.error:
        textColor = AppColors.error;
        bgColor = AppColors.error.withValues(alpha: 0.12);
        break;
      case StatusType.info:
        textColor = AppColors.primaryLight;
        bgColor = AppColors.primaryLight.withValues(alpha: 0.12);
        break;
      case StatusType.neutral:
        textColor = AppColors.textSecondary;
        bgColor = AppColors.divider;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.pill,
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
