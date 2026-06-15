import '../entities/budget_entity.dart';

abstract class BudgetRepository {
  Future<BudgetEntity?> getBudget(String category);
  Stream<BudgetEntity?> watchBudget(String category);
  Stream<List<BudgetEntity>> watchAllBudgets();
  Future<void> setBudget(BudgetEntity budget);
  Future<void> deleteBudget(int id);
}
