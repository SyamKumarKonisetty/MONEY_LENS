import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../../transactions/domain/models.dart';

class MockReceipt {
  final String merchant;
  final String category;
  final double amount;
  final String invoiceNo;
  final String gstNo;
  final String paymentMethod;
  final List<String> items;
  final String confidence; // 'High', 'Medium', 'Low'

  MockReceipt({
    required this.merchant,
    required this.category,
    required this.amount,
    required this.invoiceNo,
    required this.gstNo,
    required this.paymentMethod,
    required this.items,
    required this.confidence,
  });
}

class ScanComingSoonSheet extends ConsumerStatefulWidget {
  const ScanComingSoonSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ScanComingSoonSheet(),
    );
  }

  @override
  ConsumerState<ScanComingSoonSheet> createState() =>
      _ScanComingSoonSheetState();
}

class _ScanComingSoonSheetState extends ConsumerState<ScanComingSoonSheet>
    with SingleTickerProviderStateMixin {
  // Demo Receipts list
  final List<MockReceipt> _demoReceipts = [
    MockReceipt(
      merchant: 'Swiggy',
      category: 'Food',
      amount: 485.00,
      invoiceNo: 'SW-9812739',
      gstNo: '29AABCX9981F1Z2',
      paymentMethod: 'UPI (GPay)',
      confidence: 'High Confidence (98%)',
      items: [
        'Paneer Butter Masala - ₹320.00',
        'Butter Naan x2 - ₹100.00',
        'Delivery & Taxes - ₹65.00',
      ],
    ),
    MockReceipt(
      merchant: 'Uber Ride',
      category: 'Transport',
      amount: 245.00,
      invoiceNo: 'UB-481920',
      gstNo: '27AABCT4321A1Z5',
      paymentMethod: 'Paytm Wallet',
      confidence: 'High Confidence (95%)',
      items: ['UberGo Ride Fare - ₹210.00', 'Surge Pricing - ₹35.00'],
    ),
    MockReceipt(
      merchant: 'Apollo Pharmacy',
      category: 'Medical',
      amount: 780.00,
      invoiceNo: 'AP-89102',
      gstNo: '29APOLO1234K1Z0',
      paymentMethod: 'Credit Card',
      confidence: 'Medium Confidence (82%)',
      items: [
        'Multivitamins - ₹450.00',
        'Cough Syrup - ₹180.00',
        'Face Masks - ₹150.00',
      ],
    ),
    MockReceipt(
      merchant: 'Shell Petrol Station',
      category: 'Fuel',
      amount: 1500.00,
      invoiceNo: 'SH-55421',
      gstNo: '29SHELL5678Q1Z1',
      paymentMethod: 'Debit Card',
      confidence: 'High Confidence (97%)',
      items: ['Power Petrol 13.2L - ₹1500.00'],
    ),
  ];

  int _selectedReceiptIndex = 0;
  bool _isScanning = false;
  bool _isCropping = true;
  bool _showReview = false;
  double _scanProgress = 0.0;
  Timer? _scanTimer;

  // Controllers for Review screen fields
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();
  final _invoiceController = TextEditingController();
  final _gstController = TextEditingController();
  final _paymentController = TextEditingController();
  String _selectedCategory = 'Food';

  // Animation controller for laser scanning line
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _animController.dispose();
    _merchantController.dispose();
    _amountController.dispose();
    _invoiceController.dispose();
    _gstController.dispose();
    _paymentController.dispose();
    super.dispose();
  }

  void _startScan() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isCropping = false;
      _isScanning = true;
      _scanProgress = 0.0;
    });

    _animController.repeat(reverse: true);

    const steps = 100;
    final interval = const Duration(seconds: 2) ~/ steps;
    _scanTimer = Timer.periodic(interval, (timer) {
      if (!mounted) return;
      setState(() {
        _scanProgress += 1 / steps;
        if (_scanProgress >= 1.0) {
          _scanProgress = 1.0;
          timer.cancel();
          _finishScan();
        }
      });
    });
  }

  void _finishScan() {
    _animController.stop();
    final receipt = _demoReceipts[_selectedReceiptIndex];
    setState(() {
      _isScanning = false;
      _showReview = true;
      _merchantController.text = receipt.merchant;
      _amountController.text = receipt.amount.toStringAsFixed(0);
      _invoiceController.text = receipt.invoiceNo;
      _gstController.text = receipt.gstNo;
      _paymentController.text = receipt.paymentMethod;
      _selectedCategory = receipt.category;
    });
    HapticFeedback.mediumImpact();
  }

  Future<void> _saveTransaction() async {
    final merchant = _merchantController.text.trim();
    final amt = double.tryParse(_amountController.text) ?? 0.0;
    if (merchant.isEmpty || amt <= 0.0) return;

    HapticFeedback.mediumImpact();

    await ref
        .read(expenseNotifierProvider.notifier)
        .addExpense(
          title: merchant,
          amount: amt,
          category: _selectedCategory,
          notes:
              'OCR Scanned • Inv: ${_invoiceController.text} • GST: ${_gstController.text}',
          transactionType: 'expense',
        );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Scanned and saved $merchant of ${CurrencyFormatter.full(amt)}',
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

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
        MediaQuery.of(context).padding.bottom + bottomInset + AppSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handlebar
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

            if (_isCropping)
              _buildCropScreen()
            else if (_isScanning)
              _buildScanningScreen()
            else if (_showReview)
              _buildReviewScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildCropScreen() {
    final isDark = context.isDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm Receipt Image',
          style: AppTypography.titleLarge.copyWith(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select a demo receipt to simulate OCR camera capture.',
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Horizontal Demo Receipt Picker
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _demoReceipts.length,
            itemBuilder: (context, idx) {
              final r = _demoReceipts[idx];
              final isSelected = _selectedReceiptIndex == idx;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedReceiptIndex = idx);
                },
                child: Container(
                  width: 130,
                  margin: const EdgeInsets.only(right: AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.primaryColor.withValues(alpha: 0.12)
                        : context.surfaceColor,
                    borderRadius: AppRadius.card,
                    border: Border.all(
                      color: isSelected
                          ? context.primaryColor
                          : context.separatorColor.withValues(
                              alpha: isDark ? 0.3 : 0.6,
                            ),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.merchant,
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.textPrimaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.compact(r.amount),
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Thermal Receipt Mock Representation
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
            borderRadius: AppRadius.card,
            border: Border.all(
              color: context.separatorColor.withValues(alpha: 0.3),
            ),
          ),
          child: Stack(
            children: [
              _buildThermalReceiptView(_demoReceipts[_selectedReceiptIndex]),
              // Simulated crop boundaries handles
              Positioned(
                left: 0,
                top: 0,
                child: Icon(
                  Icons.crop_free_rounded,
                  color: context.primaryColor,
                  size: 28,
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Icon(
                  Icons.crop_free_rounded,
                  color: context.primaryColor,
                  size: 28,
                ),
              ),
              Positioned(
                left: 0,
                bottom: 0,
                child: Icon(
                  Icons.crop_free_rounded,
                  color: context.primaryColor,
                  size: 28,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Icon(
                  Icons.crop_free_rounded,
                  color: context.primaryColor,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.circularMd,
                    ),
                    side: BorderSide(color: context.separatorColor),
                    foregroundColor: context.textPrimaryColor,
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _startScan,
                  icon: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Confirm & Scan OCR',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScanningScreen() {
    return Column(
      children: [
        Text(
          'Scanning Receipt...',
          style: AppTypography.titleLarge.copyWith(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Extracting items, GST, payment, and totals.',
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Scanning receipt with animated laser overlay
        AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? const Color(0xFF1C1C1E)
                        : Colors.grey[50],
                    borderRadius: AppRadius.card,
                    border: Border.all(
                      color: context.separatorColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: _buildThermalReceiptView(
                    _demoReceipts[_selectedReceiptIndex],
                  ),
                ),
                // Laser line overlay
                Positioned(
                  left: 0,
                  right: 0,
                  top: _animController.value * 230,
                  child: Container(
                    height: 3.5,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.8),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.xl),

        // Scan Progress Indicator
        LinearProgressIndicator(
          value: _scanProgress,
          backgroundColor: context.surfaceVariantColor,
          color: Colors.green,
          minHeight: 6,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          '${(_scanProgress * 100).toStringAsFixed(0)}% Analyzed',
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildReviewScreen() {
    final receipt = _demoReceipts[_selectedReceiptIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Review OCR Results',
              style: AppTypography.titleLarge.copyWith(
                color: context.textPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                borderRadius: AppRadius.circularFull,
              ),
              child: Text(
                receipt.confidence,
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Form Fields
        TextField(
          controller: _merchantController,
          style: AppTypography.bodyLarge.copyWith(
            color: context.textPrimaryColor,
          ),
          decoration: InputDecoration(
            labelText: 'Merchant Name',
            labelStyle: TextStyle(color: context.textSecondaryColor),
            filled: true,
            fillColor: context.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: AppRadius.circularMd,
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: AppTypography.bodyLarge.copyWith(
                  color: context.textPrimaryColor,
                ),
                decoration: InputDecoration(
                  labelText: 'Amount (₹)',
                  labelStyle: TextStyle(color: context.textSecondaryColor),
                  filled: true,
                  fillColor: context.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.circularMd,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: AppRadius.card,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    dropdownColor: context.surfaceColor,
                    items: AppCategories.expense.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat.name,
                        child: Text(
                          cat.name,
                          style: TextStyle(color: context.textPrimaryColor),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedCategory = val);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        TextField(
          controller: _invoiceController,
          style: AppTypography.bodyLarge.copyWith(
            color: context.textPrimaryColor,
          ),
          decoration: InputDecoration(
            labelText: 'Invoice Number',
            labelStyle: TextStyle(color: context.textSecondaryColor),
            filled: true,
            fillColor: context.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: AppRadius.circularMd,
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _gstController,
                style: AppTypography.bodyLarge.copyWith(
                  color: context.textPrimaryColor,
                ),
                decoration: InputDecoration(
                  labelText: 'GSTIN',
                  labelStyle: TextStyle(color: context.textSecondaryColor),
                  filled: true,
                  fillColor: context.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.circularMd,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextField(
                controller: _paymentController,
                style: AppTypography.bodyLarge.copyWith(
                  color: context.textPrimaryColor,
                ),
                decoration: InputDecoration(
                  labelText: 'Payment Method',
                  labelStyle: TextStyle(color: context.textSecondaryColor),
                  filled: true,
                  fillColor: context.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.circularMd,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _isCropping = true;
                      _showReview = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.circularMd,
                    ),
                    side: BorderSide(color: context.separatorColor),
                    foregroundColor: context.textPrimaryColor,
                  ),
                  child: const Text(
                    'Retake',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _saveTransaction,
                  icon: const Icon(Icons.check_rounded, color: Colors.white),
                  label: const Text(
                    'Save Transaction',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThermalReceiptView(MockReceipt r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Text(
                r.merchant.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'monospace',
                  color: Colors.black54,
                ),
              ),
              const Text(
                'OFFICIAL RECEIPT',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'monospace',
                  color: Colors.black38,
                ),
              ),
            ],
          ),
        ),
        const Divider(color: Colors.black26, thickness: 1, height: 24),
        Text(
          'Invoice: ${r.invoiceNo}',
          style: const TextStyle(
            fontSize: 10,
            fontFamily: 'monospace',
            color: Colors.black54,
          ),
        ),
        Text(
          'GSTIN: ${r.gstNo}',
          style: const TextStyle(
            fontSize: 10,
            fontFamily: 'monospace',
            color: Colors.black54,
          ),
        ),
        Text(
          'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
          style: const TextStyle(
            fontSize: 10,
            fontFamily: 'monospace',
            color: Colors.black54,
          ),
        ),
        const Divider(color: Colors.black26, thickness: 1, height: 24),
        ...r.items.map(
          (it) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    it.split(' - ')[0],
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color: Colors.black54,
                    ),
                  ),
                ),
                Text(
                  it.split(' - ')[1],
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(color: Colors.black26, thickness: 1, height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'TOTAL',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                fontFamily: 'monospace',
                color: Colors.black87,
              ),
            ),
            Text(
              '₹${r.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                fontFamily: 'monospace',
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Paid via: ${r.paymentMethod}',
          style: const TextStyle(
            fontSize: 10,
            fontFamily: 'monospace',
            color: Colors.black38,
          ),
        ),
        const SizedBox(height: 10),
        const Center(
          child: Text(
            '*** THANK YOU ***',
            style: TextStyle(
              fontSize: 9,
              fontFamily: 'monospace',
              color: Colors.black26,
            ),
          ),
        ),
      ],
    );
  }
}
