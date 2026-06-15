import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Hero balance card — the centerpiece of the dashboard.
///
/// Displays total monthly spending with a premium gradient background
/// and glass-morphic styling.
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.netBalance,
    required this.totalIncome,
    required this.totalExpenses,
  });

  final double netBalance;
  final double totalIncome;
  final double totalExpenses;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      decoration: BoxDecoration(
        borderRadius: AppRadius.card,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                  const Color(0xFF0F3460),
                ]
              : [
                  AppColors.primaryLight,
                  const Color(0xFF0055CC),
                  const Color(0xFF003A99),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withValues(alpha: 0.4),
            blurRadius: 32,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            Text(
              'JUNE 2026',
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Balance amount
            Text(
              CurrencyFormatter.full(netBalance),
              style: AppTypography.displayLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 40,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            Text(
              'Net Balance',
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Bottom row — income vs expense summary
            Row(
              children: [
                Expanded(
                  child: _BalanceMetric(
                    label: 'Income',
                    amount: totalIncome,
                    icon: Icons.arrow_downward_rounded,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _BalanceMetric(
                    label: 'Expenses',
                    amount: totalExpenses,
                    icon: Icons.arrow_upward_rounded,
                    color: Colors.white.withValues(alpha: 0.9),
                    alignRight: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceMetric extends StatelessWidget {
  const _BalanceMetric({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    this.alignRight = false,
  });

  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: alignRight ? AppSpacing.xl : 0,
        right: alignRight ? 0 : AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: alignRight
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!alignRight) Icon(icon, color: color, size: 14),
              if (!alignRight) const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(color: color),
              ),
              if (alignRight) const SizedBox(width: 4),
              if (alignRight) Icon(icon, color: color, size: 14),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.compact(amount),
            style: AppTypography.titleLarge.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
