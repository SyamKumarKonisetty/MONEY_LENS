import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_lens/features/expenses/domain/entities/expense_entity.dart';
import 'package:money_lens/features/expenses/domain/repositories/expense_repository.dart';
import 'package:money_lens/features/expenses/presentation/providers/expense_provider.dart';
import 'package:money_lens/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:money_lens/features/settings/presentation/providers/settings_provider.dart';
import 'package:money_lens/features/dashboard/presentation/widgets/quick_add_section.dart';

/// Fake repository for testing.
class FakeExpenseRepository implements ExpenseRepository {
  final List<ExpenseEntity> _items = [];
  final StreamController<List<ExpenseEntity>> _controller = StreamController<List<ExpenseEntity>>.broadcast();

  FakeExpenseRepository() {
    _emit();
  }

  void _emit() {
    _controller.add(List.unmodifiable(_items));
  }

  @override
  Future<List<ExpenseEntity>> getAllExpenses() async => List.unmodifiable(_items);

  @override
  Stream<List<ExpenseEntity>> watchAllExpenses() => _controller.stream;

  @override
  Future<int> addExpense(ExpenseEntity expense) async {
    final newItem = expense.id == null 
        ? expense.copyWith(id: _items.length + 1)
        : expense;
    _items.add(newItem);
    _emit();
    return newItem.id!;
  }

  @override
  Future<void> updateExpense(ExpenseEntity expense) async {
    final idx = _items.indexWhere((item) => item.id == expense.id);
    if (idx != -1) {
      _items[idx] = expense;
      _emit();
    }
  }

  @override
  Future<void> deleteExpense(int id) async {
    _items.removeWhere((item) => item.id == id);
    _emit();
  }
}

void main() {
  test('Dashboard calculations validation: Income & Expense changes', () async {
    SharedPreferences.setMockInitialValues({'db_seeded': true});
    final prefs = await SharedPreferences.getInstance();
    final fakeRepo = FakeExpenseRepository();

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        expenseRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );

    // Initial states should be 0
    expect(container.read(currentMonthIncomeProvider), 0.0);
    expect(container.read(currentMonthExpensesProvider), 0.0);
    expect(container.read(currentMonthNetBalanceProvider), 0.0);

    // Add Income ₹1000
    await container.read(expenseNotifierProvider.notifier).addExpense(
      title: 'Salary',
      amount: 1000.0,
      category: 'Freelance',
      transactionType: 'income',
    );

    // Dashboard Income must increase by ₹1000
    // Dashboard Expense must remain unchanged
    expect(container.read(currentMonthIncomeProvider), 1000.0);
    expect(container.read(currentMonthExpensesProvider), 0.0);
    expect(container.read(currentMonthNetBalanceProvider), 1000.0);

    // Add Expense ₹500
    await container.read(expenseNotifierProvider.notifier).addExpense(
      title: 'Lunch',
      amount: 500.0,
      category: 'Food',
      transactionType: 'expense',
    );

    // Dashboard Expense must increase by ₹500
    // Dashboard Income must remain unchanged
    expect(container.read(currentMonthIncomeProvider), 1000.0);
    expect(container.read(currentMonthExpensesProvider), 500.0);
    expect(container.read(currentMonthNetBalanceProvider), 500.0);
  });

  test('Edit/update operations preserve transaction type', () async {
    SharedPreferences.setMockInitialValues({'db_seeded': true});
    final prefs = await SharedPreferences.getInstance();
    final fakeRepo = FakeExpenseRepository();

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        expenseRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );

    // Add an income transaction
    await container.read(expenseNotifierProvider.notifier).addExpense(
      title: 'Salary',
      amount: 1000.0,
      category: 'Freelance',
      transactionType: 'income',
    );

    // Check it's registered as income
    var txs = container.read(expenseNotifierProvider).expenses;
    expect(txs.length, 1);
    expect(txs.first.transactionType, 'income');

    // Update the transaction details but NOT type
    await container.read(expenseNotifierProvider.notifier).updateExpense(
      id: txs.first.id!,
      title: 'Freelance Work',
      amount: 1200.0,
      category: 'Freelance',
    );

    // Verify type is preserved as income, and details updated
    txs = container.read(expenseNotifierProvider).expenses;
    expect(txs.first.title, 'Freelance Work');
    expect(txs.first.amount, 1200.0);
    expect(txs.first.transactionType, 'income');
    expect(container.read(currentMonthIncomeProvider), 1200.0);
    expect(container.read(currentMonthExpensesProvider), 0.0);
  });

  test('Delete operations update correct totals', () async {
    SharedPreferences.setMockInitialValues({'db_seeded': true});
    final prefs = await SharedPreferences.getInstance();
    final fakeRepo = FakeExpenseRepository();

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        expenseRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );

    // Add Income ₹1000
    await container.read(expenseNotifierProvider.notifier).addExpense(
      title: 'Salary',
      amount: 1000.0,
      category: 'Freelance',
      transactionType: 'income',
    );

    // Add Expense ₹500
    await container.read(expenseNotifierProvider.notifier).addExpense(
      title: 'Lunch',
      amount: 500.0,
      category: 'Food',
      transactionType: 'expense',
    );

    // Verify initial totals
    expect(container.read(currentMonthIncomeProvider), 1000.0);
    expect(container.read(currentMonthExpensesProvider), 500.0);

    // Delete the expense
    final expenseId = container.read(expenseNotifierProvider).expenses.firstWhere((e) => e.transactionType == 'expense').id!;
    await container.read(expenseNotifierProvider.notifier).deleteExpense(expenseId);

    // Verify expense is removed, totals are updated
    expect(container.read(currentMonthIncomeProvider), 1000.0);
    expect(container.read(currentMonthExpensesProvider), 0.0);
    expect(container.read(currentMonthNetBalanceProvider), 1000.0);
  });

  test('quickAddCategoriesProvider dynamically sorts by usage frequency', () async {
    SharedPreferences.setMockInitialValues({'db_seeded': true});
    final prefs = await SharedPreferences.getInstance();
    final fakeRepo = FakeExpenseRepository();

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        expenseRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );

    // Initial order should be the default: food, fuel, groceries, transport, entertainment, bills
    var categories = container.read(quickAddCategoriesProvider);
    expect(categories[0].id, 'food');
    expect(categories[1].id, 'fuel');

    // Add an entertainment transaction (making it the most-used category)
    await container.read(expenseNotifierProvider.notifier).addExpense(
      title: 'Movie',
      amount: 300.0,
      category: 'Entertainment',
      transactionType: 'expense',
    );

    // Wait a tick for stream emission
    await Future<void>.delayed(Duration.zero);

    // Entertainment should now be at index 0 because it has 1 usage while others have 0
    categories = container.read(quickAddCategoriesProvider);
    expect(categories[0].id, 'entertainment');

    // Add two fuel transactions
    await container.read(expenseNotifierProvider.notifier).addExpense(
      title: 'Petrol',
      amount: 500.0,
      category: 'Fuel',
      transactionType: 'expense',
    );
    await container.read(expenseNotifierProvider.notifier).addExpense(
      title: 'Diesel',
      amount: 1000.0,
      category: 'Fuel',
      transactionType: 'expense',
    );
    await Future<void>.delayed(Duration.zero);

    // Fuel should now be at index 0 (2 usages) and Entertainment at index 1 (1 usage)
    categories = container.read(quickAddCategoriesProvider);
    expect(categories[0].id, 'fuel');
    expect(categories[1].id, 'entertainment');
  });
}
