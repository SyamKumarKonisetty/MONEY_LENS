import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../../transactions/domain/models.dart';
import '../../domain/models.dart';
import '../../../budget/presentation/providers/budget_provider.dart';

/// Monthly summary card for the analytics screen with real calculations.
class MonthlySummaryCard extends ConsumerWidget {
  const MonthlySummaryCard({super.key, required this.summary});

  final MonthlySummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(allTransactionsProvider);
    final now = DateTime.now();
    final thisMonth = all
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .toList();

    final thisMonthExpenses = thisMonth.where((t) => t.type == TransactionType.expense).toList();
    final totalExpenses = thisMonthExpenses.fold(0.0, (sum, t) => sum + t.amount);
    final txCount = thisMonthExpenses.length;

    var topCategory = 'None';
    if (thisMonthExpenses.isNotEmpty) {
      final categoryTotals = <String, double>{};
      for (final t in thisMonthExpenses) {
        final categoryName = AppCategories.findById(t.categoryId).name;
        categoryTotals[categoryName] =
            (categoryTotals[categoryName] ?? 0.0) + t.amount;
      }
      var maxVal = -1.0;
      categoryTotals.forEach((cat, total) {
        if (total > maxVal) {
          maxVal = total;
          topCategory = cat;
        }
      });
    }

    final budgetAsync = ref.watch(currentMonthBudgetProvider);
    final budgetLimit = budgetAsync.value ?? 50000.0;
    final budgetExceeded = totalExpenses > budgetLimit;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'June 2026',
                style: AppTypography.titleLarge.copyWith(
                  color: context.textPrimaryColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: budgetExceeded
                      ? context.errorColor.withValues(alpha: 0.1)
                      : context.successColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.circularFull,
                ),
                child: Text(
                  budgetExceeded ? 'Over Budget' : 'Under Budget',
                  style: AppTypography.labelSmall.copyWith(
                    color: budgetExceeded
                        ? context.errorColor
                        : context.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Three metrics
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'Total Spent',
                  value: CurrencyFormatter.compact(totalExpenses),
                  color: context.errorColor,
                ),
              ),
              Expanded(
                child: _Metric(
                  label: 'Txs Count',
                  value: '$txCount',
                  color: context.successColor,
                ),
              ),
              Expanded(
                child: _Metric(
                  label: 'Top Category',
                  value: topCategory,
                  color: context.primaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Spending progress bar relative to budget limit
          ClipRRect(
            borderRadius: AppRadius.circularFull,
            child: LinearProgressIndicator(
              value: (totalExpenses / budgetLimit).clamp(0.0, 1.0),
              backgroundColor: context.surfaceVariantColor,
              color: budgetExceeded ? context.errorColor : context.primaryColor,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${CurrencyFormatter.compact(totalExpenses)} of ${CurrencyFormatter.compact(budgetLimit)} monthly budget spent',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
