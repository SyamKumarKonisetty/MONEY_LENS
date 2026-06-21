import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/animated_page_wrapper.dart';
import 'widgets/profile/profile_hero.dart';
import 'widgets/security/security_center.dart';
import 'widgets/backup/backup_restore.dart';
import 'widgets/notifications/smart_inbox_settings.dart';
import 'widgets/notifications/notification_center.dart';
import 'widgets/support/support_center.dart';
import 'widgets/about/about_center.dart';

/// MoneyLens Settings Control Center.
///
/// Modular dashboard settings layout compiling custom glassmorphic settings widgets.
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
            // Control Center Header Title
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

            // Profile Hero Widget Card
            const SliverToBoxAdapter(
              child: ProfileHero(),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.lg),
            ),

            // Security Shield Score & Controls
            const SliverToBoxAdapter(
              child: SecurityCenter(),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.lg),
            ),

            // Backup & Recovery Database Actions
            const SliverToBoxAdapter(
              child: BackupRestoreCard(),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.lg),
            ),

            // SMS Auto Detection Logs & Statistics
            const SliverToBoxAdapter(
              child: SmartInboxSettings(),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.lg),
            ),

            // Notification Channels Toggles & Toast Preview
            const SliverToBoxAdapter(
              child: NotificationCenter(),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.lg),
            ),

            // Support, Legal T&C, and Privacy Policy
            const SliverToBoxAdapter(
              child: SupportCenter(),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.lg),
            ),

            // Release Versions & Developer Brand Badges
            const SliverToBoxAdapter(
              child: AboutCenter(),
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
