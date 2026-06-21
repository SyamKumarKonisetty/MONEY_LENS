import 'package:flutter/material.dart';

/// MoneyLens Design System (MLDS) Bottom Navigation Bar Component interface.
class MLBottomNav extends StatelessWidget {
  const MLBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.items,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
