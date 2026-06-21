import 'package:flutter/material.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
          'Terms & Conditions',
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
                        Icons.description_rounded,
                        size: 48,
                        color: context.primaryColor,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Terms of Service',
                      style: AppTypography.headlineLarge.copyWith(
                        color: context.textPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Effective: June 2026',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.giant),

              // Section 1: Usage License
              _buildTermsSection(
                context: context,
                icon: Icons.gavel_rounded,
                title: '1. Usage License',
                content:
                    'MoneyLens is provided for personal, non-commercial financial tracking. You are granted a limited, non-exclusive, non-transferable license to run this software on your personal device.',
              ),
              const SizedBox(height: AppSpacing.lg),

              // Section 2: On-Device Data & Liability
              _buildTermsSection(
                context: context,
                icon: Icons.storage_rounded,
                title: '2. On-Device Storage & Backups',
                content:
                    'MoneyLens operates entirely offline. All data is saved on your device\'s local storage. You are solely responsible for backing up your data using the CSV Export feature. The developer is not liable for data loss caused by device failures, app deletion, or operating system reinstalls.',
              ),
              const SizedBox(height: AppSpacing.lg),

              // Section 3: Disclaimer of Warranty
              _buildTermsSection(
                context: context,
                icon: Icons.warning_amber_rounded,
                title: '3. Disclaimer of Warranties',
                content:
                    'The application is provided "AS IS" and "AS AVAILABLE", without warranties of any kind, either express or implied. We do not guarantee that financial math, parsing logic, or category reports will be completely error-free or suited to specific accounting standards.',
              ),
              const SizedBox(height: AppSpacing.lg),

              // Section 4: Updates & Termination
              _buildTermsSection(
                context: context,
                icon: Icons.update_rounded,
                title: '4. Updates & Modifications',
                content:
                    'The developer reserves the right to modify or terminate support for the application or its features at any time. Changes to the database version or core schema will be migrated locally without user intervention where possible.',
              ),
              const SizedBox(height: AppSpacing.giant),

              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: Text(
                    'By using MoneyLens, you accept these terms in full. If you disagree, please uninstall the app.',
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

  Widget _buildTermsSection({
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
