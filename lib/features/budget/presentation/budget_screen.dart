import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../transactions/domain/models.dart';
import '../../../core/ui_engine/ui_engine.dart';
import '../domain/entities/budget_entity.dart';
import 'providers/budget_provider.dart';
import 'package:money_lens/core/design/design_system.dart' hide OutlinedButton;

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  void _showWizard(BuildContext context, List<BudgetEntity> activeBudgets) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => BudgetWizardBottomSheet(activeBudgets: activeBudgets),
    );
  }

  void _showEditSheet(BuildContext context, BudgetEntity budget, Category category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => EditBudgetBottomSheet(budget: budget, category: category),
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
      resizeToAvoidBottomInset: true,
      body: budgetsAsync.when(
        data: (rawBudgets) {
          if (rawBudgets.isEmpty) {
            return _buildEmptyState(context);
          }

          // Filter out archived budgets, but keep disabled ones so they can be re-enabled
          final activeBudgets = liveBudgets.where((b) => !b.isArchived).toList();

          if (activeBudgets.isEmpty && rawBudgets.isNotEmpty) {
            // If all existing budgets are archived, we can still show empty state or the list. Let's show the list containing the archived ones or show empty state if none are active.
            // Let's show the list of activeBudgets, which is empty, but we want users to see their archived budgets if they want, or we can just show the empty state.
            // Let's show the list so they can manage them, or if all are archived/deleted, show empty state.
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
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
                    onPressed: () => _showWizard(context, liveBudgets),
                  ),
                ],
              ),

              // Overall Summary Progress Card
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
                    final budget = activeBudgets[index];
                    final cat = AppCategories.findById(budget.category);
                    return _buildCategoryBudgetCard(context, budget, cat);
                  }, childCount: activeBudgets.length),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.massive),
              ),
            ],
          );
        },
        loading: () => const Center(child: MLSpinner()),
        error: (err, _) => Center(child: Text('Error loading budgets: $err')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = context.isDark;
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding * 1.25),
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
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(height: AppSpacing.lg),
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
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: 'Create Budget',
                    icon: Icons.add_rounded,
                    width: double.infinity,
                    onTap: () => _showWizard(context, []),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, BudgetSummary summary) {
    final isDark = context.isDark;
    final progress = (summary.totalSpent / (summary.totalLimit > 0 ? summary.totalLimit : 1.0)).clamp(0.0, 1.0);
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

          GradientProgressBar(
            value: progress,
            height: 10,
            borderRadius: 5,
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
                  analytics.highestBudgetCategory!.monthlyLimitEquivalent,
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
              ? 'Exceeded: ₹${CurrencyFormatter.compact(analytics.mostOverspentCategory!.spentAmount - analytics.mostOverspentCategory!.monthlyLimitEquivalent)}'
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
            category != null && category != 'All Budgets'
                ? AppCategories.findById(category).name
                : category ?? '—',
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

    final isOverBudget = spent > limit;
    final isBreached80 = spent >= (limit * 0.8) && !isOverBudget;

    return Opacity(
      opacity: budget.isEnabled ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: context.separatorColor.withValues(alpha: isDark ? 0.3 : 0.6),
          ),
        ),
        child: InkWell(
        onTap: () => _showEditSheet(context, budget, cat),
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
                        Row(
                          children: [
                            Text(
                              cat.name,
                              style: AppTypography.labelLarge.copyWith(
                                color: context.textPrimaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (!budget.isEnabled) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: context.textSecondaryColor.withValues(alpha: 0.15),
                                  borderRadius: AppRadius.circularSm,
                                ),
                                child: Text(
                                  'Disabled',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: context.textSecondaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Limit: ${CurrencyFormatter.compact(limit)} (${budget.period})',
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

              GradientProgressBar(
                value: progress,
                height: 6,
                borderRadius: 3,
              ),

              if (budget.isEnabled && isOverBudget) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.errorColor.withValues(alpha: 0.1),
                    borderRadius: AppRadius.circularMd,
                    border: Border.all(color: context.errorColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded, color: context.errorColor, size: 14),
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
              ] else if (budget.isEnabled && isBreached80) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.warningColor.withValues(alpha: 0.1),
                    borderRadius: AppRadius.circularMd,
                    border: Border.all(color: context.warningColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: context.warningColor, size: 14),
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
      ),
    );
  }
}

/// ─── 5-Step Budget Wizard Bottom Sheet ───────────────────────────────────────
class BudgetWizardBottomSheet extends ConsumerStatefulWidget {
  const BudgetWizardBottomSheet({super.key, required this.activeBudgets});

  final List<BudgetEntity> activeBudgets;

  @override
  ConsumerState<BudgetWizardBottomSheet> createState() => _BudgetWizardBottomSheetState();
}

class _BudgetWizardBottomSheetState extends ConsumerState<BudgetWizardBottomSheet> {
  int _step = 1;
  Category? _selectedCategory;
  String _amountInput = '0';
  String _selectedPeriod = 'monthly';
  bool _isSaving = false;

  void _onDigit(String d) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_amountInput == '0') {
        if (d == '.') {
          _amountInput = '0.';
        } else {
          _amountInput = d;
        }
      } else {
        if (d == '.') {
          if (!_amountInput.contains('.')) {
            _amountInput += '.';
          }
        } else {
          if (_amountInput.contains('.')) {
            final parts = _amountInput.split('.');
            if (parts.length > 1 && parts[1].length >= 2) return;
          }
          if (_amountInput.length < 10) {
            _amountInput += d;
          }
        }
      }
    });
  }

  void _onBackspace() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_amountInput.length <= 1) {
        _amountInput = '0';
      } else {
        _amountInput = _amountInput.substring(0, _amountInput.length - 1);
      }
    });
  }

  String get _displayAmount {
    if (_amountInput == '0') return '0';
    final parts = _amountInput.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : null;

    final cleanStr = intPart.replaceAll(',', '');
    String formattedInt = cleanStr;
    if (cleanStr.isNotEmpty && cleanStr != '0' && cleanStr.length > 3) {
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

    return decPart != null ? '$formattedInt.$decPart' : (_amountInput.endsWith('.') ? '$formattedInt.' : formattedInt);
  }

  Future<void> _handleSave() async {
    final limit = double.tryParse(_amountInput) ?? 0.0;
    if (limit <= 0 || _selectedCategory == null) return;

    setState(() {
      _isSaving = true;
      _step = 5;
    });

    HapticFeedback.mediumImpact();

    await ref.read(budgetNotifierProvider.notifier).setBudget(
          _selectedCategory!.id,
          limit,
          period: _selectedPeriod,
        );

    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_selectedCategory!.name} budget set to ${CurrencyFormatter.compact(limit)} ($_selectedPeriod)',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
        MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Bar handle
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
            const SizedBox(height: AppSpacing.lg),

            // Step Progress Bar
            if (_step < 5) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Step $_step of 4',
                    style: AppTypography.caption.copyWith(
                      color: context.textSecondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _step == 1
                        ? 'Category Selection'
                        : _step == 2
                            ? 'Target Amount'
                            : _step == 3
                                ? 'Billing Period'
                                : 'Confirmation',
                    style: AppTypography.caption.copyWith(
                      color: context.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _step / 4,
                  minHeight: 4,
                  backgroundColor: context.separatorColor.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(context.primaryColor),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],

            // Step Views
            if (_step == 1) _buildStepCategory()
            else if (_step == 2) _buildStepAmount()
            else if (_step == 3) _buildStepPeriod()
            else if (_step == 4) _buildStepReview()
            else if (_step == 5) _buildStepSaving(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCategory() {
    final categories = AppCategories.expense;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Category',
          style: AppTypography.titleLarge.copyWith(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select which spending area you want to track.',
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
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
            final hasActive = widget.activeBudgets.any(
              (b) => b.category.toLowerCase() == cat.id.toLowerCase() && !b.isArchived,
            );

            return Opacity(
              opacity: hasActive ? 0.35 : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: AppRadius.card,
                  border: Border.all(
                    color: context.separatorColor.withValues(
                      alpha: context.isDark ? 0.3 : 0.6,
                    ),
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (hasActive) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${cat.name} budget already exists.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      setState(() {
                        _selectedCategory = cat;
                        _step = 2;
                      });
                    }
                  },
                  borderRadius: AppRadius.card,
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
            );
          },
        ),
      ],
    );
  }

  Widget _buildStepAmount() {
    final limit = double.tryParse(_amountInput) ?? 0.0;
    return Column(
      children: [
        Text(
          'Target Limit',
          style: AppTypography.titleLarge.copyWith(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Enter the target spending amount for ${_selectedCategory?.name}.',
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Value Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '₹',
              style: AppTypography.displayLarge.copyWith(
                color: _selectedCategory?.color ?? context.primaryColor,
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

        // Keypad
        Column(
          children: [
            Row(children: ['1', '2', '3'].map((d) => Expanded(child: _buildDigitButton(d))).toList()),
            const SizedBox(height: AppSpacing.md),
            Row(children: ['4', '5', '6'].map((d) => Expanded(child: _buildDigitButton(d))).toList()),
            const SizedBox(height: AppSpacing.md),
            Row(children: ['7', '8', '9'].map((d) => Expanded(child: _buildDigitButton(d))).toList()),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(child: _buildDigitButton('.')),
                Expanded(child: _buildDigitButton('0')),
                Expanded(
                  child: IconButton(
                    onPressed: _onBackspace,
                    icon: Icon(Icons.backspace_outlined, color: context.textPrimaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // Control Row
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step = 1),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.separatorColor),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.circularMd),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Back', style: TextStyle(color: context.textPrimaryColor)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: limit > 0 ? () => setState(() => _step = 3) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedCategory?.color ?? context.primaryColor,
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.circularMd),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Next', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepPeriod() {
    final periods = ['weekly', 'monthly', 'yearly'];
    return Column(
      children: [
        Text(
          'Select Period',
          style: AppTypography.titleLarge.copyWith(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose how frequently this budget should reset.',
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        Column(
          children: periods.map((p) {
            final isSel = _selectedPeriod == p;
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isSel ? context.primaryColor.withValues(alpha: 0.12) : context.surfaceColor,
                borderRadius: AppRadius.card,
                border: Border.all(
                  color: isSel ? context.primaryColor : context.separatorColor.withValues(alpha: 0.5),
                  width: isSel ? 1.5 : 1.0,
                ),
              ),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedPeriod = p);
                },
                borderRadius: AppRadius.card,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        p.toUpperCase(),
                        style: AppTypography.labelLarge.copyWith(
                          color: isSel ? context.primaryColor : context.textPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isSel)
                        Icon(Icons.check_circle_rounded, color: context.primaryColor)
                      else
                        Icon(Icons.circle_outlined, color: context.textSecondaryColor),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.xl),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step = 2),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.separatorColor),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.circularMd),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Back', style: TextStyle(color: context.textPrimaryColor)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => setState(() => _step = 4),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedCategory?.color ?? context.primaryColor,
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.circularMd),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Review', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepReview() {
    final limit = double.tryParse(_amountInput) ?? 0.0;
    double monthlyEquivalent = limit;
    if (_selectedPeriod == 'weekly') {
      monthlyEquivalent = limit * (30 / 7);
    } else if (_selectedPeriod == 'yearly') {
      monthlyEquivalent = limit / 12;
    }

    return Column(
      children: [
        Text(
          'Confirm Settings',
          style: AppTypography.titleLarge.copyWith(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Ensure the target details are correct.',
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: AppRadius.card,
            border: Border.all(color: context.separatorColor.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              _buildReviewRow('Category', _selectedCategory?.name ?? '—', icon: _selectedCategory?.icon, iconColor: _selectedCategory?.color),
              const Divider(height: 24),
              _buildReviewRow('Limit Amount', CurrencyFormatter.full(limit)),
              const Divider(height: 24),
              _buildReviewRow('Billing Reset', _selectedPeriod.toUpperCase()),
              const Divider(height: 24),
              _buildReviewRow('Monthly Equiv.', CurrencyFormatter.full(monthlyEquivalent), textColor: context.successColor),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step = 3),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.separatorColor),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.circularMd),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Back', style: TextStyle(color: context.textPrimaryColor)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedCategory?.color ?? context.primaryColor,
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.circularMd),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Save Budget', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepSaving() {
    return SizedBox(
      height: 220,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isSaving) ...[
              const MLSpinner(),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Syncing with Database...',
                style: AppTypography.labelLarge.copyWith(color: context.textSecondaryColor),
              ),
            ] else ...[
              Icon(Icons.check_circle_outline_rounded, color: context.successColor, size: 64),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Budget Created Successfully!',
                style: AppTypography.titleMedium.copyWith(color: context.textPrimaryColor, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReviewRow(String label, String val, {IconData? icon, Color? iconColor, Color? textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: context.textSecondaryColor),
        ),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
            ],
            Text(
              val,
              style: AppTypography.labelLarge.copyWith(
                color: textColor ?? context.textPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
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

/// ─── Edit Budget Bottom Sheet ───────────────────────────────────────────────
class EditBudgetBottomSheet extends ConsumerStatefulWidget {
  const EditBudgetBottomSheet({
    super.key,
    required this.budget,
    required this.category,
  });

  final BudgetEntity budget;
  final Category category;

  @override
  ConsumerState<EditBudgetBottomSheet> createState() => _EditBudgetBottomSheetState();
}

class _EditBudgetBottomSheetState extends ConsumerState<EditBudgetBottomSheet> {
  late String _amountInput;
  late String _selectedPeriod;
  late bool _isEnabled;
  late bool _isArchived;
  bool _isEditingAmount = false;

  @override
  void initState() {
    super.initState();
    final lim = widget.budget.monthlyLimit;
    _amountInput = lim == lim.toInt() ? lim.toInt().toString() : lim.toStringAsFixed(2);
    if (_amountInput.endsWith('.00')) _amountInput = _amountInput.substring(0, _amountInput.length - 3);
    _selectedPeriod = widget.budget.period;
    _isEnabled = widget.budget.isEnabled;
    _isArchived = widget.budget.isArchived;
  }

  void _onDigit(String d) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_amountInput == '0') {
        if (d == '.') {
          _amountInput = '0.';
        } else {
          _amountInput = d;
        }
      } else {
        if (d == '.') {
          if (!_amountInput.contains('.')) _amountInput += '.';
        } else {
          if (_amountInput.contains('.')) {
            final parts = _amountInput.split('.');
            if (parts.length > 1 && parts[1].length >= 2) return;
          }
          if (_amountInput.length < 10) _amountInput += d;
        }
      }
    });
  }

  void _onBackspace() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_amountInput.length <= 1) {
        _amountInput = '0';
      } else {
        _amountInput = _amountInput.substring(0, _amountInput.length - 1);
      }
    });
  }

  String get _displayAmount {
    if (_amountInput == '0') return '0';
    final parts = _amountInput.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : null;

    final cleanStr = intPart.replaceAll(',', '');
    String formattedInt = cleanStr;
    if (cleanStr.isNotEmpty && cleanStr != '0' && cleanStr.length > 3) {
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

    return decPart != null ? '$formattedInt.$decPart' : (_amountInput.endsWith('.') ? '$formattedInt.' : formattedInt);
  }

  Future<void> _handleSave() async {
    final limit = double.tryParse(_amountInput) ?? 0.0;
    if (limit <= 0) return;

    HapticFeedback.mediumImpact();

    await ref.read(budgetNotifierProvider.notifier).setBudget(
          widget.budget.category,
          limit,
          period: _selectedPeriod,
          isEnabled: _isEnabled,
          isArchived: _isArchived,
        );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Updated ${widget.category.name} budget limit',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleDelete() async {
    if (widget.budget.id == null) return;
    HapticFeedback.mediumImpact();

    await ref.read(budgetNotifierProvider.notifier).deleteBudget(widget.budget.id!);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted ${widget.category.name} budget'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleDuplicate() async {
    final budgets = ref.read(liveBudgetsProvider);
    final unusedCat = AppCategories.expense.firstWhere(
      (cat) => !budgets.any((b) => b.category.toLowerCase() == cat.id.toLowerCase() && !b.isArchived),
      orElse: () => Category(id: 'other_dup', name: 'Other Duplicated', icon: Icons.copy_rounded, color: Colors.indigo),
    );

    HapticFeedback.mediumImpact();
    await ref.read(budgetNotifierProvider.notifier).duplicateBudget(
          widget.budget.id!,
          unusedCat.id,
        );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Duplicated budget to ${unusedCat.name}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
        MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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

              // Title
              Text(
                'Configure ${widget.category.name} Budget',
                style: AppTypography.titleLarge.copyWith(
                  color: context.textPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Keypad Amount toggle
              if (!_isEditingAmount) ...[
                // Settings Row
                GestureDetector(
                  onTap: () => setState(() => _isEditingAmount = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: AppRadius.card,
                      border: Border.all(color: context.separatorColor.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Limit Amount', style: AppTypography.labelLarge.copyWith(color: context.textSecondaryColor)),
                        Row(
                          children: [
                            Text(
                              CurrencyFormatter.full(double.tryParse(_amountInput) ?? 0.0),
                              style: AppTypography.titleMedium.copyWith(color: context.textPrimaryColor, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.edit_rounded, color: widget.category.color, size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Period Selector Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: AppRadius.card,
                    border: Border.all(color: context.separatorColor.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Period', style: AppTypography.labelLarge.copyWith(color: context.textSecondaryColor)),
                      DropdownButton<String>(
                        value: _selectedPeriod,
                        underline: const SizedBox(),
                        dropdownColor: context.surfaceColor,
                        style: TextStyle(color: context.textPrimaryColor, fontWeight: FontWeight.bold),
                        items: ['weekly', 'monthly', 'yearly']
                            .map((p) => DropdownMenuItem(value: p, child: Text(p.toUpperCase())))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedPeriod = val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Active Switch
                SwitchListTile(
                  title: Text('Enable Budget Tracking', style: TextStyle(color: context.textPrimaryColor, fontWeight: FontWeight.bold)),
                  subtitle: Text('Deactivating temporarily suspends limits.', style: TextStyle(color: context.textSecondaryColor, fontSize: 10)),
                  value: _isEnabled,
                  activeThumbColor: widget.category.color,
                  activeTrackColor: widget.category.color.withValues(alpha: 0.5),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    setState(() => _isEnabled = val);
                  },
                ),

                // Archive Switch
                SwitchListTile(
                  title: Text('Archive Budget', style: TextStyle(color: context.textPrimaryColor, fontWeight: FontWeight.bold)),
                  subtitle: Text('Archived budgets are hidden from the dashboard.', style: TextStyle(color: context.textSecondaryColor, fontSize: 10)),
                  value: _isArchived,
                  activeThumbColor: widget.category.color,
                  activeTrackColor: widget.category.color.withValues(alpha: 0.5),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    setState(() => _isArchived = val);
                  },
                ),

                const SizedBox(height: AppSpacing.xl),

                // Additional Operations
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _handleDuplicate,
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Duplicate'),
                      style: TextButton.styleFrom(foregroundColor: context.primaryColor),
                    ),
                    TextButton.icon(
                      onPressed: _handleDelete,
                      icon: const Icon(Icons.delete_outline_rounded, size: 16),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(foregroundColor: context.errorColor),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // Action Row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: context.separatorColor),
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.circularMd),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('Cancel', style: TextStyle(color: context.textPrimaryColor)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.category.color,
                          foregroundColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.circularMd),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Numeric keypad editing mode
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '₹',
                      style: AppTypography.displayLarge.copyWith(color: widget.category.color, fontSize: 32),
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
                const SizedBox(height: AppSpacing.lg),
                Column(
                  children: [
                    Row(children: ['1', '2', '3'].map((d) => Expanded(child: _buildDigitButton(d))).toList()),
                    const SizedBox(height: AppSpacing.md),
                    Row(children: ['4', '5', '6'].map((d) => Expanded(child: _buildDigitButton(d))).toList()),
                    const SizedBox(height: AppSpacing.md),
                    Row(children: ['7', '8', '9'].map((d) => Expanded(child: _buildDigitButton(d))).toList()),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(child: _buildDigitButton('.')),
                        Expanded(child: _buildDigitButton('0')),
                        Expanded(
                          child: IconButton(
                            onPressed: _onBackspace,
                            icon: Icon(Icons.backspace_outlined, color: context.textPrimaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => setState(() => _isEditingAmount = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.category.color,
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.circularMd),
                    ),
                    child: const Text('Confirm Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
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
