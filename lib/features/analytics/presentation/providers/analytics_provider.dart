import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models.dart';
import '../../../transactions/domain/models.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';

/// Analytics period selection.
enum AnalyticsPeriod { week, month, year }

/// Analytics period state notifier.
class AnalyticsPeriodNotifier extends StateNotifier<AnalyticsPeriod> {
  AnalyticsPeriodNotifier() : super(AnalyticsPeriod.month);

  void setPeriod(AnalyticsPeriod period) => state = period;
}

/// Active analytics period provider.
final analyticsPeriodProvider =
    StateNotifierProvider<AnalyticsPeriodNotifier, AnalyticsPeriod>((ref) {
      return AnalyticsPeriodNotifier();
    });

bool _isWithinPeriod(DateTime txDate, AnalyticsPeriod period, DateTime now) {
  switch (period) {
    case AnalyticsPeriod.week:
      final start = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(days: 6));
      return txDate.isAfter(start.subtract(const Duration(seconds: 1)));
    case AnalyticsPeriod.month:
      return txDate.year == now.year && txDate.month == now.month;
    case AnalyticsPeriod.year:
      return txDate.year == now.year;
  }
}

/// Current summary provider respecting period.
final monthlySummaryProvider = Provider<MonthlySummary>((ref) {
  final all = ref.watch(allTransactionsProvider);
  final period = ref.watch(analyticsPeriodProvider);
  final now = DateTime.now();

  final periodExpenses = all
      .where(
        (t) =>
            _isWithinPeriod(t.date, period, now) &&
            t.type == TransactionType.expense,
      )
      .fold(0.0, (sum, t) => sum + t.amount);

  final periodIncome = all
      .where(
        (t) =>
            _isWithinPeriod(t.date, period, now) &&
            t.type == TransactionType.income,
      )
      .fold(0.0, (sum, t) => sum + t.amount);

  return MonthlySummary(
    year: now.year,
    month: now.month,
    totalIncome: periodIncome,
    totalExpenses: periodExpenses,
  );
});

/// Category spending breakdown provider respecting period.
final categoryBreakdownProvider = Provider<List<CategorySpending>>((ref) {
  final all = ref.watch(allTransactionsProvider);
  final period = ref.watch(analyticsPeriodProvider);
  final now = DateTime.now();

  final periodExpenses = all
      .where(
        (t) =>
            _isWithinPeriod(t.date, period, now) &&
            t.type == TransactionType.expense,
      )
      .toList();

  final totals = <String, double>{};
  var grandTotal = 0.0;

  for (final t in periodExpenses) {
    totals[t.categoryId] = (totals[t.categoryId] ?? 0.0) + t.amount;
    grandTotal += t.amount;
  }

  if (grandTotal == 0.0) return [];

  return totals.entries.map((e) {
    return CategorySpending(
      categoryId: e.key,
      amount: e.value,
      percentage: e.value / grandTotal,
    );
  }).toList()..sort((a, b) => b.amount.compareTo(a.amount));
});

/// 6-month trend data provider.
final monthlyTrendsProvider = Provider<List<MonthlyTrend>>((ref) {
  final all = ref.watch(allTransactionsProvider);
  final now = DateTime.now();

  final trends = <MonthlyTrend>[];
  final monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  for (int i = 5; i >= 0; i--) {
    final targetDate = DateTime(now.year, now.month - i, 1);
    final year = targetDate.year;
    final month = targetDate.month;

    final monthExpenses = all
        .where(
          (t) =>
              t.date.year == year &&
              t.date.month == month &&
              t.type == TransactionType.expense,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final monthIncome = all
        .where(
          (t) =>
              t.date.year == year &&
              t.date.month == month &&
              t.type == TransactionType.income,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    trends.add(
      MonthlyTrend(
        month: 5 - i,
        label: monthNames[month - 1],
        expenses: monthExpenses,
        income: monthIncome,
      ),
    );
  }

  return trends;
});

class AnalyticsInsights {
  final Transaction? largestExpense;
  final double averageDailySpend;
  final double weeklyComparisonPercentage;
  final double currentWeekTotal;
  final double previousWeekTotal;

  AnalyticsInsights({
    required this.largestExpense,
    required this.averageDailySpend,
    required this.weeklyComparisonPercentage,
    required this.currentWeekTotal,
    required this.previousWeekTotal,
  });
}

final analyticsInsightsProvider = Provider<AnalyticsInsights>((ref) {
  final all = ref.watch(allTransactionsProvider);
  final period = ref.watch(analyticsPeriodProvider);
  final now = DateTime.now();

  // 1. Filter expenses in current period
  final periodExpenses = all
      .where(
        (t) =>
            _isWithinPeriod(t.date, period, now) &&
            t.type == TransactionType.expense,
      )
      .toList();

  // 2. Largest Expense
  Transaction? largest;
  if (periodExpenses.isNotEmpty) {
    largest = periodExpenses.reduce(
      (curr, next) => curr.amount > next.amount ? curr : next,
    );
  }

  // 3. Average Daily Spend (pro-rated by elapsed days)
  final totalSpent = periodExpenses.fold(0.0, (sum, t) => sum + t.amount);
  int elapsedDays = 1;
  switch (period) {
    case AnalyticsPeriod.week:
      elapsedDays = 7;
      break;
    case AnalyticsPeriod.month:
      elapsedDays = now.day;
      break;
    case AnalyticsPeriod.year:
      final startOfYear = DateTime(now.year, 1, 1);
      elapsedDays = now.difference(startOfYear).inDays + 1;
      if (elapsedDays > 365) elapsedDays = 365;
      break;
  }
  final avgDaily = elapsedDays > 0 ? totalSpent / elapsedDays : 0.0;

  // 4. Weekly Summary Comparison (past 7 days vs previous 7 days)
  final todayStart = DateTime(now.year, now.month, now.day);
  final currentWeekStart = todayStart.subtract(const Duration(days: 7));
  final previousWeekStart = todayStart.subtract(const Duration(days: 14));

  final curWeekTotal = all
      .where(
        (t) =>
            t.type == TransactionType.expense &&
            t.date.isAfter(
              currentWeekStart.subtract(const Duration(seconds: 1)),
            ) &&
            t.date.isBefore(now.add(const Duration(seconds: 1))),
      )
      .fold(0.0, (sum, t) => sum + t.amount);

  final prevWeekTotal = all
      .where(
        (t) =>
            t.type == TransactionType.expense &&
            t.date.isAfter(
              previousWeekStart.subtract(const Duration(seconds: 1)),
            ) &&
            t.date.isBefore(currentWeekStart),
      )
      .fold(0.0, (sum, t) => sum + t.amount);

  double comparisonPct = 0.0;
  if (prevWeekTotal > 0.0) {
    comparisonPct = ((curWeekTotal - prevWeekTotal) / prevWeekTotal) * 100;
  } else if (curWeekTotal > 0.0) {
    comparisonPct = 100.0;
  }

  return AnalyticsInsights(
    largestExpense: largest,
    averageDailySpend: avgDaily,
    weeklyComparisonPercentage: comparisonPct,
    currentWeekTotal: curWeekTotal,
    previousWeekTotal: prevWeekTotal,
  );
});
