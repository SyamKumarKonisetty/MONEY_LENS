import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../../../core/database/app_database.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

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
  final SharedPreferences _prefs;

  static const String _seedKey = 'db_seeded';

  ExpenseNotifier(this._repository, this._prefs)
    : super(ExpenseState(expenses: [])) {
    _init();
  }

  void _init() {
    state = state.copyWith(isLoading: true);
    _repository.watchAllExpenses().listen((expenses) async {
      final wasSeeded = _prefs.getBool(_seedKey) ?? false;
      if (expenses.isEmpty && !wasSeeded) {
        await _seedDatabase();
      } else {
        state = ExpenseState(expenses: expenses, isLoading: false);
      }
    });
  }

  Future<void> _seedDatabase() async {
    final seedData = [
      ExpenseEntity(
        title: 'Swiggy Order',
        amount: 485.00,
        category: 'Food',
        notes: 'Dinner from Truffles',
        createdAt: DateTime(2026, 6, 14, 20, 30),
        updatedAt: DateTime(2026, 6, 14, 20, 30),
      ),
      ExpenseEntity(
        title: 'Uber Ride',
        amount: 245.00,
        category: 'Transport',
        createdAt: DateTime(2026, 6, 14, 9, 15),
        updatedAt: DateTime(2026, 6, 14, 9, 15),
      ),
      ExpenseEntity(
        title: 'Amazon Shopping',
        amount: 2340.00,
        category: 'Shopping',
        createdAt: DateTime(2026, 6, 13, 14, 45),
        updatedAt: DateTime(2026, 6, 13, 14, 45),
      ),
      ExpenseEntity(
        title: 'Netflix Subscription',
        amount: 649.00,
        category: 'Entertainment',
        createdAt: DateTime(2026, 6, 12, 11, 0),
        updatedAt: DateTime(2026, 6, 12, 11, 0),
      ),
      ExpenseEntity(
        title: 'Electricity Bill',
        amount: 1850.00,
        category: 'Bills',
        createdAt: DateTime(2026, 6, 10, 16, 30),
        updatedAt: DateTime(2026, 6, 10, 16, 30),
      ),
      ExpenseEntity(
        title: 'Apollo Pharmacy',
        amount: 780.00,
        category: 'Medical',
        createdAt: DateTime(2026, 6, 8, 13, 20),
        updatedAt: DateTime(2026, 6, 8, 13, 20),
      ),
      ExpenseEntity(
        title: 'Udemy Course',
        amount: 455.00,
        category: 'Education',
        createdAt: DateTime(2026, 6, 7, 10, 0),
        updatedAt: DateTime(2026, 6, 7, 10, 0),
      ),
      ExpenseEntity(
        title: 'Zomato Order',
        amount: 320.00,
        category: 'Food',
        createdAt: DateTime(2026, 6, 4, 19, 45),
        updatedAt: DateTime(2026, 6, 4, 19, 45),
      ),
      ExpenseEntity(
        title: 'Big Basket',
        amount: 1650.00,
        category: 'Groceries',
        createdAt: DateTime(2026, 5, 25, 14, 0),
        updatedAt: DateTime(2026, 5, 25, 14, 0),
      ),
      ExpenseEntity(
        title: 'Gym Membership',
        amount: 2500.00,
        category: 'Medical',
        createdAt: DateTime(2026, 5, 20, 9, 0),
        updatedAt: DateTime(2026, 5, 20, 9, 0),
      ),
      ExpenseEntity(
        title: 'BookMyShow',
        amount: 890.00,
        category: 'Entertainment',
        createdAt: DateTime(2026, 4, 18, 20, 0),
        updatedAt: DateTime(2026, 4, 18, 20, 0),
      ),
      ExpenseEntity(
        title: 'Flight Ticket',
        amount: 4200.00,
        category: 'Travel',
        notes: 'Trip to Goa',
        createdAt: DateTime(2026, 3, 15, 8, 0),
        updatedAt: DateTime(2026, 3, 15, 8, 0),
      ),
      ExpenseEntity(
        title: 'Petrol',
        amount: 1200.00,
        category: 'Fuel',
        createdAt: DateTime(2026, 2, 10, 18, 30),
        updatedAt: DateTime(2026, 2, 10, 18, 30),
      ),
      ExpenseEntity(
        title: 'Rent Payment',
        amount: 15000.00,
        category: 'Bills',
        createdAt: DateTime(2026, 1, 1, 12, 0),
        updatedAt: DateTime(2026, 1, 1, 12, 0),
      ),
    ];

    for (final expense in seedData) {
      await _repository.addExpense(expense);
    }
    await _prefs.setBool(_seedKey, true);
  }

  /// Adds a new expense to local DB.
  Future<void> addExpense({
    required String title,
    required double amount,
    required String category,
    String? notes,
    String transactionType = 'expense',
  }) async {
    final now = DateTime.now();
    final expense = ExpenseEntity(
      title: title,
      amount: amount,
      category: category,
      notes: notes,
      createdAt: now,
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
    final original = state.expenses.firstWhere(
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
      final prefs = ref.watch(sharedPreferencesProvider);
      return ExpenseNotifier(repository, prefs);
    });
