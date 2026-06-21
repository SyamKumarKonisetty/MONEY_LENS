import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../radius/app_radius.dart';
import '../typography/app_typography.dart';

/// A card for displaying key stats (e.g., Balance, Income, Expenses).
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trendWidget;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.trendWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.divider, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.subtitle,
              ),
              if (icon != null)
                Icon(
                  icon,
                  color: iconColor ?? AppColors.textSecondary,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.displayMedium,
          ),
          if (subtitle != null || trendWidget != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                if (trendWidget != null) ...[
                  trendWidget!,
                  const SizedBox(width: AppSpacing.xxs),
                ],
                if (subtitle != null)
                  Expanded(
                    child: Text(
                      subtitle!,
                      style: AppTypography.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
