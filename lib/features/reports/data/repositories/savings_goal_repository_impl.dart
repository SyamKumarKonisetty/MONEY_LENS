import 'package:drift/drift.dart';
import '../../domain/entities/savings_goal_entity.dart';
import '../../domain/repositories/savings_goal_repository.dart';
import '../models/savings_goal_model.dart';
import '../../../../core/database/app_database.dart';

class SavingsGoalRepositoryImpl implements SavingsGoalRepository {
  final AppDatabase _db;

  SavingsGoalRepositoryImpl(this._db);

  @override
  Future<SavingsGoalEntity?> getSavingsGoal(int month, int year) async {
    final query = _db.select(_db.savingsGoals)
      ..where((t) => t.month.equals(month) & t.year.equals(year));
    final row = await query.getSingleOrNull();
    return row != null ? SavingsGoalModel.fromDb(row) : null;
  }

  @override
  Stream<SavingsGoalEntity?> watchSavingsGoal(int month, int year) {
    final query = _db.select(_db.savingsGoals)
      ..where((t) => t.month.equals(month) & t.year.equals(year));
    return query.watchSingleOrNull().map((row) => row != null ? SavingsGoalModel.fromDb(row) : null);
  }

  @override
  Future<void> setSavingsGoal(SavingsGoalEntity goal) async {
    final existing = await getSavingsGoal(goal.month, goal.year);
    if (existing != null) {
      final updated = SavingsGoalModel.toCompanion(goal.copyWith(id: existing.id));
      await _db.update(_db.savingsGoals).replace(updated);
    } else {
      final inserted = SavingsGoalModel.toCompanion(goal);
      await _db.into(_db.savingsGoals).insert(inserted);
    }
  }
}
