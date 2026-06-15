import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../transactions/domain/models.dart';

/// Full transaction list tile (Transactions screen).
class TransactionListTile extends StatelessWidget {
  const TransactionListTile({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final cat = AppCategories.findById(transaction.categoryId);
    final isExpense = transaction.type.isExpense;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: cat.color.withValues(alpha: 0.12),
              borderRadius: AppRadius.circularMd,
            ),
            child: Icon(cat.icon, color: cat.color, size: 24),
          ),

          const SizedBox(width: AppSpacing.lg),

          // Info
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
                Row(
                  children: [
                    Text(
                      cat.name,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                    if (transaction.note != null) ...[
                      Text(
                        ' · ',
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          transaction.note!,
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textSecondaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.lg),

          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isExpense
                    ? '−${CurrencyFormatter.full(transaction.amount)}'
                    : '+${CurrencyFormatter.full(transaction.amount)}',
                style: AppTypography.titleMedium.copyWith(
                  color: isExpense ? context.errorColor : context.successColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_pad(transaction.date.hour)}:${_pad(transaction.date.minute)}',
                style: AppTypography.labelSmall.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _pad(int v) => v.toString().padLeft(2, '0');
}
