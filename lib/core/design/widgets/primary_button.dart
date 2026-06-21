import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../radius/app_radius.dart';
import '../typography/app_typography.dart';
import 'animated_button.dart';
import '../../ui_engine/ui_engine.dart';

/// A premium, high-contrast primary CTA button with scale-down feedback and loading indicators.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double height;

  const PrimaryButton({
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

    final Widget buttonContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: width == null ? MainAxisSize.min : MainAxisSize.max,
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
            color: active ? AppColors.textPrimary : Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );

    return AnimatedButton(
      onTap: active ? onTap : null,
      child: Container(
        width: width,
        height: height,
        padding: width == null ? const EdgeInsets.symmetric(horizontal: AppSpacing.xl) : null,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.primary.withValues(alpha: 0.35),
          borderRadius: AppRadius.button,
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Center(
          widthFactor: width == null ? 1.0 : null,
          heightFactor: 1.0,
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: MLSpinner(
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                )
              : buttonContent,
        ),
      ),
    );
  }
}
