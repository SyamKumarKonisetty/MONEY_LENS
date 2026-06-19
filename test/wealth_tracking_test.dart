import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_lens/features/reports/domain/entities/savings_goal_entity.dart';
import 'package:money_lens/features/reports/domain/repositories/savings_goal_repository.dart';
import 'package:money_lens/features/reports/presentation/providers/reports_provider.dart';
import 'package:money_lens/features/transactions/domain/models.dart';
import 'package:money_lens/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:money_lens/features/budget/presentation/providers/budget_provider.dart';

class FakeSavingsGoalRepository implements SavingsGoalRepository {
  final List<SavingsGoalEntity> _goals = [];
  final StreamController<SavingsGoalEntity?> _controller =
      StreamController<SavingsGoalEntity?>.broadcast();

  void _emit(int month, int year) {
    try {
      final match = _goals.firstWhere(
        (g) => g.month == month && g.year == year,
      );
      _controller.add(match);
    } catch (_) {
      _controller.add(null);
    }
  }

  @override
  Future<SavingsGoalEntity?> getSavingsGoal(int month, int year) async {
    try {
      return _goals.firstWhere((g) => g.month == month && g.year == year);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<SavingsGoalEntity?> watchSavingsGoal(int month, int year) {
    return _controller.stream;
  }

  @override
  Future<void> setSavingsGoal(SavingsGoalEntity goal) async {
    _goals.removeWhere((g) => g.month == goal.month && g.year == goal.year);
    _goals.add(goal);
    _emit(goal.month, goal.year);
  }
}

void main() {
  group('Phase 5 Wealth Tracking & Reports Tests', () {
    test('Saving and loading savings goals in repository', () async {
      final repository = FakeSavingsGoalRepository();
      final now = DateTime.now();

      // Verify initially null
      final initial = await repository.getSavingsGoal(now.month, now.year);
      expect(initial, isNull);

      // Save a new goal
      final target = SavingsGoalEntity(
        amount: 25000.0,
        month: now.month,
        year: now.year,
      );
      await repository.setSavingsGoal(target);

      // Load it back
      final saved = await repository.getSavingsGoal(now.month, now.year);
      expect(saved, isNotNull);
      expect(saved!.amount, 25000.0);
    });

    test(
      'Wealth Score calculation: High Savings Rate, Under Budget, Consistent Spending',
      () async {
        final now = DateTime.now();

        // Setup data:
        // Income = 100,000; Expenses = 65,000 (Savings = 35,000 -> Rate = 35% >= 30% -> Score = 100)
        // Overall budget = 70,000 (spent 65,000 <= 70,000 -> Adherence = 100)
        // Expenses: 4 items of ₹16,250 -> Max item is 25% of total -> Consistency = 100
        final mockTxs = [
          Transaction(
            id: 'inc',
            title: 'Salary',
            amount: 100000.0,
            date: now,
            categoryId: 'salary',
            type: TransactionType.income,
          ),
          Transaction(
            id: 'exp1',
            title: 'Rent',
            amount: 16250.0,
            date: now,
            categoryId: 'bills',
            type: TransactionType.expense,
          ),
          Transaction(
            id: 'exp2',
            title: 'Groceries',
            amount: 16250.0,
            date: now,
            categoryId: 'groceries',
            type: TransactionType.expense,
          ),
          Transaction(
            id: 'exp3',
            title: 'Shopping',
            amount: 16250.0,
            date: now,
            categoryId: 'shopping',
            type: TransactionType.expense,
          ),
          Transaction(
            id: 'exp4',
            title: 'Fuel',
            amount: 16250.0,
            date: now,
            categoryId: 'fuel',
            type: TransactionType.expense,
          ),
        ];

        final container = ProviderContainer(
          overrides: [
            allTransactionsProvider.overrideWithValue(mockTxs),
            currentMonthBudgetProvider.overrideWith(
              (ref) => Stream.value(70000.0),
            ),
            budgetSummaryProvider.overrideWithValue(
              BudgetSummary(
                totalLimit: 70000.0,
                totalSpent: 65000.0,
                totalRemaining: 5000.0,
                usagePercent: 92.85,
              ),
            ),
          ],
        );

        await container.read(currentMonthBudgetProvider.future);

        final summary = container.read(reportsSummaryProvider);
        expect(summary.income, 100000.0);
        expect(summary.expenses, 65000.0);
        expect(summary.savings, 35000.0);
        expect(summary.savingsRate, 35.0);

        final wealth = container.read(wealthScoreProvider);
        expect(wealth.savingsRateFactor, 100.0);
        expect(wealth.budgetAdherenceFactor, 100.0);
        expect(wealth.consistencyFactor, 100.0);
        expect(wealth.overallScore, 100.0);
      },
    );

    test(
      'Wealth Score calculation: Negative Savings Rate, Budget Exceeded, Spiky Spending',
      () async {
        final now = DateTime.now();

        // Setup data:
        // Income = 20,000; Expenses = 30,000 (Savings = -10,000 -> Rate = -50% <= 0% -> Score = 0)
        // Overall budget = 25,000 (spent 30,000 -> Adherence = 100 - (5000/25000)*100 = 80)
        // Expenses: 1 item of ₹25,000, 1 item of ₹5,000 -> Max item is 83.33% of total
        // dominantRatio = 0.8333 -> consistency = 100 - (0.8333 - 0.25)*100 = 41.67
        final mockTxs = [
          Transaction(
            id: 'inc',
            title: 'Part-time',
            amount: 20000.0,
            date: now,
            categoryId: 'freelance',
            type: TransactionType.income,
          ),
          Transaction(
            id: 'exp1',
            title: 'Laptop Buy',
            amount: 25000.0,
            date: now,
            categoryId: 'other',
            type: TransactionType.expense,
          ),
          Transaction(
            id: 'exp2',
            title: 'Dinner',
            amount: 5000.0,
            date: now,
            categoryId: 'food',
            type: TransactionType.expense,
          ),
        ];

        final container = ProviderContainer(
          overrides: [
            allTransactionsProvider.overrideWithValue(mockTxs),
            currentMonthBudgetProvider.overrideWith(
              (ref) => Stream.value(25000.0),
            ),
            budgetSummaryProvider.overrideWithValue(
              BudgetSummary(
                totalLimit: 25000.0,
                totalSpent: 30000.0,
                totalRemaining: -5000.0,
                usagePercent: 120.0,
              ),
            ),
          ],
        );

        await container.read(currentMonthBudgetProvider.future);

        final wealth = container.read(wealthScoreProvider);
        expect(wealth.savingsRateFactor, 0.0);
        expect(wealth.budgetAdherenceFactor, 80.0);
        expect(wealth.consistencyFactor, closeTo(41.67, 0.01));

        // overall = 0*0.4 + 80*0.4 + 41.67*0.2 = 32 + 8.33 = 40.33
        expect(wealth.overallScore, closeTo(40.33, 0.01));
      },
    );

    test('Spending Trends DoD/WoW/MoM/YoY calculations', () {
      final now = DateTime.now();
      final prevMonthDate = DateTime(now.year, now.month - 1, 15);

      // Current Month: Food = 3,000
      // Previous Month: Food = 1,500 (+100% increase)
      final mockTxs = [
        Transaction(
          id: 'exp1',
          title: 'Dinner',
          amount: 3000.0,
          date: now,
          categoryId: 'food',
          type: TransactionType.expense,
        ),
        Transaction(
          id: 'exp2',
          title: 'Dinner past',
          amount: 1500.0,
          date: prevMonthDate,
          categoryId: 'food',
          type: TransactionType.expense,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          allTransactionsProvider.overrideWithValue(mockTxs),
          reportsTimelineProvider.overrideWith(
            (ref) =>
                ReportsTimelineNotifier()..setPeriod(TimelinePeriod.thisMonth),
          ),
        ],
      );

      final trends = container.read(spendingTrendsProvider);
      expect(trends.isIncrease, isTrue);
      expect(trends.deltaAmount, 1500.0);
      expect(trends.totalChangePercent, 100.0);

      expect(trends.categoryDeltas.length, 1);
      final foodDelta = trends.categoryDeltas.firstWhere(
        (d) => d.category.id == 'food',
      );
      expect(foodDelta.delta, 1500.0);
      expect(foodDelta.percentChange, 100.0);
    });

    test('CSV export formatter string validation', () {
      final now = DateTime.now();
      final txs = [
        Transaction(
          id: '1',
          title: 'Swiggy Dinner',
          amount: 650.0,
          date: now,
          categoryId: 'food',
          type: TransactionType.expense,
          note: 'Delicious food',
        ),
      ];

      final buffer = StringBuffer();
      buffer.write('\uFEFF');
      buffer.writeln('Date,Type,Category,Title,Amount,Notes');

      for (final t in txs) {
        final dateStr = t.date.toIso8601String().split('T')[0];
        final typeStr = t.type.name.toUpperCase();
        final catStr = t.categoryId;
        final titleClean = t.title.replaceAll('"', '""');
        final notesClean = (t.note ?? '').replaceAll('"', '""');
        buffer.writeln(
          '$dateStr,$typeStr,$catStr,"$titleClean",${t.amount},"$notesClean"',
        );
      }

      final csvContent = buffer.toString();
      expect(
        csvContent,
        contains('\uFEFFDate,Type,Category,Title,Amount,Notes'),
      );
      expect(
        csvContent,
        contains('EXPENSE,food,"Swiggy Dinner",650.0,"Delicious food"'),
      );
    });
  });
}
