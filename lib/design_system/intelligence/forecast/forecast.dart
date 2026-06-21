/// Core data model containing predictive financial calculations.
class MLForecast {
  const MLForecast({
    required this.spentSoFar,
    required this.budgetLimit,
    required this.daysElapsed,
    required this.daysRemaining,
    required this.totalAvailableCash,
  });

  final double spentSoFar;
  final double budgetLimit;
  final int daysElapsed;
  final int daysRemaining;
  final double totalAvailableCash;

  /// Average expenditure rate per elapsed day in the active period.
  double get dailyVelocity {
    if (daysElapsed <= 0) return 0.0;
    return spentSoFar / daysElapsed;
  }

  /// Estimated total expenditure at the end of the current period.
  double get projectedSpend {
    return spentSoFar + (dailyVelocity * daysRemaining);
  }

  /// Returns true if the month-end projection exceeds the budget ceiling.
  bool get isProjectedToExceed => projectedSpend > budgetLimit;

  /// Calculated difference by which the budget limit is projected to be exceeded (or saved).
  double get projectedDelta => (projectedSpend - budgetLimit).abs();

  /// Estimated number of days remaining until cash/budget is completely exhausted.
  int get runwayDays {
    final velocity = dailyVelocity;
    if (velocity <= 0) return 999; // Indefinite runway
    final remainingCash = totalAvailableCash - spentSoFar;
    if (remainingCash <= 0) return 0;
    return (remainingCash / velocity).floor();
  }

  /// Compiles a user-friendly text summary of predictions.
  String toSummaryStory() {
    if (spentSoFar == 0) {
      return 'No expenses recorded yet. Forecast is currently flat.';
    }

    final velocityStr = dailyVelocity.toStringAsFixed(0);
    final projectedStr = projectedSpend.toStringAsFixed(0);

    if (isProjectedToExceed) {
      return 'At your current speed of ₹$velocityStr/day, you are projected to exceed your limit by ₹${projectedDelta.toStringAsFixed(0)} at month-end.';
    } else {
      return 'At ₹$velocityStr/day, you are projected to spend ₹$projectedStr, staying within your limit with ₹${projectedDelta.toStringAsFixed(0)} in savings.';
    }
  }
}
