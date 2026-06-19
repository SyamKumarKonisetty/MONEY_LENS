import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/savings_goal_entity.dart';
import '../../domain/repositories/savings_goal_repository.dart';
import '../../data/repositories/savings_goal_repository_impl.dart';
import '../../../../core/database/app_database.dart';
import '../../../transactions/domain/models.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../../budget/presentation/providers/budget_provider.dart';

enum TimelinePeriod { today, thisWeek, thisMonth, thisYear, custom }

class ReportsFilterState {
  final TimelinePeriod period;
  final DateTime startDate;
  final DateTime endDate;

  ReportsFilterState({
    required this.period,
    required this.startDate,
    required this.endDate,
  });

  ReportsFilterState copyWith({
    TimelinePeriod? period,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ReportsFilterState(
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class ReportsFilterNotifier extends StateNotifier<ReportsFilterState> {
  ReportsFilterNotifier()
    : super(
        ReportsFilterState(
          period: TimelinePeriod.thisMonth,
          startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
          endDate: DateTime(
            DateTime.now().year,
            DateTime.now().month + 1,
            0,
            23,
            59,
            59,
            999,
          ),
        ),
      );

  void setPeriod(TimelinePeriod period) {
    final now = DateTime.now();
    DateTime start = state.startDate;
    DateTime end = state.endDate;

    switch (period) {
      case TimelinePeriod.today:
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        break;
      case TimelinePeriod.thisWeek:
        start = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));
        end = start.add(
          const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
        );
        break;
      case TimelinePeriod.thisMonth:
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
        break;
      case TimelinePeriod.thisYear:
        start = DateTime(now.year, 1, 1);
        end = DateTime(now.year, 12, 31, 23, 59, 59, 999);
        break;
      case TimelinePeriod.custom:
        break;
    }

    state = state.copyWith(period: period, startDate: start, endDate: end);
  }

  void setCustomRange(DateTime start, DateTime end) {
    state = state.copyWith(
      period: TimelinePeriod.custom,
      startDate: start,
      endDate: end,
    );
  }
}

final reportsTimelineProvider =
    StateNotifierProvider<ReportsTimelineNotifier, TimelinePeriod>((ref) {
      return ReportsTimelineNotifier();
    });

class ReportsTimelineNotifier extends StateNotifier<TimelinePeriod> {
  ReportsTimelineNotifier() : super(TimelinePeriod.thisMonth);

  void setPeriod(TimelinePeriod period) {
    state = period;
  }
}

final reportsFilterProvider =
    StateNotifierProvider<ReportsFilterNotifier, ReportsFilterState>((ref) {
      final timeline = ref.watch(reportsTimelineProvider);
      final notifier = ReportsFilterNotifier();
      // Sync the old timeline period with the new filter notifier
      notifier.setPeriod(timeline);
      return notifier;
    });

final savingsGoalRepositoryProvider = Provider<SavingsGoalRepository>((ref) {
  return SavingsGoalRepositoryImpl(AppDatabase.instance);
});

final currentMonthSavingsGoalProvider = StreamProvider<double>((ref) {
  final repo = ref.watch(savingsGoalRepositoryProvider);
  final now = DateTime.now();
  return repo
      .watchSavingsGoal(now.month, now.year)
      .map((g) => g?.amount ?? 15000.0);
});

class SavingsGoalNotifier
    extends StateNotifier<AsyncValue<SavingsGoalEntity?>> {
  final SavingsGoalRepository _repository;
  final int _month;
  final int _year;

  SavingsGoalNotifier(this._repository, this._month, this._year)
    : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _repository
        .watchSavingsGoal(_month, _year)
        .listen(
          (g) {
            if (mounted) {
              state = AsyncValue.data(g);
            }
          },
          onError: (err, stack) {
            if (mounted) {
              state = AsyncValue.error(err, stack);
            }
          },
        );
  }

  Future<void> setSavingsGoal(double amount) async {
    final goal = SavingsGoalEntity(amount: amount, month: _month, year: _year);
    await _repository.setSavingsGoal(goal);
  }
}

final savingsGoalNotifierProvider =
    StateNotifierProvider<SavingsGoalNotifier, AsyncValue<SavingsGoalEntity?>>((
      ref,
    ) {
      final repository = ref.watch(savingsGoalRepositoryProvider);
      final now = DateTime.now();
      return SavingsGoalNotifier(repository, now.month, now.year);
    });

class TimelineTransactions {
  final List<Transaction> current;
  final List<Transaction> previous;

