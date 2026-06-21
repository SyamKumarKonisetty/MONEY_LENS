import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/animated_page_wrapper.dart';
import '../../../core/ui_engine/empty_states/empty_state_view.dart';
import '../../../core/ui_engine/motion/press_scale.dart';

import 'providers/analytics_cockpit_provider.dart';
import 'services/export_service.dart';
import 'widgets/hero/analytics_header.dart';
import 'widgets/charts/financial_health_gauge.dart';
import 'widgets/charts/monthly_overview_cards.dart';
import 'widgets/charts/cash_flow_chart.dart';
import 'widgets/charts/interactive_donut_chart.dart';
import 'widgets/heatmap/spending_heatmap.dart';
import 'widgets/charts/spending_timeline.dart';
import 'widgets/charts/top_merchants.dart';
import 'widgets/insights/smart_insights_panel.dart';
import 'widgets/forecast/budget_forecast.dart';
import 'widgets/achievements/achievements_grid.dart';

/// MoneyLens Analytics Cockpit Screen.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  String _getPeriodLabel(CockpitPeriod p, DateTimeRange range) {
    final startStr = DateFormat('MMM d, yyyy').format(range.start);
    final endStr = DateFormat('MMM d, yyyy').format(range.end);
    switch (p) {
      case CockpitPeriod.week:
        return 'Week of $startStr';
      case CockpitPeriod.month:
        return DateFormat('MMMM yyyy').format(range.start);
      case CockpitPeriod.quarter:
        return 'Quarter ($startStr - $endStr)';
      case CockpitPeriod.year:
        return 'Year ${range.start.year}';
      case CockpitPeriod.custom:
        return '$startStr - $endStr';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(cockpitDataProvider);
    final isEmpty = data.transactions.isEmpty;
    final periodLabel = _getPeriodLabel(data.period, data.dateRange);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedPageWrapper(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Hero Title & Period selector
            const SliverToBoxAdapter(child: AnalyticsHeader()),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

            if (isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 80.0),
                  child: EmptyStateView(
                    theme: EmptyStateTheme.chart,
                    title: 'No Data to Analyze',
                    subtitle: 'Try adjusting your filters, query search, or active timeframes.',
                  ),
                ),
              )
            else ...[
              // Financial Health Score
              SliverToBoxAdapter(
                child: FinancialHealthGauge(
                  score: data.healthScore,
                  explanation: data.healthExplanation,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.cardGap)),

              // Monthly Summary Row
              SliverToBoxAdapter(
                child: MonthlyOverviewCards(
                  income: data.totalIncome,
                  expenses: data.totalExpenses,
                  savings: data.savings,
                  savingsRate: data.savingsRate,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.cardGap)),

              // Cash Flow Area Curve
              SliverToBoxAdapter(
                child: CashFlowChart(
                  transactions: data.transactions,
                  dateRange: data.dateRange,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.cardGap)),

              // Category donut segment chart
              const SliverToBoxAdapter(child: InteractiveDonutChart()),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.cardGap)),

              // Contribution Heatmap Calendar
              SliverToBoxAdapter(child: SpendingHeatmap(heatmapData: data.heatmapData)),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.cardGap)),

              // Key Events Timeline Track
              SliverToBoxAdapter(child: SpendingTimeline(milestones: data.timelineMilestones)),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.cardGap)),

              // Top 5 Merchants Column
              SliverToBoxAdapter(child: TopMerchants(merchants: data.topMerchants)),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.cardGap)),

              // Predicted Budget Projection
              SliverToBoxAdapter(
                child: BudgetForecastCard(
                  expectedSpend: data.expectedSpend,
                  totalBudgetLimit: data.totalBudgetLimit,
                  daysLeft: data.daysLeft,
                  riskLevel: data.forecastRisk,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.cardGap)),

              // Smart Rotating insights & search bar
              const SliverToBoxAdapter(child: SmartInsightsPanel()),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.cardGap)),

              // Unlocked Milestones Grid
              SliverToBoxAdapter(child: AchievementsGrid(achievements: data.achievements)),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.cardGap)),

              // Export statement button block
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EXPORT FINANCIAL REPORT',
                        style: AppTypography.labelSmall.copyWith(
                          color: context.textSecondaryColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: PressScale(
                              onTap: () => ExportService.sharePDF(
                                context,
                                periodLabel,
                                data.transactions,
                                data.totalIncome,
                                data.totalExpenses,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: context.primaryColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: context.primaryColor.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'PDF',
                                    style: AppTypography.labelMedium.copyWith(
                                      color: context.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: PressScale(
                              onTap: () => ExportService.shareCSV(context, periodLabel, data.transactions),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: context.separatorColor.withValues(alpha: 0.15),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'CSV',
                                    style: AppTypography.labelMedium.copyWith(
                                      color: context.textPrimaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: PressScale(
                              onTap: () => ExportService.shareJSON(context, periodLabel, data.transactions),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: context.separatorColor.withValues(alpha: 0.15),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'JSON',
                                    style: AppTypography.labelMedium.copyWith(
                                      color: context.textPrimaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.massive)),
            ],
          ],
        ),
      ),
    );
  }
}
