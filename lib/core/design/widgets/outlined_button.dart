import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../radius/app_radius.dart';
import '../typography/app_typography.dart';
import 'animated_button.dart';
import '../../ui_engine/ui_engine.dart';

/// An outlined button for tertiary, discrete triggers.
class OutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double height;

  const OutlinedButton({
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
          color: Colors.transparent,
          borderRadius: AppRadius.button,
          border: Border.all(
            color: active ? AppColors.primary : AppColors.divider,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: MLSpinner(
                  size: 20,
                  color: AppColors.primary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: active ? AppColors.primary : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Text(
                    label,
                    style: AppTypography.button.copyWith(
                      color: active ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
