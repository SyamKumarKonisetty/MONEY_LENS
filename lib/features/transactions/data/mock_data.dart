import '../../transactions/domain/models.dart';
import '../../../core/constants/app_constants.dart';

/// Mock transaction data for Phase 1 UI development.
///
/// Realistic Indian finance data seeded across multiple months.
/// Replace with real Drift database queries in Phase 2.
class MockTransactionData {
  MockTransactionData._();

  static final List<Transaction> all = [
    // ─── June 2026 ────────────────────────────────────────────────────────
    Transaction(
      id: 't001',
      title: 'Swiggy Order',
      amount: 485.00,
      type: TransactionType.expense,
      categoryId: AppConstants.categoryFoodId,
      date: DateTime(2026, 6, 14, 20, 30),
      note: 'Dinner from Truffles',
    ),
    Transaction(
      id: 't002',
      title: 'Uber Ride',
      amount: 245.00,
      type: TransactionType.expense,
      categoryId: AppConstants.categoryTransportId,
      date: DateTime(2026, 6, 14, 9, 15),
    ),
    Transaction(
      id: 't003',
      title: 'Monthly Salary',
      amount: 85000.00,
      type: TransactionType.income,
      categoryId: AppConstants.categorySalaryId,
      date: DateTime(2026, 6, 1, 10, 0),
      note: 'June salary credited',
    ),
    Transaction(
      id: 't004',
      title: 'Amazon Shopping',
      amount: 2340.00,
      type: TransactionType.expense,
      categoryId: AppConstants.categoryShoppingId,
      date: DateTime(2026, 6, 13, 14, 45),
    ),
    Transaction(
      id: 't005',
      title: 'Netflix Subscription',
      amount: 649.00,
      type: TransactionType.expense,
      categoryId: AppConstants.categoryEntertainmentId,
      date: DateTime(2026, 6, 12, 11, 0),
    ),
    Transaction(
      id: 't006',
      title: 'Electricity Bill',
      amount: 1850.00,
      type: TransactionType.expense,
      categoryId: AppConstants.categoryUtilitiesId,
      date: DateTime(2026, 6, 10, 16, 30),
    ),
    Transaction(
      id: 't007',
      title: 'Apollo Pharmacy',
      amount: 780.00,
      type: TransactionType.expense,
      categoryId: AppConstants.categoryHealthcareId,
      date: DateTime(2026, 6, 8, 13, 20),
    ),
    Transaction(
      id: 't008',
      title: 'Udemy Course',
      amount: 455.00,
      type: TransactionType.expense,
      categoryId: AppConstants.categoryEducationId,
      date: DateTime(2026, 6, 7, 10, 0),
    ),
    Transaction(
      id: 't009',
      title: 'Freelance Project',
      amount: 15000.00,
      type: TransactionType.income,
      categoryId: AppConstants.categoryFreelanceId,
      date: DateTime(2026, 6, 5, 18, 0),
      note: 'UI design for client',
    ),
    Transaction(
      id: 't010',
      title: 'Zomato Order',
      amount: 320.00,
      type: TransactionType.expense,
      categoryId: AppConstants.categoryFoodId,
      date: DateTime(2026, 6, 4, 19, 45),
    ),

    // ─── May 2026 ─────────────────────────────────────────────────────────
    Transaction(
      id: 't011',
      title: 'Monthly Salary',
      amount: 85000.00,
      type: TransactionType.income,
      categoryId: AppConstants.categorySalaryId,
      date: DateTime(2026, 5, 1, 10, 0),
    ),
    Transaction(
      id: 't012',
      title: 'Myntra Shopping',
      amount: 3200.00,
      type: TransactionType.expense,
      categoryId: AppConstants.categoryShoppingId,
      date: DateTime(2026, 5, 28, 15, 0),
    ),
    Transaction(
      id: 't013',
      title: 'Ola Auto',
      amount: 85.00,
      type: TransactionType.expense,
      categoryId: AppConstants.categoryTransportId,
      date: DateTime(2026, 5, 25, 8, 30),
    ),
    Transaction(
      id: 't014',
      title: 'Café Coffee Day',
      amount: 420.00,
      type: TransactionType.expense,
      categoryId: AppConstants.categoryFoodId,
      date: DateTime(2026, 5, 22, 11, 15),
    ),
    Transaction(
      id: 't015',
      title: 'Gym Membership',
      amount: 2500.00,
      type: TransactionType.expense,
      categoryId: AppConstants.categoryHealthcareId,
      date: DateTime(2026, 5, 20, 9, 0),
    ),

    // ─── April 2026 ───────────────────────────────────────────────────────
    Transaction(
      id: 't016',
      title: 'Monthly Salary',
      amount: 85000.00,
      type: TransactionType.income,
      categoryId: AppConstants.categorySalaryId,
      date: DateTime(2026, 4, 1, 10, 0),
    ),
    Transaction(
      id: 't017',
      title: 'BookMyShow',
      amount: 890.00,
      type: TransactionType.expense,
      categoryId: AppConstants.categoryEntertainmentId,
      date: DateTime(2026, 4, 18, 20, 0),
    ),
    Transaction(
      id: 't018',
      title: 'Big Basket',
      amount: 1650.00,
      type: TransactionType.expense,
      categoryId: AppConstants.categoryFoodId,
      date: DateTime(2026, 4, 15, 14, 0),
    ),

    // ─── March 2026 ───────────────────────────────────────────────────────
    Transaction(
      id: 't019',
      title: 'Monthly Salary',
      amount: 85000.00,
      type: TransactionType.income,
      categoryId: AppConstants.categorySalaryId,
      date: DateTime(2026, 3, 1, 10, 0),
    ),
    Transaction(
      id: 't020',
      title: 'Freelance Project',
      amount: 25000.00,
      type: TransactionType.income,
      categoryId: AppConstants.categoryFreelanceId,
      date: DateTime(2026, 3, 20, 16, 0),
    ),
  ];

  /// Returns the 5 most recent transactions.
  static List<Transaction> get recent => all.take(5).toList();

  /// Returns all transactions for a given month.
  static List<Transaction> forMonth(int year, int month) {
    return all
        .where((t) => t.date.year == year && t.date.month == month)
        .toList();
  }

  /// Returns all expense transactions.
  static List<Transaction> get expenses =>
      all.where((t) => t.type.isExpense).toList();

  /// Returns all income transactions.
  static List<Transaction> get incomes =>
      all.where((t) => t.type.isIncome).toList();

  /// Total spent in June 2026.
  static double get currentMonthExpenses {
    return forMonth(
      2026,
      6,
    ).where((t) => t.type.isExpense).fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Total income in June 2026.
  static double get currentMonthIncome {
    return forMonth(
      2026,
      6,
    ).where((t) => t.type.isIncome).fold(0.0, (sum, t) => sum + t.amount);
  }
}
