import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../models/budget_model.dart';
import '../../../../core/database/app_database.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final AppDatabase _db;

  BudgetRepositoryImpl(this._db);

  @override
  Future<BudgetEntity?> getBudget(String category) async {
    final query = _db.select(_db.budgets)
      ..where((t) => t.category.equals(category));
    final row = await query.getSingleOrNull();
    return row != null ? BudgetModel.fromDb(row) : null;
  }

  @override
  Stream<BudgetEntity?> watchBudget(String category) {
    final query = _db.select(_db.budgets)
      ..where((t) => t.category.equals(category));
    return query.watchSingleOrNull().map((row) => row != null ? BudgetModel.fromDb(row) : null);
  }

  @override
  Stream<List<BudgetEntity>> watchAllBudgets() {
    final query = _db.select(_db.budgets);
    return query.watch().map((rows) => rows.map((r) => BudgetModel.fromDb(r)).toList());
  }

  @override
  Future<void> setBudget(BudgetEntity budget) async {
    final existing = await getBudget(budget.category);
    if (existing != null) {
      final updated = BudgetModel.toCompanion(budget.copyWith(
        id: existing.id,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      ));
      await _db.update(_db.budgets).replace(updated);
    } else {
      final inserted = BudgetModel.toCompanion(budget.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      await _db.into(_db.budgets).insert(inserted);
    }
  }

  @override
  Future<void> deleteBudget(int id) async {
    await (_db.delete(_db.budgets)..where((t) => t.id.equals(id))).go();
  }
}
