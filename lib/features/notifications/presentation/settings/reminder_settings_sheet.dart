import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../providers/notifications_provider.dart';

class ReminderSettingsSheet extends ConsumerWidget {
  const ReminderSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);
    final isDark = context.isDark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
        top: AppSpacing.lg,
        left: AppSpacing.pagePadding,
        right: AppSpacing.pagePadding,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: context.separatorColor,
                borderRadius: AppRadius.circularFull,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reminder Settings',
                style: AppTypography.titleLarge.copyWith(
                  color: context.textPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Switch(
                value: settings.enabled,
                onChanged: (val) => notifier.setEnabled(val),
                activeThumbColor: context.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Configure daily, weekly, and monthly notification preferences.',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          Opacity(
            opacity: settings.enabled ? 1.0 : 0.5,
            child: AbsorbPointer(
              absorbing: !settings.enabled,
              child: Column(
                children: [
                  // Reminder Frequency
                  _buildSettingTile(
                    context,
                    icon: Icons.repeat_rounded,
                    title: 'Reminder Frequency',
                    subtitle: settings.reminderFrequency,
                    onTap: () {
                      _showFrequencyPicker(
                        context,
                        ref,
                        settings.reminderFrequency,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Reminder Time
                  _buildSettingTile(
                    context,
                    icon: Icons.alarm_rounded,
                    title: 'Reminder Time',
                    subtitle: settings.reminderTime.format(context),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: settings.reminderTime,
                      );
                      if (picked != null) {
                        await notifier.setReminderTime(picked);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Daily summary reminder
                  _buildSettingTile(
                    context,
                    icon: Icons.wb_twilight_rounded,
                    title: 'Daily Summary Time',
                    subtitle: settings.dailyTime.format(context),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: settings.dailyTime,
                      );
                      if (picked != null) {
                        await notifier.setDailyTime(picked);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Weekly report reminder
                  _buildSettingTile(
                    context,
                    icon: Icons.bar_chart_rounded,
                    title: 'Weekly Summary Schedule',
                    subtitle: settings.weeklyDayAndTime,
                    onTap: () {
                      _showWeeklyPicker(
                        context,
                        ref,
                        settings.weeklyDayAndTime,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Monthly summary reminder
                  _buildSettingTile(
                    context,
                    icon: Icons.calendar_month_rounded,
                    title: 'Monthly Summary Schedule',
                    subtitle: settings.monthlyDayAndTime,
                    onTap: () {
                      _showMonthlyPicker(
                        context,
                        ref,
                        settings.monthlyDayAndTime,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: context.separatorColor.withValues(
            alpha: context.isDark ? 0.3 : 0.6,
          ),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: context.primaryColor, size: 20),
        title: Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              subtitle,
              style: AppTypography.bodyMedium.copyWith(
                color: context.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  void _showFrequencyPicker(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) {
    final options = ['Daily', 'Weekly', 'Monthly', 'Never'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        title: const Text('Choose Reminder Frequency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) {
            return ListTile(
              title: Text(opt),
              trailing: current == opt
                  ? Icon(Icons.check_rounded, color: context.primaryColor)
                  : null,
              onTap: () {
                ref
                    .read(notificationSettingsProvider.notifier)
                    .setReminderFrequency(opt);
                Navigator.of(ctx).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showWeeklyPicker(BuildContext context, WidgetRef ref, String current) {
    final days = ['Friday', 'Saturday', 'Sunday', 'Monday'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        title: const Text('Choose Weekly Report Day'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: days.map((d) {
            return ListTile(
              title: Text(d),
              trailing: current.startsWith(d)
                  ? Icon(Icons.check_rounded, color: context.primaryColor)
                  : null,
              onTap: () {
                ref
                    .read(notificationSettingsProvider.notifier)
                    .setWeeklyTime('$d 10:00');
                Navigator.of(ctx).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showMonthlyPicker(BuildContext context, WidgetRef ref, String current) {
    final options = [
      'Last Day 10:00',
      '1st of Next Month 09:00',
      '28th of Month 18:00',
    ];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        title: const Text('Choose Monthly Summary Schedule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) {
            return ListTile(
              title: Text(opt),
              trailing: current == opt
                  ? Icon(Icons.check_rounded, color: context.primaryColor)
                  : null,
              onTap: () {
                ref
                    .read(notificationSettingsProvider.notifier)
                    .setMonthlyTime(opt);
                Navigator.of(ctx).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
