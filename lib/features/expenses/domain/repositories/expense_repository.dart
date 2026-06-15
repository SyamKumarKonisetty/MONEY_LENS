import '../entities/expense_entity.dart';

/// Repository contract for Expense database operations.
abstract class ExpenseRepository {
  /// Fetches all expenses from local database.
  Future<List<ExpenseEntity>> getAllExpenses();

  /// Watch all expenses reactively via Stream.
  Stream<List<ExpenseEntity>> watchAllExpenses();

  /// Adds a new expense, returns the new record's ID.
  Future<int> addExpense(ExpenseEntity expense);

  /// Updates an existing expense record.
  Future<void> updateExpense(ExpenseEntity expense);

  /// Deletes an expense by its auto-increment ID.
  Future<void> deleteExpense(int id);
}
