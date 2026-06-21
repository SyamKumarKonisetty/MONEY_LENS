import 'package:flutter/material.dart';
import '../../foundations/colors.dart';
import '../../foundations/spacing.dart';
import '../../foundations/typography.dart';
import 'package:money_lens/core/design/design_system.dart';


/// Supported chronological scopes for layout rendering.
enum MLTimelineScope { daily, weekly, monthly, cashFlow, recurring }

/// Represents an event in the intelligence timelines.
class MLChronologicalEvent {
  const MLChronologicalEvent({
    required this.id,
    required this.title,
    required this.amount,
    required this.timestamp,
    required this.isIncome,
    this.merchant,
    this.category,
    this.isRecurring = false,
  });

  final String id;
  final String title;
  final double amount;
  final DateTime timestamp;
  final bool isIncome;
  final String? merchant;
  final String? category;
  final bool isRecurring;
}

/// Unified timeline renderer that adjusts its hierarchy based on timeline scope.
class MLChronologicalTimeline extends StatelessWidget {
  const MLChronologicalTimeline({
    required this.events,
    required this.scope,
    super.key,
    this.isLoading = false,
    this.onEventTap,
  });

  final List<MLChronologicalEvent> events;
  final MLTimelineScope scope;
  final bool isLoading;
  final void Function(MLChronologicalEvent)? onEventTap;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Column(
        children: List.generate(3, (index) => _buildSkeletonItem(context)),
      );
    }

    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(MLSpacing.cardPadding),
          child: Column(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 36.0,
                color: MLColors.secondary(context),
              ),
              const SizedBox(height: 8.0),
              Text(
                'No events recorded for this period',
                style: MLTypography.bodyMedium.copyWith(
                  color: MLColors.secondary(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventItem(context, event, index == events.length - 1);
      },
    );
  }

  Widget _buildEventItem(
    BuildContext context,
    MLChronologicalEvent event,
    bool isLast,
  ) {
    final valueColor = event.isIncome
        ? MLColors.income(context)
        : Theme.of(context).colorScheme.onSurface;
    final sign = event.isIncome ? '+' : '-';

    String dateHeader = '';
    if (scope == MLTimelineScope.daily) {
      dateHeader =
          '${event.timestamp.hour.toString().padLeft(2, '0')}:${event.timestamp.minute.toString().padLeft(2, '0')}';
    } else if (scope == MLTimelineScope.weekly) {
      dateHeader = _getDayName(event.timestamp.weekday);
    } else if (scope == MLTimelineScope.monthly) {
      dateHeader =
          '${event.timestamp.day} ${_getMonthName(event.timestamp.month)}';
    } else if (scope == MLTimelineScope.recurring) {
      dateHeader = 'Next: Day ${event.timestamp.day}';
    } else {
      dateHeader = '${event.timestamp.day}/${event.timestamp.month}';
    }

    return InkWell(
      onTap: onEventTap != null ? () => onEventTap!(event) : null,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                const SizedBox(height: 6.0),
                Container(
                  width: 10.0,
                  height: 10.0,
                  decoration: BoxDecoration(
                    color: event.isIncome
                        ? MLColors.income(context)
                        : MLColors.primary(context),
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: MLColors.secondary(context).withValues(alpha: 0.15),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: MLSpacing.lg),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: MLSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: MLTypography.titleSmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Row(
                      children: [
                        Text(
                          dateHeader,
                          style: MLTypography.caption.copyWith(
                            color: MLColors.secondary(context),
                          ),
                        ),
                        if (event.merchant != null) ...[
                          Text(
                            ' • ',
                            style: MLTypography.caption.copyWith(
                              color: MLColors.secondary(context),
                            ),
                          ),
                          Text(
                            event.merchant!,
                            style: MLTypography.caption.copyWith(
                              color: MLColors.secondary(context),
                            ),
                          ),
                        ],
                        if (event.category != null) ...[
                          Text(
                            ' • ',
                            style: MLTypography.caption.copyWith(
                              color: MLColors.secondary(context),
                            ),
                          ),
                          Text(
                            event.category!.toUpperCase(),
                            style: MLTypography.caption.copyWith(
                              color: MLColors.secondary(context),
                            ),
                          ),
                        ],
                        if (event.isRecurring) ...[
                          const SizedBox(width: 6.0),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                              vertical: 1.0,
                            ),
                            decoration: BoxDecoration(
                              color: MLColors.primary(
                                context,
                              ).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              'RECURRING',
                              style: MLTypography.tiny.copyWith(
                                color: MLColors.primary(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: MLSpacing.lg),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$sign₹${event.amount.toStringAsFixed(0)}',
                  style: MLTypography.moneySmall.copyWith(
                    color: valueColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonItem(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 10.0,
            height: 10.0,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12.0,
                  width: 120.0,
                  color: AppColors.textMuted.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 6.0),
                Container(
                  height: 8.0,
                  width: 80.0,
                  color: AppColors.textMuted.withValues(alpha: 0.1),
                ),
              ],
            ),
          ),
          Container(
            height: 14.0,
            width: 50.0,
            color: AppColors.textMuted.withValues(alpha: 0.1),
          ),
        ],
      ),
    );
  }

  String _getDayName(int day) {
    switch (day) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }
}
