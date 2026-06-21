import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/ui_engine/glass/glass_card.dart';
import '../../../../notifications/presentation/providers/notifications_provider.dart';
import 'package:money_lens/core/design/design_system.dart' hide OutlinedButton;

class NotificationCenter extends ConsumerWidget {
  const NotificationCenter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

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
                    Text('Notification Center', style: AppTypography.titleMedium.copyWith(color: context.textPrimaryColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('Manage alert channel configurations', style: AppTypography.bodySmall.copyWith(color: context.textSecondaryColor)),
                  ],
                ),
                Icon(Icons.notifications_active_outlined, color: context.primaryColor, size: 20),
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
                      Text('Allow Notifications', style: AppTypography.bodyMedium.copyWith(color: context.textPrimaryColor, fontWeight: FontWeight.w700)),
                      Text('Master switch for app notifications', style: AppTypography.bodySmall.copyWith(color: context.textSecondaryColor)),
                    ],
                  ),
                ),
                Switch(
                  value: settings.masterEnabled,
                  onChanged: (val) async {
                    await notifier.updateSettings(settings.copyWith(masterEnabled: val));
                  },
                  activeThumbColor: context.primaryColor,
                  activeTrackColor: context.primaryColor.withValues(alpha: 0.4),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Divider(height: 1, color: context.separatorColor.withValues(alpha: 0.3)),
            const SizedBox(height: AppSpacing.md),

            Opacity(
              opacity: settings.masterEnabled ? 1.0 : 0.4,
              child: Column(
                children: [
                  _switchTile(context, 'Daily Reminders', 'Evening reminder to log transactions', settings.dailyEnabled, settings.masterEnabled ? (val) => notifier.updateSettings(settings.copyWith(dailyEnabled: val)) : null),
                  _switchTile(context, 'Budget Warnings', 'Alert when category limits reach 80%', settings.budgetWarningEnabled, settings.masterEnabled ? (val) => notifier.updateSettings(settings.copyWith(budgetWarningEnabled: val)) : null),
                  _switchTile(context, 'Goal Achievement', 'Celebration alert on savings goal hit', settings.goalAchievementEnabled, settings.masterEnabled ? (val) => notifier.updateSettings(settings.copyWith(goalAchievementEnabled: val)) : null),
                  _switchTile(context, 'Weekly Summary', 'Receive spending breakdowns on Sundays', settings.weeklySummaryEnabled, settings.masterEnabled ? (val) => notifier.updateSettings(settings.copyWith(weeklySummaryEnabled: val)) : null),
                  _switchTile(context, 'Monthly Reports', 'Comprehensive financial dashboard insights', settings.monthlyReportEnabled, settings.masterEnabled ? (val) => notifier.updateSettings(settings.copyWith(monthlyReportEnabled: val)) : null),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _switchTile(BuildContext context, String title, String subtitle, bool value, ValueChanged<bool>? onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyMedium.copyWith(color: context.textPrimaryColor)),
                Text(subtitle, style: AppTypography.caption.copyWith(color: context.textSecondaryColor, fontSize: 10)),
              ],
            ),
          ),
          SizedBox(
            height: 24,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: context.primaryColor,
              activeTrackColor: context.primaryColor.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }


}
