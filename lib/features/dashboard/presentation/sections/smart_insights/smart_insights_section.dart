import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design/design_system.dart';
import '../../../../../core/ui_engine/ui_engine.dart';
import '../../../../budget/presentation/providers/budget_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../animations/dashboard_animations.dart';
import '../models/dashboard_story_model.dart';

/// reimagined Smart Insights Carousel Section with auto-rotating crossfades.
class SmartInsightsSection extends ConsumerStatefulWidget {
  const SmartInsightsSection({super.key});

  @override
  ConsumerState<SmartInsightsSection> createState() => _SmartInsightsSectionState();
}

class _SmartInsightsSectionState extends ConsumerState<SmartInsightsSection>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  Timer? _timer;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: AppAnimations.medium,
      value: 1.0,
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: MotionConstants.smoothCurve);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) => _advance());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _advance() async {
    if (!mounted) return;
    await _fadeCtrl.reverse();
    if (!mounted) return;
    setState(() {
      _currentIndex++;
    });
    _fadeCtrl.forward();
  }

  void _jumpTo(int index) {
    _timer?.cancel();
    _fadeCtrl.reverse().then((_) {
      if (!mounted) return;
      setState(() => _currentIndex = index);
      _fadeCtrl.forward();
      _startTimer();
    });
  }

  List<SmartInsight> _generateInsights({
    required double expenses,
    required double income,
    required double spentToday,
    required String topCategory,
    required double budgetLimit,
    required double budgetSpent,
  }) {
    final list = <SmartInsight>[];

    // 1. Savings Rate Insight
    if (income > 0) {
      final rate = ((income - expenses) / income * 100).clamp(0.0, 100.0);
      if (rate >= 20.0) {
        list.add(SmartInsight(
          icon: Icons.trending_up_rounded,
          color: AppColors.income,
          headline: 'High Savings Zone',
          subtitle: 'You are saving ${rate.toStringAsFixed(0)}% of your income this month. Excellent benchmark control.',
        ));
      } else if (rate > 0.0) {
        list.add(SmartInsight(
          icon: Icons.savings_rounded,
          color: AppColors.warning,
          headline: 'Cushion Expansion opportunity',
          subtitle: 'Savings rate is ${rate.toStringAsFixed(0)}%. Try adjusting non-essentials to cross the 20% mark.',
        ));
      }
    }

    // 2. Budget Warning Insight
    if (budgetLimit > 0) {
      final usage = (budgetSpent / budgetLimit) * 100.0;
      if (usage >= 100.0) {
        list.add(SmartInsight(
          icon: Icons.dangerous_rounded,
          color: AppColors.expense,
          headline: 'Budget Breached',
          subtitle: 'Outflow has exceeded total limits. Review category allocations to control overflow.',
        ));
      } else if (usage >= 80.0) {
        list.add(SmartInsight(
          icon: Icons.warning_amber_rounded,
          color: AppColors.warning,
          headline: 'Budget Warning',
          subtitle: 'You have consumed ${usage.toStringAsFixed(0)}% of your monthly limits. Spend safely today.',
        ));
      }
    }

    // 3. Top Spending Category
    if (topCategory != 'None') {
      list.add(SmartInsight(
        icon: Icons.local_fire_department_rounded,
        color: AppColors.warning,
        headline: 'Heavy Category: $topCategory',
        subtitle: '$topCategory is taking up the highest share of expenses. Check details in reports.',
      ));
    }

    // 4. Default Insight
    if (list.isEmpty) {
      list.add(SmartInsight(
        icon: Icons.lightbulb_rounded,
        color: AppColors.primary,
        headline: 'Consistent tracking habit',
        subtitle: 'Log all transactions to unlock personalized insights and balance breakdowns.',
      ));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(currentMonthExpensesProvider);
    final income = ref.watch(currentMonthIncomeProvider);
    final spentToday = ref.watch(spentTodayProvider);
    final topCategory = ref.watch(topSpendingCategoryProvider);
    final budgetSummary = ref.watch(budgetSummaryProvider);

    final insights = _generateInsights(
      expenses: expenses,
      income: income,
      spentToday: spentToday,
      topCategory: topCategory,
      budgetLimit: budgetSummary.totalLimit,
      budgetSpent: budgetSummary.totalSpent,
    );

    final index = _currentIndex % insights.length;
    final activeInsight = insights[index];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: ScaleUpEntrance(
        delay: const Duration(milliseconds: 400),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadius.medium,
            border: Border.all(
              color: activeInsight.color.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(activeInsight.icon, color: activeInsight.color, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'SMART INSIGHTS',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  // Dot indicators
                  Row(
                    children: List.generate(insights.length, (i) => GestureDetector(
                      onTap: () => _jumpTo(i),
                      child: AnimatedContainer(
                        duration: AppAnimations.fast,
                        margin: const EdgeInsets.only(left: 4),
                        width: i == index ? 12 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == index ? activeInsight.color : AppColors.divider,
                          borderRadius: AppRadius.circularFull,
                        ),
                      ),
                    )),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeInsight.headline,
                      style: AppTypography.title.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activeInsight.subtitle,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 12, height: 1.35),
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
