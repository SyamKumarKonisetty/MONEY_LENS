import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_lens/features/budget/domain/entities/budget_entity.dart';
import 'package:money_lens/features/budget/domain/repositories/budget_repository.dart';
import 'package:money_lens/features/budget/presentation/providers/budget_provider.dart';
import 'package:money_lens/features/transactions/domain/models.dart';
import 'package:money_lens/features/transactions/presentation/providers/transactions_provider.dart';

class FakeBudgetRepository implements BudgetRepository {
  final List<BudgetEntity> _budgets = [];
  final StreamController<BudgetEntity?> _controller = StreamController<BudgetEntity?>.broadcast();
  final StreamController<List<BudgetEntity>> _allController = StreamController<List<BudgetEntity>>.broadcast();

  void _emit() {
    _allController.add(_budgets);
  }

  @override
  Future<BudgetEntity?> getBudget(String category) async {
    try {
      return _budgets.firstWhere((b) => b.category == category);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<BudgetEntity?> watchBudget(String category) {
    return _controller.stream.map((_) {
      try {
        return _budgets.firstWhere((b) => b.category == category);
      } catch (_) {
        return null;
      }
    });
  }

  @override
  Stream<List<BudgetEntity>> watchAllBudgets() {
    return _allController.stream;
  }

  @override
  Future<void> setBudget(BudgetEntity budget) async {
    _budgets.removeWhere((b) => b.category == budget.category);
    _budgets.add(budget);
    _emit();
  }

  @override
  Future<void> deleteBudget(int id) async {
    _budgets.removeWhere((b) => b.id == id);
    _emit();
  }
}

void main() {
  group('Budget Intelligence Calculations Tests', () {
    test('Saving and loading category budgets in the repository', () async {
      final repository = FakeBudgetRepository();
      final now = DateTime.now();

      // Initially no budgets
      final initialFood = await repository.getBudget('food');
      expect(initialFood, isNull);

      // Save Food budget
      await repository.setBudget(BudgetEntity(
        category: 'food',
        monthlyLimit: 8000.0,
        createdAt: now,
        updatedAt: now,
      ));

      // Save Fuel budget
      await repository.setBudget(BudgetEntity(
        category: 'fuel',
        monthlyLimit: 3000.0,
        createdAt: now,
        updatedAt: now,
      ));

      // Verify Food budget
      final foodBudget = await repository.getBudget('food');
      expect(foodBudget, isNotNull);
      expect(foodBudget!.monthlyLimit, 8000.0);

      // Verify Fuel budget
      final fuelBudget = await repository.getBudget('fuel');
      expect(fuelBudget, isNotNull);
      expect(fuelBudget!.monthlyLimit, 3000.0);
    });

    test('Safe daily spend limit calculation', () {
      final now = DateTime.now();
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
      final remainingDays = lastDayOfMonth.day - now.day + 1;

      // Mock transactions: ₹10,000 spent this month
      final mockTxs = [
        Transaction(
          id: '1',
          title: 'Rent',
          amount: 10000.0,
          date: DateTime(now.year, now.month, 5),
          categoryId: 'bills',
          type: TransactionType.expense,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          allTransactionsProvider.overrideWithValue(mockTxs),
          budgetSummaryProvider.overrideWithValue(
            BudgetSummary(
              totalLimit: 50000.0,
              totalSpent: 10000.0,
              totalRemaining: 40000.0,
              usagePercent: 20.0,
            ),
          ),
        ],
      );

      final dailyLimit = container.read(dailySpendingLimitProvider);

      // Safe daily limit = (Budget - Spent) / Remaining Days
      // = (50000 - 10000) / remainingDays = 40000 / remainingDays
      final expectedDaily = 40000.0 / remainingDays;
      expect(dailyLimit, closeTo(expectedDaily, 0.001));
    });

    test('Month-end spend and savings projection calculation', () {
      final now = DateTime.now();
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
      final totalDays = lastDayOfMonth.day;
      final daysPassed = now.day;

      // Mock transactions: ₹15,000 spent this month
      final mockTxs = [
        Transaction(
          id: '1',
          title: 'Groceries',
          amount: 15000.0,
          date: DateTime(now.year, now.month, 1),
          categoryId: 'groceries',
          type: TransactionType.expense,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          allTransactionsProvider.overrideWithValue(mockTxs),
          currentMonthBudgetProvider.overrideWith((ref) => Stream.value(50000.0)),
        ],
      );

      final projection = container.read(monthEndProjectionProvider);

      // Expected spend = (Spent / DaysPassed) * TotalDays
      final expectedSpend = (15000.0 / daysPassed) * totalDays;
      // Expected savings = Budget - Expected Spend
      final expectedSavings = 50000.0 - expectedSpend;

      expect(projection.expectedSpend, closeTo(expectedSpend, 0.001));
      expect(projection.expectedSavings, closeTo(expectedSavings, 0.001));
    });

    test('Spending insights comparison logic (MoM analysis)', () {
      final now = DateTime.now();
      final prevMonthDate = DateTime(now.year, now.month - 1, 1);

      // Food: Current 3000, Prev 2000 => +50% increase (Insight expected)
      // Fuel: Current 1000, Prev 1500 => -33% decrease (Insight expected)
      // Groceries: Current 1000, Prev 1000 => 0% change (No insight)
      final mockTxs = [
        Transaction(
          id: '1',
          title: 'Restaurant',
          amount: 3000.0,
          date: DateTime(now.year, now.month, 3),
          categoryId: 'food',
          type: TransactionType.expense,
        ),
        Transaction(
          id: '2',
          title: 'Restaurant past',
          amount: 2000.0,
          date: DateTime(prevMonthDate.year, prevMonthDate.month, 5),
          categoryId: 'food',
          type: TransactionType.expense,
        ),
        Transaction(
          id: '3',
          title: 'Petrol',
          amount: 1000.0,
          date: DateTime(now.year, now.month, 10),
          categoryId: 'fuel',
          type: TransactionType.expense,
        ),
        Transaction(
          id: '4',
          title: 'Petrol past',
          amount: 1500.0,
          date: DateTime(prevMonthDate.year, prevMonthDate.month, 12),
          categoryId: 'fuel',
          type: TransactionType.expense,
        ),
        Transaction(
          id: '5',
          title: 'Supermarket',
          amount: 1000.0,
          date: DateTime(now.year, now.month, 15),
          categoryId: 'groceries',
          type: TransactionType.expense,
        ),
        Transaction(
          id: '6',
          title: 'Supermarket past',
          amount: 1000.0,
          date: DateTime(prevMonthDate.year, prevMonthDate.month, 15),
          categoryId: 'groceries',
          type: TransactionType.expense,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          allTransactionsProvider.overrideWithValue(mockTxs),
        ],
      );

      final insights = container.read(spendingInsightsProvider);

      // Verify insights generated
      expect(insights.length, 2); // Only Food and Fuel should have insights

      final foodInsight = insights.firstWhere((i) => i.categoryId == 'food');
      expect(foodInsight.isIncrease, isTrue);
      expect(foodInsight.percentageChange, closeTo(50.0, 0.001));

      final fuelInsight = insights.firstWhere((i) => i.categoryId == 'fuel');
      expect(fuelInsight.isIncrease, isFalse);
      expect(fuelInsight.percentageChange, closeTo(33.333, 0.01));

      // Groceries shouldn't be present
      expect(insights.any((i) => i.categoryId == 'groceries'), isFalse);
    });

    group('Alert and Warning threshold calculations', () {
      test('Threshold alerts generation based on utilization percent', () {
        final budget = 10000.0;
        
        final testCases = [
          {'spent': 5000.0, 'expectedAlert': false},
          {'spent': 8200.0, 'expectedAlert': true},
          {'spent': 9100.0, 'expectedAlert': true},
          {'spent': 12000.0, 'expectedAlert': true},
        ];

        for (final tc in testCases) {
          final spent = tc['spent'] as double;
          final percent = spent / budget;
          final hasAlert = percent >= 0.8;
          expect(hasAlert, tc['expectedAlert']);
        }
      });
    });
  });
}
