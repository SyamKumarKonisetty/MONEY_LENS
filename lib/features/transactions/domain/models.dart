import 'package:flutter/material.dart';
import '../../../core/design/colors/app_colors.dart';

/// Transaction type — income or expense.
enum TransactionType {
  income,
  expense;

  bool get isExpense => this == TransactionType.expense;
  bool get isIncome => this == TransactionType.income;
}

/// A single financial transaction.
///
/// Immutable data model used across Dashboard, Transactions, and Analytics.
class Transaction {
  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.note,
  });

  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final DateTime date;
  final String? note;

  /// Returns amount with sign: negative for expense, positive for income.
  double get signedAmount => type.isExpense ? -amount : amount;

  /// Returns true if this transaction occurred today.
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    String? categoryId,
    DateTime? date,
    String? note,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// A spending category.
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;
}

/// All predefined categories in MoneyLens.
class AppCategories {
  AppCategories._();

  static final Category food = Category(
    id: 'food',
    name: 'Food',
    icon: Icons.restaurant_rounded,
    color: AppColors.categoryPalette[0],
  );

  static final Category groceries = Category(
    id: 'groceries',
    name: 'Groceries',
    icon: Icons.shopping_cart_rounded,
    color: AppColors.incomeGreen,
  );

  static final Category transport = Category(
    id: 'transport',
    name: 'Transport',
    icon: Icons.directions_car_rounded,
    color: AppColors.sapphireBlue,
  );

  static final Category fuel = Category(
    id: 'fuel',
    name: 'Fuel',
    icon: Icons.local_gas_station_rounded,
    color: AppColors.warningAmber,
  );

  static final Category shopping = Category(
    id: 'shopping',
    name: 'Shopping',
    icon: Icons.shopping_bag_rounded,
    color: AppColors.categoryPalette[4],
  );

  static final Category entertainment = Category(
    id: 'entertainment',
    name: 'Entertainment',
    icon: Icons.movie_rounded,
    color: AppColors.expenseCoral,
  );

  static final Category bills = Category(
    id: 'bills',
    name: 'Bills',
    icon: Icons.receipt_long_rounded,
    color: AppColors.cyanHighlight,
  );

  static final Category medical = Category(
    id: 'medical',
    name: 'Medical',
    icon: Icons.medical_services_rounded,
    color: AppColors.expenseCoral,
  );

  static final Category travel = Category(
    id: 'travel',
    name: 'Travel',
    icon: Icons.flight_rounded,
    color: AppColors.sapphireBlue,
  );

  static final Category education = Category(
    id: 'education',
    name: 'Education',
    icon: Icons.school_rounded,
    color: AppColors.cyanHighlight,
  );

  static final Category other = Category(
    id: 'other',
    name: 'Other',
    icon: Icons.category_rounded,
    color: AppColors.textSecondary,
  );

  // ─── Income categories ────────────────────────────────────────────────────

  static final Category salary = Category(
    id: 'salary',
    name: 'Salary',
    icon: Icons.payments_rounded,
    color: AppColors.incomeGreen,
  );

  static final Category freelance = Category(
    id: 'freelance',
    name: 'Freelance',
    icon: Icons.laptop_rounded,
    color: AppColors.sapphireBlue,
  );

  static final Category investment = Category(
    id: 'investment',
    name: 'Investment',
    icon: Icons.trending_up_rounded,
    color: AppColors.cyanHighlight,
  );

  static final Category rental = Category(
    id: 'rental',
    name: 'Rental',
    icon: Icons.home_work_rounded,
    color: AppColors.categoryPalette[4],
  );

  static final Category gift = Category(
    id: 'gift',
    name: 'Gift',
    icon: Icons.card_giftcard_rounded,
    color: AppColors.expenseCoral,
  );

  static final Category otherIncome = Category(
    id: 'other_income',
    name: 'Other',
    icon: Icons.add_circle_rounded,
    color: AppColors.textSecondary,
  );

  /// All expense categories.
  static final List<Category> all = [
    food,
    groceries,
    transport,
    fuel,
    shopping,
    entertainment,
    bills,
    medical,
    travel,
    education,
    other,
  ];

  /// Expense-only categories.
  static final List<Category> expense = all;

  /// Income categories.
  static final List<Category> income = [
    salary,
    freelance,
    investment,
    rental,
    gift,
    otherIncome,
  ];

  /// Find a category by ID. Returns [other] as fallback.
  static Category findById(String id) {
    final allCats = [...all, ...income];
    return allCats.firstWhere(
      (c) => c.id.toLowerCase() == id.toLowerCase(),
      orElse: () => other,
    );
  }
}
