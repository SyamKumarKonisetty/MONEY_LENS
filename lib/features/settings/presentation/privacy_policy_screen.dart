import 'package:flutter/material.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
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
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Intro
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: context.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.security_rounded,
                        size: 48,
                        color: context.primaryColor,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Your Data is Yours',
                      style: AppTypography.headlineLarge.copyWith(
                        color: context.textPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Last Updated: June 2026',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.giant),

              // Section 1: Offline First
              _buildPolicySection(
                context: context,
                icon: Icons.cloud_off_rounded,
                title: 'Offline-First Storage',
                content:
                    'MoneyLens is designed to be fully functional without an internet connection. All data you enter (transactions, budgets, savings goals, preferences) is saved directly onto your device in a secure local database.',
              ),
              const SizedBox(height: AppSpacing.lg),

              // Section 2: Zero Tracking
              _buildPolicySection(
                context: context,
                icon: Icons.visibility_off_rounded,
                title: 'Zero Tracking & No Cloud Servers',
                content:
                    'We do not host any remote servers, cloud databases, or tracking systems. We do not use third-party analytics SDKs, trackers, or advertising scripts. None of your financial activity is monitored or shared.',
              ),
              const SizedBox(height: AppSpacing.lg),

              // Section 3: SMS Permission
              _buildPolicySection(
                context: context,
                icon: Icons.sms_rounded,
                title: 'Local SMS Processing',
                content:
                    'If you grant the optional SMS permission, MoneyLens reads incoming transactional messages and displays them in your Smart Inbox. This parsing and filtering happens entirely on your device. Messages are never transmitted over the network.',
              ),
              const SizedBox(height: AppSpacing.lg),

              // Section 4: Data Control
              _buildPolicySection(
                context: context,
                icon: Icons.settings_suggest_rounded,
                title: 'Full Data Control',
                content:
                    'You have absolute control over your information. You can back up your database at any time using the Export feature, import historical data from a previously created JSON backup file, or wipe the database completely from the Settings screen.',
              ),
              const SizedBox(height: AppSpacing.giant),

              // Closing Statement
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: Text(
                    'Since MoneyLens operates entirely on your physical device, it is your responsibility to secure your device with a PIN or screen lock.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondaryColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.massive),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicySection({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: context.separatorColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: context.primaryColor, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    color: context.textPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  content,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textSecondaryColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
