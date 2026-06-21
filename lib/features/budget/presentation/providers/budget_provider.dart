import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../../../../core/database/app_database.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../../transactions/domain/models.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepositoryImpl(AppDatabase.instance);
});

/// Watches all budgets stored in SQLite.
final allBudgetsProvider = StreamProvider<List<BudgetEntity>>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return repository.watchAllBudgets();
});

/// Combines SQLite budgets with live current-month transaction data.
/// Combines SQLite budgets with live current-month transaction data.
final liveBudgetsProvider = Provider<List<BudgetEntity>>((ref) {
  final budgetsAsync = ref.watch(allBudgetsProvider);
  final transactions = ref.watch(allTransactionsProvider);

  final budgets = budgetsAsync.value ?? [];
  final now = DateTime.now();
  final currentMonthExpenses = transactions
      .where(
        (t) =>
            t.date.year == now.year &&
            t.date.month == now.month &&
            t.type == TransactionType.expense,
      )
      .toList();

  return budgets.map((budget) {
    final categoryExpenses = currentMonthExpenses
        .where(
          (t) => t.categoryId.toLowerCase() == budget.category.toLowerCase(),
        )
        .toList();
    final spent = categoryExpenses.fold(0.0, (sum, t) => sum + t.amount);

    return budget.copyWith(
      spentAmount: spent,
      remainingAmount: budget.monthlyLimitEquivalent - spent,
    );
  }).toList();
});

class BudgetNotifier extends StateNotifier<AsyncValue<List<BudgetEntity>>> {
  final BudgetRepository _repository;