  const TimelineTransactions({required this.current, required this.previous});
}

final timelineTransactionsProvider = Provider<TimelineTransactions>((ref) {
  final all = ref.watch(allTransactionsProvider);
  final filterState = ref.watch(reportsFilterProvider);

  final start = filterState.startDate;
  final end = filterState.endDate;

  final currentPeriodTxs = all
      .where(
        (t) =>
            t.date.isAfter(start.subtract(const Duration(milliseconds: 1))) &&
            t.date.isBefore(end.add(const Duration(milliseconds: 1))),
      )
      .toList();

  final duration = end.difference(start);
  final prevEnd = start.subtract(const Duration(milliseconds: 1));
  final prevStart = prevEnd.subtract(duration);

  final previousPeriodTxs = all
      .where(
        (t) =>
            t.date.isAfter(
              prevStart.subtract(const Duration(milliseconds: 1)),
            ) &&
            t.date.isBefore(prevEnd.add(const Duration(milliseconds: 1))),
      )
      .toList();

  return TimelineTransactions(
    current: currentPeriodTxs,
    previous: previousPeriodTxs,
  );
});

class ReportsFinancialSummary {
  final double income;
  final double expenses;
  final double savings;
  final double savingsRate;
  final double netCashFlow;
  final double averageDailySpend;
  final double averageMonthlySpend;
  final Transaction? largestExpense;
  final Transaction? largestIncome;

  const ReportsFinancialSummary({
    required this.income,
    required this.expenses,
    required this.savings,
    required this.savingsRate,
    required this.netCashFlow,
    required this.averageDailySpend,
    required this.averageMonthlySpend,
    this.largestExpense,
    this.largestIncome,
  });
}

final reportsSummaryProvider = Provider<ReportsFinancialSummary>((ref) {
  final txs = ref.watch(timelineTransactionsProvider);
  final current = txs.current;
  final filterState = ref.watch(reportsFilterProvider);

  final incomeList = current
      .where((t) => t.type == TransactionType.income)
      .toList();
  final expenseList = current
      .where((t) => t.type == TransactionType.expense)
      .toList();

  final income = incomeList.fold(0.0, (sum, t) => sum + t.amount);
  final expenses = expenseList.fold(0.0, (sum, t) => sum + t.amount);

  final savings = income - expenses;
  final savingsRate = income > 0 ? (savings / income) * 100.0 : 0.0;
  final netCashFlow = income - expenses;

  final daysDiff =
      filterState.endDate.difference(filterState.startDate).inDays.abs() + 1;
  final averageDailySpend = daysDiff > 0 ? expenses / daysDiff : 0.0;

  final monthsDiff =
      ((filterState.endDate.year - filterState.startDate.year) * 12 +
              filterState.endDate.month -
              filterState.startDate.month +
              1)
          .clamp(1, 12000);
  final averageMonthlySpend = expenses / monthsDiff;

  Transaction? largestExpense;
  if (expenseList.isNotEmpty) {
    largestExpense = expenseList.reduce(
      (curr, next) => curr.amount > next.amount ? curr : next,
    );
  }

  Transaction? largestIncome;
  if (incomeList.isNotEmpty) {
    largestIncome = incomeList.reduce(
      (curr, next) => curr.amount > next.amount ? curr : next,
    );
  }

  return ReportsFinancialSummary(
    income: income,
    expenses: expenses,
    savings: savings,
    savingsRate: savingsRate,
    netCashFlow: netCashFlow,
    averageDailySpend: averageDailySpend,
    averageMonthlySpend: averageMonthlySpend,
    largestExpense: largestExpense,
    largestIncome: largestIncome,
  );
});

class CategorySpendingDetail {
  final Category category;
  final double amount;
  final double percentage;

  CategorySpendingDetail({
    required this.category,
    required this.amount,
    required this.percentage,
  });
}

class ReportsCategoryAnalytics {
  final List<CategorySpendingDetail> details;
  final CategorySpendingDetail? topCategory;
  final CategorySpendingDetail? leastCategory;

