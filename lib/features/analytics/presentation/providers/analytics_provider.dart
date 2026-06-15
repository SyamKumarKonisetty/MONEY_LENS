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

/// Current month summary provider.
final monthlySummaryProvider = Provider<MonthlySummary>((ref) {
  final all = ref.watch(allTransactionsProvider);
  final now = DateTime.now();
  
  final currentMonthExpenses = all
      .where((t) =>
          t.date.year == now.year &&
          t.date.month == now.month &&
          t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  final currentMonthIncome = all
      .where((t) =>
          t.date.year == now.year &&
          t.date.month == now.month &&
          t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  return MonthlySummary(
    year: now.year,
    month: now.month,
    totalIncome: currentMonthIncome,
    totalExpenses: currentMonthExpenses,
  );
});

/// Category spending breakdown provider.
final categoryBreakdownProvider = Provider<List<CategorySpending>>((ref) {
  final all = ref.watch(allTransactionsProvider);
  final now = DateTime.now();
  
  final currentMonthExpenses = all
      .where((t) =>
          t.date.year == now.year &&
          t.date.month == now.month &&
          t.type == TransactionType.expense)
      .toList();

  final totals = <String, double>{};
  var grandTotal = 0.0;

  for (final t in currentMonthExpenses) {
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
        .where((t) =>
            t.date.year == year &&
            t.date.month == month &&
            t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final monthIncome = all
        .where((t) =>
            t.date.year == year &&
            t.date.month == month &&
            t.type == TransactionType.income)
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
