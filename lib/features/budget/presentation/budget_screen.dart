import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../transactions/domain/models.dart';
import '../domain/entities/budget_entity.dart';
import 'providers/budget_provider.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  void _showCategorySelectSheet(
    BuildContext context,
    List<BudgetEntity> activeBudgets,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CategorySelectSheet(activeBudgets: activeBudgets),
    );
  }

  void _showSetBudgetSheet(
    BuildContext context,
    Category category, {
    double? currentLimit,
    int? budgetId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SetBudgetBottomSheet(
        category: category,
        initialLimit: currentLimit,
        budgetId: budgetId,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetNotifierProvider);
    final liveBudgets = ref.watch(liveBudgetsProvider);
    final summary = ref.watch(budgetSummaryProvider);
    final analytics = ref.watch(budgetAnalyticsProvider);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: budgetsAsync.when(
        data: (rawBudgets) {
          if (rawBudgets.isEmpty) {
            return _buildEmptyState(context);
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Custom Header App Bar
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: context.textPrimaryColor,
                    size: 20,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  'Smart Budgets',
                  style: AppTypography.titleLarge.copyWith(
                    color: context.textPrimaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.add_rounded,
                      color: context.primaryColor,
                      size: 28,
                    ),
                    onPressed: () =>
                        _showCategorySelectSheet(context, liveBudgets),
                  ),
                ],
              ),

              // Overall Summary Progress Ring
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pagePadding,
                    vertical: AppSpacing.md,
                  ),
                  child: _buildSummaryCard(context, summary),
                ),
              ),

              // Budget Analytics Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pagePadding,
                    vertical: AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Budget Intelligence',
                        style: AppTypography.titleMedium.copyWith(
                          color: context.textPrimaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildAnalyticsGrid(context, analytics),
                    ],
                  ),
                ),
              ),

              // Category Budgets Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding,
                    AppSpacing.lg,
                    AppSpacing.pagePadding,
                    AppSpacing.xs,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category Limits',
                            style: AppTypography.titleMedium.copyWith(
                              color: context.textPrimaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tap a budget card to adjust or remove it.',
                            style: AppTypography.bodySmall.copyWith(
                              color: context.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // List of Budgets
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                  vertical: AppSpacing.md,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final budget = liveBudgets[index];
                    final cat = AppCategories.findById(budget.category);
                    return _buildCategoryBudgetCard(context, budget, cat);
                  }, childCount: liveBudgets.length),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.massive),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading budgets: $err')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = context.isDark;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: context.textPrimaryColor,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Smart Budgets',
            style: AppTypography.titleLarge.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePadding * 2,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Premium Onboarding Card with Glassmorphism feel
                Container(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding * 1.5),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: AppRadius.card,
                    border: Border.all(
                      color: context.separatorColor.withValues(
                        alpha: isDark ? 0.3 : 0.6,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.15 : 0.03,
                        ),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: context.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.insights_rounded,
                          color: context.primaryColor,
                          size: 44,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Control Your Spending',
                        style: AppTypography.titleLarge.copyWith(
                          color: context.textPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Create your first budget and stay in control of your spending. Set targets for Food, Shopping, Bills, and more.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.textSecondaryColor,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showCategorySelectSheet(context, []),
                          icon: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Create Budget',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.circularMd,
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, BudgetSummary summary) {
    final isDark = context.isDark;
    final progress = (summary.totalSpent / summary.totalLimit).clamp(0.0, 1.0);
    final usagePercent = summary.usagePercent;

    Color stateColor = context.successColor;
    if (usagePercent >= 100) {
      stateColor = context.errorColor;
    } else if (usagePercent >= 80) {
      stateColor = context.warningColor;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: context.separatorColor.withValues(alpha: isDark ? 0.3 : 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Budget Limit',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.full(summary.totalLimit),
                    style: AppTypography.displayLarge.copyWith(
                      color: context.textPrimaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: stateColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.circularFull,
                ),
                child: Text(
                  usagePercent >= 100
                      ? 'Limit Breached'
                      : '${usagePercent.toStringAsFixed(0)}% Used',
                  style: AppTypography.labelSmall.copyWith(
                    color: stateColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Custom visual Progress bar
          ClipRRect(
            borderRadius: AppRadius.circularFull,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: context.surfaceVariantColor,
              valueColor: AlwaysStoppedAnimation<Color>(stateColor),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryIndicator(
                context,
                title: 'Total Spent',
                value: CurrencyFormatter.compact(summary.totalSpent),
                color: usagePercent >= 100
                    ? context.errorColor
                    : context.textPrimaryColor,
              ),
              _buildSummaryIndicator(
                context,
                title: 'Remaining',
                value: CurrencyFormatter.compact(summary.totalRemaining),
                color: summary.totalRemaining < 0
                    ? context.errorColor
                    : context.successColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryIndicator(
    BuildContext context, {
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondaryColor,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsGrid(BuildContext context, BudgetAnalytics analytics) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.45,
      children: [
        _buildAnalyticsCard(
          context,
          title: 'Highest Budget',
          category: analytics.highestBudgetCategory?.category,
          value: analytics.highestBudgetCategory != null
              ? CurrencyFormatter.compact(
                  analytics.highestBudgetCategory!.monthlyLimit,
                )
              : '₹0',
          icon: Icons.star_rounded,
          iconColor: Colors.amber,
        ),
        _buildAnalyticsCard(
          context,
          title: 'Most Overspent',
          category: analytics.mostOverspentCategory?.category,
          value: analytics.mostOverspentCategory != null
              ? 'Exceeded: ₹${CurrencyFormatter.compact(analytics.mostOverspentCategory!.spentAmount - analytics.mostOverspentCategory!.monthlyLimit)}'
              : 'None',
          icon: Icons.error_rounded,
          iconColor: context.errorColor,
        ),
        _buildAnalyticsCard(
          context,
          title: 'Closest to Limit',
          category: analytics.closestCategoryToLimit?.category,
          value: analytics.closestCategoryToLimit != null
              ? 'Left: ₹${CurrencyFormatter.compact(analytics.closestCategoryToLimit!.remainingAmount)}'
              : 'None',
          icon: Icons.av_timer_rounded,
          iconColor: context.warningColor,
        ),
        _buildAnalyticsCard(
          context,
          title: 'Total Utilization',
          category: 'All Budgets',
          value: '${analytics.monthlyUtilizationPercent.toStringAsFixed(0)}%',
          icon: Icons.donut_large_rounded,
          iconColor: context.primaryColor,
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(
    BuildContext context, {
    required String title,
    required String? category,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    final isDark = context.isDark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: context.separatorColor.withValues(alpha: isDark ? 0.3 : 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            category != null ? AppCategories.findById(category).name : '—',
            style: AppTypography.labelLarge.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondaryColor,
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBudgetCard(
    BuildContext context,
    BudgetEntity budget,
    Category cat,
  ) {
    final isDark = context.isDark;
    final limit = budget.monthlyLimit;
    final spent = budget.spentAmount;
    final remaining = budget.remainingAmount;
    final progress = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final progressPercent = progress * 100.0;

    // Color states: Green < 70%, Orange 70%-90%, Red > 90%
    Color progressBarColor = context.successColor;
    if (progressPercent >= 90) {
      progressBarColor = context.errorColor;
    } else if (progressPercent >= 70) {
      progressBarColor = context.warningColor;
    }

    final isOverBudget = spent > limit;
    final isBreached80 = spent >= (limit * 0.8) && !isOverBudget;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: context.separatorColor.withValues(alpha: isDark ? 0.3 : 0.6),
        ),
      ),
      child: InkWell(
        onTap: () => _showSetBudgetSheet(
          context,
          cat,
          currentLimit: limit,
          budgetId: budget.id,
        ),
        borderRadius: AppRadius.card,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cat.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(cat.icon, color: cat.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.name,
                          style: AppTypography.labelLarge.copyWith(
                            color: context.textPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Limit: ${CurrencyFormatter.compact(limit)}',
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textSecondaryColor,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Spent: ${CurrencyFormatter.compact(spent)}',
                        style: AppTypography.labelLarge.copyWith(
                          color: isOverBudget
                              ? context.errorColor
                              : context.textPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        remaining < 0
                            ? 'Over: ${CurrencyFormatter.compact(remaining.abs())}'
                            : 'Left: ${CurrencyFormatter.compact(remaining)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: remaining < 0
                              ? context.errorColor
                              : context.successColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Animated-feeling Linear indicator
              ClipRRect(
                borderRadius: AppRadius.circularFull,
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: context.surfaceVariantColor,
                  color: progressBarColor,
                ),
              ),

              // Warning banner for high thresholds
              if (isOverBudget) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.errorColor.withValues(alpha: 0.1),
                    borderRadius: AppRadius.circularMd,
                    border: Border.all(
                      color: context.errorColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: context.errorColor,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Budget Exceeded',
                          style: AppTypography.bodySmall.copyWith(
                            color: context.errorColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (isBreached80) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.warningColor.withValues(alpha: 0.1),
                    borderRadius: AppRadius.circularMd,
                    border: Border.all(
                      color: context.warningColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: context.warningColor,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Warning: Exceeded 80% limit',
                          style: AppTypography.bodySmall.copyWith(
                            color: context.warningColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CategorySelectSheet extends StatelessWidget {
  const CategorySelectSheet({super.key, required this.activeBudgets});

  final List<BudgetEntity> activeBudgets;

  @override
  Widget build(BuildContext context) {
    final categories = AppCategories.expense;
    final isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: context.separatorColor.withValues(alpha: isDark ? 0.3 : 0.6),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.xl,
        AppSpacing.pagePadding,
        MediaQuery.of(context).padding.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: context.separatorColor,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Select Category',
            style: AppTypography.titleLarge.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose a spending category to set a budget limit.',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Categories Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.95,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final hasActive = activeBudgets.any(
                (b) => b.category.toLowerCase() == cat.id.toLowerCase(),
              );

              return Opacity(
                opacity: hasActive ? 0.4 : 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: AppRadius.card,
                    border: Border.all(
                      color: context.separatorColor.withValues(
                        alpha: isDark ? 0.3 : 0.6,
                      ),
                    ),
                  ),
                  child: InkWell(
                    onTap: hasActive
                        ? () {
                            HapticFeedback.mediumImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${cat.name} budget already exists.',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        : () {
                            Navigator.of(context).pop();
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) =>
                                  SetBudgetBottomSheet(category: cat),
                            );
                          },
                    borderRadius: AppRadius.card,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: cat.color.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(cat.icon, color: cat.color, size: 20),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cat.name,
                            style: AppTypography.labelMedium.copyWith(
                              color: context.textPrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SetBudgetBottomSheet extends ConsumerStatefulWidget {
  const SetBudgetBottomSheet({
    super.key,
    required this.category,
    this.initialLimit,
    this.budgetId,
  });

  final Category category;
  final double? initialLimit;
  final int? budgetId;

  @override
  ConsumerState<SetBudgetBottomSheet> createState() =>
      _SetBudgetBottomSheetState();
}

class _SetBudgetBottomSheetState extends ConsumerState<SetBudgetBottomSheet> {
  late String _inputAmount;

  @override
  void initState() {
    super.initState();
    if (widget.initialLimit == null || widget.initialLimit == 0.0) {
      _inputAmount = '0';
    } else {
      final lim = widget.initialLimit!;
      if (lim == lim.toInt()) {
        _inputAmount = lim.toInt().toString();
      } else {
        _inputAmount = lim.toStringAsFixed(2);
        if (_inputAmount.endsWith('.00')) {
          _inputAmount = _inputAmount.substring(0, _inputAmount.length - 3);
        } else if (_inputAmount.endsWith('0') && _inputAmount.contains('.')) {
          _inputAmount = _inputAmount.substring(0, _inputAmount.length - 1);
        }
      }
    }
  }

  void _onDigit(String d) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_inputAmount == '0') {
        if (d == '.') {
          _inputAmount = '0.';
        } else {
          _inputAmount = d;
        }
      } else {
        if (d == '.') {
          if (!_inputAmount.contains('.')) {
            _inputAmount += '.';
          }
        } else {
          if (_inputAmount.contains('.')) {
            final parts = _inputAmount.split('.');
            if (parts.length > 1 && parts[1].length >= 2) {
              return;
            }
          }
          if (_inputAmount.length < 10) {
            _inputAmount += d;
          }
        }
      }
    });
  }

  void _onBackspace() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_inputAmount.length <= 1) {
        _inputAmount = '0';
      } else {
        _inputAmount = _inputAmount.substring(0, _inputAmount.length - 1);
      }
    });
  }

  Future<void> _saveBudget() async {
    final limit = double.tryParse(_inputAmount) ?? 0.0;
    if (limit <= 0) return;
    HapticFeedback.mediumImpact();

    await ref
        .read(budgetNotifierProvider.notifier)
        .setBudget(widget.category.id, limit);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.category.name} budget set to ${CurrencyFormatter.compact(limit)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteBudget() async {
    if (widget.budgetId == null) return;
    HapticFeedback.mediumImpact();

    await ref
        .read(budgetNotifierProvider.notifier)
        .deleteBudget(widget.budgetId!);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Deleted ${widget.category.name} budget limit',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String get _displayAmount {
    if (_inputAmount == '0') return '0';

    final parts = _inputAmount.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : null;

    final cleanStr = intPart.replaceAll(',', '');
    String formattedInt = cleanStr;
    if (cleanStr.isNotEmpty && cleanStr != '0') {
      if (cleanStr.length > 3) {
        final last3 = cleanStr.substring(cleanStr.length - 3);
        final rest = cleanStr.substring(0, cleanStr.length - 3);
        final buffer = StringBuffer();
        for (int i = 0; i < rest.length; i++) {
          if (i > 0 && (rest.length - i) % 2 == 0) {
            buffer.write(',');
          }
          buffer.write(rest[i]);
        }
        buffer.write(',');
        buffer.write(last3);
        formattedInt = buffer.toString();
      }
    }

    if (decPart != null) {
      return '$formattedInt.$decPart';
    } else if (_inputAmount.endsWith('.')) {
      return '$formattedInt.';
    }
    return formattedInt;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final hasExisting = widget.budgetId != null;

    return Container(
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: context.separatorColor.withValues(alpha: isDark ? 0.3 : 0.6),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.xl,
        AppSpacing.pagePadding,
        MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 5,
            decoration: BoxDecoration(
              color: context.separatorColor,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            hasExisting
                ? 'Adjust ${widget.category.name} Budget'
                : 'Set ${widget.category.name} Budget',
            style: AppTypography.titleLarge.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Enter the monthly spending limit for ${widget.category.name}.',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Category Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.category.color.withValues(alpha: 0.12),
              borderRadius: AppRadius.circularFull,
              border: Border.all(
                color: widget.category.color.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.category.icon,
                  color: widget.category.color,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.category.name,
                  style: AppTypography.bodySmall.copyWith(
                    color: widget.category.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Large amount entry display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₹',
                style: AppTypography.displayLarge.copyWith(
                  color: widget.category.color,
                  fontWeight: FontWeight.w500,
                  fontSize: 32,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  _displayAmount,
                  style: AppTypography.displayLarge.copyWith(
                    color: context.textPrimaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 40,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Keypad Row Builder
          Column(
            children: [
              _buildRow(['1', '2', '3']),
              const SizedBox(height: AppSpacing.md),
              _buildRow(['4', '5', '6']),
              const SizedBox(height: AppSpacing.md),
              _buildRow(['7', '8', '9']),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(child: _buildDigitButton('.')),
                  Expanded(child: _buildDigitButton('0')),
                  Expanded(
                    child: IconButton(
                      onPressed: _onBackspace,
                      icon: Icon(
                        Icons.backspace_outlined,
                        color: context.textPrimaryColor,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              Row(
                children: [
                  if (hasExisting) ...[
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _deleteBudget,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: context.errorColor),
                            foregroundColor: context.errorColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.circularMd,
                            ),
                          ),
                          child: const Text(
                            'Delete Limit',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                            double.tryParse(_inputAmount) != null &&
                                (double.tryParse(_inputAmount) ?? 0.0) > 0
                            ? _saveBudget
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.category.color,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: context.surfaceVariantColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.circularMd,
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Save Budget',
                          style: AppTypography.labelLarge.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                double.tryParse(_inputAmount) != null &&
                                    (double.tryParse(_inputAmount) ?? 0.0) > 0
                                ? Colors.white
                                : context.textSecondaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      children: digits
          .map((d) => Expanded(child: _buildDigitButton(d)))
          .toList(),
    );
  }

  Widget _buildDigitButton(String digit) {
    return InkWell(
      onTap: () => _onDigit(digit),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        child: Text(
          digit,
          style: AppTypography.displayLarge.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: context.textPrimaryColor,
          ),
        ),
      ),
    );
  }
}
