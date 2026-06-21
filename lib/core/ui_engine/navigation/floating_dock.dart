import 'dart:ui';

import 'package:flutter/material.dart';

import '../../design/design_system.dart';

// ─────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────

/// A single item in [FloatingDock].
class DockItem {
  /// Creates a [DockItem].
  const DockItem({
    required this.icon,
    required this.label,
    this.activeIcon,
  });

  /// Icon displayed in the dock.
  final IconData icon;

  /// Icon displayed when this item is selected.
  final IconData? activeIcon;

  /// Tooltip text shown on long-press.
  final String label;
}

// ─────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────

/// A macOS-dock-inspired floating icon tray.
///
/// Icons magnify on hover/press: the touched icon reaches 48×48, while
/// neighbours shrink proportionally. A springy bounce plays on tap.
///
/// Usage:
/// ```dart
/// FloatingDock(
///   items: const [
///     DockItem(icon: Icons.home_rounded, label: 'Home'),
///     DockItem(icon: Icons.add_rounded, label: 'Add'),
///   ],
///   currentIndex: _index,
///   onTap: (i) => setState(() => _index = i),
/// )
/// ```
class FloatingDock extends StatefulWidget {
  /// Creates a [FloatingDock].
  const FloatingDock({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.baseSize = 40.0,
    this.maxSize = 52.0,
    this.itemSpacing = 12.0,
  });

  /// Dock items.
  final List<DockItem> items;

  /// Index of the currently selected item.
  final int currentIndex;

  /// Callback when an item is tapped.
  final ValueChanged<int> onTap;

  /// Default icon container size.
  final double baseSize;

  /// Maximum icon container size (when pressed/hovered).
  final double maxSize;

  /// Spacing between items.
  final double itemSpacing;

  @override
  State<FloatingDock> createState() => _FloatingDockState();
}

class _FloatingDockState extends State<FloatingDock>
    with TickerProviderStateMixin {
  int _hoveredIndex = -1;
  late final List<AnimationController> _bounceControllers;
  late final List<Animation<double>> _bounceAnims;

  @override
  void initState() {
    super.initState();
    _bounceControllers = List.generate(
      widget.items.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 420),
      ),
    );
    _bounceAnims = _bounceControllers.map((c) {
      return TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.85)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 30,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 0.85, end: 1.12)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 40,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 1.12, end: 1.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 30,
        ),
      ]).animate(c);
    }).toList();
  }

  @override
  void dispose() {
    for (final c in _bounceControllers) {
      c.dispose();
    }
    super.dispose();
  }

  double _sizeForIndex(int i) {
    if (_hoveredIndex < 0) {
      return i == widget.currentIndex ? widget.maxSize : widget.baseSize;
    }
    final dist = (i - _hoveredIndex).abs();
    if (dist == 0) return widget.maxSize;
    if (dist == 1) return widget.baseSize + (widget.maxSize - widget.baseSize) * 0.45;
    return widget.baseSize;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.pillVal),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.itemSpacing,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(AppRadius.pillVal),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(widget.items.length, (i) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.itemSpacing / 2,
                  ),
                  child: _DockIcon(
                    item: widget.items[i],
                    size: _sizeForIndex(i),
                    bounceAnim: _bounceAnims[i],
                    isSelected: i == widget.currentIndex,
                    onTap: () {
                      _bounceControllers[i]
                        ..reset()
                        ..forward();
                      widget.onTap(i);
                    },
                    onHoverChanged: (hovering) {
                      setState(() {
                        _hoveredIndex = hovering ? i : -1;
                      });
                    },
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Dock icon
// ─────────────────────────────────────────────

class _DockIcon extends StatelessWidget {
  const _DockIcon({
    required this.item,
    required this.size,
    required this.bounceAnim,
    required this.isSelected,
    required this.onTap,
    required this.onHoverChanged,
  });

  final DockItem item;
  final double size;
  final Animation<double> bounceAnim;
  final bool isSelected;
  final VoidCallback onTap;
  final ValueChanged<bool> onHoverChanged;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: item.label,
      triggerMode: TooltipTriggerMode.longPress,
      preferBelow: false,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sVal),
      ),
      textStyle: AppTypography.caption.copyWith(color: AppColors.textPrimary),
      child: MouseRegion(
        onEnter: (_) => onHoverChanged(true),
        onExit: (_) => onHoverChanged(false),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedBuilder(
            animation: bounceAnim,
            builder: (_, child) {
              return Transform.scale(
                scale: bounceAnim.value,
                child: child,
              );
            },
            child: AnimatedContainer(
              duration: AppAnimations.medium,
              curve: AppAnimations.spring,
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.mVal * (size / 48)),
                gradient: isSelected
                    ? LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : AppColors.card,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                size: size * 0.46,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
