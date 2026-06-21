import 'package:flutter/material.dart';

/// Priority levels to determine visual emphasis of metrics.
enum MLMetricPriority { low, medium, high, critical }

/// Abstract base class for all MLDS Financial Metrics.
abstract class MLMetric<T> {
  const MLMetric({
    required this.value,
    required this.label,
    this.icon,
    this.priority = MLMetricPriority.medium,
    this.story,
    this.accessibilityLabel,
  });

  final T value;
  final String label;
  final IconData? icon;
  final MLMetricPriority priority;
  final String? story;
  final String? accessibilityLabel;

  /// Returns the formatted display representation of the metric value.
  String get formattedValue;

  /// Returns the full semantic description for screen readers.
  String get semanticDescription =>
      accessibilityLabel ?? '$label is $formattedValue. ${story ?? ''}';
}

/// A metric representing monetary figures (FTS compliant).
class MLFinancialMetric extends MLMetric<double> {
  const MLFinancialMetric({
    required super.value,
    required super.label,
    this.currencySymbol = '₹',
    this.showDecimals = true,
    super.icon,
    super.priority,
    super.story,
    super.accessibilityLabel,
  });

  final String currencySymbol;
  final bool showDecimals;

  @override
  String get formattedValue {
    final amountStr = showDecimals
        ? value.toStringAsFixed(2)
        : value.toStringAsFixed(0);
    // Simple thousands formatting (e.g., 48,520)
    final parts = amountStr.split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';
    return '$currencySymbol$integerPart$decimalPart';
  }
}

/// A metric representing rates or proportions (e.g., Savings Rate).
class MLPercentageMetric extends MLMetric<double> {
  const MLPercentageMetric({
    required super.value,
    required super.label,
    this.isMultiplier = false, // If true, 0.15 represents 15%
    super.icon,
    super.priority,
    super.story,
    super.accessibilityLabel,
  });

  final bool isMultiplier;

  @override
  String get formattedValue {
    final pct = isMultiplier ? value * 100 : value;
    return '${pct.toStringAsFixed(1)}%';
  }
}

/// A metric representing positive or negative deltas/changes.
class MLChangeMetric extends MLMetric<double> {
  const MLChangeMetric({
    required super.value,
    required super.label,
    this.isPercentage = true,
    this.currencySymbol = '₹',
    super.icon,
    super.priority,
    super.story,
    super.accessibilityLabel,
  });

  final bool isPercentage;
  final String currencySymbol;

  bool get isNegative => value < 0;
  bool get isNeutral => value == 0;

  @override
  String get formattedValue {
    final sign = value > 0 ? '+' : (value < 0 ? '-' : '');
    final absVal = value.abs();
    if (isPercentage) {
      return '$sign${absVal.toStringAsFixed(1)}%';
    } else {
      final valStr = absVal
          .toStringAsFixed(0)
          .replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
      return '$sign$currencySymbol$valStr';
    }
  }
}

/// A metric representing historical or computed averages.
class MLAverageMetric extends MLMetric<double> {
  const MLAverageMetric({
    required super.value,
    required super.label,
    this.period = 'daily',
    this.currencySymbol = '₹',
    super.icon,
    super.priority,
    super.story,
    super.accessibilityLabel,
  });

  final String period;
  final String currencySymbol;

  @override
  String get formattedValue {
    final valStr = value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return '$currencySymbol$valStr/$period';
  }
}

/// A metric comparing progress against a ceiling or goal.
class MLGoalMetric extends MLMetric<double> {
  const MLGoalMetric({
    required super.value,
    required this.target,
    required super.label,
    this.currencySymbol = '₹',
    super.icon,
    super.priority,
    super.story,
    super.accessibilityLabel,
  });

  final double target;
  final String currencySymbol;

  double get ratio => target > 0 ? (value / target).clamp(0.0, 1.0) : 0.0;
  bool get isAchieved => value >= target;
  double get remaining => (target - value).clamp(0.0, double.infinity);

  @override
  String get formattedValue {
    final ratioPct = (ratio * 100).toStringAsFixed(0);
    return '$ratioPct%';
  }
}

/// A metric representing overall Financial Health scoring indexes.
class MLHealthMetric extends MLMetric<int> {
  const MLHealthMetric({
    required super.value,
    required super.label,
    super.icon,
    super.priority = MLMetricPriority.high,
    super.story,
    super.accessibilityLabel,
  }) : assert(value >= 0 && value <= 100, 'Score must be between 0 and 100');

  String get rating {
    if (value >= 85) return 'Excellent';
    if (value >= 70) return 'Stable';
    if (value >= 50) return 'Fair';
    return 'Attention Needed';
  }

  @override
  String get formattedValue => '$value/100';
}
