library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design/design_system.dart';
import '../../expenses/domain/entities/expense_entity.dart';
import '../../expenses/presentation/providers/expense_provider.dart';
import '../domain/models.dart';
import 'providers/transactions_provider.dart';
import 'widgets/add_expense_bottom_sheet.dart';
import 'widgets/detail/transaction_detail_screen.dart';
import 'widgets/edit_expense_bottom_sheet.dart';
import 'widgets/filter_sort_bottom_sheet.dart';
import 'widgets/filters/smart_filter_chips.dart';
import 'widgets/header/transactions_header.dart';
import '../../../core/ui_engine/ui_engine.dart';
import 'widgets/timeline/timeline_section.dart';

/// MoneyLens NEXT — Reimagined Transactions screen assembly.
///
/// Implements full timeline grouping, gestures, and premium details transitions.
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    final query = ref.read(transactionSearchQueryProvider);
    _searchController = TextEditingController(text: query);
    _searchFocusNode = FocusNode();
    _isSearchExpanded = query.isNotEmpty;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _openAddBottomSheet(BuildContext context) {
    showAddTransactionSheet(context);
  }

  void _openEditBottomSheet(BuildContext context, WidgetRef ref, Transaction tx) {
    final expenseState = ref.read(expenseNotifierProvider);
    final expense = expenseState.expenses.cast<ExpenseEntity>().firstWhere(
          (e) => e.id.toString() == tx.id,
          orElse: () => ExpenseEntity(
            id: int.tryParse(tx.id),
            title: tx.title,
            amount: tx.amount,
            category: tx.categoryId,
            notes: tx.note,
            createdAt: tx.date,
            updatedAt: tx.date,
            transactionType: tx.type.isIncome ? 'income' : 'expense',
          ),
        );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => EditExpenseBottomSheet(expense: expense),
    );
  }

  Future<void> _deleteTransactionWithUndo(Transaction tx) async {
    final expenseId = int.tryParse(tx.id);
    if (expenseId == null) return;

    final expenseState = ref.read(expenseNotifierProvider);
    final expense = expenseState.expenses.cast<ExpenseEntity>().firstWhere(
          (e) => e.id == expenseId,
          orElse: () => ExpenseEntity(
            id: expenseId,
            title: tx.title,
            amount: tx.amount,
            category: tx.categoryId,
            notes: tx.note,
            createdAt: tx.date,
            updatedAt: tx.date,
            transactionType: tx.type.isIncome ? 'income' : 'expense',
          ),
        );

    try {
      await ref.read(expenseNotifierProvider.notifier).deleteExpense(expenseId);
    } catch (e) {
      if (mounted) {
        FloatingSnackBar.showError(context, 'Unable to delete transaction');
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted "${expense.title}"'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.card,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          action: SnackBarAction(
            label: 'Undo',
            textColor: AppColors.primaryLight,
            onPressed: () async {
              await ref.read(expenseNotifierProvider.notifier).addExpense(
                    title: expense.title,
                    amount: expense.amount,
                    category: expense.category,
                    notes: expense.notes,
                    transactionType: expense.transactionType,
                  );
            },
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _openDetailScreen(BuildContext context, Transaction tx) {
    Navigator.of(context, rootNavigator: true).push(
      SlideUpRoute(
        page: TransactionDetailScreen(
          transaction: tx,
          onEdit: () => _openEditBottomSheet(context, ref, tx),
          onDelete: () => _deleteTransactionWithUndo(tx),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(filteredTransactionsProvider);
    final activeSort = ref.watch(transactionSortProvider);
    final activeDate = ref.watch(transactionDateFilterProvider);
    final activeCategory = ref.watch(transactionCategoryFilterProvider);

    final hasActiveFilters = activeSort != TransactionSort.newest ||
        activeDate != TransactionDateFilter.all ||
        activeCategory != null;

    ref.listen<String>(transactionSearchQueryProvider, (prev, next) {
      if (_searchController.text != next) {
        _searchController.text = next;
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: RepaintBoundary(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Header
            SliverToBoxAdapter(
              child: TransactionsHeader(
                onFilterTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    useRootNavigator: true,
                    builder: (context) => const FilterSortBottomSheet(),
                  );
                },
                hasActiveFilters: hasActiveFilters,
                onSearchTap: () {
                  setState(() {
                    _isSearchExpanded = !_isSearchExpanded;
                    if (_isSearchExpanded) {
                      _searchFocusNode.requestFocus();
                    } else {
                      _searchFocusNode.unfocus();
                      _searchController.clear();
                      ref.read(transactionSearchQueryProvider.notifier).state = '';
                    }
                  });
                },
                isSearchActive: _isSearchExpanded || _searchController.text.isNotEmpty,
              ),
            ),

            // 2. Sticky Search Box
            if (_isSearchExpanded)
              SliverPersistentHeader(
                pinned: true,
                delegate: _SearchBarDelegate(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: (val) {
                    ref.read(transactionSearchQueryProvider.notifier).state = val;
                  },
                ),
              ),

            // 3. Quick Glass Category & Type Filters
            const SliverToBoxAdapter(
              child: SmartFilterChips(),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.sm),
            ),

            // 4. Scrollable Grouped Timeline or Empty State
            if (transactions.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyStateView(
                  theme: EmptyStateTheme.wallet,
                  title: 'Your financial journey starts here.',
                  subtitle: 'Try adjusting your filters, or log a new transaction.',
                  actionLabel: 'Add First Transaction',
                  onAction: () => _openAddBottomSheet(context),
                ),
              )
            else
              SliverToBoxAdapter(
                child: TimelineSection(
                  transactions: transactions,
                  onTap: (tx) => _openDetailScreen(context, tx),
                  onEdit: (tx) => _openEditBottomSheet(context, ref, tx),
                  onDelete: _deleteTransactionWithUndo,
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.massive),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  _SearchBarDelegate({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  double get minExtent => 64.0;

  @override
  double get maxExtent => 64.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
        child: Container(
          color: AppColors.backgroundDark,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            AppSpacing.sm,
            AppSpacing.pagePadding,
            AppSpacing.sm,
          ),
          alignment: Alignment.center,
          child: GlassSearch(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            compact: false,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SearchBarDelegate oldDelegate) {
    return oldDelegate.controller != controller ||
        oldDelegate.focusNode != focusNode ||
        oldDelegate.onChanged != onChanged;
  }
}
