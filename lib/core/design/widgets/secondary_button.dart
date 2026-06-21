import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../radius/app_radius.dart';
import '../typography/app_typography.dart';
import 'animated_button.dart';
import '../../ui_engine/ui_engine.dart';

/// A secondary button with a card-surface background for lower-priority options.
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double height;

  const SecondaryButton({
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
          color: active ? AppColors.card : AppColors.card.withValues(alpha: 0.35),
          borderRadius: AppRadius.button,
          border: Border.all(
            color: AppColors.divider,
            width: 1.0,
          ),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: MLSpinner(
                  size: 20,
                  color: AppColors.textSecondary,
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
                      color: active ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
