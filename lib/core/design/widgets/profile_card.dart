import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../radius/app_radius.dart';
import '../typography/app_typography.dart';
import 'avatar.dart';

/// A card displaying user identity information and active profile states.
class ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final String? avatarUrl;
  final VoidCallback? onTap;

  const ProfileCard({
    super.key,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.medium,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadius.medium,
            border: Border.all(color: AppColors.divider, width: 1.0),
          ),
          child: Row(
            children: [
              Avatar(
                name: name,
                imageUrl: avatarUrl,
                size: 48,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
