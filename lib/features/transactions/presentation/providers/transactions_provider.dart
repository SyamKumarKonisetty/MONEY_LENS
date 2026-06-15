import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';

/// Transaction filter options.
enum TransactionFilter { all, income, expense }

/// Transactions filter state notifier.
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
  final filter = ref.watch(transactionFilterProvider);
  final all = ref.watch(allTransactionsProvider);

  switch (filter) {
    case TransactionFilter.income:
      return all.where((t) => t.type.isIncome).toList();
    case TransactionFilter.expense:
      return all.where((t) => t.type.isExpense).toList();
    case TransactionFilter.all:
      return all;
  }
});

/// Transactions grouped by date string.
final groupedTransactionsProvider = Provider<Map<String, List<Transaction>>>((
  ref,
) {
  final transactions = ref.watch(filteredTransactionsProvider);
  final Map<String, List<Transaction>> grouped = {};

  for (final t in transactions) {
    final key = _formatDateKey(t.date);
    grouped.putIfAbsent(key, () => []).add(t);
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
