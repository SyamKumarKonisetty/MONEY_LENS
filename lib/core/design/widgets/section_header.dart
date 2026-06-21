import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';

/// A reusable section header with an optional trailing action label.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTypography.headline.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (actionLabel != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: AppTypography.button.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
