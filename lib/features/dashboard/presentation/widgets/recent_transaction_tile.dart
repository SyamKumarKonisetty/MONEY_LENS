import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../transactions/domain/models.dart';

/// A single transaction tile for the dashboard recent list.
class RecentTransactionTile extends StatelessWidget {
  const RecentTransactionTile({
    super.key,
    required this.transaction,
    this.category,
  });

  final Transaction transaction;
  final Category? category;

  @override
  Widget build(BuildContext context) {
    final cat = category ?? AppCategories.findById(transaction.categoryId);
    final isExpense = transaction.type.isExpense;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cat.color.withValues(alpha: 0.12),
              borderRadius: AppRadius.circularMd,
            ),
            child: Icon(cat.icon, color: cat.color, size: 22),
          ),

          const SizedBox(width: AppSpacing.lg),

          // Title + category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: AppTypography.titleMedium.copyWith(
                    color: context.textPrimaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  cat.name,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.lg),

          // Amount
          Text(
            isExpense
                ? '−${CurrencyFormatter.compact(transaction.amount)}'
                : '+${CurrencyFormatter.compact(transaction.amount)}',
            style: AppTypography.titleMedium.copyWith(
              color: isExpense ? context.errorColor : context.successColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
