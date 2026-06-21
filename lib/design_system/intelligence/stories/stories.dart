import '../metrics/metrics.dart';
import '../comparison/comparison.dart';
import '../forecast/forecast.dart';
import '../health/health.dart';


/// Represents a compiled human-readable narrative story for financial states.
class MLStory {
  const MLStory({
    required this.headline,
    required this.summary,
    required this.context,
    required this.recommendation,
    this.primaryMetric,
    this.isPositive = true,
  });

  final String headline;
  final String summary;
  final String context;
  final String recommendation;
  final MLMetric? primaryMetric;
  final bool isPositive;

  /// Returns the full combined narrative for accessibility or text export.
  String get fullNarrative => '$headline. $summary $context $recommendation';
}

/// Compilation utility that maps raw metrics/evaluations into high-quality stories.
class MLStoryCompiler {
  MLStoryCompiler._();

  /// Compiles a story from comparison metrics.
  static MLStory compileComparison(
    MLComparisonMetrics comparison, {
    String? categoryName,
  }) {
    final scopeName = comparison.isExpense ? 'spending' : 'income';
    final target = categoryName != null ? 'on $categoryName' : '';

    final headline = comparison.isPositiveChange
        ? 'Looking good! Your $scopeName is down'
        : 'Heads up: Your $scopeName has risen';

    final summary = comparison.toStoryString();

    final context = categoryName != null
        ? 'Your total $scopeName $target is ₹${comparison.currentPeriodTotal.toStringAsFixed(0)} compared to ₹${comparison.previousPeriodTotal.toStringAsFixed(0)} previously.'
        : 'Total recorded $scopeName is ₹${comparison.currentPeriodTotal.toStringAsFixed(0)} against ₹${comparison.previousPeriodTotal.toStringAsFixed(0)} last period.';

    final recommendation = comparison.isPositiveChange
        ? 'Great job keeping expenses low. Consider redirecting these savings into your primary savings goal.'
        : 'Consider reviewing your largest transaction logs to identify potential items to scale back.';

    return MLStory(
      headline: headline,
      summary: summary,
      context: context,
      recommendation: recommendation,
      primaryMetric: MLChangeMetric(
        value: comparison.difference,
        label: '${categoryName ?? "Overall"} Change',
        isPercentage: false,
      ),
      isPositive: comparison.isPositiveChange,
    );
  }

  /// Compiles a story from a projection/forecast.
  static MLStory compileForecast(MLForecast forecast) {
    final isExceeding = forecast.isProjectedToExceed;
    final headline = isExceeding
        ? 'Potential budget overrun detected'
        : 'On track to meet budget';

    final summary = forecast.toSummaryStory();

    final context =
        'You have spent ₹${forecast.spentSoFar.toStringAsFixed(0)} of your ₹${forecast.budgetLimit.toStringAsFixed(0)} budget. There are ${forecast.daysRemaining} days left in the period.';

    final recommendation = isExceeding
        ? 'To stay within limits, reduce daily spending to under ₹${((forecast.budgetLimit - forecast.spentSoFar) / forecast.daysRemaining).clamp(0.0, double.infinity).toStringAsFixed(0)} for the rest of the month.'
        : 'You have a comfortable buffer. Keep maintaining your daily spend rate under ₹${forecast.dailyVelocity.toStringAsFixed(0)}/day.';

    return MLStory(
      headline: headline,
      summary: summary,
      context: context,
      recommendation: recommendation,
      primaryMetric: MLFinancialMetric(
        value: forecast.projectedSpend,
        label: 'Projected Spend',
      ),
      isPositive: !isExceeding,
    );
  }

  /// Compiles a story from financial health.
  static MLStory compileHealth(MLFinancialHealth health) {
    final isPositive = health.score >= 70;

    final headline = health.headline;
    final summary =
        'Your overall Financial Health Score is ${health.score}/100, indicating a ${health.riskLevel.name} risk level.';
    final context = health.educationalNote;

    String recommendation;
    if (health.score >= 85) {
      recommendation =
          'Maintain this momentum by setting up automated investments for surplus cash flow.';
    } else if (health.score >= 70) {
      recommendation =
          'Look for minor subscriptions or daily dining expenses to trim and cross into the 85+ score category.';
    } else {
      recommendation =
          'Focus on tracking every single expense for the next 7 days to establish logging consistency.';
    }

    return MLStory(
      headline: headline,
      summary: summary,
      context: context,
      recommendation: recommendation,
      primaryMetric: MLHealthMetric(value: health.score, label: 'Health Score'),
      isPositive: isPositive,
    );
  }
}
