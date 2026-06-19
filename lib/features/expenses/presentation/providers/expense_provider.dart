import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../../../core/database/app_database.dart';

/// Presentation state for the Expenses feature.
class ExpenseState {
  final List<ExpenseEntity> expenses;
  final bool isLoading;

  ExpenseState({required this.expenses, this.isLoading = false});

  ExpenseState copyWith({List<ExpenseEntity>? expenses, bool? isLoading}) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier that manages expense tracking logic, handles database reactivity, and initial data seeding.
class ExpenseNotifier extends StateNotifier<ExpenseState> {
  final ExpenseRepository _repository;

  ExpenseNotifier(this._repository) : super(ExpenseState(expenses: [])) {
    _init();
  }

  void _init() {
    state = state.copyWith(isLoading: true);
    _repository.watchAllExpenses().listen((expenses) {
      state = ExpenseState(expenses: expenses, isLoading: false);
    });
  }

  /// Adds a new expense to local DB.
  Future<void> addExpense({
    required String title,
    required double amount,
    required String category,
    String? notes,
    String transactionType = 'expense',
    DateTime? createdAt,
  }) async {
    final now = DateTime.now();
    final expense = ExpenseEntity(
      title: title,
      amount: amount,
      category: category,
      notes: notes,
      createdAt: createdAt ?? now,
      updatedAt: now,
      transactionType: transactionType,
    );
    await _repository.addExpense(expense);
  }

  /// Updates an existing expense in DB.
  Future<void> updateExpense({
    required int id,
    required String title,
    required double amount,
    required String category,
    String? notes,
    String? transactionType,
  }) async {
    final original = state.expenses.cast<ExpenseEntity>().firstWhere(
      (e) => e.id == id,
      orElse: () => ExpenseEntity(
        id: id,
        title: title,
        amount: amount,
        category: category,
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    final expense = original.copyWith(
      title: title,
      amount: amount,
      category: category,
      notes: notes,
      transactionType: transactionType ?? original.transactionType,
      updatedAt: DateTime.now(),
    );
    await _repository.updateExpense(expense);
  }

  /// Deletes an expense from DB.
  Future<void> deleteExpense(int id) async {
    final updatedExpenses = state.expenses.where((e) => e.id != id).toList();
    state = state.copyWith(expenses: updatedExpenses);
    await _repository.deleteExpense(id);
  }
}

/// Provides the ExpenseRepository instance.
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl(AppDatabase.instance);
});

/// Provides the active ExpenseNotifier.
final expenseNotifierProvider =
    StateNotifierProvider<ExpenseNotifier, ExpenseState>((ref) {
      final repository = ref.watch(expenseRepositoryProvider);
      return ExpenseNotifier(repository);
    });