  ReportsCategoryAnalytics({
    required this.details,
    this.topCategory,
    this.leastCategory,
  });
}

final categoryAnalyticsProvider = Provider<ReportsCategoryAnalytics>((ref) {
  final txs = ref.watch(timelineTransactionsProvider);
  final currentExpenses = txs.current
      .where((t) => t.type == TransactionType.expense)
      .toList();
  final totalExpenses = currentExpenses.fold(0.0, (sum, t) => sum + t.amount);

  final categorySums = <String, double>{};
  for (final t in currentExpenses) {
    categorySums[t.categoryId] = (categorySums[t.categoryId] ?? 0.0) + t.amount;
  }

  final details = <CategorySpendingDetail>[];
  categorySums.forEach((catId, sum) {
    final cat = AppCategories.findById(catId);
    final pct = totalExpenses > 0 ? (sum / totalExpenses) * 100.0 : 0.0;
    details.add(
      CategorySpendingDetail(category: cat, amount: sum, percentage: pct),
    );
  });

  details.sort((a, b) => b.amount.compareTo(a.amount));

  CategorySpendingDetail? topCategory = details.isNotEmpty
      ? details.first
      : null;
  CategorySpendingDetail? leastCategory;
  final nonZeroDetails = details.where((d) => d.amount > 0).toList();
  if (nonZeroDetails.isNotEmpty) {
    leastCategory = nonZeroDetails.last;
  }

  return ReportsCategoryAnalytics(
    details: details,
    topCategory: topCategory,
    leastCategory: leastCategory,
  );
});

class WealthScoreDetails {
  final double overallScore;
  final double savingsRateFactor;
  final double budgetAdherenceFactor;
  final double consistencyFactor;

  const WealthScoreDetails({
    required this.overallScore,
    required this.savingsRateFactor,
    required this.budgetAdherenceFactor,
    required this.consistencyFactor,
  });
}

final wealthScoreProvider = Provider<WealthScoreDetails>((ref) {
  final summary = ref.watch(reportsSummaryProvider);

  // 1. Savings Rate Score (40%)
  final rate = summary.savingsRate;
  double savingsRateFactor = 0.0;
  if (rate >= 30.0) {
    savingsRateFactor = 100.0;
  } else if (rate > 0.0) {
    savingsRateFactor = (rate / 30.0) * 100.0;
  }

  // 2. Budget Adherence Score (40%)
  final budgetSummary = ref.watch(budgetSummaryProvider);
  final budgetLimit = budgetSummary.totalLimit > 0
      ? budgetSummary.totalLimit
      : 50000.0;
  final expenses = summary.expenses;

  double budgetAdherenceFactor = 100.0;
  if (expenses > budgetLimit) {
    final overspendPercent = (expenses - budgetLimit) / budgetLimit;
    budgetAdherenceFactor = (100.0 - overspendPercent * 100.0).clamp(
      0.0,
      100.0,
    );
  }

  // 3. Spending Consistency Score (20%)
  final txs = ref.watch(timelineTransactionsProvider);
  final currentExpenses = txs.current
      .where((t) => t.type == TransactionType.expense)
      .toList();

  double consistencyFactor = 100.0;
  if (currentExpenses.isNotEmpty) {
    final total = currentExpenses.fold(0.0, (sum, t) => sum + t.amount);
    if (total > 0.0) {
      double maxExpense = 0.0;
      for (final tx in currentExpenses) {
        if (tx.amount > maxExpense) {
          maxExpense = tx.amount;
        }
      }
      final dominantRatio = maxExpense / total;
      if (dominantRatio > 0.25) {
        consistencyFactor = (100.0 - (dominantRatio - 0.25) * 100.0).clamp(
          20.0,
          100.0,
        );
      }
    }
  }

  final overall =
      (savingsRateFactor * 0.40) +
      (budgetAdherenceFactor * 0.40) +
      (consistencyFactor * 0.20);

  return WealthScoreDetails(
    overallScore: overall,
    savingsRateFactor: savingsRateFactor,
    budgetAdherenceFactor: budgetAdherenceFactor,
    consistencyFactor: consistencyFactor,
  );
});

class CategoryDelta {
  final Category category;
  final double currentAmount;
  final double previousAmount;
  final double delta;
  final double percentChange;

