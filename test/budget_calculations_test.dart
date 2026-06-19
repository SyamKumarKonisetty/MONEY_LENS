import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_lens/features/budget/domain/entities/budget_entity.dart';
import 'package:money_lens/features/budget/domain/repositories/budget_repository.dart';
import 'package:money_lens/features/budget/presentation/providers/budget_provider.dart';

class FakeBudgetRepository implements BudgetRepository {
  final List<BudgetEntity> _budgets = [];
  final StreamController<BudgetEntity?> _controller =
      StreamController<BudgetEntity?>.broadcast();
  final StreamController<List<BudgetEntity>> _allController =
      StreamController<List<BudgetEntity>>.broadcast();

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
  test(
    'Budget calculations validation: set and update monthly budget',
    () async {
      final fakeRepo = FakeBudgetRepository();
      final container = ProviderContainer(
        overrides: [budgetRepositoryProvider.overrideWithValue(fakeRepo)],
      );

      // Initial state should be loading
      expect(
        container.read(budgetNotifierProvider),
        const AsyncValue<List<BudgetEntity>>.loading(),
      );

      // Watch the notifier to kickstart listening
      final subscription = container.listen(
        budgetNotifierProvider,
        (previous, next) {},
      );

      // Set budget amount to ₹45,000 for Food
      await container
          .read(budgetNotifierProvider.notifier)
          .setBudget('food', 45000.0);

      // Wait a brief tick for stream emission
      await Future<void>.delayed(Duration.zero);

      // Verify budget is successfully set
      final budgetState = container.read(budgetNotifierProvider).value;
      expect(budgetState, isNotNull);
      expect(budgetState!.length, 1);
      expect(budgetState.first.category, 'food');
      expect(budgetState.first.monthlyLimit, 45000.0);

      // Update budget amount to ₹60,000
      await container
          .read(budgetNotifierProvider.notifier)
          .setBudget('food', 60000.0);
      await Future<void>.delayed(Duration.zero);

      // Verify updated budget value
      final updatedState = container.read(budgetNotifierProvider).value;
      expect(updatedState!.first.monthlyLimit, 60000.0);

      subscription.close();
    },
  );
}
