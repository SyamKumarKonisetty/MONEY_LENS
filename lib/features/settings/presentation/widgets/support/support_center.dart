import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/ui_engine/glass/glass_card.dart';
import '../../privacy_policy_screen.dart';
import '../../terms_conditions_screen.dart';

class SupportCenter extends ConsumerStatefulWidget {
  const SupportCenter({super.key});

  @override
  ConsumerState<SupportCenter> createState() => _SupportCenterState();
}

class _SupportCenterState extends ConsumerState<SupportCenter> {
  @override
  Widget build(BuildContext context) {
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
                    Text(
                      'Support & Trust',
                      style: AppTypography.titleMedium.copyWith(
                        color: context.textPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Contact developers & review terms',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.contact_support_outlined, color: context.primaryColor, size: 20),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Divider(height: 1, color: context.separatorColor.withValues(alpha: 0.3)),
            const SizedBox(height: AppSpacing.md),

            // Rate MoneyLens
            _tile(
              icon: Icons.star_outline_rounded,
              title: 'Rate MoneyLens',
              subtitle: 'Show your support on Google Play',
              onTap: () {
                _showMsg('Thank you for your support! Rating will be available after launch.');
              },
            ),

            // Share App
            _tile(
              icon: Icons.share_outlined,
              title: 'Share App with Friends',
              subtitle: 'Invite others to manage finance locally',
              onTap: () async {
                try {
                  await SharePlus.instance.share(
                    ShareParams(
                      text: 'Track your personal finance locally and securely with MoneyLens! Download now.',
                    ),
                  );
                } catch (e) {
                  _showMsg('Could not share: $e', isError: true);
                }
              },
            ),

            // Contact Developer
            _tile(
              icon: Icons.email_outlined,
              title: 'Developer Support',
              subtitle: 'Email support@moneylens.app',
              onTap: _showContactDialog,
            ),

            // Terms & Conditions
            _tile(
              icon: Icons.gavel_rounded,
              title: 'Terms & Conditions',
              subtitle: 'Review legal usage disclaimers',
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) => const TermsConditionsScreen(),
                  ),
                );
              },
            ),

            // Privacy Policy
            _tile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'Read about offline security vault',
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
                  Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 16),
          ],
        ),
      ),
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Contact Developer',
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
              'Have feedback, questions, or bug reports? Reach out to us!',
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Icon(Icons.email_rounded, color: context.primaryColor, size: 20),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'support@moneylens.app',
                  style: AppTypography.bodyLarge.copyWith(
                    color: context.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(Icons.code_rounded, color: context.primaryColor, size: 20),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'github.com/moneylens/app',
                  style: AppTypography.bodyLarge.copyWith(
                    color: context.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Close',
              style: AppTypography.labelLarge.copyWith(
                color: context.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMsg(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? context.errorColor : context.primaryColor,
      ),
    );
  }
}
