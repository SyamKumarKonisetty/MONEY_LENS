import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../models/expense_model.dart';

/// SQLite implementation of the [ExpenseRepository] contract using Drift database instance.
class ExpenseRepositoryImpl implements ExpenseRepository {
  final AppDatabase _db;

  ExpenseRepositoryImpl(this._db);

  @override
  Future<List<ExpenseEntity>> getAllExpenses() async {
    final rows = await _db.select(_db.expenses).get();
    return rows.map((row) => ExpenseModel.fromDb(row)).toList();
  }

  @override
  Stream<List<ExpenseEntity>> watchAllExpenses() {
    return (_db.select(_db.expenses)..orderBy([
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]))
        .watch()
        .map((rows) => rows.map((row) => ExpenseModel.fromDb(row)).toList());
  }

  @override
  Future<int> addExpense(ExpenseEntity expense) {
    return _db.into(_db.expenses).insert(ExpenseModel.toCompanion(expense));
  }

  @override
  Future<void> updateExpense(ExpenseEntity expense) {
    return _db.update(_db.expenses).replace(ExpenseModel.toCompanion(expense));
  }

  @override
  Future<void> deleteExpense(int id) async {
    debugPrint('Executing DB delete query for id: $id');
    final rowsAffected = await (_db.delete(_db.expenses)..where((t) => t.id.equals(id))).go();
    debugPrint('DB delete query executed. Rows affected: $rowsAffected');
  }
}
