/// Analytics domain models for MoneyLens.
library;

/// Monthly spending summary for the analytics screen.
class MonthlySummary {
  const MonthlySummary({
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpenses,
  });

  final int year;
  final int month;
  final double totalIncome;
  final double totalExpenses;

  double get savings => totalIncome - totalExpenses;
  double get savingsRate => totalIncome > 0 ? savings / totalIncome : 0.0;
}

/// Spending by category for the donut chart.
class CategorySpending {
  const CategorySpending({
    required this.categoryId,
    required this.amount,
    required this.percentage,
  });

  final String categoryId;
  final double amount;
  final double percentage;
}

/// Monthly trend data point for the line chart.
class MonthlyTrend {
  const MonthlyTrend({
    required this.month,
    required this.label,
    required this.expenses,
    required this.income,
  });

  /// Month index (0-based, 0 = oldest shown month)
  final int month;

  /// Short label: 'Jan', 'Feb', etc.
  final String label;

  final double expenses;
  final double income;
}
