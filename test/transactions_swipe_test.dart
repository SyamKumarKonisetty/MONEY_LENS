import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_lens/core/database/app_database.dart';
import 'package:money_lens/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:money_lens/features/expenses/domain/entities/expense_entity.dart';
import 'package:money_lens/features/expenses/presentation/providers/expense_provider.dart';
import 'package:money_lens/features/settings/presentation/providers/settings_provider.dart';
import 'package:money_lens/features/transactions/presentation/transactions_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TransactionsScreen Swipe Delete Integration Tests', () {
    late AppDatabase db;
    late ExpenseRepositoryImpl repository;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repository = ExpenseRepositoryImpl(db);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets(
      'Swiping a transaction card executes delete in DB and updates UI',
      (WidgetTester tester) async {
        // 1. Prepare SharedPreferences with seeding enabled (meaning we mock it as already seeded so it doesn't auto-seed on empty db)
        SharedPreferences.setMockInitialValues({'db_seeded': true});
        final prefs = await SharedPreferences.getInstance();

        // 2. Insert one test transaction
        final expense = ExpenseEntity(
          title: 'Swipe Test Item',
          amount: 250.0,
          category: 'Food',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          transactionType: 'expense',
        );
        final id = await repository.addExpense(expense);
        expect(id, greaterThan(0));

        // 3. Render TransactionsScreen in isolation
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(prefs),
              expenseRepositoryProvider.overrideWithValue(repository),
            ],
            child: const MaterialApp(
              home: Scaffold(body: TransactionsScreen()),
            ),
          ),
        );

        // Wait for the stream initialization to complete and show the item
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));

        // 4. Verify transaction tile is visible
        expect(find.text('Swipe Test Item'), findsOneWidget);

        // 5. Perform swipe-to-delete (endToStart means from right to left)
        final dismissibleFinder = find.byType(Dismissible);
        expect(dismissibleFinder, findsOneWidget);

        await tester.drag(dismissibleFinder, const Offset(-500.0, 0.0));
        await tester.pump();
        for (int i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        // 6. Verify visual item is gone
        expect(find.text('Swipe Test Item'), findsNothing);

        // 7. Verify database entry is deleted
        final listAfter = await repository.getAllExpenses();
        expect(listAfter.any((e) => e.id == id), isFalse);
      },
    );
  });
}
