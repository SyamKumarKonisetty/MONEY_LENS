import 'package:drift/drift.dart';
import '../../domain/entities/budget_entity.dart';
import '../../../../core/database/app_database.dart';

class BudgetModel extends BudgetEntity {
  const BudgetModel({
    super.id,
    required super.category,
    required super.monthlyLimit,
    super.spentAmount = 0.0,
    super.remainingAmount = 0.0,
    required super.createdAt,
    required super.updatedAt,
    super.period = 'monthly',
    super.isEnabled = true,
    super.isArchived = false,
  });

  factory BudgetModel.fromDb(Budget row) {
    return BudgetModel(
      id: row.id,
      category: row.category,
      monthlyLimit: row.monthlyLimit,
      spentAmount: row.spentAmount,
      remainingAmount: row.remainingAmount,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      period: row.period,
      isEnabled: row.isEnabled,
      isArchived: row.isArchived,
    );
  }

  static BudgetsCompanion toCompanion(BudgetEntity entity) {
    return BudgetsCompanion(
      id: entity.id == null ? const Value.absent() : Value(entity.id!),
      category: Value(entity.category),
      monthlyLimit: Value(entity.monthlyLimit),
      spentAmount: Value(entity.spentAmount),
      remainingAmount: Value(entity.remainingAmount),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      period: Value(entity.period),
      isEnabled: Value(entity.isEnabled),
      isArchived: Value(entity.isArchived),
    );
  }
}
