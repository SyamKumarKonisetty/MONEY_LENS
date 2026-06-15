import 'package:drift/drift.dart';
import '../../domain/entities/expense_entity.dart';
import '../../../../core/database/app_database.dart';

/// Data model representing an SQLite Expense row, mapping domain entity to database.
class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    super.id,
    required super.title,
    required super.amount,
    required super.category,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
    super.transactionType,
  });

  /// Factory constructor to convert from SQLite database row object [Expense] to [ExpenseModel].
  factory ExpenseModel.fromDb(Expense row) {
    return ExpenseModel(
      id: row.id,
      title: row.title,
      amount: row.amount,
      category: row.category,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      transactionType: row.transactionType,
    );
  }

  /// Converts an [ExpenseEntity] into a Drift database table companion [ExpensesCompanion].
  static ExpensesCompanion toCompanion(ExpenseEntity entity) {
    return ExpensesCompanion(
      id: entity.id == null ? const Value.absent() : Value(entity.id!),
      title: Value(entity.title),
      amount: Value(entity.amount),
      category: Value(entity.category),
      notes: Value(entity.notes),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      transactionType: Value(entity.transactionType),
    );
  }
}
