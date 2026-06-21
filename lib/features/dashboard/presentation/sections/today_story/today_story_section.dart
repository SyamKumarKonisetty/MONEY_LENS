import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design/design_system.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../transactions/domain/models.dart';
import '../../../../transactions/presentation/providers/transactions_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../animations/dashboard_animations.dart';

/// A dynamic storytelling section displaying contextual highlights in large typography.
class TodayStorySection extends ConsumerWidget {
  const TodayStorySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spentToday = ref.watch(spentTodayProvider);
    final topCategoryToday = ref.watch(topCategoryTodayProvider);
    final allTransactions = ref.watch(allTransactionsProvider);

    // Compute yesterday's date
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    // Check for recent income today or yesterday
    double recentIncome = 0.0;
    bool incomeIsToday = false;
    for (final t in allTransactions) {
      final isToday = t.date.year == now.year &&
          t.date.month == now.month &&
          t.date.day == now.day;
      final isYesterday = t.date.year == yesterday.year &&
          t.date.month == yesterday.month &&
          t.date.day == yesterday.day;

      if ((isToday || isYesterday) && t.type == TransactionType.income) {
        recentIncome = t.amount;
        incomeIsToday = isToday;
        break;
      }
    }

    Color highlightColor = AppColors.primary;
    IconData storyIcon = Icons.auto_awesome_rounded;

    if (recentIncome > 0.0) {
      highlightColor = AppColors.income;
      storyIcon = Icons.trending_up_rounded;
    } else if (spentToday > 0.0) {
      highlightColor = AppColors.expense;
      storyIcon = Icons.shopping_bag_rounded;
    } else {
      highlightColor = AppColors.income;
      storyIcon = Icons.check_circle_rounded;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: ScaleUpEntrance(
        delay: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadius.medium,
            border: Border.all(
              color: AppColors.divider,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rotating / animated story icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: highlightColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  storyIcon,
                  color: highlightColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Dynamic storytelling typography block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TODAY\'S STORY',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _RichStoryText(
                      spentToday: spentToday,
                      recentIncome: recentIncome,
                      incomeIsToday: incomeIsToday,
                      topCategoryToday: topCategoryToday,
                      highlightColor: highlightColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RichStoryText extends StatelessWidget {
  const _RichStoryText({
    required this.spentToday,
    required this.recentIncome,
    required this.incomeIsToday,
    required this.topCategoryToday,
    required this.highlightColor,
  });

  final double spentToday;
  final double recentIncome;
  final bool incomeIsToday;
  final String topCategoryToday;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    if (recentIncome > 0.0) {
      return RichText(
        text: TextSpan(
          style: AppTypography.title.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
            height: 1.4,
          ),
          children: [
            const TextSpan(text: 'Received a deposit of '),
            TextSpan(
              text: CurrencyFormatter.compact(recentIncome),
              style: TextStyle(
                color: highlightColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            TextSpan(text: ' ${incomeIsToday ? "today" : "yesterday"}. Balance is trending upward!'),
          ],
        ),
      );
    }

    if (spentToday > 0.0) {
      return RichText(
        text: TextSpan(
          style: AppTypography.title.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
            height: 1.4,
          ),
          children: [
            const TextSpan(text: 'You spent '),
            TextSpan(
              text: CurrencyFormatter.compact(spentToday),
              style: TextStyle(
                color: highlightColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const TextSpan(text: ' today. Most of it was allocated to '),
            TextSpan(
              text: topCategoryToday,
              style: TextStyle(
                color: highlightColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: AppTypography.title.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
          height: 1.4,
        ),
        children: [
          const TextSpan(text: 'No transactions logged today. You are maintaining a perfect '),
          TextSpan(
            text: 'budget shield',
            style: TextStyle(
              color: highlightColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const TextSpan(text: '!'),
        ],
      ),
    );
  }
}