  BudgetNotifier(this._repository) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _repository.watchAllBudgets().listen(
      (budgets) {
        if (mounted) {
          state = AsyncValue.data(budgets);
        }
      },
      onError: (err, stack) {
        if (mounted) {
          state = AsyncValue.error(err, stack);
        }
      },
    );
  }

  Future<void> setBudget(
    String category,
    double limit, {
    String period = 'monthly',
    bool isEnabled = true,
    bool isArchived = false,
  }) async {
    final existing = await _repository.getBudget(category);
    final budget = BudgetEntity(
      id: existing?.id,
      category: category,
      monthlyLimit: limit,
      period: period,
      isEnabled: isEnabled,
      isArchived: isArchived,
      createdAt: existing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _repository.setBudget(budget);
  }

  Future<void> setBudgetAmount(double amount, {String? category}) async {
    await setBudget(category ?? 'other', amount);
  }

  Future<void> toggleBudgetEnabled(int id, bool enabled) async {
    final list = state.value ?? [];
    final existing = list.firstWhere((b) => b.id == id);
    final updated = existing.copyWith(isEnabled: enabled, updatedAt: DateTime.now());
    await _repository.setBudget(updated);
  }

  Future<void> toggleBudgetArchived(int id, bool archived) async {
    final list = state.value ?? [];
    final existing = list.firstWhere((b) => b.id == id);
    final updated = existing.copyWith(isArchived: archived, updatedAt: DateTime.now());
    await _repository.setBudget(updated);
  }

  Future<void> duplicateBudget(int id, String toCategory) async {
    final list = state.value ?? [];
    final existing = list.firstWhere((b) => b.id == id);
    final duplicated = existing.copyWith(
      id: null,
      category: toCategory,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _repository.setBudget(duplicated);
  }

  Future<void> deleteBudget(int id) async {
    await _repository.deleteBudget(id);
  }
}

final budgetNotifierProvider =
    StateNotifierProvider<BudgetNotifier, AsyncValue<List<BudgetEntity>>>((
      ref,
    ) {
      final repository = ref.watch(budgetRepositoryProvider);
      return BudgetNotifier(repository);
    });

class BudgetSummary {
  final double totalLimit;
  final double totalSpent;
  final double totalRemaining;
  final double usagePercent;

  BudgetSummary({
    required this.totalLimit,
    required this.totalSpent,
    required this.totalRemaining,
    required this.usagePercent,
  });
}

/// Provides the active budget summary for the Dashboard and screens.
final budgetSummaryProvider = Provider<BudgetSummary>((ref) {
  final liveBudgets = ref.watch(liveBudgetsProvider);
  final activeBudgets = liveBudgets.where((b) => b.isEnabled && !b.isArchived).toList();
  final totalLimit = activeBudgets.fold(0.0, (sum, b) => sum + b.monthlyLimitEquivalent);
  final totalSpent = activeBudgets.fold(0.0, (sum, b) => sum + b.spentAmount);
  final totalRemaining = totalLimit - totalSpent;
  final usagePercent = totalLimit > 0 ? (totalSpent / totalLimit) * 100.0 : 0.0;

  return BudgetSummary(
    totalLimit: totalLimit,
    totalSpent: totalSpent,
    totalRemaining: totalRemaining,
    usagePercent: usagePercent,
  );
});

class BudgetAnalytics {
  final BudgetEntity? highestBudgetCategory;
  final BudgetEntity? mostOverspentCategory;
  final BudgetEntity? closestCategoryToLimit;
  final double monthlyUtilizationPercent;

  BudgetAnalytics({
    this.highestBudgetCategory,
    this.mostOverspentCategory,
    this.closestCategoryToLimit,
    required this.monthlyUtilizationPercent,
  });
}

/// Provides smart analytics metrics for the budgets.
final budgetAnalyticsProvider = Provider<BudgetAnalytics>((ref) {
  final liveBudgets = ref.watch(liveBudgetsProvider);
  final activeBudgets = liveBudgets.where((b) => b.isEnabled && !b.isArchived).toList();
  if (activeBudgets.isEmpty) {
    return BudgetAnalytics(monthlyUtilizationPercent: 0.0);
  }

  BudgetEntity? highestBudgetCat;
  BudgetEntity? mostOverspentCat;
  BudgetEntity? closestToLimitCat;

  double maxLimit = -1.0;
  double maxOverspent = 0.0;
  double minRemainingDiff = double.infinity;

  for (final b in activeBudgets) {
    // 1. Highest budget
    if (b.monthlyLimitEquivalent > maxLimit) {
      maxLimit = b.monthlyLimitEquivalent;
      highestBudgetCat = b;
    }

    // 2. Most overspent
    final overspend = b.spentAmount - b.monthlyLimitEquivalent;
    if (overspend > maxOverspent) {
      maxOverspent = overspend;
      mostOverspentCat = b;
    }

    // 3. Closest to limit
    if (b.spentAmount < b.monthlyLimitEquivalent) {
      final diff = b.monthlyLimitEquivalent - b.spentAmount;
      if (diff < minRemainingDiff) {
        minRemainingDiff = diff;
        closestToLimitCat = b;
      }
    }
  }

  final summary = ref.watch(budgetSummaryProvider);

  return BudgetAnalytics(
    highestBudgetCategory: highestBudgetCat,
    mostOverspentCategory: mostOverspentCat,
    closestCategoryToLimit: closestToLimitCat,
    monthlyUtilizationPercent: summary.usagePercent,
  );
});

/// Calculates overall safe daily limit based on ALL budget categories.
final dailySpendingLimitProvider = Provider<double>((ref) {
  final summary = ref.watch(budgetSummaryProvider);
  final remaining = summary.totalRemaining;

  final now = DateTime.now();
  final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
  final remainingDays = lastDayOfMonth.day - now.day + 1;

  return remaining > 0 ? (remaining / remainingDays) : 0.0;
});

// ─── Legacy Compatibility Layer for Tests & Screens ──────────────────────

final currentMonthBudgetProvider = StreamProvider<double>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return repository.watchAllBudgets().map((list) {
    final total = list.fold(0.0, (sum, b) => sum + b.monthlyLimit);
    return total > 0 ? total : 50000.0;
  });
});

final categoryBudgetsProvider = StreamProvider<Map<String, double>>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return repository.watchAllBudgets().map((list) {
    final map = <String, double>{};
    for (final b in list) {
      map[b.category.toLowerCase()] = b.monthlyLimit;
    }
    return map;
  });
});

