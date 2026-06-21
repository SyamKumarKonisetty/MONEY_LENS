import 'package:flutter/material.dart';
import '../foundations/colors.dart';
import '../foundations/typography.dart';
import '../foundations/radius.dart';

import 'charts.dart';
import 'money.dart';

/// Data contract representing a transaction event in the Timeline System.
class MLTimelineEvent {
  const MLTimelineEvent({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.isIncome,
    this.merchant,
    this.notes,
  });

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final bool isIncome;
  final String? merchant;
  final String? notes;
}

/// Abstract base timeline class enforcing unified accessibility and performance.
abstract class MLTimeline extends StatelessWidget {
  const MLTimeline({
    required this.events,
    super.key,
    this.state = MLChartState.render,
    this.emptyType = MLChartEmptyType.noData,
    this.onEmptyAction,
  });

  final List<MLTimelineEvent> events;
  final MLChartState state;
  final MLChartEmptyType emptyType;
  final VoidCallback? onEmptyAction;

  /// Semantic accessibility text generator.
  String getAccessibilityDescription(MLTimelineEvent event) {
    final typeStr = event.isIncome ? 'Inflow' : 'Outflow';
    final cleanAmount = event.amount.toStringAsFixed(2);
    return 'Transaction event: ${event.title}. Type: $typeStr. Amount: $cleanAmount. Date: ${event.date.day}/${event.date.month}.';
  }
}

// ─── Timeline Components ─────────────────────────────────────────────────────

/// Displays inflows and outflows chronologically.
class MLCashFlowTimeline extends MLTimeline {
  const MLCashFlowTimeline({
    required super.events,
    super.state,
    super.emptyType,
    super.onEmptyAction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (state == MLChartState.loading) {
      return Column(
        children: List.generate(
          3,
          (index) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: MLSkeletonPlaceholder(height: 72),
          ),
        ),
      );
    }

    if (state == MLChartState.empty || events.isEmpty) {
      return MLChartEmptyState(type: emptyType, onActionPressed: onEmptyAction);
    }

    // Lazy list rendering (virtualization support for large lists)
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Semantics(
          label: getAccessibilityDescription(event),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: MLColors.surfaceCard(context),
              borderRadius: BorderRadius.circular(MLRadius.large),
              border: Border.all(
                color: MLColors.surfaceOverlay(context),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                // Visual node indicator
                Container(
                  width: 8,
                  height: 36,
                  decoration: BoxDecoration(
                    color: event.isIncome
                        ? MLColors.income(context)
                        : MLColors.expense(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: MLTypography.titleMedium.copyWith(
                          color: MLColors.primary(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        '${event.date.day}/${event.date.month} • ${event.categoryId.toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontFamily: 'NothingDotMatrix',
                        ),
                      ),
                    ],
                  ),
                ),
                MLMoneyDisplay.standard(
                  amount: event.amount,
                  currency: '₹',
                  isIncome: event.isIncome,
                  showSign: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Chronological display focused on expenses.
class MLSpendingTimeline extends MLTimeline {
  const MLSpendingTimeline({
    required super.events,
    super.state,
    super.emptyType,
    super.onEmptyAction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (state == MLChartState.loading) {
      return Column(
        children: List.generate(
          3,
          (index) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: MLSkeletonPlaceholder(height: 60),
          ),
        ),
      );
    }

    if (state == MLChartState.empty || events.isEmpty) {
      return MLChartEmptyState(type: emptyType, onActionPressed: onEmptyAction);
    }

    final expenseEvents = events.where((e) => !e.isIncome).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: expenseEvents.length,
      itemBuilder: (context, index) {
        final event = expenseEvents[index];
        return Semantics(
          label: getAccessibilityDescription(event),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 16.0,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: MLColors.surfaceOverlay(context),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: MLTypography.bodySmall.copyWith(
                        color: MLColors.primary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      '${event.merchant ?? 'Unknown Merchant'} • ${event.date.day}/${event.date.month}',
                      style: TextStyle(
                        fontSize: 9.0,
                        color: MLColors.secondary(context),
                      ),
                    ),
                  ],
                ),
                MLMoneyDisplay.standard(
                  amount: event.amount,
                  currency: '₹',
                  isIncome: false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Chronological display focused on earnings.
class MLIncomeTimeline extends MLTimeline {
  const MLIncomeTimeline({
    required super.events,
    super.state,
    super.emptyType,
    super.onEmptyAction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (state == MLChartState.loading) {
      return Column(
        children: List.generate(
          3,
          (index) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: MLSkeletonPlaceholder(height: 60),
          ),
        ),
      );
    }

    if (state == MLChartState.empty || events.isEmpty) {
      return MLChartEmptyState(type: emptyType, onActionPressed: onEmptyAction);
    }

    final incomeEvents = events.where((e) => e.isIncome).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: incomeEvents.length,
      itemBuilder: (context, index) {
        final event = incomeEvents[index];
        return Semantics(
          label: getAccessibilityDescription(event),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 16.0,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: MLColors.surfaceOverlay(context),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: MLTypography.bodySmall.copyWith(
                        color: MLColors.primary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      'Received: ${event.date.day}/${event.date.month}',
                      style: TextStyle(
                        fontSize: 9.0,
                        color: MLColors.secondary(context),
                      ),
                    ),
                  ],
                ),
                MLMoneyDisplay.standard(
                  amount: event.amount,
                  currency: '₹',
                  isIncome: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
