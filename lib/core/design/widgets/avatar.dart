import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../typography/app_typography.dart';

/// Reusable profile avatar component supporting network images or character initials.
class Avatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double size;

  const Avatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 40.0,
  });

  String get initials {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Center(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? ClipOval(
                child: Image.network(
                  imageUrl!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Text(
                    initials,
                    style: AppTypography.button.copyWith(
                      color: AppColors.primary,
                      fontSize: size * 0.4,
                    ),
                  ),
                ),
              )
            : Text(
                initials,
                style: AppTypography.button.copyWith(
                  color: AppColors.primary,
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
