import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/design/design_system.dart';
import '../../../../../core/ui_engine/ui_engine.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../budget/presentation/providers/budget_provider.dart';
import '../animations/dashboard_animations.dart';

/// reimagined Monthly Budget Section utilising LiquidProgressRing from Stage 2.
class MonthlyBudgetSection extends ConsumerWidget {
  const MonthlyBudgetSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(budgetSummaryProvider);
    final safeDaily = ref.watch(dailySpendingLimitProvider);

    if (summary.totalLimit == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        child: ScaleUpEntrance(
          delay: const Duration(milliseconds: 350),
          child: GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            onTap: () => context.push(AppConstants.routeBudget),
            isInteractive: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.pie_chart_rounded,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'MONTHLY BUDGET',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'No Budgets Set',
                        style: AppTypography.title.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Set monthly budgets to monitor category tracking.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      GlassButton(
                        label: 'Configure Budget',
                        onTap: () => context.push(AppConstants.routeBudget),
                        gradient: AppGradients.primary,
                        height: 40,
                        width: 180,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isOverBudget = summary.totalSpent > summary.totalLimit;
    final percentUsed = summary.usagePercent;
    final progress = (summary.totalSpent / summary.totalLimit).clamp(0.0, 1.0);
    
    Color ringColor = AppColors.primary;
    if (percentUsed >= 100.0) {
      ringColor = AppColors.expense;
    } else if (percentUsed >= 80.0) {
      ringColor = AppColors.warning;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: ScaleUpEntrance(
        delay: const Duration(milliseconds: 350),
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          onTap: () => context.push(AppConstants.routeBudget),
          isInteractive: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pie_chart_rounded, color: ringColor, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'MONTHLY BUDGET',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    isOverBudget ? 'OVER LIMIT' : '${percentUsed.toStringAsFixed(0)}% USED',
                    style: AppTypography.caption.copyWith(
                      color: ringColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Progress circle side-by-side with statistics
              Row(
                children: [
                  // Liquid Progress Ring
                  LiquidProgressRing(
                    progress: progress,
                    size: 96,
                    strokeWidth: 8,
                    gradientStart: ringColor,
                    gradientEnd: ringColor.withValues(alpha: 0.7),
                    child: Text(
                      isOverBudget ? '!' : '${(progress * 100).toStringAsFixed(0)}%',
                      style: AppTypography.title.copyWith(
                        color: ringColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xl),

                  // Detail columns
                  Expanded(
                    child: Column(
                      children: [
                        _DetailRow(
                          label: 'Monthly Limit',
                          value: summary.totalLimit,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(height: 6),
                        _DetailRow(
                          label: 'Spent Outflow',
                          value: summary.totalSpent,
                          color: isOverBudget ? AppColors.expense : AppColors.textPrimary,
                        ),
                        const SizedBox(height: 6),
                        _DetailRow(
                          label: 'Remaining Balance',
                          value: summary.totalRemaining,
                          color: isOverBudget ? AppColors.expense : AppColors.income,
                          isNegative: summary.totalRemaining < 0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.md),

              // Safe Daily Spend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Safe Daily Spend',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${CurrencyFormatter.compact(safeDaily.abs())}/day available',
                    style: AppTypography.caption.copyWith(
                      color: safeDaily > 0 ? AppColors.income : AppColors.expense,
                      fontWeight: FontWeight.bold,
                    ),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.color,
    this.isNegative = false,
  });

  final String label;
  final double value;
  final Color color;
  final bool isNegative;

  @override
  Widget build(BuildContext context) {
    final prefix = isNegative ? '−' : '';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        Text(
          '$prefix${CurrencyFormatter.compact(value.abs())}',
          style: AppTypography.body.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
