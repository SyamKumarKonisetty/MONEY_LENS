import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../domain/models.dart';
import '../providers/transactions_provider.dart';

// ─── Public entry-point ───────────────────────────────────────────────────────

/// Shows the premium Add Transaction sheet.
/// Call this instead of instantiating the widget directly.
void showAddTransactionSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: false,
    builder: (_) => const AddExpenseBottomSheet(),
  );
}

// ─── Main Widget ──────────────────────────────────────────────────────────────

/// Premium Add Transaction bottom sheet.
///
/// Features:
/// - Expense / Income type toggle
/// - Wallet-style large amount display
/// - Category icon grid (no dropdowns)
/// - Live transaction preview card
/// - Mandatory category selection
class AddExpenseBottomSheet extends ConsumerStatefulWidget {
  const AddExpenseBottomSheet({super.key});

  @override
  ConsumerState<AddExpenseBottomSheet> createState() =>
      _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends ConsumerState<AddExpenseBottomSheet>
    with SingleTickerProviderStateMixin {
  // ─── State ────────────────────────────────────────────────────────────────
  TransactionType _type = TransactionType.expense;
  Category? _selectedCategory; // null = not yet selected
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _titleFocus = FocusNode();
  final _notesFocus = FocusNode();
  final _dummyFocus = FocusNode();

  // Amount is stored as a raw input string (e.g. '0', '10.5', etc.)
  String _amountInput = '0';

  bool _isSaving = false;

  // ─── Animations & Income Quotes ───────────────────────────────────────────
  late final AnimationController _typeToggleController;
  late String _currentQuote;

  static const List<String> _incomeQuotes = [
    'Keep going. Every rupee earned is a step toward freedom.',
    "Your future self will thank you for today's effort.",
    'Income grows where consistency goes.',
    'Small wins compound into big wealth.',
    'Earn more. Save more. Stress less.',
    'Progress beats perfection.',
    "You're building wealth one transaction at a time.",
    'Discipline today. Freedom tomorrow.',
    'Every income entry tells a story of hard work.',
    'Money follows value. Keep creating value.',
  ];

  String _getRandomQuote() {
    final rand = math.Random();
    return _incomeQuotes[rand.nextInt(_incomeQuotes.length)];
  }

  @override
  void initState() {
    super.initState();
    _typeToggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _currentQuote = _getRandomQuote();
  }

  @override
  void dispose() {
    _typeToggleController.dispose();
    _titleController.dispose();
    _notesController.dispose();
    _titleFocus.dispose();
    _notesFocus.dispose();
    _dummyFocus.dispose();
    super.dispose();
  }

  // ─── Computed ─────────────────────────────────────────────────────────────

  double get _amount {
    if (_amountInput.isEmpty || _amountInput == '0') return 0.0;
    return double.tryParse(_amountInput) ?? 0.0;
  }

  String get _amountDisplay {
    if (_amountInput.isEmpty || _amountInput == '0') return '0';
    if (_amountInput.contains('.')) {
      final parts = _amountInput.split('.');
      final whole = parts[0];
      final formattedWhole = _formatIndianRupees(whole);
      if (parts.length > 1) {
        return '$formattedWhole.${parts[1]}';
      } else {
        return '$formattedWhole.';
      }
    } else {
      return _formatIndianRupees(_amountInput);
    }
  }

  String _formatIndianRupees(String wholeNumberStr) {
    if (wholeNumberStr.isEmpty || wholeNumberStr == '0') return '0';
    final cleanStr = wholeNumberStr.replaceAll(',', '');
    if (cleanStr.length <= 3) return cleanStr;
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
    return buffer.toString();
  }

  List<Category> get _categories =>
      _type == TransactionType.expense
          ? AppCategories.expense
          : AppCategories.income;

  Color get _typeColor =>
      _type == TransactionType.expense
          ? const Color(0xFFFF3B30)
          : const Color(0xFF34C759);

  bool get _isValid =>
      _amount > 0 &&
      _selectedCategory != null;

  // ─── Numpad ───────────────────────────────────────────────────────────────

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
            if (parts.length > 1 && parts[1].length >= 2) {
              return;
            }
          }
          _amountInput += d;
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

  // ─── Submit ───────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_isValid || _isSaving) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    // Fallback title to selected category name with type suffix if empty
    final String title;
    if (_titleController.text.trim().isEmpty) {
      final categoryName = _selectedCategory!.name;
      title = _type == TransactionType.expense
          ? '$categoryName Expense'
          : '$categoryName Income';
    } else {
      title = _titleController.text.trim();
    }
    final notes = _notesController.text.trim();

