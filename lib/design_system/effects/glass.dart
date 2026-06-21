import 'package:flutter/material.dart';

/// MoneyLens Design System (MLDS) Glassmorphic backdrop filter styling wrapper.
class MLGlassEffect extends StatelessWidget {
  const MLGlassEffect({
    required this.child,
    super.key,
    this.blurSigma = 15.0,
    this.opacity = 0.1,
  });

  final Widget child;
  final double blurSigma;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
