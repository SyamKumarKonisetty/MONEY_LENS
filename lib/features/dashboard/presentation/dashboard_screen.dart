import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/animated_page_wrapper.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/utils/currency_formatter.dart';
import 'providers/dashboard_provider.dart';
import 'widgets/greeting_header.dart';
import 'widgets/balance_card.dart';
import 'widgets/quick_stats_row.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/recent_transaction_tile.dart';
import 'widgets/scan_coming_soon_sheet.dart';
import 'widgets/quick_add_section.dart';
import 'widgets/today_summary_section.dart';
import 'widgets/dashboard_budget_card.dart';
import '../../../features/transactions/domain/models.dart';
import '../../../features/transactions/presentation/widgets/add_expense_bottom_sheet.dart';

/// MoneyLens Dashboard Screen.
///
/// The primary home view showing:
/// - Time-aware greeting
/// - Monthly balance hero card
/// - Quick stats (income / expenses / savings)
/// - Quick action shortcuts (all functional)
/// - Recent 5 transactions
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  // ─── Quick Action Handlers ─────────────────────────────────────────────────

  void _onAdd(BuildContext context) {
    showAddTransactionSheet(context);
  }

  void _onScan(BuildContext context) {
    ScanComingSoonSheet.show(context);
  }

  void _onBudget(BuildContext context) {
    context.push(AppConstants.routeBudget);
  }

  void _onReports(BuildContext context) {
    context.push(AppConstants.routeReports);
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(recentTransactionsProvider);
    final expenses = ref.watch(currentMonthExpensesProvider);
    final income = ref.watch(currentMonthIncomeProvider);
    final netBalance = ref.watch(currentMonthNetBalanceProvider);
    final totalTxs = ref.watch(totalTransactionsCountProvider);
    final topCategory = ref.watch(topSpendingCategoryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedPageWrapper(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Status bar padding
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.giant)),

            // Greeting
            const SliverToBoxAdapter(child: GreetingHeader()),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),

            // Balance hero card
            SliverToBoxAdapter(
              child: BalanceCard(
                netBalance: netBalance,
                totalIncome: income,
                totalExpenses: expenses,
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.cardGap),
            ),

            // Budget Card
            const SliverToBoxAdapter(child: DashboardBudgetCard()),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.cardGap + 4),
            ),

            // Quick stats row
            SliverToBoxAdapter(
              child: QuickStatsRow(
                totalTransactions: totalTxs,
                totalExpenses: CurrencyFormatter.compact(expenses),
                topCategory: topCategory,
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.sectionGap),
            ),

            // Today Summary Section
            const SliverToBoxAdapter(child: TodaySummarySection()),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.sectionGap),
            ),

            // Quick Add Section
            const SliverToBoxAdapter(child: QuickAddSection()),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.sectionGap),
            ),

            // Quick actions
            const SliverToBoxAdapter(
              child: SectionHeader(title: 'Quick Actions'),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
            SliverToBoxAdapter(
              child: QuickActionsGrid(
                onAdd: () => _onAdd(context),
                onScan: () => _onScan(context),
                onBudget: () => _onBudget(context),
                onReports: () => _onReports(context),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.sectionGap),
            ),

            // Recent transactions header
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Recent',
                actionLabel: 'See All',
                onAction: () => context.go(AppConstants.routeTransactions),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

            // Recent transaction list or empty state
            if (recent.isEmpty)
              SliverFillRemaining(
                child: EmptyStateWidget(
                  icon: Icons.wallet_rounded,
                  title: 'No transactions yet',
                  subtitle:
                      'Add your first transaction to start building your financial timeline.',
                  actionLabel: 'Add Transaction',
                  onAction: () => _onAdd(context),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => StaggeredListItem(
                    index: index,
                    baseDelay: 100,
                    child: RecentTransactionTile(
                      transaction: recent[index],
                      category: AppCategories.findById(
                        recent[index].categoryId,
                      ),
                    ),
                  ),
                  childCount: recent.length,
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.massive),
            ),
          ],
        ),
      ),
    );
  }
}
