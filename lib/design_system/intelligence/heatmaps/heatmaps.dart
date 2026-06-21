/// Data model representing density of category expenditures.
class MLCategoryDensity {
  const MLCategoryDensity({
    required this.categoryName,
    required this.transactionCount,
    required this.totalAmount,
    required this.densityFactor,
  });

  final String categoryName;
  final int transactionCount;
  final double totalAmount;
  final double densityFactor;
}

/// Data model mapping spending density across a week/day matrix.
class MLSpendingHabit {
  const MLSpendingHabit({
    required this.dayOfWeek,
    required this.hourOfDay,
    required this.frequency,
    required this.totalAmount,
  });

  final int dayOfWeek;
  final int hourOfDay;
  final int frequency;
  final double totalAmount;
}
