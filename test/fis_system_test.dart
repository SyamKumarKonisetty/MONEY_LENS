import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_lens/design_system/foundations/trends.dart';
import 'package:money_lens/design_system/foundations/health_score.dart';
import 'package:money_lens/design_system/foundations/comparison.dart';
import 'package:money_lens/design_system/foundations/reports.dart';
import 'package:money_lens/design_system/components/charts.dart';
import 'package:money_lens/design_system/components/timelines.dart';
import 'package:money_lens/design_system/components/insights_components.dart';
import 'package:money_lens/design_system/theme/dark_theme.dart';

void main() {
  group('FIS Foundations Tests', () {
    test('Trend system resolves correctly', () {
      final upTrend = MLTrends.resolve(MLTrendType.up);
      expect(upTrend.label, 'Upward');
      expect(upTrend.icon, Icons.trending_up_rounded);

      final stableTrend = MLTrends.resolve(MLTrendType.stable);
      expect(stableTrend.label, 'Stable');
      expect(stableTrend.icon, Icons.trending_flat_rounded);
    });

    test('Comparison system calculates percentages and stories', () {
      final metrics = MLComparisonMetrics.calculate(
        scope: MLComparisonScope.thisWeekVsLastWeek,
        primary: 80,
        base: 100,
        isExpense: true,
      );

      expect(metrics.percentageChange, 20.0);
      expect(metrics.isPositiveChange, true); // Spent less
      expect(
        metrics.toStoryString(isExpense: true),
        'You spent 20% less than last week.',
      );
    });

    test('Health score calculates correctly and remains supportive', () {
      const factors = MLHealthScoreFactors(
        budgetHealth: 0.9,
        savingsRate: 0.8,
        cashFlowRatio: 0.8,
        spendingConsistency: 0.9,
        overspendingBuffer: 0.9,
        goalProgress: 0.7,
      );

      final score = MLHealthScore.calculate(factors);
      expect(score.score, greaterThanOrEqualTo(50));
      expect(score.insights, isNotEmpty);
      expect(score.headline, isNot(contains('bad'))); // No shaming
    });

    test('Report metadata generates accurate CSV summaries', () {
      final report = MLReportMetadata(
        id: 'rep_123',
        type: MLReportType.weekly,
        title: 'Weekly Statement',
        dateGenerated: DateTime(2026, 6, 20),
        startDate: DateTime(2026, 6, 13),
        endDate: DateTime(2026, 6, 20),
        totalIncome: 10000,
        totalExpenses: 4000,
        transactionCount: 15,
        categoryBreakdown: const {'food': 1200, 'bills': 2800},
        merchantBreakdown: const {'Walmart': 1200},
      );

      final csv = report.toCsvSummary();
      expect(csv, contains('rep_123'));
      expect(csv, contains('WEEKLY'));
      expect(csv, contains('Category Breakdown'));
      expect(csv, contains('food,1200.00'));
    });
  });

  group('FIS Components Widget Tests', () {
    testWidgets('MLLineChart renders correct states', (
      WidgetTester tester,
    ) async {
      // Loading State
      await tester.pumpWidget(
        MaterialApp(
          theme: mldsDarkTheme,
          home: const Scaffold(
            body: MLLineChart(
              dataPoints: [],
              xAxisLabels: [],
              state: MLChartState.loading,
            ),
          ),
        ),
      );

      expect(find.byType(MLSkeletonPlaceholder), findsOneWidget);

      // Empty State
      await tester.pumpWidget(
        MaterialApp(
          theme: mldsDarkTheme,
          home: const Scaffold(
            body: MLLineChart(
              dataPoints: [],
              xAxisLabels: [],
              state: MLChartState.empty,
              emptyType: MLChartEmptyType.noData,
            ),
          ),
        ),
      );

      expect(find.byType(MLChartEmptyState), findsOneWidget);
      expect(find.text('No Data Recorded'), findsOneWidget);
    });

    testWidgets('MLCashFlowTimeline renders items chronologically', (
      WidgetTester tester,
    ) async {
      final events = [
        MLTimelineEvent(
          id: '1',
          title: 'Salary Credit',
          amount: 50000,
          date: DateTime(2026, 6, 18),
          categoryId: 'salary',
          isIncome: true,
        ),
        MLTimelineEvent(
          id: '2',
          title: 'Electric Bill',
          amount: 2500,
          date: DateTime(2026, 6, 19),
          categoryId: 'utilities',
          isIncome: false,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: mldsDarkTheme,
          home: Scaffold(body: MLCashFlowTimeline(events: events)),
        ),
      );

      expect(find.text('Salary Credit'), findsOneWidget);
      expect(find.text('Electric Bill'), findsOneWidget);
    });

    testWidgets('MLFinancialStory renders narrative details', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: mldsDarkTheme,
          home: Scaffold(
            body: MLFinancialStory(
              storyText: 'Your savings rate was 18% higher than last week.',
              actionLabel: 'View details',
              onAction: () {},
            ),
          ),
        ),
      );

      expect(
        find.text('Your savings rate was 18% higher than last week.'),
        findsOneWidget,
      );
      expect(find.text('View details'), findsOneWidget);
    });
  });
}