class MonthEndProjection {
  final double expectedSpend;
  final double expectedSavings;
  final double dailyAverage;

  const MonthEndProjection({
    required this.expectedSpend,
    required this.expectedSavings,
    required this.dailyAverage,
  });
}

final monthEndProjectionProvider = Provider<MonthEndProjection>((ref) {
  final spent = ref.watch(currentMonthExpensesProvider);
  final budgetAsync = ref.watch(currentMonthBudgetProvider);
  final budgetLimit = budgetAsync.value ?? 50000.0;

  final now = DateTime.now();
  final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
  final totalDays = lastDayOfMonth.day;
  final daysPassed = now.day;

  final dailyAverage = daysPassed > 0 ? (spent / daysPassed) : 0.0;
  final expectedSpend = dailyAverage * totalDays;
  final expectedSavings = budgetLimit - expectedSpend;

  return MonthEndProjection(
    expectedSpend: expectedSpend,
    expectedSavings: expectedSavings,
    dailyAverage: dailyAverage,
  );
});

class SpendingInsight {
  final String categoryId;
  final String categoryName;
  final IconData icon;
  final Color color;
  final double percentageChange;
  final bool isIncrease;
  final String text;

  const SpendingInsight({
    required this.categoryId,
    required this.categoryName,
    required this.icon,
    required this.color,
    required this.percentageChange,
    required this.isIncrease,
    required this.text,
  });
}

final spendingInsightsProvider = Provider<List<SpendingInsight>>((ref) {
  final all = ref.watch(allTransactionsProvider);
  final now = DateTime.now();

  final currentMonth = now.month;
  final currentYear = now.year;

  final prevMonthDate = DateTime(now.year, now.month - 1, 1);
  final prevMonth = prevMonthDate.month;
  final prevYear = prevMonthDate.year;

  final currentMonthTxs = all
      .where(
        (t) =>
            t.date.year == currentYear &&
            t.date.month == currentMonth &&
            t.type == TransactionType.expense,
      )
      .toList();
  final prevMonthTxs = all
      .where(
        (t) =>
            t.date.year == prevYear &&
            t.date.month == prevMonth &&
            t.type == TransactionType.expense,
      )
      .toList();

  final currentTotals = <String, double>{};
  for (final t in currentMonthTxs) {
    currentTotals[t.categoryId] =
        (currentTotals[t.categoryId] ?? 0.0) + t.amount;
  }

  final prevTotals = <String, double>{};
  for (final t in prevMonthTxs) {
    prevTotals[t.categoryId] = (prevTotals[t.categoryId] ?? 0.0) + t.amount;
  }

  final insights = <SpendingInsight>[];

  final allCategories = AppCategories.expense;
  for (final cat in allCategories) {
    final curAmount = currentTotals[cat.id] ?? 0.0;
    final prevAmount = prevTotals[cat.id] ?? 0.0;

    if (curAmount == 0 && prevAmount == 0) continue;

    if (prevAmount > 0) {
      final change = ((curAmount - prevAmount) / prevAmount) * 100;
      if (change.abs() >= 5.0) {
        final isIncrease = change > 0;
        insights.add(
          SpendingInsight(
            categoryId: cat.id,
            categoryName: cat.name,
            icon: cat.icon,
            color: cat.color,
            percentageChange: change.abs(),
            isIncrease: isIncrease,
            text: isIncrease
                ? '${cat.name} spending increased ${change.toStringAsFixed(0)}% compared to last month.'
                : '${cat.name} spending decreased ${change.abs().toStringAsFixed(0)}% compared to last month.',
          ),
        );
      }
    } else if (curAmount > 0) {
      insights.add(
        SpendingInsight(
          categoryId: cat.id,
          categoryName: cat.name,
          icon: cat.icon,
          color: cat.color,
          percentageChange: 100.0,
          isIncrease: true,
          text: 'New spending recorded in ${cat.name} this month.',
        ),
      );
    }
  }

  insights.sort((a, b) => b.percentageChange.compareTo(a.percentageChange));
  return insights;
});
