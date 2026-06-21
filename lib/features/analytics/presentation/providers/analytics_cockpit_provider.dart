import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../transactions/domain/models.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../domain/models.dart';

/// Available periods for the Analytics cockpit.
enum CockpitPeriod { week, month, quarter, year, custom }

/// Represents an event on the horizontal financial timeline.
class TimelineMilestone {
  final DateTime date;
  final String title;
  final double amount;
  final String type; // 'salary', 'bill', 'large_purchase', 'milestone'
  final IconData icon;

  const TimelineMilestone({
    required this.date,
    required this.title,
    required this.amount,
    required this.type,
    required this.icon,
  });
}

/// Represents a gamified achievement item.
class AchievementItem {
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final String valueText;

  const AchievementItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.valueText,
  });
}

/// Represents a merchant spend summary.
class MerchantSpend {
  final String name;
  final String categoryId;
  final double amount;
  final int transactionCount;
  final double trendPercentage;

  const MerchantSpend({
    required this.name,
    required this.categoryId,
    required this.amount,
    required this.transactionCount,
    required this.trendPercentage,
  });
}

/// Main data container for the Analytics cockpit.
class CockpitData {
  final CockpitPeriod period;
  final DateTimeRange dateRange;
  final List<Transaction> transactions;
  final double totalIncome;
  final double totalExpenses;
  final double savings;
  final double savingsRate;
  final int healthScore;
  final String healthExplanation;
  final double expectedSpend;
  final double remainingBudget;
  final double totalBudgetLimit;
  final String forecastRisk; // 'Low', 'Moderate', 'High'
  final int daysLeft;
  final Map<DateTime, double> heatmapData;
  final List<TimelineMilestone> timelineMilestones;
  final List<AchievementItem> achievements;
  final List<MerchantSpend> topMerchants;
  final List<CategorySpending> categorySpendingList;

  const CockpitData({
    required this.period,
    required this.dateRange,
    required this.transactions,
    required this.totalIncome,
    required this.totalExpenses,
    required this.savings,
    required this.savingsRate,
    required this.healthScore,
    required this.healthExplanation,
    required this.expectedSpend,
    required this.remainingBudget,
    required this.totalBudgetLimit,
    required this.forecastRisk,
    required this.daysLeft,
    required this.heatmapData,
    required this.timelineMilestones,
    required this.achievements,
    required this.topMerchants,
    required this.categorySpendingList,
  });
}

// ─────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────

/// Active period selection provider.
final cockpitPeriodProvider = StateProvider<CockpitPeriod>((ref) => CockpitPeriod.month);

/// Active custom date range provider.
final cockpitCustomRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

/// Search query provider for filtering analytics screen components.
final analyticsSearchQueryProvider = StateProvider<String>((ref) => '');

