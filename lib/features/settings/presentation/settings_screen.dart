import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/animated_page_wrapper.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/constants/app_constants.dart';
import 'package:go_router/go_router.dart';
import 'providers/user_profile_provider.dart';
import '../../notifications/presentation/providers/notifications_provider.dart';
import '../../notifications/presentation/settings/reminder_settings_sheet.dart';
import '../../sms_detection/presentation/providers/sms_detection_provider.dart';
import 'widgets/settings_section.dart';
import 'widgets/settings_tile.dart';
import 'widgets/theme_selector_widget.dart';
import '../../auth/presentation/change_pin_sheet.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/utils/backup_helper.dart';
import '../../expenses/presentation/providers/expense_provider.dart';
import '../../budget/presentation/providers/budget_provider.dart';

/// MoneyLens Settings Screen.
///
/// Apple Settings-inspired layout with:
/// - Profile card
/// - Appearance (theme toggle)
/// - Data section (export/import/clear)
/// - About section (version, developer)
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedPageWrapper(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.giant,
                  left: AppSpacing.pagePadding,
                  right: AppSpacing.pagePadding,
                  bottom: AppSpacing.xl,
                ),
                child: Text(
                  'Settings',
                  style: AppTypography.displayMedium.copyWith(
                    color: context.textPrimaryColor,
                  ),
                ),
              ),
            ),

            // ─── Profile Card ──────────────────────────────────────────────
            SliverToBoxAdapter(child: _ProfileCard()),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.sectionGap),
            ),

            // ─── Appearance ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: SettingsSection(
                title: 'Appearance',
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pagePadding,
                      vertical: AppSpacing.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Theme',
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const ThemeSelectorWidget(),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),

            // ─── Notifications & Detection Settings ───────────────────────────
            Consumer(
              builder: (context, ref, _) {
                final settings = ref.watch(notificationSettingsProvider);
                final smsPrivacy = ref.watch(smsPrivacySettingsProvider);

                return SliverToBoxAdapter(
                  child: SettingsSection(
                    title: 'Smart Reminders & SMS',
                    children: [
                      SettingsTile(
                        icon: Icons.notifications_rounded,
                        title: 'Enable Notifications',
                        subtitle: 'Receive summaries & alerts',
                        iconColor: const Color(0xFFFF9F0A),
                        trailing: Switch(
                          value: settings.enabled,
                          onChanged: (val) {
                            ref.read(notificationSettingsProvider.notifier).setEnabled(val);
                          },
                          activeThumbColor: context.primaryColor,
                          activeTrackColor: context.primaryColor.withValues(alpha: 0.5),
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.alarm_rounded,
                        title: 'Configure Schedules',
                        subtitle: 'Set daily / weekly / monthly times',
                        iconColor: const Color(0xFF6366F1),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (_) => const ReminderSettingsSheet(),
                          );
                        },
                      ),
                      SettingsTile(
                        icon: Icons.sms_rounded,
                        title: 'SMS Auto Detection',
                        subtitle: 'Read transaction SMS locally',
                        iconColor: const Color(0xFF34C759),
                        trailing: Switch(
                          value: smsPrivacy.detectionEnabled && smsPrivacy.permissionGranted,
                          onChanged: (val) {
                            if (!smsPrivacy.permissionGranted && val) {
                              context.push(AppConstants.routeSmsInbox);
                            } else {
                              ref.read(smsPrivacySettingsProvider.notifier).setDetectionEnabled(val);
                            }
                          },
                          activeThumbColor: context.primaryColor,
                          activeTrackColor: context.primaryColor.withValues(alpha: 0.5),
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.history_edu_rounded,
                        title: 'Notification History',
                        subtitle: 'Review streaks & unlocked badges',
                        iconColor: const Color(0xFFFF375F),
                        onTap: () => context.push(AppConstants.routeNotifications),
                      ),
                      SettingsTile(
                        icon: Icons.mark_email_read_rounded,
                        title: 'SMS Transaction Inbox',
                        subtitle: 'Review parsed messages',
                        iconColor: const Color(0xFF007AFF),
                        showDivider: false,
                        onTap: () => context.push(AppConstants.routeSmsInbox),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),

            // ─── Security ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: SettingsSection(
                title: 'Security',
                children: [
                  SettingsTile(
                    icon: Icons.vpn_key_rounded,
                    title: 'Change PIN',
                    subtitle: 'Update your 4-digit app passcode',
                    iconColor: const Color(0xFF5856D6),
                    showDivider: false,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (_) => const ChangePinSheet(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),

            // ─── Data ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: SettingsSection(
                title: 'Data',
                children: [
                  SettingsTile(
                    icon: Icons.upload_rounded,
                    title: 'Export Data',
                    subtitle: 'Export database as JSON',
                    iconColor: const Color(0xFF007AFF),
                    onTap: () async {
                      try {
                        await BackupHelper.shareBackupFile();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Backup file shared successfully')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Export failed: $e')),
                          );
                        }
                      }
                    },
                  ),
                  SettingsTile(
                    icon: Icons.download_rounded,
                    title: 'Import Data',
                    subtitle: 'Import database from JSON text',
                    iconColor: const Color(0xFF6366F1),
                    onTap: () {
                      final controller = TextEditingController();
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          backgroundColor: context.surfaceColor,
                          title: Text(
                            'Import Backup Data',
                            style: AppTypography.titleLarge.copyWith(
                              color: context.textPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Paste the JSON content of your backup below. This will overwrite all current transactions and budgets.',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: context.textSecondaryColor,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              TextField(
                                controller: controller,
                                maxLines: 8,
                                style: AppTypography.bodySmall.copyWith(
                                  color: context.textPrimaryColor,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: context.surfaceVariantColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: 'Paste JSON here...',
                                  hintStyle: TextStyle(
                                    color: context.textSecondaryColor.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(),
                              child: Text(
                                'Cancel',
                                style: AppTypography.labelLarge.copyWith(
                                  color: context.textSecondaryColor,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final jsonText = controller.text.trim();
                                if (jsonText.isEmpty) return;
                                try {
                                  await BackupHelper.deserializeData(jsonText);
                                  
                                  // Invalidate providers to refresh UI instantly
                                  ref.invalidate(expenseNotifierProvider);
                                  ref.invalidate(budgetNotifierProvider);
                                  
                                  if (context.mounted) {
                                    Navigator.of(dialogContext).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Data imported successfully')),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Failed to import: Invalid JSON format')),
                                    );
                                  }
                                }
                              },
                              child: Text(
                                'Import',
                                style: AppTypography.labelLarge.copyWith(
                                  color: context.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SettingsTile(
                    icon: Icons.delete_outline_rounded,
                    title: 'Clear All Data',
                    subtitle: 'This action cannot be undone',
                    isDestructive: true,
                    showDivider: false,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          backgroundColor: context.surfaceColor,
                          title: Text(
                            'Clear All Data?',
                            style: AppTypography.titleLarge.copyWith(
                              color: context.textPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            'This will completely wipe all transactions, analytics, preferences, notifications, security credentials, and reset MoneyLens. This action cannot be undone.',
                            style: AppTypography.bodyMedium.copyWith(
                              color: context.textSecondaryColor,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(),
                              child: Text(
                                'Cancel',
                                style: AppTypography.labelLarge.copyWith(
                                  color: context.textSecondaryColor,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.of(dialogContext).pop();
                                await ref.read(authNotifierProvider.notifier).clearAllAppData();
                              },
                              child: Text(
                                'Clear All',
                                style: AppTypography.labelLarge.copyWith(
                                  color: context.errorColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),

            // ─── About ─────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: SettingsSection(
                title: 'About',
                children: [
                  SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Version',
                    iconColor: const Color(0xFF8E8E93),
                    trailing: Text(
                      '${AppConstants.appVersion} (${AppConstants.appBuildNumber})',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                    showDivider: false,
                  ),
                ],
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

/// Profile card at the top of settings.
class _ProfileCard extends ConsumerWidget {
  void _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
    String currentName,
  ) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) {
        return AlertDialog(
          backgroundColor: context.surfaceColor,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Edit Profile',
            style: AppTypography.headlineLarge.copyWith(
              color: context.textPrimaryColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your name:',
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: controller,
                autofocus: true,
                style: AppTypography.bodyLarge.copyWith(
                  color: context.textPrimaryColor,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: context.surfaceVariantColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Name',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: context.textSecondaryColor.withValues(alpha: 0.5),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ],
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
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  ref
                      .read(userProfileNotifierProvider.notifier)
                      .updateName(newName);
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                'Save',
                style: AppTypography.labelLarge.copyWith(
                  color: context.primaryColor,
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
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileNotifierProvider);
    final displayName = profile.name.isEmpty ? 'Syam' : profile.name;
    final firstLetter = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'S';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Material(
        color: context.surfaceColor,
        borderRadius: AppRadius.card,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showEditProfileDialog(context, ref, displayName),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF007AFF), Color(0xFF0055CC)],
                    ),
                    borderRadius: AppRadius.circularFull,
                  ),
                  child: Center(
                    child: Text(
                      firstLetter,
                      style: AppTypography.headlineLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),

                // Name + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: AppTypography.titleLarge.copyWith(
                          color: context.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Personal Finance Profile',
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Edit icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.1),
                    borderRadius: AppRadius.circularFull,
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 16,
                    color: context.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
