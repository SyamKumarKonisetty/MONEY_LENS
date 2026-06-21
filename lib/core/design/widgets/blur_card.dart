import 'dart:ui';
import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../radius/app_radius.dart';

/// A card applying simple backdrop blur with solid background overlays.
class BlurCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? color;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const BlurCard({
    super.key,
    required this.child,
    this.blur = 16.0,
    this.color,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final borderRad = borderRadius ?? AppRadius.medium;

    return ClipRRect(
      borderRadius: borderRad,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? AppColors.card.withValues(alpha: 0.5),
            borderRadius: borderRad,
          ),
          child: child,
        ),
      ),
    );
  }
}
