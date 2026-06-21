import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/ui_engine/glass/glass_card.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/database/app_database.dart';
import '../../../../sms_detection/presentation/providers/sms_detection_provider.dart';
import '../../../../notifications/presentation/settings/reminder_settings_sheet.dart';

class SmartInboxSettings extends ConsumerStatefulWidget {
  const SmartInboxSettings({super.key});

  @override
  ConsumerState<SmartInboxSettings> createState() => _SmartInboxSettingsState();
}

class _SmartInboxSettingsState extends ConsumerState<SmartInboxSettings> {
  int _processedCount = 0;
  int _ignoredCount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final db = AppDatabase.instance;
      final processed = await (db.select(db.rawSmsTable)..where((t) => t.processed.equals(true))).get();
      final ignored = await (db.select(db.rawSmsTable)..where((t) => t.ignored.equals(true))).get();
      if (mounted) {
        setState(() {
          _processedCount = processed.length;
          _ignoredCount = ignored.length;
        });
      }
    } catch (_) {}
  }

  Future<void> _clearInbox() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(smsDetectionNotifierProvider.notifier).clearCache();
      await _loadStats();
      _showMsg('SMS Inbox reset successfully');
    } catch (e) {
      _showMsg('Reset failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMsg(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? context.errorColor : context.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final smsPrivacy = ref.watch(smsPrivacySettingsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: GlassCard(
        isInteractive: false,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Smart Inbox & SMS', style: AppTypography.titleMedium.copyWith(color: context.textPrimaryColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('Local SMS detection engine', style: AppTypography.bodySmall.copyWith(color: context.textSecondaryColor)),
                  ],
                ),
                Icon(Icons.sms_failed_outlined, color: context.primaryColor, size: 20),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Divider(height: 1, color: context.separatorColor.withValues(alpha: 0.3)),
            const SizedBox(height: AppSpacing.md),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SMS Auto Detection', style: AppTypography.bodyMedium.copyWith(color: context.textPrimaryColor, fontWeight: FontWeight.w600)),
                      Text('Auto-parse transactions offline', style: AppTypography.bodySmall.copyWith(color: context.textSecondaryColor)),
                    ],
                  ),
                ),
                Switch(
                  value: smsPrivacy.detectionEnabled && smsPrivacy.permissionGranted,
                  onChanged: (val) async {
                    if (val) {
                      final g = await ref.read(smsDetectionNotifierProvider.notifier).requestSmsPermission();
                      if (g) {
                        await ref.read(smsPrivacySettingsProvider.notifier).setDetectionEnabled(true);
                      } else {
                        if (context.mounted) context.push(AppConstants.routeSmsInbox);
                      }
                    } else {
                      await ref.read(smsPrivacySettingsProvider.notifier).setDetectionEnabled(false);
                    }
                    setState(() {});
                  },
                  activeThumbColor: context.primaryColor,
                  activeTrackColor: context.primaryColor.withValues(alpha: 0.4),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            _statRow('Processed Transactions', '$_processedCount parsed'),
            const SizedBox(height: AppSpacing.xs),
            _statRow('Ignored Messages', '$_ignoredCount ignored'),
            const SizedBox(height: AppSpacing.md),
            Divider(height: 1, color: context.separatorColor.withValues(alpha: 0.3)),
            const SizedBox(height: AppSpacing.md),

            _actionTile(
              icon: Icons.schedule_rounded,
              title: 'Reminder Schedules',
              subtitle: 'Set daily / weekly alert times',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => const ReminderSettingsSheet(),
                );
              },
            ),
            _actionTile(
              icon: Icons.mark_email_read_outlined,
              title: 'SMS Transaction Inbox',
              subtitle: 'Verify or add from raw logs',
              onTap: () => context.push(AppConstants.routeSmsInbox),
            ),
            _actionTile(
              icon: Icons.refresh_rounded,
              title: 'Reset SMS Cache',
              subtitle: 'Clear all processed raw logs',
              onTap: _clearInbox,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(color: context.textSecondaryColor)),
        Text(value, style: AppTypography.bodySmall.copyWith(color: context.textPrimaryColor, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isLoading ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(icon, color: context.textSecondaryColor, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyMedium.copyWith(color: context.textPrimaryColor, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: AppTypography.bodySmall.copyWith(color: context.textSecondaryColor)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}