    await ref
        .read(expenseNotifierProvider.notifier)
        .addExpense(
          title: title,
          amount: _amount,
          category: _selectedCategory!.name,
          notes: notes.isEmpty ? null : notes,
          transactionType: _type.name,
        );

    if (mounted) Navigator.of(context).pop();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenHeight = context.screenHeight;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    // Responsive gap: tighter on small screens, comfortable on large.
    final vGap = (screenHeight * 0.018).clamp(8.0, 20.0);

    return SafeArea(
      top: false,
      child: Focus(
        focusNode: _dummyFocus,
        autofocus: true, // Auto-focuses this dummy node so keyboard doesn't pop up
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: screenHeight * 0.95),
          child: Container(
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                bottom: bottomInset > 0
                    ? AppSpacing.lg
                    : safeBottom + AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHandle(),
                  _buildTypeToggle(),
                  SizedBox(height: vGap),
                  _buildAmountDisplay(),
                  SizedBox(height: vGap * 0.8),
                  if (_type == TransactionType.expense) ...[
                    _buildTitleField(),
                    SizedBox(height: vGap * 0.8),
                    _buildNotesField(),
                    SizedBox(height: vGap * 0.8),
                  ] else ...[
                    _buildMotivationalCard(),
                    SizedBox(height: vGap * 0.8),
                  ],
                  _buildCategorySection(),
                  SizedBox(height: vGap * 0.8),
                  _buildPreviewCard(),
                  SizedBox(height: vGap * 0.8),
                  _buildNumpad(),
                  SizedBox(height: vGap * 0.8),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  // ─── Handle ───────────────────────────────────────────────────────────────

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: context.separatorColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  // ─── Type Toggle ──────────────────────────────────────────────────────────

  Widget _buildTypeToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.lg,
        AppSpacing.pagePadding,
        0,
      ),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: context.surfaceVariantColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          children: [
            // Sliding indicator
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: _type == TransactionType.expense
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: _typeColor,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: [
                      BoxShadow(
                        color: _typeColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Labels row
            Row(
              children: [
                _typeTab(TransactionType.expense, '↑  Expense'),
                _typeTab(TransactionType.income, '↓  Income'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeTab(TransactionType t, String label) {
    final isActive = _type == t;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_type == t) return;
          HapticFeedback.selectionClick();
          setState(() {
            _type = t;
            _selectedCategory = null; // reset when switching type
            if (t == TransactionType.income) {
              _currentQuote = _getRandomQuote();
            }
          });
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: AppTypography.labelLarge.copyWith(
            color: isActive ? Colors.white : context.textSecondaryColor,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
          child: Center(child: Text(label)),
        ),
      ),
    );
  }


  // ─── Amount Display ───────────────────────────────────────────────────────

  Widget _buildAmountDisplay() {
    final isZero = _amount == 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₹',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: isZero
                      ? context.textSecondaryColor
                      : context.textPrimaryColor,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 100),
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: isZero ? 48 : 52,
                  fontWeight: FontWeight.w700,
                  color: isZero
                      ? context.textSecondaryColor.withValues(alpha: 0.5)
                      : _typeColor,
                  letterSpacing: -2,
                  height: 1,
                ),
                child: Text(_amountDisplay),
              ),
            ],
          ),
        ),
        if (isZero) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: context.primaryColor.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_downward_rounded,
                  color: context.primaryColor,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'Enter Amount First',
                  style: AppTypography.labelSmall.copyWith(
                    color: context.primaryColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ─── Title Field ──────────────────────────────────────────────────────────

  Widget _buildTitleField() {
    final isZero = _amount == 0;
    return GestureDetector(
      onTap: isZero ? _showAmountRequiredFeedback : null,
      behavior: HitTestBehavior.opaque,
      child: IgnorePointer(
        ignoring: isZero,
        child: Opacity(
          opacity: isZero ? 0.4 : 1.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
            child: TextField(
              controller: _titleController,
              focusNode: _titleFocus,
              enabled: !isZero,
              style: AppTypography.bodyLarge.copyWith(
                color: context.textPrimaryColor,
                fontWeight: FontWeight.w500,
              ),
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'What was this for?',
                hintStyle: AppTypography.bodyLarge.copyWith(
                  color: context.textSecondaryColor.withValues(alpha: 0.6),
                ),
                filled: true,
                fillColor: context.surfaceVariantColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: _typeColor, width: 1.5),
                ),
                prefixIcon: Icon(
                  isZero ? Icons.lock_outline_rounded : Icons.edit_rounded,
                  color: context.textSecondaryColor.withValues(alpha: isZero ? 0.4 : 0.8),
                  size: 18,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    final isZero = _amount == 0;
    return GestureDetector(
      onTap: isZero ? _showAmountRequiredFeedback : null,
      behavior: HitTestBehavior.opaque,
      child: IgnorePointer(
        ignoring: isZero,
        child: Opacity(
          opacity: isZero ? 0.4 : 1.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
            child: TextField(
              controller: _notesController,
              focusNode: _notesFocus,
              enabled: !isZero,
              style: AppTypography.bodyLarge.copyWith(
                color: context.textPrimaryColor,
                fontWeight: FontWeight.w500,
              ),
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Notes (optional)',
                hintStyle: AppTypography.bodyLarge.copyWith(
                  color: context.textSecondaryColor.withValues(alpha: 0.6),
                ),
                filled: true,
                fillColor: context.surfaceVariantColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: _typeColor, width: 1.5),
                ),
                prefixIcon: Icon(
                  isZero ? Icons.lock_outline_rounded : Icons.notes_rounded,
                  color: context.textSecondaryColor.withValues(alpha: isZero ? 0.4 : 0.8),
                  size: 18,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMotivationalCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF34C759).withValues(alpha: 0.08),
                const Color(0xFF007AFF).withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF34C759).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Color(0xFF34C759),
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Text(
                    _currentQuote,
                    key: ValueKey<String>(_currentQuote),
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textPrimaryColor.withValues(alpha: 0.9),
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAmountRequiredFeedback() {
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.amberAccent, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Please enter an amount first',
                style: AppTypography.bodyMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2C2C2E),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
          bottom: 16,
          left: 16,
          right: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
    );
  }


  // ─── Category Grid ────────────────────────────────────────────────────────

  Widget _buildCategorySection() {
    final cats = _categories;
    final isZero = _amount == 0;

    final recentlyUsed = ref.watch(recentlyUsedCategoriesProvider);
    final recentlyUsedFiltered = recentlyUsed
        .where((cat) => cats.any((c) => c.id == cat.id))
        .take(4)
        .toList();

    return GestureDetector(
      onTap: isZero ? _showAmountRequiredFeedback : null,
      behavior: HitTestBehavior.opaque,
      child: IgnorePointer(
        ignoring: isZero,
        child: Opacity(
          opacity: isZero ? 0.4 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recently Used strip
              if (recentlyUsedFiltered.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                  child: Text(
                    'RECENTLY USED',
                    style: AppTypography.labelSmall.copyWith(
                      color: context.textSecondaryColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                    physics: const BouncingScrollPhysics(),
                    itemCount: recentlyUsedFiltered.length,
                    separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, i) {
                      final cat = recentlyUsedFiltered[i];
                      final isSelected = _selectedCategory?.id == cat.id;
                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cat.icon,
                              size: 14,
                              color: isSelected ? Colors.white : cat.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              cat.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? Colors.white
                                    : context.textPrimaryColor,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        selected: isSelected,
                        selectedColor: cat.color,
                        backgroundColor: context.surfaceColor,
                        checkmarkColor: Colors.white,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : context.separatorColor.withValues(alpha: 0.5),
                          ),
                        ),
                        onSelected: (selected) {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedCategory = cat);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                child: Row(
                  children: [
                    Text(
                      _selectedCategory == null
                          ? 'Select Category'
                          : 'All Categories',
                      style: AppTypography.labelSmall.copyWith(
                        color: _selectedCategory == null
                            ? (isZero ? context.textSecondaryColor : context.errorColor.withValues(alpha: 0.8))
                            : context.textSecondaryColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (_selectedCategory != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedCategory!.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _selectedCategory!.name,
                          style: AppTypography.labelSmall.copyWith(
                            color: _selectedCategory!.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pagePadding,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: cats.length,
                  separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final cat = cats[i];
                    final isSelected = _selectedCategory?.id == cat.id;
                    return _CategoryChip(
                      category: cat,
                      isSelected: isSelected,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedCategory = cat);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // ─── Preview Card ─────────────────────────────────────────────────────────

  Widget _buildPreviewCard() {
    final hasTitle = _titleController.text.trim().isNotEmpty;
    final hasAmount = _amount > 0;
    final hasCat = _selectedCategory != null;

    if (!hasTitle && !hasAmount && !hasCat) return const SizedBox.shrink();

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: _typeColor.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _typeColor.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              // Category icon or placeholder
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: hasCat
                      ? _selectedCategory!.color.withValues(alpha: 0.15)
                      : context.surfaceVariantColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  hasCat
                      ? _selectedCategory!.icon
                      : Icons.category_outlined,
                  color: hasCat
                      ? _selectedCategory!.color
                      : context.textSecondaryColor.withValues(alpha: 0.4),
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasTitle 
                          ? _titleController.text.trim() 
                          : (hasCat ? _selectedCategory!.name : (_type == TransactionType.expense ? 'Transaction' : 'Income')),
                      style: AppTypography.titleMedium.copyWith(
                        color: (hasTitle || hasCat)
                            ? context.textPrimaryColor
                            : context.textSecondaryColor.withValues(alpha: 0.4),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      hasCat ? _selectedCategory!.name : 'No category',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                hasAmount
                    ? '${_type == TransactionType.expense ? '-' : '+'}₹$_amountDisplay'
                    : '₹0.00',
                style: AppTypography.titleMedium.copyWith(
                  color: hasAmount ? _typeColor : context.textSecondaryColor.withValues(alpha: 0.3),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Numpad ───────────────────────────────────────────────────────────────

  Widget _buildNumpad() {
    // Responsive key height: shorter on small screens.
    final keyH = (context.screenHeight * 0.062).clamp(42.0, 52.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        children: [
          _numRow(['1', '2', '3'], keyH),
          const SizedBox(height: AppSpacing.xs),
          _numRow(['4', '5', '6'], keyH),
          const SizedBox(height: AppSpacing.xs),
          _numRow(['7', '8', '9'], keyH),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              _numKey('.', keyH),
              _numKey('0', keyH),
              _backspaceKey(keyH),
            ],
          ),
        ],
      ),
    );
  }

  Widget _numRow(List<String> digits, double keyH) {
    return Row(
      children: digits.map((d) => _numKey(d, keyH)).toList(),
    );
  }

  Widget _numKey(String digit, double keyH) {
    return Expanded(
      child: _NumpadKey(
        label: digit,
        keyHeight: keyH,
        onTap: () => _onDigit(digit),
        textColor: context.textPrimaryColor,
      ),
    );
  }

  Widget _backspaceKey(double keyH) {
    return Expanded(
      child: _NumpadKey(
        icon: Icons.backspace_rounded,
        keyHeight: keyH,
        onTap: _onBackspace,
        textColor: context.textSecondaryColor,
      ),
    );
  }

  // ─── Save Button ──────────────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          color: _isValid ? _typeColor : context.surfaceVariantColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isValid
              ? [
                  BoxShadow(
                    color: _typeColor.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isValid ? _submit : null,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isValid
                          ? 'Save ${_type == TransactionType.expense ? 'Expense' : 'Income'}'
                          : _amount == 0
                              ? 'Enter an amount'
                              : 'Select a category',
                      style: AppTypography.titleMedium.copyWith(
                        color: _isValid
                            ? Colors.white
                            : context.textSecondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

}

// ─── Category Chip ────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 64,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected
              ? category.color.withValues(alpha: 0.15)
              : context.surfaceVariantColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? category.color
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? category.color.withValues(alpha: 0.2)
                    : category.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                category.icon,
                color: category.color,
                size: 18,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              category.name,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 9.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? category.color
                    : context.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Numpad Key ───────────────────────────────────────────────────────────────

class _NumpadKey extends StatefulWidget {
  const _NumpadKey({
    this.label,
    this.icon,
    required this.onTap,
    required this.textColor,
    this.keyHeight = 52,
  });

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final Color textColor;
  final double keyHeight;

  @override
  State<_NumpadKey> createState() => _NumpadKeyState();
}

class _NumpadKeyState extends State<_NumpadKey>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: widget.keyHeight,
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: widget.label != null
                ? Text(
                    widget.label!,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: widget.textColor,
                    ),
                  )
                : Icon(
                    widget.icon,
                    color: widget.textColor,
                    size: 22,
                  ),
          ),
        ),
      ),
    );
  }
}
