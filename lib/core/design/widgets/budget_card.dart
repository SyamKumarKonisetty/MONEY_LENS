import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../radius/app_radius.dart';
import '../typography/app_typography.dart';
import '../../ui_engine/ui_engine.dart';

/// A card for displaying category budgets and progress bars.
class BudgetCard extends StatelessWidget {
  final String category;
  final double limit;
  final double spent;
  final double percentage;
  final String formattedLimit;
  final String formattedSpent;
  final VoidCallback? onTap;

  const BudgetCard({
    super.key,
    required this.category,
    required this.limit,
    required this.spent,
    required this.percentage,
    required this.formattedLimit,
    required this.formattedSpent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine color based on threshold
    final Color progressColor = percentage >= 1.0
        ? AppColors.error
        : percentage >= 0.85
            ? AppColors.warning
            : AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.medium,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadius.medium,
            border: Border.all(color: AppColors.divider, width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category,
                    style: AppTypography.title,
                  ),
                  Text(
                    '${(percentage * 100).toStringAsFixed(0)}%',
                    style: AppTypography.subtitle.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              GradientProgressBar(
                value: percentage.clamp(0.0, 1.0),
                height: 8.0,
                borderRadius: AppRadius.pill.topLeft.x, // or similar double
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Spent: $formattedSpent',
                    style: AppTypography.caption,
                  ),
                  Text(
                    'Limit: $formattedLimit',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
