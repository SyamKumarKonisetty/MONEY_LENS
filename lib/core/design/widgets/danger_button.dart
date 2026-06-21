import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../radius/app_radius.dart';
import '../typography/app_typography.dart';
import 'animated_button.dart';
import '../../ui_engine/ui_engine.dart';

/// A button representing destructive / high-risk operations (e.g. Delete, Wipe).
class DangerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double height;

  const DangerButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height = 52.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = onTap != null && !isDisabled && !isLoading;

    return AnimatedButton(
      onTap: active ? onTap : null,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: active ? AppColors.error : AppColors.error.withValues(alpha: 0.35),
          borderRadius: AppRadius.button,
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.error.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: MLSpinner(
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Text(
                    label,
                    style: AppTypography.button.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
