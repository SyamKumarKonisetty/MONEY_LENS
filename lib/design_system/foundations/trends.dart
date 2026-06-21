import 'package:flutter/material.dart';
import 'colors.dart';

/// Semantic Trend Types for MoneyLens Design System (MLDS).
enum MLTrendType {
  up,
  down,
  stable,
  improving,
  declining,
  recovering,
  accelerating,
  slowing,
}

/// Metadata model defining a visual trend indicator.
class MLTrendMetadata {
  const MLTrendMetadata({
    required this.type,
    required this.label,
    required this.description,
    required this.icon,
    required this.colorResolver,
    required this.motionDescription,
  });

  final MLTrendType type;
  final String label;
  final String description;
  final IconData icon;
  final Color Function(BuildContext context, {bool isExpense}) colorResolver;
  final String motionDescription;
}

/// Core Trend System engine for resolving visual metrics contextually.
class MLTrends {
  MLTrends._();

  /// Resolves the trend metadata for a specific trend type.
  static MLTrendMetadata resolve(MLTrendType type) {
    switch (type) {
      case MLTrendType.up:
        return MLTrendMetadata(
          type: MLTrendType.up,
          label: 'Upward',
          description: 'Value increased compared to the previous period.',
          icon: Icons.trending_up_rounded,
          colorResolver: (context, {bool isExpense = false}) =>
              isExpense ? MLColors.expense(context) : MLColors.income(context),
          motionDescription: 'Staggered upward spring animation (overshoot).',
        );
      case MLTrendType.down:
        return MLTrendMetadata(
          type: MLTrendType.down,
          label: 'Downward',
          description: 'Value decreased compared to the previous period.',
          icon: Icons.trending_down_rounded,
          colorResolver: (context, {bool isExpense = false}) =>
              isExpense ? MLColors.income(context) : MLColors.expense(context),
          motionDescription: 'Subtle downward spring compression.',
        );
      case MLTrendType.stable:
        return MLTrendMetadata(
          type: MLTrendType.stable,
          label: 'Stable',
          description: 'Value remained stable or changed insignificantly.',
          icon: Icons.trending_flat_rounded,
          colorResolver: (context, {bool isExpense = false}) =>
              MLColors.secondary(context),
          motionDescription: 'Linear horizontal drift animation.',
        );
      case MLTrendType.improving:
        return MLTrendMetadata(
          type: MLTrendType.improving,
          label: 'Improving',
          description: 'Financial situation is progressing positively.',
          icon: Icons.arrow_upward_rounded,
          colorResolver: (context, {bool isExpense = false}) =>
              MLColors.success(context),
          motionDescription: 'Breathing glow animation with green aura.',
        );
      case MLTrendType.declining:
        return MLTrendMetadata(
          type: MLTrendType.declining,
          label: 'Declining',
          description: 'Financial parameters show signs of deterioration.',
          icon: Icons.arrow_downward_rounded,
          colorResolver: (context, {bool isExpense = false}) =>
              MLColors.error(context),
          motionDescription: 'Jittery pulse warning animation.',
        );
      case MLTrendType.recovering:
        return MLTrendMetadata(
          type: MLTrendType.recovering,
          label: 'Recovering',
          description:
              'Exceeded budgets or savings deficits are bouncing back.',
          icon: Icons.keyboard_double_arrow_up_rounded,
          colorResolver: (context, {bool isExpense = false}) =>
              MLColors.budget(context),
          motionDescription: 'Elastic snap-up spring animation.',
        );
      case MLTrendType.accelerating:
        return MLTrendMetadata(
          type: MLTrendType.accelerating,
          label: 'Accelerating',
          description: 'Growth rates are rising fast.',
          icon: Icons.speed_rounded,
          colorResolver: (context, {bool isExpense = false}) =>
              MLColors.primary(context),
          motionDescription: 'Rapid progressive sweep motion.',
        );
      case MLTrendType.slowing:
        return MLTrendMetadata(
          type: MLTrendType.slowing,
          label: 'Slowing',
          description: 'Expense or growth velocity is cooling off.',
          icon: Icons.slow_motion_video_rounded,
          colorResolver: (context, {bool isExpense = false}) =>
              MLColors.warning(context),
          motionDescription: 'Muted decay decelerating fade.',
        );
    }
  }
}
