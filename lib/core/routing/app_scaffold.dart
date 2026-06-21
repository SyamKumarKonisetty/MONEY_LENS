import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

import '../extensions/context_extensions.dart';
import '../../features/notifications/presentation/widgets/in_app_notification_banner.dart';


import '../ui_engine/glass/glass_config.dart';
import '../ui_engine/glass/glass_navigation.dart';

/// The root scaffold containing the animated bottom navigation bar.
///
/// Used as the [StatefulShellRoute] builder — wraps all tab screens
/// with the persistent bottom navigation.
class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      extendBody: true,
      body: Stack(
        children: [
          navigationShell,
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: InAppNotificationBanner(),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: DynamicIslandNavBar(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) => navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dynamic Island Navigation ────────────────────────────────────────────────

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

const List<_NavItem> _navItems = [
  _NavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'Dashboard',
  ),
  _NavItem(
    icon: Icons.receipt_long_outlined,
    activeIcon: Icons.receipt_long_rounded,
    label: 'Transactions',
  ),
  _NavItem(
    icon: Icons.bar_chart_outlined,
    activeIcon: Icons.bar_chart_rounded,
    label: 'Analytics',
  ),
  _NavItem(
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings_rounded,
    label: 'Settings',
  ),
];

class DynamicIslandNavBar extends StatelessWidget {
  const DynamicIslandNavBar({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1677FF).withValues(alpha: GlassConfig.ambientGlowOpacity),
                  blurRadius: 32,
                  spreadRadius: -4,
                  offset: const Offset(0, 16),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 24,
                  spreadRadius: -8,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: GlassNavigation(
              currentIndex: currentIndex,
              onTap: onTap,
              items: _navItems.map((item) => GlassNavigationItem(
                icon: item.icon,
                label: item.label,
              )).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
