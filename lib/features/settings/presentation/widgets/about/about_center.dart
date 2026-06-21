import 'package:flutter/material.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/ui_engine/glass/glass_card.dart';
import '../../../../../core/constants/app_constants.dart';
import 'package:money_lens/core/design/design_system.dart' hide OutlinedButton;

class AboutCenter extends StatelessWidget {
  const AboutCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: GlassCard(
        isInteractive: false,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            // Logo & Title
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.primaryColor,
                        context.primaryColor.withValues(alpha: 0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.textPrimary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.appName,
                        style: AppTypography.titleLarge.copyWith(
                          color: context.textPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Version ${AppConstants.appVersion} (${AppConstants.appBuildNumber})',
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Divider(height: 1, color: context.separatorColor.withValues(alpha: 0.3)),
            const SizedBox(height: AppSpacing.md),

            // Metadata rows
            _infoRow(context, 'Developer', AppConstants.developerName),
            const SizedBox(height: AppSpacing.xs),
            _infoRow(context, 'Engine Platform', 'Flutter / Drift SQL'),
            const SizedBox(height: AppSpacing.xs),
            _infoRow(context, 'Status', 'Ready for Release'),

            const SizedBox(height: AppSpacing.md),
            Divider(height: 1, color: context.separatorColor.withValues(alpha: 0.3)),
            const SizedBox(height: AppSpacing.md),

            // Release Notes action
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.primaryColor.withValues(alpha: 0.2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                onPressed: () => _showReleaseNotesSheet(context),
                child: Text(
                  'View Release Notes',
                  style: AppTypography.labelLarge.copyWith(color: context.primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: context.textSecondaryColor),
        ),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showReleaseNotesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(
              color: context.separatorColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: context.textSecondaryColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Release Notes — Stage 6',
                  style: AppTypography.titleLarge.copyWith(
                    color: context.textPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'What\'s New in MoneyLens NEXT:',
                  style: AppTypography.bodyLarge.copyWith(
                    color: context.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _bulletPoint(context, 'Premium Glassmorphism redesign for settings control center'),
                _bulletPoint(context, 'Interactive security rating indicator'),
                _bulletPoint(context, 'Local storage optimizer and directory size tracker'),
                _bulletPoint(context, 'Structured backups supporting JSON and formatted text statements'),
                _bulletPoint(context, 'Custom theme options & accent color selectors'),
                _bulletPoint(context, 'Reduce motion controls for performance optimizations'),
                const SizedBox(height: AppSpacing.xl),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text('Great!', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bulletPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline_rounded, color: context.primaryColor, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyMedium.copyWith(color: context.textSecondaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
