import 'package:flutter/material.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/design/colors/app_colors.dart';
import '../../../../../core/ui_engine/glass/glass_card.dart';
import '../../../../../core/utils/currency_formatter.dart';

/// Predicted monthly spending forecast card.
class BudgetForecastCard extends StatelessWidget {
  const BudgetForecastCard({
    super.key,
    required this.expectedSpend,
    required this.totalBudgetLimit,
    required this.daysLeft,
    required this.riskLevel,
  });

  final double expectedSpend;
  final double totalBudgetLimit;
  final int daysLeft;
  final String riskLevel;

  @override
  Widget build(BuildContext context) {
    final riskColor = _getRiskColor(riskLevel);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: GlassCard(
        isInteractive: false,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'BUDGET FORECAST',
                  style: AppTypography.labelSmall.copyWith(
                    color: context.textSecondaryColor,
                    letterSpacing: 1.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xxs),
                  decoration: BoxDecoration(
                    color: riskColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: riskColor.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Text(
                    '$riskLevel Risk'.toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(
                      color: riskColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            Row(
              children: [
                Expanded(
                  child: _ForecastMetric(
                    label: 'Projected spend',
                    value: CurrencyFormatter.full(expectedSpend),
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: context.separatorColor.withValues(alpha: 0.15),
                ),
                Expanded(
                  child: _ForecastMetric(
                    label: 'Budget limit',
                    value: totalBudgetLimit > 0 ? CurrencyFormatter.full(totalBudgetLimit) : 'No Limit',
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: context.separatorColor.withValues(alpha: 0.15),
                ),
                Expanded(
                  child: _ForecastMetric(
                    label: 'Days left',
                    value: '$daysLeft Days',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(
              _getExplanation(riskLevel, totalBudgetLimit),
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondaryColor,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRiskColor(String risk) {
    switch (risk) {
      case 'Low':
        return AppColors.incomeGreen; // Green
      case 'Moderate':
        return AppColors.warningAmber; // Orange
      case 'High':
        return AppColors.expenseCoral; // Red
      default:
        return AppColors.textMuted;
    }
  }

  String _getExplanation(String risk, double limit) {
    if (limit == 0) {
      return 'Create category budget limits in the Budgets tab to track your risk of overspending.';
    }
    switch (risk) {
      case 'Low':
        return 'Awesome! At your current spending pace, you will finish the period within your total budget limits.';
      case 'Moderate':
        return 'Caution. Your daily spending speed is pacing close to the budget limits. Monitor category transactions.';
      default:
        return 'Critical. At your current daily average, you are projected to exceed your monthly limit. Reduce minor spending.';
    }
  }
}

class _ForecastMetric extends StatelessWidget {
  const _ForecastMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: context.textSecondaryColor),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.labelMedium.copyWith(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
