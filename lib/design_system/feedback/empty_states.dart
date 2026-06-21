import 'package:flutter/material.dart';

/// MoneyLens Design System (MLDS) Empty State Component interface.
class MLEmptyState extends StatelessWidget {
  const MLEmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
    super.key,
    this.actionLabel,
    this.onActionPressed,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
