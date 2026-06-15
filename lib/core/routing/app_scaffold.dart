import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../animations/animation_constants.dart';
import '../extensions/context_extensions.dart';
import '../constants/app_constants.dart';
import '../../features/notifications/presentation/widgets/in_app_notification_banner.dart';

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
        ],
      ),
      bottomNavigationBar: _MoneyLensNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

// ─── Navigation Bar ───────────────────────────────────────────────────────────

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

/// Custom bottom navigation bar — Apple-inspired, no Material defaults.
class _MoneyLensNavBar extends StatelessWidget {
  const _MoneyLensNavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark
        ? AppColors.separatorDark
        : AppColors.separatorLight;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppConstants.navBarHeight,
          child: Row(
            children: List.generate(
              _navItems.length,
              (index) => Expanded(
                child: _NavBarItem(
                  item: _navItems[index],
                  isSelected: index == currentIndex,
                  onTap: () => onTap(index),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Individual nav bar item with animated icon + indicator.
class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = context.primaryColor;
    final inactiveColor = context.textSecondaryColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with animated switcher
          AnimatedSwitcher(
            duration: AppAnimations.fast,
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Icon(
              isSelected ? item.activeIcon : item.icon,
              key: ValueKey(isSelected),
              color: isSelected ? activeColor : inactiveColor,
              size: AppConstants.navBarIconSize,
            ),
          ),

          const SizedBox(height: 2),

          // Label
          AnimatedDefaultTextStyle(
            duration: AppAnimations.fast,
            style: AppTypography.navLabel.copyWith(
              color: isSelected ? activeColor : inactiveColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
            child: Text(item.label),
          ),

          const SizedBox(height: 4),

          // Selection indicator dot
          AnimatedContainer(
            duration: AppAnimations.fast,
            curve: AppAnimations.smooth,
            width: isSelected ? 16 : 0,
            height: isSelected ? 3 : 0,
            decoration: BoxDecoration(
              color: activeColor,
              borderRadius: AppRadius.circularFull,
            ),
          ),
        ],
      ),
    );
  }
}
