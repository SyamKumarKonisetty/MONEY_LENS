import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../typography/app_typography.dart';

/// A premium section title text widget.
class SectionTitle extends StatelessWidget {
  final String title;
  final Color? color;

  const SectionTitle({
    super.key,
    required this.title,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.headline.copyWith(
        color: color ?? AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