  const CategoryDelta({
    required this.category,
    required this.currentAmount,
    required this.previousAmount,
    required this.delta,
    required this.percentChange,
  });
}

class SpendingTrends {
  final double totalChangePercent;
  final double deltaAmount;
  final bool isIncrease;
  final List<CategoryDelta> categoryDeltas;

  const SpendingTrends({
    required this.totalChangePercent,
    required this.deltaAmount,
    required this.isIncrease,
    required this.categoryDeltas,
  });
}

final spendingTrendsProvider = Provider<SpendingTrends>((ref) {
  final txs = ref.watch(timelineTransactionsProvider);

  final curExpenses = txs.current
      .where((t) => t.type == TransactionType.expense)
      .toList();
  final prevExpenses = txs.previous
      .where((t) => t.type == TransactionType.expense)
      .toList();

  final curTotal = curExpenses.fold(0.0, (sum, t) => sum + t.amount);
  final prevTotal = prevExpenses.fold(0.0, (sum, t) => sum + t.amount);

  final deltaAmount = curTotal - prevTotal;
  final isIncrease = deltaAmount > 0;
  final totalChangePercent = prevTotal > 0
      ? (deltaAmount.abs() / prevTotal) * 100.0
      : 0.0;

  final curCatTotals = <String, double>{};
  for (final t in curExpenses) {
    curCatTotals[t.categoryId] = (curCatTotals[t.categoryId] ?? 0.0) + t.amount;
  }

  final prevCatTotals = <String, double>{};
  for (final t in prevExpenses) {
    prevCatTotals[t.categoryId] =
        (prevCatTotals[t.categoryId] ?? 0.0) + t.amount;
  }

  final deltas = <CategoryDelta>[];
  final allCats = AppCategories.expense;

  for (final cat in allCats) {
    final curAmount = curCatTotals[cat.id] ?? 0.0;
    final prevAmount = prevCatTotals[cat.id] ?? 0.0;
    if (curAmount == 0.0 && prevAmount == 0.0) continue;

    final diff = curAmount - prevAmount;
    final pct = prevAmount > 0 ? (diff.abs() / prevAmount) * 100.0 : 100.0;
    deltas.add(
      CategoryDelta(
        category: cat,
        currentAmount: curAmount,
        previousAmount: prevAmount,
        delta: diff,
        percentChange: pct,
      ),
    );
  }

  // Sort deltas: biggest absolute change first
  deltas.sort((a, b) => b.delta.abs().compareTo(a.delta.abs()));

  return SpendingTrends(
    totalChangePercent: totalChangePercent,
    deltaAmount: deltaAmount.abs(),
    isIncrease: isIncrease,
    categoryDeltas: deltas,
  );
});

class SmartInsightItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const SmartInsightItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

final smartInsightsProvider = Provider<List<SmartInsightItem>>((ref) {
  final summary = ref.watch(reportsSummaryProvider);
  final wealth = ref.watch(wealthScoreProvider);
  final trends = ref.watch(spendingTrendsProvider);
  final budgetSummary = ref.watch(budgetSummaryProvider);
  final budgetLimit = budgetSummary.totalLimit > 0
      ? budgetSummary.totalLimit
      : 50000.0;

  final insights = <SmartInsightItem>[];

  // 1. Savings Rate Insight
  if (summary.savingsRate >= 30.0) {
    insights.add(
      SmartInsightItem(
        title: 'Excellent Savings Rate',
        description:
            'Your savings rate of ${summary.savingsRate.toStringAsFixed(1)}% is healthy. You are building wealth successfully.',
        icon: Icons.check_circle_rounded,
        color: Colors.green,
      ),
    );
  } else if (summary.savingsRate > 0.0) {
    insights.add(
      SmartInsightItem(
        title: 'Boost Savings Rate',
        description:
            'Your savings rate is ${summary.savingsRate.toStringAsFixed(1)}%. Aim for 30% by reducing discretionary items to raise your Wealth Score.',
        icon: Icons.info_rounded,
        color: Colors.orange,
      ),
    );
  } else {
    insights.add(
      SmartInsightItem(
        title: 'Negative Savings Rate',
        description:
            'You are spending more than you earn. Review your expenses to cut back on non-essential categories.',
        icon: Icons.warning_rounded,
        color: Colors.red,
      ),
    );
  }

  // 2. Budget Insight
  if (summary.expenses > budgetLimit) {
    final over = summary.expenses - budgetLimit;
    insights.add(
      SmartInsightItem(
        title: 'Budget Exceeded',
        description:
            'You exceeded your monthly budget by ₹${over.toStringAsFixed(0)}. Set category budgets to organize and limit your spending.',
        icon: Icons.error_rounded,
        color: Colors.red,
      ),
    );
  } else {
    final left = budgetLimit - summary.expenses;
    insights.add(
      SmartInsightItem(
        title: 'Under Budget',
        description:
            'Great job! You have ₹${left.toStringAsFixed(0)} remaining of your monthly budget.',
        icon: Icons.thumb_up_rounded,
        color: Colors.green,
      ),
    );
  }

  // 3. Trend Insight
  if (trends.deltaAmount > 0.0) {
    if (trends.isIncrease) {
      insights.add(
        SmartInsightItem(
          title: 'Spending is Up',
          description:
              'You spent ₹${trends.deltaAmount.toStringAsFixed(0)} (${trends.totalChangePercent.toStringAsFixed(0)}%) more than the previous period.',
          icon: Icons.trending_up_rounded,
          color: Colors.red,
        ),
      );
    } else {
      insights.add(
        SmartInsightItem(
          title: 'Spending is Down',
          description:
              'Excellent! You saved ₹${trends.deltaAmount.toStringAsFixed(0)} (${trends.totalChangePercent.toStringAsFixed(0)}%) compared to the last period.',
          icon: Icons.trending_down_rounded,
          color: Colors.green,
        ),
      );
    }
  }

  // 4. Category specific delta insights
  for (final d in trends.categoryDeltas.take(2)) {
    if (d.delta.abs() > 200.0) {
      final changeDir = d.delta > 0 ? 'increased' : 'decreased';
      final changeColor = d.delta > 0 ? Colors.red : Colors.green;
      insights.add(
        SmartInsightItem(
          title: '${d.category.name} Spend Change',
          description:
              'Your spending on ${d.category.name} $changeDir by ${d.percentChange.toStringAsFixed(0)}% compared to the previous period.',
          icon: d.category.icon,
          color: changeColor,
        ),
      );
    }
  }

  // 5. Wealth Score Insight
  if (wealth.overallScore < 50) {
    insights.add(
      SmartInsightItem(
        title: 'Wealth Score Warning',
        description:
            'Your Wealth Score is ${wealth.overallScore.toStringAsFixed(0)}/100. Try setting a monthly savings goal to raise it.',
        icon: Icons.speed_rounded,
        color: Colors.red,
      ),
    );
  } else if (wealth.overallScore >= 80) {
    insights.add(
      SmartInsightItem(
        title: 'Elite Wealth Score',
        description:
            'Fantastic! Your Wealth Score is ${wealth.overallScore.toStringAsFixed(0)}/100. You exhibit top-tier financial habits.',
        icon: Icons.workspace_premium_rounded,
        color: Colors.amber,
      ),
    );
  }

  return insights;
});

class MonthlyReportItem {
  final int month;
  final int year;
  final double income;
  final double expenses;
  final double savings;
  final double savingsRate;

  const MonthlyReportItem({
    required this.month,
    required this.year,
    required this.income,
    required this.expenses,
    required this.savings,
    required this.savingsRate,
  });
}

final monthlyReportsHistoryProvider = Provider<List<MonthlyReportItem>>((ref) {
  final all = ref.watch(allTransactionsProvider);
  if (all.isEmpty) return [];

  final groups = <String, List<Transaction>>{};
  for (final t in all) {
    final key = '${t.date.year}-${t.date.month}';
    groups.putIfAbsent(key, () => []).add(t);
  }

  final reports = <MonthlyReportItem>[];
  for (final entry in groups.entries) {
    final parts = entry.key.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final txs = entry.value;

    final income = txs
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final expenses = txs
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final savings = income - expenses;
    final savingsRate = income > 0 ? (savings / income) * 100.0 : 0.0;

    reports.add(
      MonthlyReportItem(
        month: month,
        year: year,
        income: income,
        expenses: expenses,
        savings: savings,
        savingsRate: savingsRate,
      ),
    );
  }

  reports.sort((a, b) {
    if (a.year != b.year) {
      return b.year.compareTo(a.year);
    }
    return b.month.compareTo(a.month);
  });

  return reports;
});
