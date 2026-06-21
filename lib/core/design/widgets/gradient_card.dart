import 'package:flutter/material.dart';
import '../colors/app_gradients.dart';
import '../radius/app_radius.dart';
import '../theme/app_shadows.dart';

/// A premium card styled with custom linear gradients and soft glow shadows.
class GradientCard extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool hasGlow;

  const GradientCard({
    super.key,
    required this.child,
    this.gradient,
    this.padding,
    this.borderRadius,
    this.hasGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderRad = borderRadius ?? AppRadius.medium;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient ?? AppGradients.primary,
        borderRadius: borderRad,
        boxShadow: hasGlow ? AppShadows.primaryGlowList : null,
      ),
      child: child,
    );
  }
}
