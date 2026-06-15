import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Quick stats row — 3 mini cards: Total Transactions, Total Spent, Top Category.
class QuickStatsRow extends StatelessWidget {
  const QuickStatsRow({
    super.key,
    required this.totalTransactions,
    required this.totalExpenses,
    required this.topCategory,
  });

  final int totalTransactions;
  final String totalExpenses;
  final String topCategory;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'Total Txs',
              value: '$totalTransactions',
              icon: Icons.receipt_long_rounded,
              iconColor: context.successColor,
            ),
          ),
          const SizedBox(width: AppSpacing.cardGap),
          Expanded(
            child: _StatCard(
              label: 'Spent',
              value: totalExpenses,
              icon: Icons.trending_down_rounded,
              iconColor: context.errorColor,
            ),
          ),
          const SizedBox(width: AppSpacing.cardGap),
          Expanded(
            child: _StatCard(
              label: 'Top Category',
              value: topCategory,
              icon: Icons.star_rounded,
              iconColor: context.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.circularLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.circularSm,
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