/// Main provider that computes all stats for the selected period.
final cockpitDataProvider = Provider<CockpitData>((ref) {
  final allTx = ref.watch(allTransactionsProvider);
  final period = ref.watch(cockpitPeriodProvider);
  final customRange = ref.watch(cockpitCustomRangeProvider);
  final search = ref.watch(analyticsSearchQueryProvider).trim().toLowerCase();
  final budgets = ref.watch(liveBudgetsProvider);

  final now = DateTime.now();
  late DateTime start;
  late DateTime end;

  switch (period) {
    case CockpitPeriod.week:
      start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
      end = now;
      break;
    case CockpitPeriod.month:
      start = DateTime(now.year, now.month, 1);
      end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      break;
    case CockpitPeriod.quarter:
      final quarterMonth = ((now.month - 1) ~/ 3) * 3 + 1;
      start = DateTime(now.year, quarterMonth, 1);
      end = DateTime(now.year, quarterMonth + 3, 0, 23, 59, 59);
      break;
    case CockpitPeriod.year:
      start = DateTime(now.year, 1, 1);
      end = DateTime(now.year, 12, 31, 23, 59, 59);
      break;
    case CockpitPeriod.custom:
      start = customRange?.start ?? DateTime(now.year, now.month, 1);
      end = customRange?.end ?? now;
      break;
  }

  // Filter transactions within range
  final rangeTx = allTx.where((t) => t.date.isAfter(start.subtract(const Duration(seconds: 1))) && t.date.isBefore(end.add(const Duration(seconds: 1)))).toList();

  // Search filter
  final tx = search.isEmpty ? rangeTx : rangeTx.where((t) {
    final catName = AppCategories.findById(t.categoryId).name.toLowerCase();
    return t.title.toLowerCase().contains(search) || catName.contains(search) || (t.note?.toLowerCase().contains(search) ?? false);
  }).toList();

  // Summaries
  final expenses = tx.where((t) => t.type == TransactionType.expense).toList();
  final totalExpenses = expenses.fold(0.0, (sum, t) => sum + t.amount);
  final totalIncome = tx.where((t) => t.type == TransactionType.income).fold(0.0, (sum, t) => sum + t.amount);
  final savings = totalIncome - totalExpenses;
  final savingsRate = totalIncome > 0 ? savings / totalIncome : 0.0;

  // Health Score Calculation
  int score = 100;
  if (savingsRate < 0.3) {
    score -= ((0.3 - savingsRate).clamp(0.0, 0.3) * 133).round();
  }
  if (totalExpenses > totalIncome) score -= 20;

  final totalLimit = budgets.fold(0.0, (sum, b) => sum + b.monthlyLimit);
  if (totalLimit > 0) {
    if (totalExpenses > totalLimit) {
      score -= 20;
    } else {
      score -= ((totalExpenses / totalLimit) * 15).round();
    }
  }

  final exceededCount = budgets.where((b) => b.spentAmount > b.monthlyLimit).length;
  score -= (exceededCount * 5);
  score = score.clamp(0, 100);

  late String explanation;
  if (score >= 90) {
    explanation = 'Excellent! Strong savings rate and well within budget limits.';
  } else if (score >= 70) {
    explanation = 'Good health. Optimize minor expenses to improve savings rate.';
  } else if (score >= 50) {
    explanation = 'Needs Attention. Expenses are running high compared to income.';
  } else {
    explanation = 'Critical. Budget exceeded or expenses far exceed income.';
  }

  // Forecast Calculations
  final totalDays = end.difference(start).inDays + 1;
  final elapsed = now.difference(start).inDays.clamp(1, totalDays);
  final daysLeft = (totalDays - elapsed).clamp(0, totalDays);
  final avgDaily = elapsed > 0 ? totalExpenses / elapsed : 0.0;
  final expectedSpend = avgDaily * totalDays;
  final remainingBudget = (totalLimit - totalExpenses).clamp(0.0, double.infinity);

  late String risk;
  if (totalLimit == 0 || expectedSpend <= totalLimit) {
    risk = 'Low';
  } else if (expectedSpend <= totalLimit * 1.15) {
    risk = 'Moderate';
  } else {
    risk = 'High';
  }

  // Heatmap Data
  final heatmap = <DateTime, double>{};
  for (final t in expenses) {
    final day = DateTime(t.date.year, t.date.month, t.date.day);
    heatmap[day] = (heatmap[day] ?? 0.0) + t.amount;
  }

  // Timeline Milestones
  final milestones = <TimelineMilestone>[];
  for (final t in tx) {
    if (t.type == TransactionType.income && (t.title.toLowerCase().contains('salary') || t.amount >= 15000)) {
      milestones.add(TimelineMilestone(date: t.date, title: 'Salary Credited', amount: t.amount, type: 'salary', icon: Icons.work_rounded));
    } else if (t.type == TransactionType.expense && (t.title.toLowerCase().contains('bill') || t.title.toLowerCase().contains('rent') || t.categoryId == 'bills')) {
      milestones.add(TimelineMilestone(date: t.date, title: t.title, amount: t.amount, type: 'bill', icon: Icons.receipt_long_rounded));
    } else if (t.type == TransactionType.expense && t.amount >= 5000) {
      milestones.add(TimelineMilestone(date: t.date, title: 'Large Purchase: ${t.title}', amount: t.amount, type: 'large_purchase', icon: Icons.shopping_bag_rounded));
    }
  }
  milestones.sort((a, b) => b.date.compareTo(a.date));

  // Achievements
  int streak = 0;
  int currentStreak = 0;
  for (int d = 0; d < elapsed; d++) {
    final checkDay = start.add(Duration(days: d));
    final checkDate = DateTime(checkDay.year, checkDay.month, checkDay.day);
    final spentOnDay = heatmap[checkDate] ?? 0.0;
    if (spentOnDay < 500) {
      currentStreak++;
      if (currentStreak > streak) streak = currentStreak;
    } else {
      currentStreak = 0;
    }
  }

  final achievements = [
    AchievementItem(title: '7-Day Streak', description: 'Kept daily spend under ₹500', icon: Icons.local_fire_department_rounded, isUnlocked: streak >= 7, valueText: '$streak Days'),
    AchievementItem(title: 'Budget Champion', description: 'Stayed under budget limits', icon: Icons.emoji_events_rounded, isUnlocked: exceededCount == 0 && totalLimit > 0, valueText: exceededCount == 0 ? 'Exceeded: 0' : 'Exceeded: $exceededCount'),
    AchievementItem(title: 'Super Saver', description: 'Saved over 30% of income', icon: Icons.savings_rounded, isUnlocked: savingsRate >= 0.3, valueText: '${(savingsRate * 100).toStringAsFixed(0)}% saved'),
    AchievementItem(title: 'Wealth Builder', description: 'Single income over ₹25k', icon: Icons.trending_up_rounded, isUnlocked: tx.any((t) => t.type == TransactionType.income && t.amount >= 25000), valueText: 'Unlocked'),
  ];

  // Top Merchants
  final merchantMap = <String, Map<String, dynamic>>{};
  for (final t in expenses) {
    final entry = merchantMap.putIfAbsent(t.title, () => {'amount': 0.0, 'count': 0, 'cat': t.categoryId});
    entry['amount'] += t.amount;
    entry['count'] += 1;
  }
  final topMerchants = merchantMap.entries.map((e) => MerchantSpend(name: e.key, categoryId: e.value['cat'], amount: e.value['amount'], transactionCount: e.value['count'], trendPercentage: -8.5)).toList()..sort((a, b) => b.amount.compareTo(a.amount));

  // Category spending breakdown
  final categoryMap = <String, double>{};
  for (final t in expenses) {
    categoryMap[t.categoryId] = (categoryMap[t.categoryId] ?? 0.0) + t.amount;
  }
  final categorySpendingList = categoryMap.entries.map((e) {
    return CategorySpending(categoryId: e.key, amount: e.value, percentage: totalExpenses > 0 ? e.value / totalExpenses : 0.0);
  }).toList()..sort((a, b) => b.amount.compareTo(a.amount));

  return CockpitData(
    period: period,
    dateRange: DateTimeRange(start: start, end: end),
    transactions: tx,
    totalIncome: totalIncome,
    totalExpenses: totalExpenses,
    savings: savings,
    savingsRate: savingsRate,
    healthScore: score,
    healthExplanation: explanation,
    expectedSpend: expectedSpend,
    remainingBudget: remainingBudget,
    totalBudgetLimit: totalLimit,
    forecastRisk: risk,
    daysLeft: daysLeft,
    heatmapData: heatmap,
    timelineMilestones: milestones,
    achievements: achievements,
    topMerchants: topMerchants.take(5).toList(),
    categorySpendingList: categorySpendingList,
  );
});
