import 'package:flutter/material.dart';
import '../../foundations/colors.dart';

/// Semantic types of trends supported by the Trend Engine.
enum MLTrendType {
  increasing,
  decreasing,
  stable,
  recovering,
  declining,
  accelerating,
  slowing,
  volatile,
  seasonal,
}

/// Evaluation definition for a specific trend type.
class MLTrend {
  const MLTrend({
    required this.type,
    required this.label,
    required this.icon,
    required this.colorResolver,
    required this.hapticPattern,
    required this.narrativeTemplate,
    required this.accessibilityLabel,
  });

  final MLTrendType type;
  final String label;
  final IconData icon;
  final Color Function(BuildContext context, {bool isIncome}) colorResolver;
  final String hapticPattern; // Light, doubleTap, warning, success
  final String narrativeTemplate;
  final String accessibilityLabel;

  /// Resolves the semantic color based on the current theme context and transaction type.
  Color resolveColor(BuildContext context, {bool isIncome = false}) =>
      colorResolver(context, isIncome: isIncome);
}

/// Registry supplying configurations for all trend types.
class MLTrendRegistry {
  MLTrendRegistry._();

  static final Map<MLTrendType, MLTrend> _configs = {
    MLTrendType.increasing: MLTrend(
      type: MLTrendType.increasing,
      label: 'Increasing',
      icon: Icons.trending_up_rounded,
      colorResolver: (context, {isIncome = false}) =>
          isIncome ? MLColors.success(context) : MLColors.error(context),
      hapticPattern: 'light',
      narrativeTemplate: 'Your spending trend increased by {delta} this week.',
      accessibilityLabel: 'Increasing trend.',
    ),
    MLTrendType.decreasing: MLTrend(
      type: MLTrendType.decreasing,
      label: 'Decreasing',
      icon: Icons.trending_down_rounded,
      colorResolver: (context, {isIncome = false}) =>
          isIncome ? MLColors.error(context) : MLColors.success(context),
      hapticPattern: 'light',
      narrativeTemplate: 'Your spending trend decreased by {delta} this week.',
      accessibilityLabel: 'Decreasing trend.',
    ),
    MLTrendType.stable: MLTrend(
      type: MLTrendType.stable,
      label: 'Stable',
      icon: Icons.trending_flat_rounded,
      colorResolver: (context, {isIncome = false}) =>
          MLColors.secondary(context),
      hapticPattern: 'light',
      narrativeTemplate:
          'Spending remained stable for {period} consecutive periods.',
      accessibilityLabel: 'Stable trend.',
    ),
    MLTrendType.recovering: MLTrend(
      type: MLTrendType.recovering,
      label: 'Recovering',
      icon: Icons.unfold_more_rounded,
      colorResolver: (context, {isIncome = false}) => MLColors.primary(context),
      hapticPattern: 'success',
      narrativeTemplate:
          'Savings are recovering, rising {delta} above baseline.',
      accessibilityLabel: 'Recovering trend.',
    ),
    MLTrendType.declining: MLTrend(
      type: MLTrendType.declining,
      label: 'Declining',
      icon: Icons.keyboard_double_arrow_down_rounded,
      colorResolver: (context, {isIncome = false}) => MLColors.error(context),
      hapticPattern: 'warning',
      narrativeTemplate: 'Balance has been declining over the last {period}.',
      accessibilityLabel: 'Declining trend.',
    ),
    MLTrendType.accelerating: MLTrend(
      type: MLTrendType.accelerating,
      label: 'Accelerating',
      icon: Icons.rocket_launch_rounded,
      colorResolver: (context, {isIncome = false}) =>
          isIncome ? MLColors.success(context) : MLColors.error(context),
      hapticPattern: 'doubleTap',
      narrativeTemplate: 'Spending velocity is accelerating by {delta}/day.',
      accessibilityLabel: 'Accelerating trend.',
    ),
    MLTrendType.slowing: MLTrend(
      type: MLTrendType.slowing,
      label: 'Slowing',
      icon: Icons.speed_rounded,
      colorResolver: (context, {isIncome = false}) => MLColors.success(context),
      hapticPattern: 'light',
      narrativeTemplate: 'Spending rate is slowing down.',
      accessibilityLabel: 'Slowing trend.',
    ),
    MLTrendType.volatile: MLTrend(
      type: MLTrendType.volatile,
      label: 'Volatile',
      icon: Icons.analytics_rounded,
      colorResolver: (context, {isIncome = false}) => MLColors.warning(context),
      hapticPattern: 'warning',
      narrativeTemplate:
          'Cash flow shows high volatility with spikes up to {delta}.',
      accessibilityLabel: 'Volatile trend.',
    ),
    MLTrendType.seasonal: MLTrend(
      type: MLTrendType.seasonal,
      label: 'Seasonal',
      icon: Icons.calendar_today_rounded,
      colorResolver: (context, {isIncome = false}) => MLColors.primary(context),
      hapticPattern: 'light',
      narrativeTemplate: 'Matching seasonal baseline pattern for {period}.',
      accessibilityLabel: 'Seasonal trend pattern.',
    ),
  };

  /// Resolves the trend metadata definition.
  static MLTrend resolve(MLTrendType type) {
    return _configs[type]!;
  }
}

/// Timeframes supported by the visual comparison engine.
enum MLComparisonScope {
  today,
  yesterday,
  week,
  month,
  quarter,
  year,
  customRange,
}

/// Engine to compute and hold delta figures between comparison periods.
class MLComparisonMetrics {
  const MLComparisonMetrics({
    required this.scope,
    required this.currentPeriodTotal,
    required this.previousPeriodTotal,
    this.isExpense = true,
  });

  final MLComparisonScope scope;
  final double currentPeriodTotal;
  final double previousPeriodTotal;
  final bool isExpense;

  double get difference => currentPeriodTotal - previousPeriodTotal;

  double get percentageChange {
    if (previousPeriodTotal == 0) {
      return currentPeriodTotal > 0 ? 100.0 : 0.0;
    }
    return ((currentPeriodTotal - previousPeriodTotal) / previousPeriodTotal) *
        100.0;
  }

  /// True if the change is a positive financial indicator (e.g. less spent or more earned).
  bool get isPositiveChange {
    if (isExpense) {
      return currentPeriodTotal <= previousPeriodTotal;
    } else {
      return currentPeriodTotal >= previousPeriodTotal;
    }
  }

  /// Automatically generates human-centric story narration strings.
  String toStoryString() {
    final absPct = percentageChange.abs().toStringAsFixed(0);
    final periodName = _getPeriodName(scope);

    if (percentageChange == 0) {
      return 'Spending was unchanged compared to $periodName.';
    }

    if (isExpense) {
      if (isPositiveChange) {
        return 'You spent $absPct% less than $periodName.';
      } else {
        return 'You spent $absPct% more than $periodName.';
      }
    } else {
      if (isPositiveChange) {
        return 'Income increased by $absPct% compared to $periodName.';
      } else {
        return 'Income decreased by $absPct% compared to $periodName.';
      }
    }
  }

  String _getPeriodName(MLComparisonScope scope) {
    switch (scope) {
      case MLComparisonScope.today:
        return 'earlier today';
      case MLComparisonScope.yesterday:
        return 'yesterday';
      case MLComparisonScope.week:
        return 'last week';
      case MLComparisonScope.month:
        return 'last month';
      case MLComparisonScope.quarter:
        return 'last quarter';
      case MLComparisonScope.year:
        return 'last year';
      case MLComparisonScope.customRange:
        return 'previous period';
    }
  }
}
