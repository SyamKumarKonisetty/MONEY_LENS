library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design/design_system.dart';
import '../../../domain/models.dart';
import '../../providers/transactions_provider.dart';
import '../animations/transaction_animations.dart';
import '../transaction_tile/swipeable_action_wrapper.dart';
import '../transaction_tile/transaction_tile.dart';

/// Chronological timeline list representing transaction groups.
class TimelineSection extends ConsumerWidget {
  const TimelineSection({
    super.key,
    required this.transactions,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Transaction> transactions;
  final ValueChanged<Transaction> onTap;
  final ValueChanged<Transaction> onEdit;
  final ValueChanged<Transaction> onDelete;

  Map<String, List<Transaction>> _groupTransactions(
    List<Transaction> list,
    TransactionSort sort,
  ) {
    final Map<String, List<Transaction>> grouped = {};
    if (sort == TransactionSort.amountHighToLow) {
      if (list.isNotEmpty) grouped['HIGHEST AMOUNT'] = list;
      return grouped;
    }
    if (sort == TransactionSort.amountLowToHigh) {
      if (list.isNotEmpty) grouped['LOWEST AMOUNT'] = list;
      return grouped;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final startOfLastWeek = startOfWeek.subtract(const Duration(days: 7));
    final startOfMonth = DateTime(now.year, now.month, 1);

    for (final t in list) {
      final txDate = DateTime(t.date.year, t.date.month, t.date.day);
      String key;
      if (txDate == today) {
        key = 'TODAY';
      } else if (txDate == yesterday) {
        key = 'YESTERDAY';
      } else if (t.date.isAfter(startOfWeek)) {
        key = 'THIS WEEK';
      } else if (t.date.isAfter(startOfLastWeek)) {
        key = 'LAST WEEK';
      } else if (t.date.isAfter(startOfMonth)) {
        key = 'THIS MONTH';
      } else {
        key = 'OLDER';
      }
      grouped.putIfAbsent(key, () => []).add(t);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(transactionSortProvider);
    final grouped = _groupTransactions(transactions, sort);
    final groupKeys = grouped.keys.toList();

    int globalIndex = 0;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: groupKeys.length,
      itemBuilder: (context, sectionIndex) {
        final key = groupKeys[sectionIndex];
        final items = grouped[key]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Timeline Group Header
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.pagePadding + 16,
                top: AppSpacing.xl,
                bottom: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Text(
                    key,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppColors.divider.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),

            // Timeline Items
            ...items.asMap().entries.map((entry) {
              final idx = entry.key;
              final tx = entry.value;
              final cat = AppCategories.findById(tx.categoryId);
              final isFirst = idx == 0;
              final isLast = idx == items.length - 1;

              final currentGlobalIndex = globalIndex++;

              return StaggeredTimelineEntrance(
                index: currentGlobalIndex,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: AppSpacing.md),
                    // Visual Node Line Indicator
                    _TimelineIndicator(
                      isFirst: isFirst,
                      isLast: isLast,
                      color: cat.color,
                    ),
                    // Swipe Action Wrapper + Interactive Tile
                    Expanded(
                      child: SwipeableActionWrapper(
                        key: Key(tx.id),
                        onDelete: () => onDelete(tx),
                        onEdit: () => onEdit(tx),
                        child: TransactionTile(
                          transaction: tx,
                          onTap: () => onTap(tx),
                          onEdit: () => onEdit(tx),
                          onDelete: () => onDelete(tx),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _TimelineIndicator extends StatelessWidget {
  const _TimelineIndicator({
    required this.isFirst,
    required this.isLast,
    required this.color,
  });

  final bool isFirst;
  final bool isLast;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 76, // Matches standard tile height roughly
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vertical Line segment
          Positioned(
            top: isFirst ? 38 : 0,
            bottom: isLast ? 38 : 0,
            child: Container(
              width: 1.5,
              color: AppColors.divider.withValues(alpha: 0.6),
            ),
          ),
          // Circle Dot Node
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
