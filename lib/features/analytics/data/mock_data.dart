import '../domain/models.dart';
import '../../transactions/data/mock_data.dart';

/// Mock analytics data derived from mock transactions.
class MockAnalyticsData {
  MockAnalyticsData._();

  // ─── Monthly Summary ──────────────────────────────────────────────────────

  /// June 2026 summary
  static MonthlySummary get currentMonth => MonthlySummary(
    year: 2026,
    month: 6,
    totalIncome: MockTransactionData.currentMonthIncome,
    totalExpenses: MockTransactionData.currentMonthExpenses,
  );

  // ─── Category Breakdown ───────────────────────────────────────────────────

  static final List<CategorySpending> categoryBreakdown = _buildBreakdown();

  static List<CategorySpending> _buildBreakdown() {
    final expenses = MockTransactionData.forMonth(
      2026,
      6,
    ).where((t) => t.type.name == 'expense');

    final totals = <String, double>{};
    double grandTotal = 0;

    for (final t in expenses) {
      totals[t.categoryId] = (totals[t.categoryId] ?? 0) + t.amount;
      grandTotal += t.amount;
    }

    if (grandTotal == 0) return [];

    return totals.entries
        .map(
          (e) => CategorySpending(
            categoryId: e.key,
            amount: e.value,
            percentage: e.value / grandTotal,
          ),
        )
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }

  // ─── Monthly Trends (6-month view) ───────────────────────────────────────

  static const List<MonthlyTrend> monthlyTrends = [
    MonthlyTrend(month: 0, label: 'Jan', expenses: 42500, income: 85000),
    MonthlyTrend(month: 1, label: 'Feb', expenses: 38200, income: 85000),
    MonthlyTrend(month: 2, label: 'Mar', expenses: 51000, income: 110000),
    MonthlyTrend(month: 3, label: 'Apr', expenses: 43600, income: 85000),
    MonthlyTrend(month: 4, label: 'May', expenses: 48300, income: 85000),
    MonthlyTrend(month: 5, label: 'Jun', expenses: 6779, income: 100000),
  ];
}
