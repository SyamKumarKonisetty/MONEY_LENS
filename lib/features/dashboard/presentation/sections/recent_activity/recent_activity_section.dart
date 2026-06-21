import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/design/design_system.dart';
import '../../../../../core/ui_engine/ui_engine.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../expenses/presentation/providers/expense_provider.dart';
import '../../../../transactions/domain/models.dart';
import '../../../../transactions/presentation/widgets/add_expense_bottom_sheet.dart';
import '../../providers/dashboard_provider.dart';
import '../animations/dashboard_animations.dart';

/// Reimagined Recent Activity Timeline.
class RecentActivitySection extends ConsumerStatefulWidget {
  const RecentActivitySection({super.key});
  @override
  ConsumerState<RecentActivitySection> createState() => _RecentActivitySectionState();
}

class _RecentActivitySectionState extends ConsumerState<RecentActivitySection> {
  String? _deletingTxId;

  @override
  Widget build(BuildContext context) {
    final recent = ref.watch(recentTransactionsProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text('RECENT TIMELINE',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.go(AppConstants.routeTransactions),
                child: Text('See All',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (recent.isEmpty)
            ScaleUpEntrance(
              delay: const Duration(milliseconds: 400),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: AppRadius.medium,
                  border: Border.all(color: AppColors.divider, width: 1),
                ),
                child: EmptyStateView(
                  theme: EmptyStateTheme.wallet,
                  title: 'No activity yet',
                  subtitle: 'Log a transaction to start building your visual timeline.',
                  actionLabel: 'Add Expense',
                  onAction: () => showAddTransactionSheet(context),
                ),
              ),
            )
          else
            _buildTimeline(recent),
        ],
      ),
    );
  }

  Widget _buildTimeline(List<Transaction> items) {
    return Column(
      children: List.generate(items.length, (index) {
        final tx = items[index];
        final cat = AppCategories.findById(tx.categoryId);
        final timeStr = DateFormat('h:mm a').format(tx.date);
        final isExpense = tx.type == TransactionType.expense;

        return DeleteRipple(
          isDeleting: _deletingTxId == tx.id,
          onDeleteComplete: () async {
            final id = int.tryParse(tx.id);
            if (id != null) {
              await ref.read(expenseNotifierProvider.notifier).deleteExpense(id);
              if (mounted) setState(() => _deletingTxId = null);
            }
          },
          child: Dismissible(
            key: ValueKey(tx.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (dir) async {
              HapticFeedback.mediumImpact();
              setState(() => _deletingTxId = tx.id);
              return false;
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: AppColors.expense.withValues(alpha: 0.15),
                borderRadius: AppRadius.medium,
              ),
              child: Icon(Icons.delete_outline_rounded, color: AppColors.expense, size: 24),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 32,
                  height: 68,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned(
                        top: index == 0 ? 34 : 0,
                        bottom: index == items.length - 1 ? 34 : 0,
                        width: 1.5,
                        child: Container(color: AppColors.divider),
                      ),
                      Positioned(
                        top: 28,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: cat.color,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.background, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PressScale(
                      onTap: () => HapticFeedback.lightImpact(),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: AppRadius.medium,
                          border: Border.all(color: AppColors.divider, width: 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: cat.color.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(cat.icon, color: cat.color, size: 18),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tx.title,
                                    style: AppTypography.body.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text('$timeStr • ${cat.name}',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              isExpense
                                  ? '−${CurrencyFormatter.compact(tx.amount)}'
                                  : '+${CurrencyFormatter.compact(tx.amount)}',
                              style: AppTypography.body.copyWith(
                                color: isExpense ? AppColors.expense : AppColors.income,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
