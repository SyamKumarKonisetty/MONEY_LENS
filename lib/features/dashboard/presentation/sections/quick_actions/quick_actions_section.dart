import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/design/design_system.dart';
import '../../../../../core/ui_engine/ui_engine.dart';
import '../../../../transactions/domain/models.dart';
import '../../../../transactions/presentation/widgets/add_expense_bottom_sheet.dart';
import '../animations/dashboard_animations.dart';

/// reimagined springy circular glass quick action bar for primary dashboard workflows.
class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: ScaleUpEntrance(
        delay: const Duration(milliseconds: 250),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                'QUICK ACTIONS',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _QuickActionBtn(
                  label: 'Add Expense',
                  icon: Icons.north_east_rounded,
                  color: AppColors.expense,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    showAddTransactionSheet(
                      context,
                      initialType: TransactionType.expense,
                    );
                  },
                ),
                _QuickActionBtn(
                  label: 'Add Income',
                  icon: Icons.south_west_rounded,
                  color: AppColors.income,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    showAddTransactionSheet(
                      context,
                      initialType: TransactionType.income,
                    );
                  },
                ),
                _QuickActionBtn(
                  label: 'SMS Inbox',
                  icon: Icons.sms_rounded,
                  color: AppColors.primaryLight,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push(AppConstants.routeSmsInbox);
                  },
                ),
                _QuickActionBtn(
                  label: 'Budgets',
                  icon: Icons.pie_chart_rounded,
                  color: AppColors.warning,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push(AppConstants.routeBudget);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  const _QuickActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PressScale(
          onTap: onTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.divider,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.06),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
