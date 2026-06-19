import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../transactions/domain/models.dart';
import 'providers/reports_provider.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int _activeChartIndex =
      0; // 0 = Category Pie, 1 = Income/Expense Bar, 2 = Trend Line

  void _showSetSavingsGoalSheet(BuildContext context, double currentGoal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SetSavingsGoalBottomSheet(initialGoal: currentGoal),
    );
  }

  Future<void> _selectCustomDateRange(BuildContext context) async {
    final filter = ref.read(reportsFilterProvider);
    final initialRange = DateTimeRange(
      start: filter.startDate,
      end: filter.endDate,
    );

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: context.primaryColor,
              onPrimary: Colors.white,
              surface: context.surfaceColor,
              onSurface: context.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref
          .read(reportsFilterProvider.notifier)
          .setCustomRange(
            picked.start,
            DateTime(
              picked.end.year,
              picked.end.month,
              picked.end.day,
              23,
              59,
              59,
              999,
            ),
          );
    }
  }

  Future<void> _exportCsvReport(
    BuildContext context,
    String title,
    List<Transaction> transactions,
  ) async {
    try {
      final buffer = StringBuffer();
      // UTF-8 BOM for Excel compatibility
      buffer.write('\uFEFF');
      buffer.writeln('Date,Type,Category,Title,Amount,Notes');

      for (final t in transactions) {
        final dateStr = DateFormat('yyyy-MM-dd').format(t.date);
        final typeStr = t.type.name.toUpperCase();
        final catStr = AppCategories.findById(t.categoryId).name;
        final titleClean = t.title.replaceAll('"', '""');
        final notesClean = (t.note ?? '').replaceAll('"', '""');
        buffer.writeln(
          '$dateStr,$typeStr,$catStr,"$titleClean",${t.amount},"$notesClean"',
        );
      }

      final tempDir = await getTemporaryDirectory();
      final sanitizedTitle = title.replaceAll(' ', '_').toLowerCase();
      final file = File('${tempDir.path}/moneylens_report_$sanitizedTitle.csv');
      await file.writeAsString(buffer.toString());

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'MoneyLens Statement Statement (CSV) - $title',
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to export CSV: $e')));
      }
    }
  }

  Future<void> _exportPdfReport(
    BuildContext context,
    String title,
    List<Transaction> transactions,
    ReportsFinancialSummary summary,
    double wealthScore,
  ) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context pdfContext) {
            return [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'MONEYLENS STATEMENT',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.Text(
                          'Your Premium Wealth Insights',
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      DateFormat('yyyy-MM-dd').format(DateTime.now()),
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),
              pw.Text(
                'Reporting Range: $title',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 15),
              pw.Text(
                'FINANCIAL SUMMARY',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.GridView(
                crossAxisCount: 2,
                childAspectRatio: 0.25,
                children: [
                  pw.Text(
                    'Total Income: INR ${summary.income.toStringAsFixed(2)}',
                  ),
                  pw.Text(
                    'Total Expenses: INR ${summary.expenses.toStringAsFixed(2)}',
                  ),
                  pw.Text(
                    'Net Savings: INR ${summary.savings.toStringAsFixed(2)}',
                  ),
                  pw.Text(
                    'Savings Rate: ${summary.savingsRate.toStringAsFixed(1)}%',
                  ),
                  pw.Text(
                    'Average Daily Spend: INR ${summary.averageDailySpend.toStringAsFixed(2)}',
                  ),
                  pw.Text(
                    'Wealth Intelligence Score: ${wealthScore.toStringAsFixed(0)}/100',
                  ),
                ],
              ),
              pw.SizedBox(height: 25),
              pw.Text(
                'TRANSACTION TIMELINE',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.symmetric(
                  inside: const pw.BorderSide(
                    width: 0.5,
                    color: PdfColors.grey200,
                  ),
                ),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9,
                ),
                cellStyle: const pw.TextStyle(fontSize: 8),
                headers: ['Date', 'Type', 'Category', 'Title', 'Amount'],
                data: transactions.map((t) {
                  return [
                    DateFormat('yyyy-MM-dd').format(t.date),
                    t.type.name.toUpperCase(),
                    AppCategories.findById(t.categoryId).name,
                    t.title,
                    t.amount.toStringAsFixed(2),
                  ];
                }).toList(),
              ),
            ];
          },
        ),
      );

      final tempDir = await getTemporaryDirectory();
      final sanitizedTitle = title.replaceAll(' ', '_').toLowerCase();
      final file = File('${tempDir.path}/moneylens_report_$sanitizedTitle.pdf');
      final bytes = await pdf.save();
      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'MoneyLens Statement Statement (PDF) - $title',
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to export PDF: $e')));
      }
    }
  }

  String _getPeriodTitle(ReportsFilterState filter) {
    if (filter.period == TimelinePeriod.custom) {
      final startStr = DateFormat('MMM d, yyyy').format(filter.startDate);
      final endStr = DateFormat('MMM d, yyyy').format(filter.endDate);
      return '$startStr - $endStr';
    }
    switch (filter.period) {
      case TimelinePeriod.today:
        return 'Today';
      case TimelinePeriod.thisWeek:
        return 'This Week';
      case TimelinePeriod.thisMonth:
        return 'This Month';
      case TimelinePeriod.thisYear:
        return 'This Year';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(reportsFilterProvider);
    final timelineTxs = ref.watch(timelineTransactionsProvider);
    final summary = ref.watch(reportsSummaryProvider);
    final categoryAnalytics = ref.watch(categoryAnalyticsProvider);
    final wealth = ref.watch(wealthScoreProvider);
    final insights = ref.watch(smartInsightsProvider);
    final savingsGoalAsync = ref.watch(currentMonthSavingsGoalProvider);

    final hasTransactions = timelineTxs.current.isNotEmpty;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: context.textPrimaryColor,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Reports & Exports',
              style: AppTypography.titleLarge.copyWith(
                color: context.textPrimaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
          ),

          // Filters control chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
                vertical: AppSpacing.md,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildTimelineChip(
                      TimelinePeriod.today,
                      'Today',
                      filterState.period,
                    ),
                    const SizedBox(width: 8),
                    _buildTimelineChip(
                      TimelinePeriod.thisWeek,
                      'Week',
                      filterState.period,
                    ),
                    const SizedBox(width: 8),
                    _buildTimelineChip(
                      TimelinePeriod.thisMonth,
                      'Month',
                      filterState.period,
                    ),
                    const SizedBox(width: 8),
                    _buildTimelineChip(
                      TimelinePeriod.thisYear,
                      'Year',
                      filterState.period,
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _selectCustomDateRange(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: filterState.period == TimelinePeriod.custom
                              ? context.primaryColor
                              : context.surfaceVariantColor,
                          borderRadius: AppRadius.circularMd,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: filterState.period == TimelinePeriod.custom
                                  ? Colors.white
                                  : context.textSecondaryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Custom Range',
                              style: AppTypography.bodySmall.copyWith(
                                color:
                                    filterState.period == TimelinePeriod.custom
                                    ? Colors.white
                                    : context.textSecondaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Active range display
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
              ),
              child: Text(
                _getPeriodTitle(filterState),
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

          if (!hasTransactions)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(context),
            )
          else ...[
            // ─── Financial Summary Details ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                  vertical: AppSpacing.sm,
                ),
                child: _buildSpendingSummaryCard(context, summary),
              ),
            ),

            // ─── Interactive Advanced Charts Card ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                  vertical: AppSpacing.md,
                ),
                child: _buildAdvancedChartsCard(
                  context,
                  timelineTxs.current,
                  categoryAnalytics,
                ),
              ),
            ),

            // ─── Category-wise analytics Breakdown ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                  vertical: AppSpacing.md,
                ),
                child: _buildCategoryBreakdownSection(
                  context,
                  categoryAnalytics,
                ),
              ),
            ),

            // ─── Savings Goals tracker ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                  vertical: AppSpacing.sm,
                ),
                child: savingsGoalAsync.when(
                  data: (goalAmount) {
                    final savings = summary.savings;
                    final progress = goalAmount > 0
                        ? (savings / goalAmount).clamp(0.0, 1.0)
                        : 0.0;
                    return _buildSavingsGoalCard(
                      context,
                      goalAmount,
                      savings,
                      progress,
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => const SizedBox.shrink(),
                ),
              ),
            ),

            // ─── Smart Insights ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                  vertical: AppSpacing.md,
                ),
                child: _buildInsightsSection(context, insights),
              ),
            ),

            // ─── Export & Share Card ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                  vertical: AppSpacing.lg,
                ),
                child: _buildExportCard(
                  context,
                  filterState,
                  timelineTxs.current,
                  summary,
                  wealth.overallScore,
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.massive),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineChip(
    TimelinePeriod period,
    String label,
    TimelinePeriod active,
  ) {
    final isSelected = active == period;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(reportsTimelineProvider.notifier).setPeriod(period);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? context.primaryColor
              : context.surfaceVariantColor,
          borderRadius: AppRadius.circularMd,
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: isSelected ? Colors.white : context.textSecondaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.pagePadding),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: context.separatorColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.folder_off_rounded,
            size: 48,
            color: context.textSecondaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No Data Available',
            style: AppTypography.titleMedium.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'We couldn\'t find any transactions in this range. Change your filters or log a transaction to see insights.',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingSummaryCard(
    BuildContext context,
    ReportsFinancialSummary summary,
  ) {
    final isDark = context.isDark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: context.separatorColor.withValues(alpha: isDark ? 0.3 : 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.query_stats_rounded,
                color: context.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Spending Summary',
                style: AppTypography.titleMedium.copyWith(
                  color: context.textPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Total Income / Expenses Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryHeaderItem(
                context,
                title: 'Total Income',
                amount: summary.income,
                color: context.successColor,
              ),
              _buildSummaryHeaderItem(
                context,
                title: 'Total Expenses',
                amount: summary.expenses,
                color: context.errorColor,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.lg),

          // Net Cash Flow / Savings Rate Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryHeaderItem(
                context,
                title: 'Net Cash Flow',
                amount: summary.netCashFlow,
                color: summary.netCashFlow >= 0
                    ? context.successColor
                    : context.errorColor,
                prefix: summary.netCashFlow >= 0 ? '+' : '',
              ),
              _buildSummaryHeaderItem(
                context,
                title: 'Savings Rate',
                amount: summary.savingsRate,
                color: Colors.deepPurpleAccent,
                isPercent: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.lg),

          // Averages & Highs Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 2.1,
            children: [
              _buildSimpleStatCard(
                context,
                'Daily Average',
                CurrencyFormatter.compact(summary.averageDailySpend),
              ),
              _buildSimpleStatCard(
                context,
                'Monthly Average',
                CurrencyFormatter.compact(summary.averageMonthlySpend),
              ),
              _buildSimpleStatCard(
                context,
                'Largest Expense',
                summary.largestExpense != null
                    ? CurrencyFormatter.compact(summary.largestExpense!.amount)
                    : '₹0',
                subtitle: summary.largestExpense?.title,
              ),
              _buildSimpleStatCard(
                context,
                'Largest Income',
                summary.largestIncome != null
                    ? CurrencyFormatter.compact(summary.largestIncome!.amount)
                    : '₹0',
                subtitle: summary.largestIncome?.title,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeaderItem(
    BuildContext context, {
    required String title,
    required double amount,
    required Color color,
    String prefix = '',
    bool isPercent = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondaryColor,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isPercent
              ? '${amount.toStringAsFixed(1)}%'
              : '$prefix${CurrencyFormatter.full(amount)}',
          style: AppTypography.displayLarge.copyWith(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleStatCard(
    BuildContext context,
    String title,
    String value, {
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: context.surfaceVariantColor.withValues(alpha: 0.5),
        borderRadius: AppRadius.circularMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondaryColor,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.labelLarge.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondaryColor,
                fontSize: 9,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdvancedChartsCard(
    BuildContext context,
    List<Transaction> currentTxs,
    ReportsCategoryAnalytics analytics,
  ) {
    final isDark = context.isDark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: context.separatorColor.withValues(alpha: isDark ? 0.3 : 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart switcher row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Financial Analytics',
                style: AppTypography.titleMedium.copyWith(
                  color: context.textPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: context.surfaceVariantColor,
                  borderRadius: AppRadius.circularMd,
                ),
                child: Row(
                  children: [
                    _buildChartTabButton(0, Icons.pie_chart_rounded),
                    _buildChartTabButton(1, Icons.bar_chart_rounded),
                    _buildChartTabButton(2, Icons.show_chart_rounded),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Render Selected Chart
          SizedBox(
            height: 200,
            child: _activeChartIndex == 0
                ? _buildPieDonutChart(context, analytics)
                : (_activeChartIndex == 1
                      ? _buildIncomeExpenseBarChart(context, currentTxs)
                      : _buildTrendLineChart(context, currentTxs)),
          ),
        ],
      ),
    );
  }

  Widget _buildChartTabButton(int index, IconData icon) {
    final isSelected = _activeChartIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _activeChartIndex = index);
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected ? context.surfaceColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isSelected ? context.primaryColor : context.textSecondaryColor,
        ),
      ),
    );
  }

  Widget _buildPieDonutChart(
    BuildContext context,
    ReportsCategoryAnalytics analytics,
  ) {
    if (analytics.details.isEmpty) {
      return const Center(
        child: Text('No expense data available for breakdown.'),
      );
    }

    final pieSections = analytics.details.map((d) {
      return PieChartSectionData(
        color: d.category.color,
        value: d.amount,
        title: '${d.percentage.toStringAsFixed(0)}%',
        radius: 40,
        titleStyle: AppTypography.bodySmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      );
    }).toList();

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: PieChart(
            PieChartData(
              sections: pieSections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 5,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: analytics.details.take(4).length,
            itemBuilder: (context, idx) {
              final d = analytics.details[idx];
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, color: d.category.color),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        d.category.name,
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 10,
                          color: context.textPrimaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.compact(d.amount),
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeExpenseBarChart(
    BuildContext context,
    List<Transaction> transactions,
  ) {
    final income = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final expenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    if (income == 0.0 && expenses == 0.0) {
      return const Center(child: Text('No cash flow records in this period.'));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (income > expenses ? income : expenses) * 1.25,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, _) {
                if (val.toInt() == 0) {
                  return const Text(
                    'Income',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  );
                }
                if (val.toInt() == 1) {
                  return const Text(
                    'Expense',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: income,
                color: context.successColor,
                width: 32,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: expenses,
                color: context.errorColor,
                width: 32,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendLineChart(
    BuildContext context,
    List<Transaction> transactions,
  ) {
    final expenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();
    expenses.sort((a, b) => a.date.compareTo(b.date));

    if (expenses.isEmpty) {
      return const Center(child: Text('No spending trend data available.'));
    }

    // Group expenses by date for points
    final dateTotals = <String, double>{};
    for (final t in expenses) {
      final key = DateFormat('Md').format(t.date);
      dateTotals[key] = (dateTotals[key] ?? 0.0) + t.amount;
    }

    final spots = <FlSpot>[];
    final labels = dateTotals.keys.toList();
    for (int i = 0; i < labels.length; i++) {
      spots.add(FlSpot(i.toDouble(), dateTotals[labels[i]]!));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, _) {
                final idx = val.toInt();
                if (idx >= 0 &&
                    idx < labels.length &&
                    idx % (labels.length > 5 ? labels.length ~/ 4 : 1) == 0) {
                  return Text(labels[idx], style: const TextStyle(fontSize: 8));
                }
                return const Text('');
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: context.primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: context.primaryColor.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownSection(
    BuildContext context,
    ReportsCategoryAnalytics analytics,
  ) {
    final isDark = context.isDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category Breakdown',
          style: AppTypography.titleMedium.copyWith(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: AppRadius.card,
            border: Border.all(
              color: context.separatorColor.withValues(
                alpha: isDark ? 0.3 : 0.6,
              ),
            ),
          ),
          child: analytics.details.isEmpty
              ? const Center(child: Text('No spending details.'))
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: analytics.details.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, idx) {
                    final d = analytics.details[idx];
                    return Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              d.category.icon,
                              color: d.category.color,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              d.category.name,
                              style: AppTypography.labelLarge.copyWith(
                                color: context.textPrimaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${d.percentage.toStringAsFixed(0)}%',
                              style: AppTypography.bodySmall.copyWith(
                                color: context.textSecondaryColor,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              CurrencyFormatter.compact(d.amount),
                              style: AppTypography.labelLarge.copyWith(
                                color: context.textPrimaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: AppRadius.circularFull,
                          child: LinearProgressIndicator(
                            value: d.percentage / 100.0,
                            minHeight: 5,
                            backgroundColor: context.surfaceVariantColor,
                            color: d.category.color,
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSavingsGoalCard(
    BuildContext context,
    double goal,
    double saved,
    double progress,
  ) {
    final isDark = context.isDark;
    final remains = goal - saved;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: context.separatorColor.withValues(alpha: isDark ? 0.3 : 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.savings_rounded,
                    color: context.successColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Savings Goal Tracker',
                    style: AppTypography.titleMedium.copyWith(
                      color: context.textPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.edit_rounded, size: 18),
                onPressed: () => _showSetSavingsGoalSheet(context, goal),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Goal Target: ${CurrencyFormatter.compact(goal)}',
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Saved: ${CurrencyFormatter.compact(saved)}',
                style: AppTypography.bodySmall.copyWith(
                  color: saved >= goal
                      ? context.successColor
                      : context.textPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppRadius.circularFull,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: context.surfaceVariantColor,
              color: saved >= goal
                  ? context.successColor
                  : context.primaryColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            remains <= 0
                ? '🎉 Target savings goal achieved!'
                : '₹${CurrencyFormatter.compact(remains)} remaining to complete target.',
            style: AppTypography.bodySmall.copyWith(
              color: remains <= 0
                  ? context.successColor
                  : context.textSecondaryColor,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(
    BuildContext context,
    List<SmartInsightItem> insights,
  ) {
    final isDark = context.isDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wealth Intelligence Insights',
          style: AppTypography.titleMedium.copyWith(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (insights.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: AppRadius.card,
              border: Border.all(
                color: context.separatorColor.withValues(
                  alpha: isDark ? 0.3 : 0.6,
                ),
              ),
            ),
            child: Text(
              'No smart insights generated yet.',
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: insights.length,
            itemBuilder: (context, idx) {
              final item = insights[idx];
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: AppRadius.card,
                  border: Border.all(
                    color: context.separatorColor.withValues(
                      alpha: isDark ? 0.3 : 0.6,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.icon, color: item.color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: AppTypography.labelLarge.copyWith(
                              color: context.textPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.description,
                            style: AppTypography.bodySmall.copyWith(
                              color: context.textSecondaryColor,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildExportCard(
    BuildContext context,
    ReportsFilterState filter,
    List<Transaction> transactions,
    ReportsFinancialSummary summary,
    double wealthScore,
  ) {
    final isDark = context.isDark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: context.separatorColor.withValues(alpha: isDark ? 0.3 : 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export Statements',
            style: AppTypography.titleMedium.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Generate reports for the selected timeline: ${_getPeriodTitle(filter)}',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.circularMd,
                    ),
                  ),
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                  label: const Text('Export PDF'),
                  onPressed: () => _exportPdfReport(
                    context,
                    _getPeriodTitle(filter),
                    transactions,
                    summary,
                    wealthScore,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.surfaceVariantColor,
                    foregroundColor: context.textPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.circularMd,
                    ),
                  ),
                  icon: const Icon(Icons.table_rows_rounded, size: 16),
                  label: const Text('Export CSV'),
                  onPressed: () => _exportCsvReport(
                    context,
                    _getPeriodTitle(filter),
                    transactions,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SetSavingsGoalBottomSheet extends ConsumerStatefulWidget {
  const SetSavingsGoalBottomSheet({super.key, required this.initialGoal});

  final double initialGoal;

  @override
  ConsumerState<SetSavingsGoalBottomSheet> createState() =>
      _SetSavingsGoalBottomSheetState();
}

class _SetSavingsGoalBottomSheetState
    extends ConsumerState<SetSavingsGoalBottomSheet> {
  late String _inputAmount;

  @override
  void initState() {
    super.initState();
    if (widget.initialGoal == 0.0 || widget.initialGoal == 15000.0) {
      _inputAmount = '0';
    } else {
      if (widget.initialGoal == widget.initialGoal.toInt()) {
        _inputAmount = widget.initialGoal.toInt().toString();
      } else {
        _inputAmount = widget.initialGoal.toStringAsFixed(2);
        if (_inputAmount.endsWith('.00')) {
          _inputAmount = _inputAmount.substring(0, _inputAmount.length - 3);
        } else if (_inputAmount.endsWith('0') && _inputAmount.contains('.')) {
          _inputAmount = _inputAmount.substring(0, _inputAmount.length - 1);
        }
      }
    }
  }

  void _onDigit(String d) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_inputAmount == '0') {
        if (d == '.') {
          _inputAmount = '0.';
        } else {
          _inputAmount = d;
        }
      } else {
        if (d == '.') {
          if (!_inputAmount.contains('.')) {
            _inputAmount += '.';
          }
        } else {
          if (_inputAmount.contains('.')) {
            final parts = _inputAmount.split('.');
            if (parts.length > 1 && parts[1].length >= 2) {
              return;
            }
          }
          if (_inputAmount.length < 10) {
            _inputAmount += d;
          }
        }
      }
    });
  }

  void _onBackspace() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_inputAmount.length <= 1) {
        _inputAmount = '0';
      } else {
        _inputAmount = _inputAmount.substring(0, _inputAmount.length - 1);
      }
    });
  }

  Future<void> _saveGoal() async {
    final amount = double.tryParse(_inputAmount) ?? 0.0;
    if (amount <= 0) return;
    HapticFeedback.mediumImpact();

    await ref.read(savingsGoalNotifierProvider.notifier).setSavingsGoal(amount);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Savings Goal set to ₹${CurrencyFormatter.compact(amount)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String get _displayAmount {
    if (_inputAmount == '0') return '0';

    final parts = _inputAmount.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : null;

    final cleanStr = intPart.replaceAll(',', '');
    String formattedInt = cleanStr;
    if (cleanStr.isNotEmpty && cleanStr != '0') {
      if (cleanStr.length > 3) {
        final last3 = cleanStr.substring(cleanStr.length - 3);
        final rest = cleanStr.substring(0, cleanStr.length - 3);
        final buffer = StringBuffer();
        for (int i = 0; i < rest.length; i++) {
          if (i > 0 && (rest.length - i) % 2 == 0) {
            buffer.write(',');
          }
          buffer.write(rest[i]);
        }
        buffer.write(',');
        buffer.write(last3);
        formattedInt = buffer.toString();
      }
    }

    if (decPart != null) {
      return '$formattedInt.$decPart';
    } else if (_inputAmount.endsWith('.')) {
      return '$formattedInt.';
    }
    return formattedInt;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: context.separatorColor.withValues(
            alpha: context.isDark ? 0.3 : 0.6,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.xl,
        AppSpacing.pagePadding,
        MediaQuery.of(context).padding.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 5,
            decoration: BoxDecoration(
              color: context.separatorColor,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Set Savings Goal',
            style: AppTypography.titleLarge.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Enter the monthly savings target you want to achieve.',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₹',
                style: AppTypography.displayLarge.copyWith(
                  color: context.primaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 32,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  _displayAmount,
                  style: AppTypography.displayLarge.copyWith(
                    color: context.textPrimaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 40,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Column(
            children: [
              _buildRow(['1', '2', '3']),
              const SizedBox(height: AppSpacing.md),
              _buildRow(['4', '5', '6']),
              const SizedBox(height: AppSpacing.md),
              _buildRow(['7', '8', '9']),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(child: _buildDigitButton('.')),
                  Expanded(child: _buildDigitButton('0')),
                  Expanded(
                    child: IconButton(
                      onPressed: _onBackspace,
                      icon: Icon(
                        Icons.backspace_outlined,
                        color: context.textPrimaryColor,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      double.tryParse(_inputAmount) != null &&
                          (double.tryParse(_inputAmount) ?? 0.0) > 0
                      ? _saveGoal
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: context.surfaceVariantColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.circularMd,
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Save Goal',
                    style: AppTypography.labelLarge.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color:
                          double.tryParse(_inputAmount) != null &&
                              (double.tryParse(_inputAmount) ?? 0.0) > 0
                          ? Colors.white
                          : context.textSecondaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      children: digits
          .map((d) => Expanded(child: _buildDigitButton(d)))
          .toList(),
    );
  }

  Widget _buildDigitButton(String digit) {
    return InkWell(
      onTap: () => _onDigit(digit),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        child: Text(
          digit,
          style: AppTypography.displayLarge.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: context.textPrimaryColor,
          ),
        ),
      ),
    );
  }
}
