import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_lens/main.dart';
import 'package:money_lens/features/settings/presentation/providers/settings_provider.dart';
import 'package:money_lens/features/expenses/domain/entities/expense_entity.dart';
import 'package:money_lens/features/expenses/domain/repositories/expense_repository.dart';
import 'package:money_lens/features/expenses/presentation/providers/expense_provider.dart';

import 'package:money_lens/features/budget/domain/entities/budget_entity.dart';
import 'package:money_lens/features/budget/domain/repositories/budget_repository.dart';
import 'package:money_lens/features/budget/presentation/providers/budget_provider.dart';

/// Fake repository for widget testing to avoid Drift SQLite background thread issues.
class FakeExpenseRepository implements ExpenseRepository {
  @override
  Future<List<ExpenseEntity>> getAllExpenses() async => [];

  @override
  Stream<List<ExpenseEntity>> watchAllExpenses() => Stream.value([]);

  @override
  Future<int> addExpense(ExpenseEntity expense) async => 1;

  @override
  Future<void> updateExpense(ExpenseEntity expense) async {}

  @override
  Future<void> deleteExpense(int id) async {}
}

class FakeBudgetRepository implements BudgetRepository {
  @override
  Future<BudgetEntity?> getBudget(String category) async => null;

  @override
  Stream<BudgetEntity?> watchBudget(String category) => Stream.value(null);

  @override
  Stream<List<BudgetEntity>> watchAllBudgets() => Stream.value([]);

  @override
  Future<void> setBudget(BudgetEntity budget) async {}

  @override
  Future<void> deleteBudget(int id) async {}
}

void main() {
  testWidgets('MoneyLens app smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          expenseRepositoryProvider.overrideWithValue(FakeExpenseRepository()),
          budgetRepositoryProvider.overrideWithValue(FakeBudgetRepository()),
        ],
        child: const MoneyLensApp(),
      ),
    );

    // Verify the app renders without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
