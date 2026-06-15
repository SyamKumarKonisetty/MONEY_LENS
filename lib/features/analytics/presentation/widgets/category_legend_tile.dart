import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models.dart';
import '../../../transactions/domain/models.dart';

/// Category legend row for the analytics screen.
class CategoryLegendTile extends StatelessWidget {
  const CategoryLegendTile({super.key, required this.spending});

  final CategorySpending spending;

  @override
  Widget build(BuildContext context) {
    final category = AppCategories.findById(spending.categoryId);
    final percentage = (spending.percentage * 100).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Color dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: category.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Category icon + name
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.12),
              borderRadius: AppRadius.circularSm,
            ),
            child: Icon(category.icon, color: category.color, size: 16),
          ),
          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Text(
              category.name,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textPrimaryColor,
              ),
            ),
          ),

          // Percentage
          Text(
            '$percentage%',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(width: AppSpacing.xl),

          // Amount
          Text(
            CurrencyFormatter.compact(spending.amount),
            style: AppTypography.titleSmall.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
