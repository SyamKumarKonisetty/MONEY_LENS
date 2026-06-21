import 'package:flutter/material.dart';
import '../foundations/colors.dart';
import '../foundations/typography.dart';
import 'primitives.dart';
import '../foundations/radius.dart';
import '../foundations/insights.dart';
import 'charts.dart';
import 'money.dart';
import 'text.dart';


/// Card component to render single actionable insights.
class MLInsightCard extends StatelessWidget {
  const MLInsightCard({required this.insight, super.key, this.onTap});

  final MLInsight insight;
  final VoidCallback? onTap;

  Color _severityColor(BuildContext context) {
    switch (insight.severity) {
      case MLInsightSeverity.info:
        return MLColors.primary(context);
      case MLInsightSeverity.warning:
        return MLColors.warning(context);
      case MLInsightSeverity.critical:
        return MLColors.error(context);
      case MLInsightSeverity.success:
        return MLColors.success(context);
    }
  }

  IconData _severityIcon() {
    switch (insight.severity) {
      case MLInsightSeverity.info:
        return Icons.info_outline_rounded;
      case MLInsightSeverity.warning:
        return Icons.warning_amber_rounded;
      case MLInsightSeverity.critical:
        return Icons.error_outline_rounded;
      case MLInsightSeverity.success:
        return Icons.check_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderCol = _severityColor(context).withAlpha(60);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: MLColors.surfaceCard(context),
          borderRadius: BorderRadius.circular(MLRadius.large),
          border: Border.all(color: borderCol, width: 1.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_severityIcon(), color: _severityColor(context), size: 24.0),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insight.title,
                    style: MLTypography.titleMedium.copyWith(
                      color: MLColors.primary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    insight.message,
                    style: MLTypography.bodySmall.copyWith(
                      color: MLColors.secondary(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders future predictions and budget boundaries.
class MLForecastCard extends StatelessWidget {
  const MLForecastCard({
    required this.predictedSpend,
    required this.daysRemaining,
    required this.currentVelocity,
    required this.limit,
    super.key,
  });

  final double predictedSpend;
  final int daysRemaining;
  final double currentVelocity;
  final double limit;

  @override
  Widget build(BuildContext context) {
    final isExceeding = predictedSpend > limit;
    final alertColor = isExceeding
        ? MLColors.error(context)
        : MLColors.success(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: MLColors.surfaceCard(context),
        borderRadius: BorderRadius.circular(MLRadius.large),
        border: Border.all(color: MLColors.surfaceOverlay(context), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MLText.dotLabel('Month-End Projection'),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Projected Spend', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 4.0),
                  MLMoneyDisplay.standard(
                    amount: predictedSpend,
                    currency: '₹',
                  ),
                ],
              ),
              Icon(
                isExceeding
                    ? Icons.trending_up_rounded
                    : Icons.trending_flat_rounded,
                color: alertColor,
                size: 28.0,
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          MLLinearProgress(
            value: (predictedSpend / limit).clamp(0.0, 1.0),
            color: alertColor,
          ),
          const SizedBox(height: 12.0),
          Text(
            isExceeding
                ? 'Warning: You are projected to exceed your budget limit of ₹$limit by ${(predictedSpend - limit).toStringAsFixed(0)}.'
                : 'Safe: You are projected to finish the month under your budget limit.',
            style: MLTypography.caption.copyWith(
              color: isExceeding
                  ? MLColors.error(context)
                  : MLColors.secondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dynamic narrative generator converting financial data into short stories.
class MLFinancialStory extends StatelessWidget {
  const MLFinancialStory({
    required this.storyText,
    required this.actionLabel,
    this.onAction,
    super.key,
  });

  final String storyText;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MLColors.primary(context).withAlpha(15),
            MLColors.secondary(context).withAlpha(5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(MLRadius.large),
        border: Border.all(
          color: MLColors.primary(context).withAlpha(30),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_outlined,
                color: MLColors.primary(context),
                size: 20.0,
              ),
              const SizedBox(width: 8.0),
              const Text(
                'MONEYLENS STORY',
                style: TextStyle(
                  fontFamily: 'NothingDotMatrix',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(
            storyText,
            style: MLTypography.titleMedium.copyWith(
              color: MLColors.primary(context),
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          if (onAction != null) ...[
            const SizedBox(height: 12.0),
            GestureDetector(
              onTap: onAction,
              child: Row(
                children: [
                  Text(
                    actionLabel,
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: MLColors.primary(context),
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14.0,
                    color: MLColors.primary(context),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Metric KPI display with trend indicator support.
class MLMetricCard extends StatelessWidget {
  const MLMetricCard({
    required this.title,
    required this.value,
    required this.trendText,
    required this.isPositiveTrend,
    this.sparklinePoints,
    super.key,
  });

  final String title;
  final String value;
  final String trendText;
  final bool isPositiveTrend;
  final List<double>? sparklinePoints;

  @override
  Widget build(BuildContext context) {
    final trendColor = isPositiveTrend
        ? MLColors.success(context)
        : MLColors.error(context);
    final trendIcon = isPositiveTrend
        ? Icons.arrow_upward_rounded
        : Icons.arrow_downward_rounded;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: MLColors.surfaceCard(context),
        borderRadius: BorderRadius.circular(MLRadius.large),
        border: Border.all(color: MLColors.surfaceOverlay(context), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'NothingDotMatrix',
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            value,
            style: MLTypography.displayLarge.copyWith(
              color: MLColors.primary(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(trendIcon, color: trendColor, size: 14.0),
                  const SizedBox(width: 4.0),
                  Text(
                    trendText,
                    style: MLTypography.caption.copyWith(
                      color: trendColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (sparklinePoints != null && sparklinePoints!.isNotEmpty)
                SizedBox(
                  width: 60,
                  height: 24,
                  child: MLTrendLine(values: sparklinePoints!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Arranges multiple metrics cleanly.
class MLStatGrid extends StatelessWidget {
  const MLStatGrid({required this.cards, super.key});

  final List<MLMetricCard> cards;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 1.3,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => cards[index],
    );
  }
}

/// Category utilization breakdown logs.
class MLCategoryBreakdown extends StatelessWidget {
  const MLCategoryBreakdown({
    required this.categoryName,
    required this.spent,
    required this.limit,
    required this.percentage,
    required this.color,
    super.key,
  });

  final String categoryName;
  final double spent;
  final double limit;
  final double percentage;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    categoryName,
                    style: MLTypography.bodySmall.copyWith(
                      color: MLColors.primary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '₹${spent.toStringAsFixed(0)} / ₹${limit.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'NothingDotMatrix',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          MLLinearProgress(
            value: percentage.clamp(0.0, 1.0),
            color: color,
          ),
        ],
      ),
    );
  }
}

/// Merchant frequency ledger.
class MLMerchantBreakdown extends StatelessWidget {
  const MLMerchantBreakdown({
    required this.merchantName,
    required this.spent,
    required this.transactionCount,
    super.key,
  });

  final String merchantName;
  final double spent;
  final int transactionCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: MLColors.surfaceCard(context),
        borderRadius: BorderRadius.circular(MLRadius.small),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                merchantName,
                style: MLTypography.bodySmall.copyWith(
                  color: MLColors.primary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                '$transactionCount payments this month',
                style: MLTypography.caption.copyWith(
                  color: MLColors.secondary(context),
                ),
              ),
            ],
          ),
          MLMoneyDisplay.standard(amount: spent, currency: '₹'),
        ],
      ),
    );
  }
}

/// Aggregate progress toward goal.
class MLSavingsProgress extends StatelessWidget {
  const MLSavingsProgress({
    required this.goalLabel,
    required this.targetAmount,
    required this.savedAmount,
    super.key,
  });

  final String goalLabel;
  final double targetAmount;
  final double savedAmount;

  @override
  Widget build(BuildContext context) {
    final ratio = targetAmount > 0 ? savedAmount / targetAmount : 0.0;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: MLColors.surfaceCard(context),
        borderRadius: BorderRadius.circular(MLRadius.large),
        border: Border.all(color: MLColors.surfaceOverlay(context), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                goalLabel,
                style: MLTypography.titleMedium.copyWith(
                  color: MLColors.primary(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(ratio * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontFamily: 'NothingDotMatrix',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MLMoneyDisplay.standard(
                amount: savedAmount,
                currency: '₹',
                isIncome: true,
              ),
              Text(
                'Target: ₹${targetAmount.toStringAsFixed(0)}',
                style: MLTypography.caption.copyWith(
                  color: MLColors.secondary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          MLLinearProgress(
            value: ratio.clamp(0.0, 1.0),
            color: MLColors.success(context),
          ),
        ],
      ),
    );
  }
}
