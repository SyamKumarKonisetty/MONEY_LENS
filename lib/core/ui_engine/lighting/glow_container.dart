import 'package:flutter/material.dart';

import '../../design/design_system.dart';

/// A container that emits a soft, customisable box-shadow glow.
///
/// When [isPulsing] is `true` the glow breathes in and out continuously
/// (min → max opacity → min) using an [AnimationController] in repeat mode.
///
/// Example:
/// ```dart
/// GlowContainer(
///   glowColor: AppColors.income,
///   glowRadius: 24,
///   isPulsing: true,
///   child: Icon(Icons.savings, color: AppColors.income),
/// )
/// ```
class GlowContainer extends StatefulWidget {
  const GlowContainer({
    super.key,
    required this.child,
    this.glowColor,
    this.glowRadius = 20.0,
    this.glowSpread = 0.0,
    this.isPulsing = false,
    this.minGlowOpacity = 0.2,
    this.maxGlowOpacity = 0.7,
    this.pulseDuration = const Duration(milliseconds: 1500),
    this.borderRadius,
    this.backgroundColor,
    this.padding,
  });

  /// The widget wrapped by the glowing container.
  final Widget child;

  /// Colour of the glow shadow. Defaults to [AppColors.primaryLight].
  final Color? glowColor;

  /// Blur radius of the glow in logical pixels. Defaults to 20.
  final double glowRadius;

  /// Spread radius of the glow. Defaults to 0.
  final double glowSpread;

  /// When `true`, the glow breathes between [minGlowOpacity] and
  /// [maxGlowOpacity]. Defaults to `false`.
  final bool isPulsing;

  /// Minimum glow opacity during the dim phase of pulsing. Defaults to 0.2.
  final double minGlowOpacity;

  /// Maximum glow opacity during the bright phase. Defaults to 0.7.
  final double maxGlowOpacity;

  /// Duration of one half-cycle (dim→bright) when pulsing. Defaults to 1.5 s.
  final Duration pulseDuration;

  /// Border radius of the container. Defaults to [AppRadius.medium].
  final double? borderRadius;

  /// Optional background colour. Defaults to transparent.
  final Color? backgroundColor;

  /// Optional inner padding.
  final EdgeInsetsGeometry? padding;

  @override
  State<GlowContainer> createState() => _GlowContainerState();
}

class _GlowContainerState extends State<GlowContainer>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;
  Animation<double>? _opacityAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.isPulsing) {
      _startPulse();
    }
  }

  @override
  void didUpdateWidget(GlowContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPulsing != widget.isPulsing) {
      if (widget.isPulsing) {
        _startPulse();
      } else {
        _stopPulse();
      }
    }
  }

  void _startPulse() {
    _pulseController = AnimationController(
      vsync: this,
      duration: widget.pulseDuration,
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(
      begin: widget.minGlowOpacity,
      end: widget.maxGlowOpacity,
    ).animate(
      CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
    )..addListener(() {
        if (mounted) setState(() {});
      });
  }

  void _stopPulse() {
    _pulseController?.dispose();
    _pulseController = null;
    _opacityAnimation = null;
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  double get _resolvedOpacity {
    if (widget.isPulsing && _opacityAnimation != null) {
      return _opacityAnimation!.value;
    }
    return widget.maxGlowOpacity;
  }

  @override
  Widget build(BuildContext context) {
    final Color glow = widget.glowColor ?? AppColors.primaryLight;
    final double r = widget.borderRadius ?? AppRadius.mVal;

    return RepaintBoundary(
      child: Container(
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(r),
          boxShadow: <BoxShadow>[
            // Primary glow halo
            BoxShadow(
              color: glow.withValues(alpha: _resolvedOpacity),
              blurRadius: widget.glowRadius,
              spreadRadius: widget.glowSpread,
            ),
            // Secondary larger, softer bloom
            BoxShadow(
              color: glow.withValues(alpha: _resolvedOpacity * 0.4),
              blurRadius: widget.glowRadius * 2.5,
              spreadRadius: widget.glowSpread * 0.5,
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GlowIcon – convenience wrapper for a glowing icon
// ---------------------------------------------------------------------------

/// A convenience widget that wraps an [Icon] (or any widget) inside a
/// [GlowContainer] with a circular shape and matching glow colour.
///
/// Example:
/// ```dart
/// GlowIcon(
///   icon: Icons.trending_up,
///   color: AppColors.income,
///   size: 24,
///   isPulsing: true,
/// )
/// ```
class GlowIcon extends StatelessWidget {
  const GlowIcon({
    super.key,
    required this.icon,
    this.color,
    this.size = 24.0,
    this.isPulsing = false,
    this.glowRadius = 16.0,
    this.padding = const EdgeInsets.all(AppSpacing.xs),
  });

  /// The icon data to render.
  final IconData icon;

  /// Colour of the icon and its glow. Defaults to [AppColors.primaryLight].
  final Color? color;

  /// Size of the icon. Defaults to 24.
  final double size;

  /// Whether the glow should pulse. Defaults to `false`.
  final bool isPulsing;

  /// Blur radius of the glow. Defaults to 16.
  final double glowRadius;

  /// Padding around the icon inside the glow container.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final Color c = color ?? AppColors.primaryLight;
    return GlowContainer(
      glowColor: c,
      glowRadius: glowRadius,
      isPulsing: isPulsing,
      borderRadius: AppRadius.pillVal,
      padding: padding,
      child: Icon(icon, color: c, size: size),
    );
  }
}
