import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';

/// Transaction filter options.
enum TransactionFilter { all, income, expense }

/// Transaction sort options.
enum TransactionSort { newest, oldest, amountHighToLow, amountLowToHigh }

/// Transaction date filter options.
enum TransactionDateFilter { all, today, week, month }

/// Transactions search query provider.
final transactionSearchQueryProvider = StateProvider<String>((ref) => '');

/// Transactions sort provider.
final transactionSortProvider = StateProvider<TransactionSort>(
  (ref) => TransactionSort.newest,
);

/// Transactions date range filter provider.
final transactionDateFilterProvider = StateProvider<TransactionDateFilter>(
  (ref) => TransactionDateFilter.all,
);

/// Transactions category filter provider.
final transactionCategoryFilterProvider = StateProvider<String?>((ref) => null);

/// Transactions type filter state notifier.
class TransactionFilterNotifier extends StateNotifier<TransactionFilter> {
  TransactionFilterNotifier() : super(TransactionFilter.all);

  void setFilter(TransactionFilter filter) => state = filter;
}

/// Active filter provider.
final transactionFilterProvider =
    StateNotifierProvider<TransactionFilterNotifier, TransactionFilter>((ref) {
      return TransactionFilterNotifier();
    });

/// All transactions provider (unfiltered).
final allTransactionsProvider = Provider<List<Transaction>>((ref) {
  final expenseState = ref.watch(expenseNotifierProvider);
  return expenseState.expenses.map((e) {
    return Transaction(
      id: e.id.toString(),
      title: e.title,
      amount: e.amount,
      type: e.transactionType == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      categoryId: e.category.toLowerCase(),
      date: e.createdAt,
      note: e.notes,
    );
  }).toList();
});

/// Filtered transactions based on active filter.
final filteredTransactionsProvider = Provider<List<Transaction>>((ref) {
  final all = ref.watch(allTransactionsProvider);
  final typeFilter = ref.watch(transactionFilterProvider);
  final searchQuery = ref
      .watch(transactionSearchQueryProvider)
      .trim()
      .toLowerCase();
  final dateFilter = ref.watch(transactionDateFilterProvider);
  final categoryFilter = ref.watch(transactionCategoryFilterProvider);
  final sort = ref.watch(transactionSortProvider);

  List<Transaction> list = [...all];

  // 1. Filter by type
  if (typeFilter == TransactionFilter.income) {
    list = list.where((t) => t.type.isIncome).toList();
  } else if (typeFilter == TransactionFilter.expense) {
    list = list.where((t) => t.type.isExpense).toList();
  }

  // 2. Filter by search query
  if (searchQuery.isNotEmpty) {
    list = list.where((t) {
      final titleMatch = t.title.toLowerCase().contains(searchQuery);
      final categoryMatch = t.categoryId.toLowerCase().contains(searchQuery);
      final noteMatch = t.note?.toLowerCase().contains(searchQuery) ?? false;
      return titleMatch || categoryMatch || noteMatch;
    }).toList();
  }

  // 3. Filter by date range
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  if (dateFilter == TransactionDateFilter.today) {
    list = list.where((t) {
      final txDate = DateTime(t.date.year, t.date.month, t.date.day);
      return txDate == today;
    }).toList();
  } else if (dateFilter == TransactionDateFilter.week) {
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    list = list.where((t) {
      return t.date.isAfter(startOfWeek.subtract(const Duration(seconds: 1)));
    }).toList();
  } else if (dateFilter == TransactionDateFilter.month) {
    list = list.where((t) {
      return t.date.year == now.year && t.date.month == now.month;
    }).toList();
  }

  // 4. Filter by category
  if (categoryFilter != null) {
    list = list
        .where(
          (t) => t.categoryId.toLowerCase() == categoryFilter.toLowerCase(),
        )
        .toList();
  }

  // 5. Sort list
  switch (sort) {
    case TransactionSort.newest:
      list.sort((a, b) => b.date.compareTo(a.date));
      break;
    case TransactionSort.oldest:
      list.sort((a, b) => a.date.compareTo(b.date));
      break;
    case TransactionSort.amountHighToLow:
      list.sort((a, b) => b.amount.compareTo(a.amount));
      break;
    case TransactionSort.amountLowToHigh:
      list.sort((a, b) => a.amount.compareTo(b.amount));
      break;
  }

  return list;
});

/// Transactions grouped by date string (or amount header if sorted by amount).
final groupedTransactionsProvider = Provider<Map<String, List<Transaction>>>((
  ref,
) {
  final transactions = ref.watch(filteredTransactionsProvider);
  final sort = ref.watch(transactionSortProvider);
  final Map<String, List<Transaction>> grouped = {};

  if (sort == TransactionSort.amountHighToLow) {
    if (transactions.isNotEmpty) {
      grouped['Highest Amount'] = transactions;
    }
  } else if (sort == TransactionSort.amountLowToHigh) {
    if (transactions.isNotEmpty) {
      grouped['Lowest Amount'] = transactions;
    }
  } else {
    for (final t in transactions) {
      final key = _formatDateKey(t.date);
      grouped.putIfAbsent(key, () => []).add(t);
    }
  }

  return grouped;
});

String _formatDateKey(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final txDate = DateTime(date.year, date.month, date.day);

  if (txDate == today) return 'Today';
  if (txDate == yesterday) return 'Yesterday';

  const months = [
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
  return '${date.day} ${months[date.month - 1]}, ${date.year}';
}

/// Provides the list of recently/most used categories based on history.
final recentlyUsedCategoriesProvider = Provider<List<Category>>((ref) {
  final all = ref.watch(allTransactionsProvider);
  if (all.isEmpty) return [];

  // Count category usage frequencies
  final frequencies = <String, int>{};
  for (final t in all) {
    frequencies[t.categoryId] = (frequencies[t.categoryId] ?? 0) + 1;
  }

  // Sort by frequency (descending)
  final sortedCategoryIds = frequencies.keys.toList()
    ..sort((a, b) => frequencies[b]!.compareTo(frequencies[a]!));

  // Map to UI Category entities
  return sortedCategoryIds.map((id) => AppCategories.findById(id)).toList();
});
