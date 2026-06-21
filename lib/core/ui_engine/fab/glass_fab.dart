import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../design/design_system.dart';

// ─────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────

/// A child action shown when [GlassFab] is expanded.
class FabAction {
  /// Creates a [FabAction].
  FabAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.primary,
  });

  /// Action icon.
  final IconData icon;

  /// Short label shown beside the icon.
  final String label;

  /// Color of the action button.
  final Color color;

  /// Callback when this action is tapped.
  final VoidCallback onTap;
}

// ─────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────

/// A premium glass morphic floating action button.
///
/// When expanded, up to 4 child [actions] are revealed in a radial arc above
/// the main button. Each action staggers in 60 ms apart.
///
/// Usage:
/// ```dart
/// GlassFab(
///   actions: [
///     FabAction(
///       icon: Icons.arrow_upward_rounded,
///       label: 'Income',
///       color: AppColors.income,
///       onTap: () {},
///     ),
///     FabAction(
///       icon: Icons.arrow_downward_rounded,
///       label: 'Expense',
///       color: AppColors.expense,
///       onTap: () {},
///     ),
///   ],
/// )
/// ```
class GlassFab extends StatefulWidget {
  /// Creates a [GlassFab].
  const GlassFab({
    super.key,
    this.actions = const [],
    this.mainIcon = Icons.add_rounded,
    this.onMainTap,
    this.size = 60.0,
    this.actionSize = 48.0,
    this.arcRadius = 88.0,
    this.staggerDelay = const Duration(milliseconds: 60),
    this.expandDuration = const Duration(milliseconds: 300),
  });

  /// Child actions shown when expanded. If empty, [onMainTap] is called instead.
  final List<FabAction> actions;

  /// Icon on the main button.
  final IconData mainIcon;

  /// Callback when main button is tapped and [actions] is empty.
  final VoidCallback? onMainTap;

  /// Diameter of the main FAB.
  final double size;

  /// Diameter of each child action button.
  final double actionSize;

  /// Radial distance from center of FAB to center of child actions.
  final double arcRadius;

  /// Stagger delay between each child action's entrance animation.
  final Duration staggerDelay;

  /// Duration for the expansion animation of each child.
  final Duration expandDuration;

  @override
  State<GlassFab> createState() => _GlassFabState();
}

class _GlassFabState extends State<GlassFab> with TickerProviderStateMixin {
  bool _isExpanded = false;

  late final AnimationController _rotateCtrl;
  late final Animation<double> _rotateAnim;

  late final List<AnimationController> _childControllers;
  late final List<Animation<double>> _scaleAnims;
  late final List<Animation<double>> _fadeAnims;

  late final AnimationController _scrimCtrl;
  late final Animation<double> _scrimAnim;

  @override
  void initState() {
    super.initState();

    _rotateCtrl = AnimationController(
      vsync: this,
      duration: widget.expandDuration,
    );
    _rotateAnim = Tween<double>(begin: 0, end: math.pi / 4)
        .animate(CurvedAnimation(parent: _rotateCtrl, curve: Curves.easeOutBack));

    _scrimCtrl = AnimationController(
      vsync: this,
      duration: widget.expandDuration,
    );
    _scrimAnim = CurvedAnimation(parent: _scrimCtrl, curve: Curves.easeInOut);

    final n = widget.actions.length;
    _childControllers = List.generate(
      n,
      (_) => AnimationController(
        vsync: this,
        duration: widget.expandDuration,
      ),
    );
    _scaleAnims = _childControllers.map((c) {
      return CurvedAnimation(parent: c, curve: Curves.easeOutBack);
    }).toList();
    _fadeAnims = _childControllers.map((c) {
      return CurvedAnimation(parent: c, curve: Curves.easeIn);
    }).toList();
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    _scrimCtrl.dispose();
    for (final c in _childControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _toggle() async {
    if (widget.actions.isEmpty) {
      widget.onMainTap?.call();
      return;
    }

    if (_isExpanded) {
      // Collapse
      _rotateCtrl.reverse();
      _scrimCtrl.reverse();
      for (int i = _childControllers.length - 1; i >= 0; i--) {
        await Future.delayed(widget.staggerDelay);
        if (mounted) _childControllers[i].reverse();
      }
    } else {
      // Expand
      _rotateCtrl.forward();
      _scrimCtrl.forward();
      for (int i = 0; i < _childControllers.length; i++) {
        await Future.delayed(widget.staggerDelay);
        if (mounted) _childControllers[i].forward();
      }
    }

    if (mounted) setState(() => _isExpanded = !_isExpanded);
  }

  /// Computes the position of each child action in the arc above the FAB.
  Offset _actionOffset(int index, int total) {
    // Distribute actions in an arc from 240° to 300° (above the FAB)
    final double startAngle = math.pi * 1.15; // ~207°
    final double endAngle = math.pi * 1.85;   // ~333°
    final double step = total <= 1 ? 0 : (endAngle - startAngle) / (total - 1);
    final double angle = total == 1
        ? (startAngle + endAngle) / 2
        : startAngle + step * index;
    return Offset(
      math.cos(angle) * widget.arcRadius,
      math.sin(angle) * widget.arcRadius,
    );
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.actions.length;

    return SizedBox(
      width: widget.arcRadius * 2.4,
      height: widget.arcRadius * 2.4,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Scrim
          AnimatedBuilder(
            animation: _scrimAnim,
            builder: (context, child) {
              return IgnorePointer(
                ignoring: !_isExpanded,
                child: GestureDetector(
                  onTap: _isExpanded ? _toggle : null,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black.withValues(
                      alpha: 0.4 * _scrimAnim.value,
                    ),
                  ),
                ),
              );
            },
          ),

          // Child action buttons
          ...List.generate(n, (i) {
            final offset = _actionOffset(i, n);
            return AnimatedBuilder(
              animation: _scaleAnims[i],
              builder: (context, child) {
                final s = _scaleAnims[i].value;
                final f = _fadeAnims[i].value;
                return Positioned(
                  bottom:
                      widget.size / 2 - offset.dy - widget.actionSize / 2,
                  left: widget.arcRadius * 2.4 / 2 +
                      offset.dx -
                      widget.actionSize / 2,
                  child: IgnorePointer(
                    ignoring: s < 0.05,
                    child: Opacity(
                      opacity: f.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: s.clamp(0.0, 1.0),
                        child: _ActionButton(
                          action: widget.actions[i],
                          size: widget.actionSize,
                          onTap: () {
                            _toggle();
                            widget.actions[i].onTap();
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Main FAB
          Positioned(
            bottom: 0,
            child: _MainFab(
              icon: widget.mainIcon,
              size: widget.size,
              rotateAnim: _rotateAnim,
              onTap: _toggle,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Main FAB
// ─────────────────────────────────────────────

class _MainFab extends StatelessWidget {
  const _MainFab({
    required this.icon,
    required this.size,
    required this.rotateAnim,
    required this.onTap,
  });

  final IconData icon;
  final double size;
  final Animation<double> rotateAnim;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: rotateAnim,
        builder: (_, child) {
          return Transform.rotate(
            angle: rotateAnim.value,
            child: child,
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size / 2),
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                Icons.add_rounded,
                color: AppColors.textPrimary,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Action button
// ─────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.action,
    required this.size,
    required this.onTap,
  });

  final FabAction action;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size / 2),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(size / 2),
                  border: Border.all(
                    color: action.color.withValues(alpha: 0.4),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: action.color.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: size * 0.44,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          action.label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
