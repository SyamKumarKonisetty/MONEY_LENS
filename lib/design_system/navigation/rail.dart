import 'package:flutter/material.dart';

/// MoneyLens Design System (MLDS) Navigation Rail Component interface.
class MLNavRail extends StatelessWidget {
  const MLNavRail({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationRailDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
