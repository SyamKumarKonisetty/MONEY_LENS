import 'dart:ui';

import 'package:flutter/material.dart';

import '../../design/design_system.dart';

// ─────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────

/// A single item in [GlassNavBar].
class GlassNavItem {
  /// Creates a [GlassNavItem].
  const GlassNavItem({
    required this.icon,
    required this.label,
    this.activeIcon,
  });

  /// Icon displayed when the item is not selected.
  final IconData icon;

  /// Optional alternative icon shown when selected (falls back to [icon]).
  final IconData? activeIcon;

  /// Navigation label shown below the selected item's icon.
  final String label;
}

// ─────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────

/// A premium floating glass navigation bar positioned above safe-area.
///
/// Selected items scale up, show a soft glow indicator, and reveal their
/// label. Transitions use a 250 ms spring curve.
///
/// Usage:
/// ```dart
/// GlassNavBar(
///   items: const [
///     GlassNavItem(icon: Icons.home_rounded, label: 'Home'),
///     GlassNavItem(icon: Icons.bar_chart_rounded, label: 'Analytics'),
///   ],
///   currentIndex: _selectedIndex,
///   onTap: (i) => setState(() => _selectedIndex = i),
/// )
/// ```
class GlassNavBar extends StatefulWidget {
  /// Creates a [GlassNavBar].
  const GlassNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.height = 64.0,
    this.horizontalPadding = 24.0,
    this.bottomPadding = 16.0,
  });

  /// Navigation items.
  final List<GlassNavItem> items;

  /// Index of the currently selected item.
  final int currentIndex;

  /// Callback when an item is tapped.
  final ValueChanged<int> onTap;

  /// Height of the nav bar container.
  final double height;

  /// Horizontal inset from screen edges.
  final double horizontalPadding;

  /// Padding below the nav bar (for home indicator).
  final double bottomPadding;

  @override
  State<GlassNavBar> createState() => _GlassNavBarState();
}

class _GlassNavBarState extends State<GlassNavBar>
    with TickerProviderStateMixin {
  late final List<AnimationController> _scaleControllers;
  late final List<Animation<double>> _scaleAnims;

  @override
  void initState() {
    super.initState();
    _scaleControllers = List.generate(
      widget.items.length,
      (i) => AnimationController(
        vsync: this,
        duration: AppAnimations.medium,
        value: i == widget.currentIndex ? 1.0 : 0.0,
      ),
    );
    _scaleAnims = _scaleControllers
        .map((c) => CurvedAnimation(parent: c, curve: AppAnimations.spring))
        .toList();
  }

  @override
  void didUpdateWidget(GlassNavBar old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      _scaleControllers[old.currentIndex].reverse();
      _scaleControllers[widget.currentIndex].forward();
    }
  }

  @override
  void dispose() {
    for (final c in _scaleControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    return Positioned(
      left: widget.horizontalPadding,
      right: widget.horizontalPadding,
      bottom: bottomInset + widget.bottomPadding,
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pillVal),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(AppRadius.pillVal),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  widget.items.length,
                  (i) => _NavItem(
                    item: widget.items[i],
                    scaleAnim: _scaleAnims[i],
                    isSelected: i == widget.currentIndex,
                    onTap: () => widget.onTap(i),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Nav item
// ─────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.scaleAnim,
    required this.isSelected,
    required this.onTap,
  });

  final GlassNavItem item;
  final Animation<double> scaleAnim;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: scaleAnim,
        builder: (context, child) {
          final t = scaleAnim.value;
          final scale = 0.9 + t * 0.3; // 0.9 → 1.2
          final iconColor = Color.lerp(
            AppColors.textSecondary,
            AppColors.primary,
            t,
          )!;

          return SizedBox(
            width: 64,
            height: 64,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glow indicator
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (t > 0.01)
                      Container(
                        width: 36 * t,
                        height: 36 * t,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.18 * t),
                        ),
                      ),
                    Transform.scale(
                      scale: scale,
                      child: Icon(
                        isSelected
                            ? (item.activeIcon ?? item.icon)
                            : item.icon,
                        color: iconColor,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                // Label (fades + slides in when selected)
                SizedBox(height: 2 * t),
                if (t > 0.1)
                  Opacity(
                    opacity: t,
                    child: Text(
                      item.label,
                      style: AppTypography.caption.copyWith(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
