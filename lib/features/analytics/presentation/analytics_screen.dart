import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/animated_page_wrapper.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/extensions/context_extensions.dart';
import 'providers/analytics_provider.dart';
import 'widgets/monthly_summary_card.dart';
import 'widgets/category_donut_chart.dart';
import 'widgets/trend_line_chart.dart';
import 'widgets/category_legend_tile.dart';
import '../../../core/widgets/section_header.dart';

/// MoneyLens Analytics Screen.
///
/// Shows monthly summary, category breakdown donut chart,
/// 6-month trend line chart, and category legend.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(monthlySummaryProvider);
    final breakdown = ref.watch(categoryBreakdownProvider);
    final trends = ref.watch(monthlyTrendsProvider);
    final period = ref.watch(analyticsPeriodProvider);

    final isEmpty = breakdown.isEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedPageWrapper(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.giant,
                  left: AppSpacing.pagePadding,
                  right: AppSpacing.pagePadding,
                  bottom: AppSpacing.xl,
                ),
                child: Row(
                  children: [
                    Text(
                      'Analytics',
                      style: AppTypography.displayMedium.copyWith(
                        color: context.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Period selector
            SliverToBoxAdapter(child: _PeriodSelector(activePeriod: period)),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),

            if (isEmpty) ...[
              // ── Empty state ─────────────────────────────────────────────
              SliverFillRemaining(
                child: EmptyStateWidget(
                  icon: Icons.bar_chart_rounded,
                  title: 'No analytics available',
                  subtitle:
                      'Add transactions to see your spending breakdown, trends, and insights here.',
                  accentColor: const Color(0xFF8B5CF6),
                ),
              ),
            ] else ...[
              // Monthly summary card
              SliverToBoxAdapter(child: MonthlySummaryCard(summary: summary)),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.cardGap),
              ),

              // Category donut chart
              SliverToBoxAdapter(
                child: CategoryDonutChart(breakdown: breakdown),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.cardGap),
              ),

              // Trend line chart
              SliverToBoxAdapter(child: TrendLineChart(trends: trends)),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),

              // Category legend
              const SliverToBoxAdapter(
                child: SectionHeader(title: 'Breakdown'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => StaggeredListItem(
                    index: index,
                    baseDelay: 80,
                    child: CategoryLegendTile(spending: breakdown[index]),
                  ),
                  childCount: breakdown.length,
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.massive),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Period selector chips.
class _PeriodSelector extends ConsumerWidget {
  const _PeriodSelector({required this.activePeriod});

  final AnalyticsPeriod activePeriod;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Row(
        children: AnalyticsPeriod.values.map((p) {
          final isSelected = p == activePeriod;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () =>
                  ref.read(analyticsPeriodProvider.notifier).setPeriod(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.primaryColor
                      : context.surfaceColor,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  _label(p),
                  style: AppTypography.labelLarge.copyWith(
                    color: isSelected
                        ? Colors.white
                        : context.textSecondaryColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _label(AnalyticsPeriod p) {
    switch (p) {
      case AnalyticsPeriod.week:
        return 'Week';
      case AnalyticsPeriod.month:
        return 'Month';
      case AnalyticsPeriod.year:
        return 'Year';
    }
  }
}
