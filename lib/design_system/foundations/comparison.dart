/// Semantic comparison time scopes.
library;

enum MLComparisonScope {
  todayVsYesterday,
  thisWeekVsLastWeek,
  thisMonthVsLastMonth,
  thisYearVsPreviousYear,
  custom,
}

/// Holds the comparison metrics between a primary and a base period.
class MLComparisonMetrics {
  const MLComparisonMetrics({
    required this.scope,
    required this.primaryValue,
    required this.baseValue,
    required this.difference,
    required this.percentageChange,
    required this.isPositiveChange, // E.g., true if income is up or expense is down
    required this.label,
  });

  final MLComparisonScope scope;
  final double primaryValue;
  final double baseValue;
  final double difference;

  /// Percentage change value (e.g. 18.5 for 18.5%).
  final double percentageChange;

  /// True if the change is positive for the user's health.
  final bool isPositiveChange;

  /// Text label of the comparison (e.g., "vs Last Week")
  final String label;

  /// Helper to generate a human-readable comparison text
  String toStoryString({required bool isExpense}) {
    final pctStr = '${percentageChange.toStringAsFixed(0)}%';
    if (percentageChange == 0.0) {
      return isExpense
          ? 'Your spending remained stable.'
          : 'Your income remained stable.';
    }

    if (isExpense) {
      return isPositiveChange
          ? 'You spent $pctStr less than $label.'
          : 'You spent $pctStr more than $label.';
    } else {
      return isPositiveChange
          ? 'Your income rose by $pctStr compared to $label.'
          : 'Your income fell by $pctStr compared to $label.';
    }
  }

  /// Calculates comparison metrics.
  static MLComparisonMetrics calculate({
    required MLComparisonScope scope,
    required double primary,
    required double base,
    required bool isExpense,
    String? customLabel,
  }) {
    final diff = primary - base;
    final pct = base > 0 ? (diff / base) * 100.0 : 0.0;

    // For expenses, a negative difference (spent less) is positive progress.
    // For income, a positive difference (earned more) is positive progress.
    final isPositive = isExpense ? (diff <= 0) : (diff >= 0);

    final String resolvedLabel;
    switch (scope) {
      case MLComparisonScope.todayVsYesterday:
        resolvedLabel = 'yesterday';
        break;
      case MLComparisonScope.thisWeekVsLastWeek:
        resolvedLabel = 'last week';
        break;
      case MLComparisonScope.thisMonthVsLastMonth:
        resolvedLabel = 'last month';
        break;
      case MLComparisonScope.thisYearVsPreviousYear:
        resolvedLabel = 'last year';
        break;
      case MLComparisonScope.custom:
        resolvedLabel = customLabel ?? 'previous period';
        break;
    }

    return MLComparisonMetrics(
      scope: scope,
      primaryValue: primary,
      baseValue: base,
      difference: diff.abs(),
      percentageChange: pct.abs(),
      isPositiveChange: isPositive,
      label: resolvedLabel,
    );
  }
}
