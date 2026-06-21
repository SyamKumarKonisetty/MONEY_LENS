import 'package:flutter/material.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/design/colors/app_colors.dart';
import '../../../../../core/ui_engine/glass/glass_card.dart';
import '../../../../../core/ui_engine/numbers/animated_number.dart';

/// Horizontal scrolling premium glass cards showing Income, Expenses, Savings, and Savings Rate.
class MonthlyOverviewCards extends StatelessWidget {
  const MonthlyOverviewCards({
    super.key,
    required this.income,
    required this.expenses,
    required this.savings,
    required this.savingsRate,
  });

  final double income;
  final double expenses;
  final double savings;
  final double savingsRate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Row(
        children: [
          _OverviewCard(
            title: 'INCOME',
            value: income,
            accentColor: AppColors.incomeGreen, // Green
            icon: Icons.trending_up_rounded,
          ),
          const SizedBox(width: AppSpacing.md),
          _OverviewCard(
            title: 'EXPENSES',
            value: expenses,
            accentColor: AppColors.expenseCoral, // Red
            icon: Icons.trending_down_rounded,
          ),
          const SizedBox(width: AppSpacing.md),
          _OverviewCard(
            title: 'SAVINGS',
            value: savings,
            accentColor: AppColors.sapphireBlue, // Blue
            icon: Icons.savings_rounded,
          ),
          const SizedBox(width: AppSpacing.md),
          _RateCard(
            title: 'SAVINGS RATE',
            rate: savingsRate,
            accentColor: AppColors.categoryPalette[4], // Purple
            icon: Icons.pie_chart_rounded,
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.title,
    required this.value,
    required this.accentColor,
    required this.icon,
  });

  final String title;
  final double value;
  final Color accentColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      isInteractive: true,
      width: 140,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.labelSmall.copyWith(
                  color: context.textSecondaryColor,
                  letterSpacing: 1.0,
                ),
              ),
              Icon(
                icon,
                color: accentColor.withValues(alpha: 0.8),
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedNumber(
            value: value,
            isCompact: true,
            style: AppTypography.titleLarge.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _RateCard extends StatelessWidget {
  const _RateCard({
    required this.title,
    required this.rate,
    required this.accentColor,
    required this.icon,
  });

  final String title;
  final double rate;
  final Color accentColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final pctText = '${(rate * 100).toStringAsFixed(0)}%';

    return GlassCard(
      isInteractive: true,
      width: 140,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.labelSmall.copyWith(
                  color: context.textSecondaryColor,
                  letterSpacing: 1.0,
                ),
              ),
              Icon(
                icon,
                color: accentColor.withValues(alpha: 0.8),
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            pctText,
            style: AppTypography.titleLarge.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
