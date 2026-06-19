import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../budget/presentation/providers/budget_provider.dart';

class DashboardBudgetCard extends ConsumerWidget {
  const DashboardBudgetCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(budgetSummaryProvider);
    final safeDaily = ref.watch(dailySpendingLimitProvider);
    final isDark = context.isDark;

    if (summary.totalLimit == 0) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: context.separatorColor.withValues(alpha: isDark ? 0.3 : 0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pie_chart_rounded,
                  color: context.primaryColor.withValues(alpha: 0.6),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Monthly Budget',
                  style: AppTypography.titleMedium.copyWith(
                    color: context.textPrimaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Column(
                children: [
                  Text(
                    'No Budgets Configured',
                    style: AppTypography.titleLarge.copyWith(
                      color: context.textPrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Create category budgets to stay in control.',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: () => context.push(AppConstants.routeBudget),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.circularMd,
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Configure Budget',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final progress = (summary.totalSpent / summary.totalLimit).clamp(0.0, 1.0);
    final isOverBudget = summary.totalSpent > summary.totalLimit;
    final percentUsed = summary.usagePercent;

    String? alertMessage;
    Color alertColor = context.successColor;

    if (percentUsed >= 100.0) {
      alertMessage =
          '🚨 Budget Exceeded by ${CurrencyFormatter.compact(summary.totalSpent - summary.totalLimit)}!';
      alertColor = context.errorColor;
    } else if (percentUsed >= 90.0) {
      alertMessage = '⚠️ Warning: 90%+ of monthly budget used!';
      alertColor = context.warningColor;
    } else if (percentUsed >= 80.0) {
      alertMessage = '⚠️ Alert: 80%+ of monthly budget used.';
      alertColor = context.warningColor;
    } else if (percentUsed >= 70.0) {
      alertColor = context.warningColor;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: context.separatorColor.withValues(alpha: isDark ? 0.3 : 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.pie_chart_rounded,
                    color: isOverBudget ? context.errorColor : alertColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Monthly Budget',
                    style: AppTypography.titleMedium.copyWith(
                      color: context.textPrimaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isOverBudget
                      ? context.errorColor.withValues(alpha: 0.12)
                      : context.successColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.circularFull,
                ),
                child: Text(
                  isOverBudget
                      ? 'Budget Exceeded'
                      : '${percentUsed.toStringAsFixed(0)}% Used',
                  style: AppTypography.labelSmall.copyWith(
                    color: isOverBudget
                        ? context.errorColor
                        : context.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Progress Bar
          ClipRRect(
            borderRadius: AppRadius.circularFull,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: context.surfaceVariantColor,
              color: isOverBudget ? context.errorColor : alertColor,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Details row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BudgetDetailItem(
                label: 'Budget Limit',
                amount: summary.totalLimit,
                alignRight: false,
              ),
              _BudgetDetailItem(
                label: 'Total Spent',
                amount: summary.totalSpent,
                alignRight: false,
                color: isOverBudget ? context.errorColor : null,
              ),
              _BudgetDetailItem(
                label: 'Remaining',
                amount: summary.totalRemaining.abs(),
                alignRight: true,
                prefixSign: summary.totalRemaining < 0 ? '−' : '',
                color: summary.totalRemaining < 0
                    ? context.errorColor
                    : context.successColor,
              ),
            ],
          ),

          if (alertMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: alertColor.withValues(alpha: 0.1),
                borderRadius: AppRadius.circularMd,
                border: Border.all(color: alertColor.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Icon(
                    percentUsed >= 100.0
                        ? Icons.error_rounded
                        : Icons.warning_rounded,
                    color: alertColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      alertMessage,
                      style: AppTypography.bodySmall.copyWith(
                        color: alertColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),

          // Safe Daily Spend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Safe Daily Spend',
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${CurrencyFormatter.compact(safeDaily)} / day available',
                style: AppTypography.labelLarge.copyWith(
                  color: safeDaily > 0
                      ? context.successColor
                      : context.errorColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BudgetDetailItem extends StatelessWidget {
  const _BudgetDetailItem({
    required this.label,
    required this.amount,
    required this.alignRight,
    this.prefixSign = '',
    this.color,
  });

  final String label;
  final double amount;
  final bool alignRight;
  final String prefixSign;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondaryColor,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$prefixSign${CurrencyFormatter.compact(amount)}',
          style: AppTypography.labelLarge.copyWith(
            color: color ?? context.textPrimaryColor,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
