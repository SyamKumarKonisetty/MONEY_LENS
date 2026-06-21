import 'dart:ui';
import 'package:flutter/material.dart';
import '../foundations/colors.dart';
import '../foundations/radius.dart';
import '../foundations/spacing.dart';
import '../animations/haptics.dart';

/// MoneyLens Design System (MLDS) Card Component interface.
///
/// Ensures consistent margins, border shapes, shadow depth, and surface color.
abstract class MLCard extends StatelessWidget {
  const MLCard({super.key});

  /// Standard content card.
  const factory MLCard.standard({
    required Widget child,
    Key? key,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) = _MLStandardCard;

  /// Floating elevated card with soft shadows.
  const factory MLCard.elevated({
    required Widget child,
    Key? key,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) = _MLElevatedCard;

  /// Glassmorphic translucent card overlay.
  const factory MLCard.glass({
    required Widget child,
    Key? key,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) = _MLGlassCard;
}

class _MLStandardCard extends MLCard {
  const _MLStandardCard({
    required this.child,
    super.key,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cardColor = MLColors.surfaceCard(context);
    final borderColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFE5E5EA);

    Widget current = Container(
      padding: padding ?? const EdgeInsets.all(MLSpacing.cardPadding),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: MLRadius.largeBorderRadius,
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: child,
    );

    if (onTap != null) {
      current = InkWell(
        onTap: () {
          MLHaptics.selection();
          onTap!();
        },
        borderRadius: MLRadius.largeBorderRadius,
        child: current,
      );
    }

    return current;
  }
}

class _MLElevatedCard extends MLCard {
  const _MLElevatedCard({
    required this.child,
    super.key,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cardColor = MLColors.surfaceFloating(context);
    final shadowColor = Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.4 : 0.08);

    Widget current = Container(
      padding: padding ?? const EdgeInsets.all(MLSpacing.cardPadding),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: MLRadius.largeBorderRadius,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 16.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      current = InkWell(
        onTap: () {
          MLHaptics.selection();
          onTap!();
        },
        borderRadius: MLRadius.largeBorderRadius,
        child: current,
      );
    }

    return current;
  }
}

class _MLGlassCard extends MLCard {
  const _MLGlassCard({
    required this.child,
    super.key,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final glassColor = MLColors.glass(context);
    final borderColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0x1FFFFFFF)
        : const Color(0x1F000000);

    Widget current = ClipRRect(
      borderRadius: MLRadius.largeBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
        child: Container(
          padding: padding ?? const EdgeInsets.all(MLSpacing.cardPadding),
          decoration: BoxDecoration(
            color: glassColor,
            borderRadius: MLRadius.largeBorderRadius,
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      current = GestureDetector(
        onTap: () {
          MLHaptics.selection();
          onTap!();
        },
        child: current,
      );
    }

    return current;
  }
}
