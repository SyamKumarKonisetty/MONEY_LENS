import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../animations/app_animations.dart';

/// A secure PIN dot indicator displaying entered credentials progress.
class AppPinField extends StatelessWidget {
  final int length;
  final int currentLength;
  final double dotSize;

  const AppPinField({
    super.key,
    this.length = 4,
    required this.currentLength,
    this.dotSize = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final bool isFilled = index < currentLength;

        return AnimatedContainer(
          duration: AppAnimations.fast,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? AppColors.primary : Colors.transparent,
            border: Border.all(
              color: isFilled ? AppColors.primary : AppColors.divider,
              width: 2.0,
            ),
            boxShadow: isFilled
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 8.0,
                      spreadRadius: 1.0,
                    )
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
