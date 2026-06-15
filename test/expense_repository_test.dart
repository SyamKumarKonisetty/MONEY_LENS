import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_lens/core/database/app_database.dart';
import 'package:money_lens/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:money_lens/features/expenses/domain/entities/expense_entity.dart';
import 'package:money_lens/features/expenses/presentation/providers/expense_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Drift SQLite Database Persistence & Deletion Tests', () {
    late AppDatabase db;
    late ExpenseRepositoryImpl repository;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repository = ExpenseRepositoryImpl(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('Inserting, querying, and deleting an expense in SQLite', () async {
      final expense = ExpenseEntity(
        title: 'Test Expense',
        amount: 125.50,
        category: 'Food',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        transactionType: 'expense',
      );

      // 1. Add expense
      final insertedId = await repository.addExpense(expense);
      expect(insertedId, greaterThan(0));

      // 2. Query all expenses and verify it exists
      final listBefore = await repository.getAllExpenses();
      expect(listBefore.any((e) => e.id == insertedId), isTrue);

      // 3. Delete expense
      await repository.deleteExpense(insertedId);

      // 4. Query all expenses and verify it is gone
      final listAfter = await repository.getAllExpenses();
      expect(listAfter.any((e) => e.id == insertedId), isFalse);
    });

    test('ExpenseNotifier seeds, deletes, and updates state reactively', () async {
      SharedPreferences.setMockInitialValues({'db_seeded': true});
      final prefs = await SharedPreferences.getInstance();
      
      final notifier = ExpenseNotifier(repository, prefs);
      
      // Wait for initialization and stream listener
      await Future<void>.delayed(const Duration(milliseconds: 50));
      
      // Verify initial state is empty because db_seeded is true and database is empty
      expect(notifier.state.expenses, isEmpty);
      
      // Add an expense through notifier
      await notifier.addExpense(
        title: 'Snacks',
        amount: 15.0,
        category: 'Food',
      );
      
      // Wait for stream to emit and notifier to process
      await Future<void>.delayed(const Duration(milliseconds: 50));
      
      expect(notifier.state.expenses.length, 1);
      final expenseId = notifier.state.expenses.first.id!;
      
      // Delete the expense
      await notifier.deleteExpense(expenseId);
      
      // Wait for stream to emit and notifier to process
      await Future<void>.delayed(const Duration(milliseconds: 50));
      
      expect(notifier.state.expenses, isEmpty);
    });
  });
}
