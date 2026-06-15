import 'package:drift/drift.dart';
import '../../domain/entities/savings_goal_entity.dart';
import '../../../../core/database/app_database.dart';

class SavingsGoalModel extends SavingsGoalEntity {
  const SavingsGoalModel({
    super.id,
    required super.amount,
    required super.month,
    required super.year,
  });

  factory SavingsGoalModel.fromDb(SavingsGoal row) {
    return SavingsGoalModel(
      id: row.id,
      amount: row.amount,
      month: row.month,
      year: row.year,
    );
  }

  static SavingsGoalsCompanion toCompanion(SavingsGoalEntity entity) {
    return SavingsGoalsCompanion(
      id: entity.id == null ? const Value.absent() : Value(entity.id!),
      amount: Value(entity.amount),
      month: Value(entity.month),
      year: Value(entity.year),
    );
  }
}
