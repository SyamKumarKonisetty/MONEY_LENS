import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/animated_page_wrapper.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/search_bar_widget.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../expenses/presentation/providers/expense_provider.dart';
import '../domain/models.dart';
import 'providers/transactions_provider.dart';
import 'widgets/filter_chip_bar.dart';
import 'widgets/date_section_header.dart';
import 'widgets/transaction_list_tile.dart';
import 'widgets/add_expense_bottom_sheet.dart';
import 'widgets/edit_expense_bottom_sheet.dart';

/// MoneyLens Transactions Screen with full CRUD integrations.
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openAddBottomSheet(BuildContext context) {
    showAddTransactionSheet(context);
  }

  void _openEditBottomSheet(
    BuildContext context,
    WidgetRef ref,
    Transaction tx,
  ) {
    final expenseState = ref.read(expenseNotifierProvider);
    final expense = expenseState.expenses.firstWhere(
      (e) => e.id.toString() == tx.id,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditExpenseBottomSheet(expense: expense),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Transaction tx,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: context.surfaceColor,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'Delete Expense',
            style: AppTypography.titleLarge.copyWith(
              color: context.textPrimaryColor,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this expense of ${CurrencyFormatter.full(tx.amount)}?',
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTypography.labelLarge.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final id = int.tryParse(tx.id);
                if (id != null) {
                  ref.read(expenseNotifierProvider.notifier).deleteExpense(id);
                }
                Navigator.of(context).pop();
              },
              child: Text(
                'Delete',
                style: AppTypography.labelLarge.copyWith(
                  color: context.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = ref.watch(groupedTransactionsProvider);
    final dateKeys = grouped.keys.toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddBottomSheet(context),
        backgroundColor: context.primaryColor,
        elevation: 6,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
        label: const Text(
          'Add Expense',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      body: AnimatedPageWrapper(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Status bar + title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.giant,
                  left: AppSpacing.pagePadding,
                  right: AppSpacing.pagePadding,
                  bottom: AppSpacing.xl,
                ),
                child: Text(
                  'Transactions',
                  style: AppTypography.displayMedium.copyWith(
                    color: context.textPrimaryColor,
                  ),
                ),
              ),
            ),

            // Search
            const SliverToBoxAdapter(child: SearchBarWidget()),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

            // Filters
            const SliverToBoxAdapter(child: FilterChipBar()),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

            // Empty state or grouped list
            if (grouped.isEmpty)
              SliverFillRemaining(
                child: EmptyStateWidget(
                  icon: Icons.receipt_long_outlined,
                  title: 'No Transactions Found',
                  subtitle:
                      'Try adjusting your filters, or add a new transaction.',
                  actionLabel: 'Add Transaction',
                  onAction: () => _openAddBottomSheet(context),
                  accentColor: const Color(0xFF007AFF),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, sectionIndex) {
                  final dateKey = dateKeys[sectionIndex];
                  final items = grouped[dateKey]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DateSectionHeader(dateLabel: dateKey),
                      ...items.asMap().entries.map((entry) {
                        final tx = entry.value;
                        return StaggeredListItem(
                          index: entry.key + (sectionIndex * 3),
                          baseDelay: 50,
                          child: Dismissible(
                            key: Key(tx.id),
                            direction: DismissDirection.horizontal,
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.startToEnd) {
                                // Swipe Right -> Duplicate
                                HapticFeedback.mediumImpact();
                                final expenseState = ref.read(expenseNotifierProvider);
                                final expense = expenseState.expenses.firstWhere(
                                  (e) => e.id.toString() == tx.id,
                                );
                                await ref.read(expenseNotifierProvider.notifier).addExpense(
                                  title: expense.title,
                                  amount: expense.amount,
                                  category: expense.category,
                                  notes: expense.notes,
                                  transactionType: expense.transactionType,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Duplicated "${expense.title}"'),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: context.isDark ? const Color(0xFF1C1C1E) : Colors.white,
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                                return false; // Slide back immediately
                              } else {
                                // Swipe Left -> Delete
                                HapticFeedback.mediumImpact();
                                final expenseId = int.tryParse(tx.id);
                                if (expenseId != null) {
                                  final expenseState = ref.read(expenseNotifierProvider);
                                  final expense = expenseState.expenses.firstWhere((e) => e.id == expenseId);
                                  await ref.read(expenseNotifierProvider.notifier).deleteExpense(expenseId);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Deleted "${expense.title}"'),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: context.isDark ? const Color(0xFF1C1C1E) : Colors.white,
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        action: SnackBarAction(
                                          label: 'Undo',
                                          textColor: context.primaryColor,
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
                                return true; // Dismiss
                              }
                            },
                            background: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: AppSpacing.xl),
                              decoration: BoxDecoration(
                                color: context.successColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.copy_rounded, color: context.successColor, size: 20),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    'Duplicate',
                                    style: TextStyle(
                                      color: context.successColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            secondaryBackground: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: AppSpacing.xl),
                              decoration: BoxDecoration(
                                color: context.errorColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: context.errorColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Icon(Icons.delete_rounded, color: context.errorColor, size: 20),
                                ],
                              ),
                            ),
                            child: GestureDetector(
                              onTap: () => _openEditBottomSheet(context, ref, tx),
                              onLongPress: () =>
                                  _showDeleteConfirmation(context, ref, tx),
                              child: TransactionListTile(transaction: tx),
                            ),
                          ),
                        );
                      }),
                      const Padding(
                        padding: EdgeInsets.only(
                          left: 84,
                          right: AppSpacing.pagePadding,
                        ),
                        child: Divider(height: 1),
                      ),
                    ],
                  );
                }, childCount: dateKeys.length),
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
