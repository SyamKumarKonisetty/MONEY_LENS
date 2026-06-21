import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../transactions/domain/models.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';

/// Provides the 5 most recent transactions for the dashboard.
final recentTransactionsProvider = Provider<List<Transaction>>((ref) {
  final all = ref.watch(allTransactionsProvider);
  return all.take(5).toList();
});

/// Provides current month's total expenses.
final currentMonthExpensesProvider = Provider<double>((ref) {
  final all = ref.watch(allTransactionsProvider);
  final now = DateTime.now();
  return all
      .where(
        (t) =>
            t.date.year == now.year &&
            t.date.month == now.month &&
            t.type == TransactionType.expense,
      )
      .fold(0.0, (sum, t) => sum + t.amount);
});

/// Provides current month's total income.
final currentMonthIncomeProvider = Provider<double>((ref) {
  final all = ref.watch(allTransactionsProvider);
  final now = DateTime.now();
  return all
      .where(
        (t) =>
            t.date.year == now.year &&
            t.date.month == now.month &&
            t.type == TransactionType.income,
      )
      .fold(0.0, (sum, t) => sum + t.amount);
});

/// Provides current month's net balance.
final currentMonthNetBalanceProvider = Provider<double>((ref) {
  final income = ref.watch(currentMonthIncomeProvider);
  final expenses = ref.watch(currentMonthExpensesProvider);
  return income - expenses;
});

/// Provides the total transactions count in the database.
final totalTransactionsCountProvider = Provider<int>((ref) {
  final all = ref.watch(allTransactionsProvider);
  return all.length;
});

/// Provides the top spending category name (expenses only).
final topSpendingCategoryProvider = Provider<String>((ref) {
  final all = ref.watch(allTransactionsProvider);
  final expenses = all.where((t) => t.type == TransactionType.expense).toList();
  if (expenses.isEmpty) return 'None';

  final categoryTotals = <String, double>{};
  for (final t in expenses) {
    final categoryName = AppCategories.findById(t.categoryId).name;
    categoryTotals[categoryName] =
        (categoryTotals[categoryName] ?? 0.0) + t.amount;
  }

  var topCat = 'None';
  var maxVal = -1.0;
  categoryTotals.forEach((cat, total) {
    if (total > maxVal) {
      maxVal = total;
      topCat = cat;
    }
  });

  return topCat;
});

/// Provides today's total expenses.
final spentTodayProvider = Provider<double>((ref) {
  final all = ref.watch(allTransactionsProvider);
  final now = DateTime.now();
  return all
      .where(
        (t) =>
            t.date.year == now.year &&
            t.date.month == now.month &&
            t.date.day == now.day &&
            t.type == TransactionType.expense,
      )
      .fold(0.0, (sum, t) => sum + t.amount);
});

/// Provides today's transactions count.
final transactionsCountTodayProvider = Provider<int>((ref) {
  final all = ref.watch(allTransactionsProvider);
  final now = DateTime.now();
  return all
      .where(
        (t) =>
            t.date.year == now.year &&
            t.date.month == now.month &&
            t.date.day == now.day,
      )
      .length;
});

/// Provides today's top spending category name.
final topCategoryTodayProvider = Provider<String>((ref) {
  final all = ref.watch(allTransactionsProvider);
  final now = DateTime.now();
  final todayExpenses = all
      .where(
        (t) =>
            t.date.year == now.year &&
            t.date.month == now.month &&
            t.date.day == now.day &&
            t.type == TransactionType.expense,
      )
      .toList();
  if (todayExpenses.isEmpty) return 'None';

  final categoryTotals = <String, double>{};
  for (final t in todayExpenses) {
    final categoryName = AppCategories.findById(t.categoryId).name;
    categoryTotals[categoryName] =
        (categoryTotals[categoryName] ?? 0.0) + t.amount;
  }

  var topCat = 'None';
  var maxVal = -1.0;
  categoryTotals.forEach((cat, total) {
    if (total > maxVal) {
      maxVal = total;
      topCat = cat;
    }
  });

  return topCat;
});

/// Provider that returns the default 6 categories sorted by frequency of use.
final quickAddCategoriesProvider = Provider<List<Category>>((ref) {
  final recentlyUsed = ref.watch(recentlyUsedCategoriesProvider);

  // The default 6 categories requested
  final defaultIds = [
    'food',
    'fuel',
    'groceries',
    'transport',
    'entertainment',
    'bills',
  ];

  // Sort the defaultIds based on their index in recentlyUsed list.
  final sortedIds = List<String>.from(defaultIds);
  sortedIds.sort((a, b) {
    final indexA = recentlyUsed.indexWhere((c) => c.id == a);
    final indexB = recentlyUsed.indexWhere((c) => c.id == b);

    if (indexA != -1 && indexB != -1) {
      return indexA.compareTo(indexB);
    }
    if (indexA != -1) return -1;
    if (indexB != -1) return 1;
    return defaultIds.indexOf(a).compareTo(defaultIds.indexOf(b));
  });

  return sortedIds.map((id) => AppCategories.findById(id)).toList();
});
