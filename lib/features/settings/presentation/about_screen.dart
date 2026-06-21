import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/constants/app_constants.dart';
import 'privacy_policy_screen.dart';
import 'package:money_lens/core/design/design_system.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: context.textPrimaryColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'About',
          style: AppTypography.titleLarge.copyWith(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.giant),

              // App Logo / Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.primaryColor,
                      context.primaryColor.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: context.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 48,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // App Title & Version
              Text(
                AppConstants.appName,
                style: AppTypography.displayMedium.copyWith(
                  color: context.textPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Version ${AppConstants.appVersion} (${AppConstants.appBuildNumber})',
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
              const SizedBox(height: AppSpacing.giant),

              // Info List Card
              Container(
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: AppRadius.card,
                  border: Border.all(
                    color: context.separatorColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      context: context,
                      label: 'Developer',
                      value: AppConstants.developerName,
                      showDivider: true,
                    ),
                    _buildInfoRow(
                      context: context,
                      label: 'Framework',
                      value: 'Flutter',
                      showDivider: true,
                    ),
                    _buildInfoRow(
                      context: context,
                      label: 'Database Schema',
                      value: 'Drift v7',
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.giant),

              // Interactive Action Tiles
              Container(
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: AppRadius.card,
                  border: Border.all(
                    color: context.separatorColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _buildNavigationTile(
                      context: context,
                      icon: Icons.privacy_tip_rounded,
                      title: 'Privacy Policy',
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (context) => const PrivacyPolicyScreen(),
                          ),
                        );
                      },
                      showDivider: true,
                    ),
                    _buildNavigationTile(
                      context: context,
                      icon: Icons.code_rounded,
                      title: 'Open Source Licenses',
                      onTap: () {
                        showLicensePage(
                          context: context,
                          useRootNavigator: true,
                          applicationName: AppConstants.appName,
                          applicationVersion: AppConstants.appVersion,
                          applicationIcon: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: context.primaryColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.account_balance_wallet_rounded,
                                color: AppColors.textPrimary,
                                size: 32,
                              ),
                            ),
                          ),
                          applicationLegalese:
                              '© 2026 Syam Kumar. All rights reserved.',
                        );
                      },
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.giant),

              // Bottom note
              Text(
                'MoneyLens is secure, offline-first, and private.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondaryColor.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required String label,
    required String value,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            color: context.separatorColor.withValues(alpha: 0.3),
            height: 1,
            indent: AppSpacing.lg,
            endIndent: AppSpacing.lg,
          ),
      ],
    );
  }

  Widget _buildNavigationTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool showDivider,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          leading: Icon(icon, color: context.primaryColor),
          title: Text(
            title,
            style: AppTypography.bodyLarge.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: context.textSecondaryColor,
          ),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(
            color: context.separatorColor.withValues(alpha: 0.3),
            height: 1,
            indent: AppSpacing.lg,
            endIndent: AppSpacing.lg,
          ),
      ],
    );
  }
}
