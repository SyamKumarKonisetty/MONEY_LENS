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
      child: SingleChildScrollView(
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
                  'Smart Notifications',
                  style: AppTypography.titleLarge.copyWith(
                    color: context.textPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: settings.masterEnabled,
                  onChanged: (val) async {
                    await notifier.updateSettings(settings.copyWith(masterEnabled: val));
                  },
                  activeThumbColor: context.primaryColor,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your personal finance assistant. Configure what you want to hear about.',
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Opacity(
              opacity: settings.masterEnabled ? 1.0 : 0.5,
              child: AbsorbPointer(
                absorbing: !settings.masterEnabled,
                child: Column(
                  children: [
                    // Daily Reminder
                    _buildSwitchTile(
                      context,
                      icon: Icons.wb_twilight_rounded,
                      title: 'Daily Reminder',
                      subtitle: 'Remind me to log today\'s expenses',
                      value: settings.dailyEnabled,
                      onChanged: (val) async {
                        await notifier.updateSettings(settings.copyWith(dailyEnabled: val));
                      },
                      timeStr: settings.dailyTime.format(context),
                      onTimeTap: () async {
                        final picked = await showTimePicker(context: context, initialTime: settings.dailyTime);
                        if (picked != null) {
                          await notifier.updateSettings(settings.copyWith(dailyTime: picked));
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Budget Warning
                    _buildSwitchTile(
                      context,
                      icon: Icons.warning_amber_rounded,
                      title: 'Budget Warnings',
                      subtitle: 'Alert me when spending exceeds 80%',
                      value: settings.budgetWarningEnabled,
                      onChanged: (val) async {
                        await notifier.updateSettings(settings.copyWith(budgetWarningEnabled: val));
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Weekly Summary
                    _buildSwitchTile(
                      context,
                      icon: Icons.bar_chart_rounded,
                      title: 'Weekly Summary',
                      subtitle: 'Get a recap of this week\'s finances',
                      value: settings.weeklySummaryEnabled,
                      onChanged: (val) async {
                        await notifier.updateSettings(settings.copyWith(weeklySummaryEnabled: val));
                      },
                      timeStr: '${_getWeekdayName(settings.weeklyDay)} ${settings.weeklyTime.format(context)}',
                      onTimeTap: () => _showWeeklyPicker(context, ref, settings),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Monthly Report
                    _buildSwitchTile(
                      context,
                      icon: Icons.calendar_month_rounded,
                      title: 'Monthly Report',
                      subtitle: 'Detailed end-of-month breakdown',
                      value: settings.monthlyReportEnabled,
                      onChanged: (val) async {
                        await notifier.updateSettings(settings.copyWith(monthlyReportEnabled: val));
                      },
                      timeStr: 'Day ${settings.monthlyDay} ${settings.monthlyTime.format(context)}',
                      onTimeTap: () => _showMonthlyPicker(context, ref, settings),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Goal Achievement
                    _buildSwitchTile(
                      context,
                      icon: Icons.emoji_events_rounded,
                      title: 'Goal Achievement',
                      subtitle: 'Celebrate staying within budgets',
                      value: settings.goalAchievementEnabled,
                      onChanged: (val) async {
                        await notifier.updateSettings(settings.copyWith(goalAchievementEnabled: val));
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Inactive Reminder
                    _buildSwitchTile(
                      context,
                      icon: Icons.waving_hand_rounded,
                      title: 'Inactive Reminder',
                      subtitle: 'Check in if I forget to log for 3 days',
                      value: settings.inactiveReminderEnabled,
                      onChanged: (val) async {
                        await notifier.updateSettings(settings.copyWith(inactiveReminderEnabled: val));
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? timeStr,
    VoidCallback? onTimeTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: context.separatorColor.withValues(
            alpha: context.isDark ? 0.3 : 0.6,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: context.primaryColor, size: 24),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(color: context.textSecondaryColor, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: context.primaryColor,
              ),
            ],
          ),
          if (timeStr != null && onTimeTap != null) ...[
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: onTimeTap,
              borderRadius: AppRadius.button,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Scheduled: $timeStr',
                      style: AppTypography.labelMedium.copyWith(color: context.primaryColor, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.edit_rounded, size: 14, color: context.primaryColor),
                  ],
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return 'Sun';
    }
  }

  void _showWeeklyPicker(BuildContext context, WidgetRef ref, NotificationSettings settings) {
    // Simplified picker logic, ideally we would use a more robust UI.
    ref.read(notificationSettingsProvider.notifier).updateSettings(settings.copyWith(
      weeklyDay: 7, // Set to Sunday for now
    ));
  }

  void _showMonthlyPicker(BuildContext context, WidgetRef ref, NotificationSettings settings) {
    ref.read(notificationSettingsProvider.notifier).updateSettings(settings.copyWith(
      monthlyDay: 31, // Set to last day for now
    ));
  }
}
