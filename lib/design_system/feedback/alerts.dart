import 'package:flutter/material.dart';

/// MoneyLens Design System (MLDS) Alert Banner Components interface.
class MLAlert extends StatelessWidget {
  const MLAlert({
    required this.message,
    super.key,
    this.title,
    this.isCritical = false,
  });

  final String message;
  final String? title;
  final bool isCritical;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
