import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Settings list tile — Apple-style row with icon, title, optional subtitle.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.iconColor,
    this.onTap,
    this.isDestructive = false,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final tileIconColor = isDestructive
        ? context.errorColor
        : (iconColor ?? context.primaryColor);
    final titleColor = isDestructive
        ? context.errorColor
        : context.textPrimaryColor;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: showDivider
              ? BorderRadius.zero
              : BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePadding,
              vertical: AppSpacing.lg,
            ),
            child: Opacity(
              opacity: onTap == null ? 0.5 : 1.0,
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: tileIconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: tileIconColor, size: 17),
                  ),
                  const SizedBox(width: AppSpacing.lg),

                  // Title + subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.bodyMedium.copyWith(
                            color: titleColor,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: AppTypography.bodySmall.copyWith(
                              color: context.textSecondaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Trailing widget or default chevron
                  trailing ??
                      Icon(
                        Icons.chevron_right_rounded,
                        color: context.textSecondaryColor,
                        size: 20,
                      ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 68),
            child: Divider(
              height: 1,
              color: context.separatorColor.withValues(alpha: 0.5),
            ),
          ),
      ],
    );
  }
}
