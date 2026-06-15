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

class _SmsInboxScreenState extends ConsumerState<SmsInboxScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasTriggeredScan = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Trigger SMS scan when screen opens and permission is granted.
  void _triggerAutoScan() {
    if (_hasTriggeredScan) return;
    _hasTriggeredScan = true;

    // Use addPostFrameCallback to avoid modifying providers during build
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

    // Auto-scan when permission is granted
    if (privacy.permissionGranted) {
      _triggerAutoScan();
    }

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: !privacy.permissionGranted
          ? _buildOnboardingView(context)
          : _buildSmartInboxView(context, inbox, privacy, scanStatus),
    );
  }

  // ─── Onboarding Flow ─────────────────────────────────────────────────────

  Widget _buildOnboardingView(BuildContext context) {
    final isDark = context.isDark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: context.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.sms_rounded, size: 72, color: context.primaryColor),
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

            // Privacy Guarantees Info Box
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: AppRadius.card,
                border: Border.all(
                  color: context.separatorColor.withValues(alpha: isDark ? 0.3 : 0.6),
                ),
              ),
              child: Column(
                children: [
                  _buildPrivacyBullet(
                    context,
                    icon: Icons.security_rounded,
                    title: '100% On-Device & Private',
                    desc: 'All message parsing is done locally. No data ever leaves your phone.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildPrivacyBullet(
                    context,
                    icon: Icons.visibility_off_rounded,
                    title: 'No Personal Messages Read',
                    desc: 'We only extract structured financial amounts from registered bank SMS channels.',
                  ),
                ],
              ),
            ),
            const Spacer(),

            // Actions
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
              ),
              onPressed: () async {
                HapticFeedback.mediumImpact();
                final messenger = ScaffoldMessenger.of(context);
                // Request actual runtime permission
                final granted = await ref
                    .read(smsDetectionNotifierProvider.notifier)
                    .requestSmsPermission();
                if (!mounted) return;
                if (granted) {
                  // Permission granted — scan will auto-trigger via build
                  setState(() {
                    _hasTriggeredScan = false; // Reset so scan triggers
                  });
                } else {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                          'SMS permission denied. You can grant it from device Settings.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child:
                  const Text('Grant SMS Permission', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              child: Text(
                'Skip for Now',
                style: TextStyle(color: context.textSecondaryColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyBullet(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: context.primaryColor, size: 20),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTypography.titleMedium
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 2),
              Text(desc, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Smart Inbox View ────────────────────────────────────────────────────

  Widget _buildSmartInboxView(
    BuildContext context,
    List<SmsTransaction> inbox,
    SmsPrivacySettings privacy,
    SmsScanStatus scanStatus,
  ) {
    final pending = inbox.where((t) => t.status == SmsDetectionStatus.pending).toList();
    final approved = inbox.where((t) => t.status == SmsDetectionStatus.approved).toList();
    final rejected = inbox.where((t) => t.status == SmsDetectionStatus.rejected).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          pinned: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: context.textPrimaryColor, size: 20),
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
            // Refresh / Re-scan button
            IconButton(
              icon: scanStatus.isScanning
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.primaryColor,
                      ),
                    )
                  : Icon(Icons.refresh_rounded, color: context.textPrimaryColor, size: 22),
              onPressed: scanStatus.isScanning
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      setState(() => _hasTriggeredScan = false);
                      ref.read(smsDetectionNotifierProvider.notifier).scanDeviceSmsInbox();
                    },
              tooltip: 'Re-scan SMS',
            ),
            IconButton(
              icon: Icon(Icons.settings_outlined, color: context.textPrimaryColor, size: 22),
              onPressed: () => _showPrivacySettingsDialog(context, privacy),
            ),
          ],
        ),

        // Scan Status Banner
        SliverToBoxAdapter(
          child: _buildScanStatusBanner(context, scanStatus),
        ),

        // Tabs
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
            child: TabBar(
              controller: _tabController,
              indicatorColor: context.primaryColor,
              labelColor: context.primaryColor,
              unselectedLabelColor: context.textSecondaryColor,
              labelStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
              tabs: [
                Tab(text: 'Pending (${pending.length})'),
                Tab(text: 'Approved (${approved.length})'),
                Tab(text: 'Rejected (${rejected.length})'),
              ],
            ),
          ),
        ),

        // Tab Content
        SliverFillRemaining(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPendingList(context, pending, scanStatus),
              _buildStatusList(context, approved, 'No approved transactions yet.'),
              _buildStatusList(context, rejected, 'No rejected transactions yet.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScanStatusBanner(BuildContext context, SmsScanStatus status) {
    if (status.isScanning) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.primaryColor.withValues(alpha: 0.08),
          borderRadius: AppRadius.card,
          border: Border.all(color: context.primaryColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.primaryColor,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Scanning device SMS inbox...',
                style: AppTypography.bodySmall.copyWith(
                  color: context.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (status.errorMessage != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.errorColor.withValues(alpha: 0.08),
          borderRadius: AppRadius.card,
          border: Border.all(color: context.errorColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: context.errorColor, size: 18),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                status.errorMessage!,
                style: AppTypography.bodySmall.copyWith(
                  color: context.errorColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (status.lastScanTime != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.successColor.withValues(alpha: 0.08),
          borderRadius: AppRadius.card,
          border: Border.all(color: context.successColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: context.successColor, size: 18),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scan complete • ${DateFormat('h:mm a').format(status.lastScanTime!)}',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.successColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${status.totalSmsCount} total SMS → ${status.financialSmsCount} financial → ${status.newTransactionCount} new',
                    style: AppTypography.labelSmall.copyWith(
                      color: context.textSecondaryColor,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPendingList(BuildContext context, List<SmsTransaction> pending, SmsScanStatus scanStatus) {
    if (pending.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.mark_email_read_rounded, size: 48, color: context.textSecondaryColor),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            scanStatus.isScanning
                ? 'Scanning...'
                : scanStatus.lastScanTime != null
                    ? 'No Pending Transactions'
                    : 'Inbox is Clear!',
            style: AppTypography.titleMedium.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            scanStatus.lastScanTime != null
                ? 'All detected transactions have been reviewed.\nTap refresh (↻) to re-scan.'
                : 'Tap the refresh button to scan your SMS inbox, or use the simulator below.',
            style: AppTypography.bodySmall.copyWith(color: context.textSecondaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.giant),
          _buildSimulatorCard(context),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      itemCount: pending.length + 1, // list + simulator card at bottom
      itemBuilder: (context, index) {
        if (index == pending.length) {
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.massive),
            child: _buildSimulatorCard(context),
          );
        }

        final item = pending[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _PendingReviewCard(transaction: item),
        );
      },
    );
  }

  Widget _buildStatusList(BuildContext context, List<SmsTransaction> list, String emptyText) {
    if (list.isEmpty) {
      return Center(
        child: Text(emptyText,
            style: AppTypography.bodySmall.copyWith(color: context.textSecondaryColor)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePadding, vertical: AppSpacing.sm),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, idx) {
        final item = list[idx];
        final isApproved = item.status == SmsDetectionStatus.approved;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: AppRadius.card,
            border: Border.all(
              color: context.separatorColor.withValues(alpha: context.isDark ? 0.3 : 0.6),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isApproved ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
                color: isApproved ? context.successColor : context.errorColor,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.merchant,
                      style: AppTypography.titleMedium
                          .copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.category} • ${DateFormat('MMM d, h:mm a').format(item.timestamp)}',
                      style: AppTypography.labelSmall
                          .copyWith(color: context.textSecondaryColor, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '₹${item.amount.toStringAsFixed(0)}',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isApproved ? context.textPrimaryColor : context.textSecondaryColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimulatorCard(BuildContext context) {
    final simulatorList = [
      'Rs.499 debited from Account XX5542 for Swiggy. Ref No: UPI90988771.',
      'UPI payment of Rs.245 successful to Uber. Ref: Ref98711.',
      'INR 1,200.00 debited for Apollo Pharmacy. Ref: AP88221.',
      'Salary Rs.75,000 credited to Account XX2345. Ref: UPI776622.',
      'Rs.1,500 debited from card XX9012 at Shell Petrol Station. Ref: SH44321.',
    ];

    return Card(
      color: context.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(
            color: context.separatorColor.withValues(alpha: context.isDark ? 0.3 : 0.6)),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.terminal_rounded, color: context.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'SMS Simulator (Offline Demo)',
                  style: AppTypography.titleMedium
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tap a mock message below to simulate a bank SMS arriving. The parser will extract transaction fields instantly.',
              style:
                  AppTypography.bodySmall.copyWith(color: context.textSecondaryColor, fontSize: 11),
            ),
            const SizedBox(height: AppSpacing.md),
            ...simulatorList.map((sms) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(smsDetectionNotifierProvider.notifier).receiveIncomingSms(sms);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Simulated SMS received! Check review list.'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: context.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            sms,
                            style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showPrivacySettingsDialog(BuildContext context, SmsPrivacySettings privacy) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        title: const Text('SMS Privacy Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Enable Auto Detection'),
              subtitle:
                  const Text('Allow parser to extract details locally from new messages.'),
              value: privacy.detectionEnabled,
              onChanged: (val) {
                ref.read(smsPrivacySettingsProvider.notifier).setDetectionEnabled(val);
                Navigator.of(ctx).pop();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_sweep_rounded, color: Colors.orange),
              title: const Text('Clear SMS Cache'),
              onTap: () {
                ref.read(smsDetectionNotifierProvider.notifier).clearCache();
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('SMS Cache Cleared')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
              title: const Text('Delete Parsed Data'),
              onTap: () {
                ref.read(smsDetectionNotifierProvider.notifier).deleteParsedData();
                ref.read(smsPrivacySettingsProvider.notifier).setPermissionGranted(false);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('All parsed SMS data deleted')));
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Review Card ───────────────────────────────────────────────────────────

class _PendingReviewCard extends ConsumerStatefulWidget {
  final SmsTransaction transaction;

  const _PendingReviewCard({required this.transaction});

  @override
  ConsumerState<_PendingReviewCard> createState() => _PendingReviewCardState();
}

class _PendingReviewCardState extends ConsumerState<_PendingReviewCard> {
  bool _isEditing = false;
  late TextEditingController _merchantController;
  late TextEditingController _amountController;
  late String _category;

  @override
  void initState() {
    super.initState();
    _merchantController = TextEditingController(text: widget.transaction.merchant);
    _amountController =
        TextEditingController(text: widget.transaction.amount.toStringAsFixed(0));
    _category = widget.transaction.category;
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.transaction;

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
      'Other',
    ];

    // Ensure current category is in the list
    if (!categories.contains(_category)) {
      categories.add(_category);
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: context.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: (t.type == TransactionType.income
                          ? context.successColor
                          : context.errorColor)
                      .withValues(alpha: 0.12),
                  borderRadius: AppRadius.circularFull,
                ),
                child: Text(
                  t.type == TransactionType.income ? '↓ Credit Detected' : '↑ Debit Detected',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: t.type == TransactionType.income
                        ? context.successColor
                        : context.errorColor,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('MMM d').format(t.timestamp),
                    style: AppTypography.labelSmall.copyWith(
                      color: context.textSecondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    DateFormat('h:mm a').format(t.timestamp),
                    style: AppTypography.labelSmall.copyWith(
                      color: context.textSecondaryColor,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          if (!_isEditing) ...[
            Text(
              '₹${t.amount.toStringAsFixed(t.amount == t.amount.truncateToDouble() ? 0 : 2)} at ${t.merchant}',
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              '${_categoryEmoji(_category)} $_category',
              style: AppTypography.bodySmall
                  .copyWith(fontWeight: FontWeight.w600, color: context.primaryColor),
            ),
            if (t.senderAddress.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                'From: ${t.senderAddress}',
                style: AppTypography.labelSmall
                    .copyWith(color: context.textSecondaryColor, fontSize: 9),
              ),
            ],
          ] else ...[
            TextField(
              controller: _merchantController,
              decoration: const InputDecoration(labelText: 'Merchant'),
              style: TextStyle(color: context.textPrimaryColor),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount (₹)'),
              keyboardType: TextInputType.number,
              style: TextStyle(color: context.textPrimaryColor),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButton<String>(
              value: _category,
              dropdownColor: context.surfaceColor,
              items: categories.map((cat) {
                return DropdownMenuItem<String>(
                  value: cat,
                  child: Text(cat, style: TextStyle(color: context.textPrimaryColor)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _category = val);
                }
              },
            ),
          ],

          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.sm),

          // Message details
          Text(
            t.smsBody,
            style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.grey),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.cancel_outlined, size: 16),
                label: const Text('Reject'),
                style: TextButton.styleFrom(foregroundColor: context.errorColor),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ref.read(smsDetectionNotifierProvider.notifier).rejectTransaction(t.id);
                },
              ),
              const SizedBox(width: AppSpacing.sm),
              TextButton.icon(
                icon: Icon(_isEditing ? Icons.check_rounded : Icons.edit_rounded, size: 16),
                label: Text(_isEditing ? 'Done' : 'Edit'),
                style: TextButton.styleFrom(foregroundColor: context.primaryColor),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
              ),
              const SizedBox(width: AppSpacing.sm),
              ElevatedButton.icon(
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text('Approve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  final amt = double.tryParse(_amountController.text) ?? t.amount;
                  ref.read(smsDetectionNotifierProvider.notifier).approveTransaction(
                        t.id,
                        category: _category,
                        amount: amt,
                        merchant: _merchantController.text.trim(),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction approved and logged!'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _categoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return '🍔';
      case 'transport':
        return '🚗';
      case 'shopping':
        return '🛒';
      case 'bills':
        return '💡';
      case 'fuel':
        return '⛽';
      case 'medical':
        return '🏥';
      case 'entertainment':
        return '🎬';
      case 'groceries':
        return '🥬';
      case 'travel':
        return '✈️';
      case 'transfer':
        return '💸';
      default:
        return '📦';
    }
  }
}
