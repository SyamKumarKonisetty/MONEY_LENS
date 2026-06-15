import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../transactions/domain/models.dart';
import 'providers/sms_detection_provider.dart';

class SmsInboxScreen extends ConsumerStatefulWidget {
  const SmsInboxScreen({super.key});

  @override
  ConsumerState<SmsInboxScreen> createState() => _SmsInboxScreenState();
}

class _SmsInboxScreenState extends ConsumerState<SmsInboxScreen> {
  bool _hasTriggeredScan = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _triggerAutoScan() {
    if (_hasTriggeredScan) return;
    _hasTriggeredScan = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(smsDetectionNotifierProvider.notifier).scanDeviceSmsInbox();
    });
  }

  @override
  Widget build(BuildContext context) {
    final privacy = ref.watch(smsPrivacySettingsProvider);
    final inbox = ref.watch(smsDetectionNotifierProvider);
    final scanStatus = ref.watch(smsScanStatusProvider);

    if (privacy.permissionGranted) {
      _triggerAutoScan();
    }

    final pendingTransactions = inbox;
    final approvedTransactions = <SmsTransaction>[];
    final rejectedTransactions = <SmsTransaction>[];

    // Log values per tasks
    debugPrint('Pending Count: ${pendingTransactions.length}');
    debugPrint('Approved Count: ${approvedTransactions.length}');
    debugPrint('Rejected Count: ${rejectedTransactions.length}');

    // Filter list by search query
    final filteredInbox = inbox.where((sms) {
      final sender = (sms.senderAddress ?? 'Unknown').toLowerCase();
      final body = sms.smsBody.toLowerCase();
      return sender.contains(_searchQuery) || body.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.textPrimaryColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Smart SMS Inbox',
          style: AppTypography.titleLarge.copyWith(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: scanStatus.isScanning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.refresh_rounded, color: context.textPrimaryColor, size: 22),
            onPressed: scanStatus.isScanning
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    ref.read(smsDetectionNotifierProvider.notifier).scanDeviceSmsInbox();
                  },
            tooltip: 'Scan SMS',
          ),
        ],
      ),
      body: !privacy.permissionGranted
          ? _buildOnboardingView(context)
          : Column(
              children: [
                // Scan Banner
                _buildScanStatusBanner(context, scanStatus),

                // Search Box
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.pagePadding),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: context.textPrimaryColor),
                    decoration: InputDecoration(
                      hintText: 'Search by sender or message content...',
                      hintStyle: TextStyle(color: context.textSecondaryColor.withValues(alpha: 0.6)),
                      prefixIcon: Icon(Icons.search_rounded, color: context.textSecondaryColor),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close_rounded, color: context.textSecondaryColor),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      border: OutlineInputBorder(borderRadius: AppRadius.card),
                      filled: true,
                      fillColor: context.surfaceColor,
                    ),
                  ),
                ),

                // List
                Expanded(
                  child: filteredInbox.isEmpty
                      ? _buildEmptyState(scanStatus)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                          itemCount: filteredInbox.length,
                          itemBuilder: (context, index) {
                            final transaction = filteredInbox[index];
                            debugPrint('Rendering transaction: ${transaction.id}');
                            debugPrint('Amount: ${transaction.amount}');
                            debugPrint('Merchant: ${transaction.merchant}');

                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: _SmsCard(transaction: transaction),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(SmsScanStatus scanStatus) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.sms_failed_rounded, size: 48, color: context.textSecondaryColor),
        const SizedBox(height: AppSpacing.lg),
        Text(
          scanStatus.isScanning ? 'Scanning...' : 'No SMS messages',
          style: AppTypography.titleMedium.copyWith(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Ensure permission is granted and tap scan to fetch messages.',
          style: AppTypography.bodySmall.copyWith(color: context.textSecondaryColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOnboardingView(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Center(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.sms_rounded, size: 72, color: context.primaryColor),
              ),
            ),
            const SizedBox(height: AppSpacing.giant),
            Text(
              'Smart SMS Detection',
              style: AppTypography.displayMedium.copyWith(
                color: context.textPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Reduce manual entry by auto-detecting transactions directly from your bank SMS notifications.',
              style: AppTypography.bodyMedium.copyWith(color: context.textSecondaryColor),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
              ),
              onPressed: () async {
                HapticFeedback.mediumImpact();
                final messenger = ScaffoldMessenger.of(context);
                final granted = await ref
                    .read(smsDetectionNotifierProvider.notifier)
                    .requestSmsPermission();
                if (!mounted) return;
                if (granted) {
                  setState(() {
                    _hasTriggeredScan = false;
                  });
                } else {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('SMS permission denied. You can grant it from device Settings.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Grant SMS Permission', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Skip for Now',
                  style: TextStyle(color: context.textSecondaryColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanStatusBanner(BuildContext context, SmsScanStatus status) {
    if (status.isScanning) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding, vertical: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.primaryColor.withValues(alpha: 0.08),
          borderRadius: AppRadius.card,
          border: Border.all(color: context.primaryColor.withValues(alpha: 0.2)),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: AppSpacing.md),
            Text(
              'Scanning device SMS inbox...',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _SmsCard extends ConsumerWidget {
  final SmsTransaction transaction;

  const _SmsCard({required this.transaction});

  void _showMarkDialog(BuildContext context, WidgetRef ref, TransactionType type) {
    final amountController = TextEditingController(
      text: transaction.amount != null ? transaction.amount!.toStringAsFixed(0) : '',
    );
    final merchantController = TextEditingController(
      text: (transaction.senderAddress ?? 'Unknown').replaceAll('-', ' '),
    );
    String selectedCategory = type == TransactionType.income ? 'Salary' : 'Other';

    final categories = [
      'Food',
      'Transport',
      'Shopping',
      'Bills',
      'Fuel',
      'Medical',
      'Entertainment',
      'Groceries',
      'Travel',
      'Transfer',
      'Salary',
      'Other',
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: context.surfaceColor,
          title: Text(
            type == TransactionType.expense ? 'Confirm Expense' : 'Confirm Income',
            style: TextStyle(color: context.textPrimaryColor, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: context.textPrimaryColor),
                  decoration: InputDecoration(
                    labelText: 'Amount (₹)',
                    labelStyle: TextStyle(color: context.textSecondaryColor),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: merchantController,
                  style: TextStyle(color: context.textPrimaryColor),
                  decoration: InputDecoration(
                    labelText: type == TransactionType.expense ? 'Merchant / Paid To' : 'Sender / Source',
                    labelStyle: TextStyle(color: context.textSecondaryColor),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  dropdownColor: context.surfaceColor,
                  style: TextStyle(color: context.textPrimaryColor),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(color: context.textSecondaryColor),
                  ),
                  items: categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      selectedCategory = val;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel', style: TextStyle(color: context.textSecondaryColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: context.primaryColor),
              onPressed: () {
                final amtStr = amountController.text.trim();
                final amt = double.tryParse(amtStr);
                if (amt == null || amt <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid amount.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                ref.read(smsDetectionNotifierProvider.notifier).approveTransaction(
                      transaction.id,
                      category: selectedCategory,
                      amount: amt,
                      merchant: merchantController.text.trim(),
                      type: type,
                    );

                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Transaction successfully logged as ${type.name}!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateFormat('dd-MMM-yyyy').format(transaction.timestamp);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: context.separatorColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sender: ${transaction.senderAddress ?? 'Unknown'}',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                dateStr,
                style: AppTypography.labelSmall.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          Text(
            transaction.smsBody,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            alignment: WrapAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ref.read(smsDetectionNotifierProvider.notifier).ignoreTransaction(transaction.id);
                },
                style: TextButton.styleFrom(foregroundColor: context.textSecondaryColor),
                child: const Text('Ignore', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                onPressed: () => _showMarkDialog(context, ref, TransactionType.income),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.successColor.withValues(alpha: 0.1),
                  foregroundColor: context.successColor,
                  elevation: 0,
                ),
                child: const Text('Mark Income', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                onPressed: () => _showMarkDialog(context, ref, TransactionType.expense),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: const Text('Mark Expense', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
