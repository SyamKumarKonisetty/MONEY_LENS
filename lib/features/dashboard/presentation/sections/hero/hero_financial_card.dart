
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design/design_system.dart';
import '../../../../../core/ui_engine/ui_engine.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../transactions/domain/models.dart';
import '../../../../transactions/presentation/providers/transactions_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../animations/dashboard_animations.dart';

/// reimagined glass balance card with dynamic mesh gradient background and haptic pan scale.
class HeroFinancialCard extends ConsumerStatefulWidget {
  const HeroFinancialCard({super.key});

  @override
  ConsumerState<HeroFinancialCard> createState() => _HeroFinancialCardState();
}

class _HeroFinancialCardState extends ConsumerState<HeroFinancialCard> {

  double _calculateMonthOverMonthChange(WidgetRef ref) {
    final all = ref.watch(allTransactionsProvider);
    final now = DateTime.now();
    
    final curMonth = now.month;
    final curYear = now.year;
    
    final prevMonth = now.month == 1 ? 12 : now.month - 1;
    final prevYear = now.month == 1 ? now.year - 1 : now.year;

    double curNet = 0.0;
    double prevNet = 0.0;

    for (final t in all) {
      if (t.date.year == curYear && t.date.month == curMonth) {
        if (t.type == TransactionType.income) curNet += t.amount;
        if (t.type == TransactionType.expense) curNet -= t.amount;
      } else if (t.date.year == prevYear && t.date.month == prevMonth) {
        if (t.type == TransactionType.income) prevNet += t.amount;
        if (t.type == TransactionType.expense) prevNet -= t.amount;
      }
    }

    if (prevNet == 0.0) return 0.0;
    return ((curNet - prevNet) / prevNet.abs()) * 100.0;
  }

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(currentMonthExpensesProvider);
    final income = ref.watch(currentMonthIncomeProvider);
    final netBalance = ref.watch(currentMonthNetBalanceProvider);
    final savings = (income - expenses).clamp(0.0, double.infinity);
    final changePercent = _calculateMonthOverMonthChange(ref);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: ScaleUpEntrance(
        delay: const Duration(milliseconds: 150),
        child: PressScale(
          onTap: () {
            HapticFeedback.mediumImpact();
          },
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: AppRadius.medium,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: AppRadius.medium,
              child: Stack(
                children: [
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    isInteractive: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'AVAILABLE BALANCE',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            _buildChangeIndicator(changePercent),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        
                        // Digit rolling counter
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: CounterText(
                                value: CurrencyFormatter.full(netBalance)
                                    .replaceAll('₹', ''),
                                style: AppTypography.displayLarge.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 40,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Stats Row: Income, Expenses, Savings
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _Metric(
                              label: 'Income',
                              value: income,
                              icon: Icons.south_west_rounded,
                              color: AppColors.income,
                            ),
                            _Metric(
                              label: 'Expenses',
                              value: expenses,
                              icon: Icons.north_east_rounded,
                              color: AppColors.expense,
                            ),
                            _Metric(
                              label: 'Savings',
                              value: savings,
                              icon: Icons.savings_rounded,
                              color: AppColors.primaryLight,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChangeIndicator(double percent) {
    if (percent == 0.0) return const SizedBox.shrink();
    final isPositive = percent > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: (isPositive ? AppColors.income : AppColors.expense)
            .withValues(alpha: 0.12),
        borderRadius: AppRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: isPositive ? AppColors.income : AppColors.expense,
            size: 12,
          ),
          const SizedBox(width: 2),
          Text(
            '${isPositive ? "+" : ""}${percent.toStringAsFixed(1)}%',
            style: AppTypography.caption.copyWith(
              color: isPositive ? AppColors.income : AppColors.expense,
              fontWeight: FontWeight.bold,
              fontSize: 10,
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
    required this.icon,
    required this.color,
  });

  final String label;
  final double value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        AnimatedNumber(
          value: value,
          isCompact: true,
          style: AppTypography.body.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
