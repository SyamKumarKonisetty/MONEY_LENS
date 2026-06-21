/// {@template press_scale}
/// A reusable press-scale interaction wrapper for the MoneyLens Motion System.
///
/// [PressScale] wraps any child widget and adds:
///  - Scale-down on tap-down to [scaleTo] (default 0.95) using
///    [MotionConstants.tapDuration] + [MotionConstants.springCurve].
///  - Spring-back to 1.0 on tap-up/cancel before invoking [onTap].
///  - [HapticFeedback.lightImpact] on every tap-down for tactile feedback.
///
/// This widget is the recommended way to add press-scale feedback to custom
/// widgets that cannot use [GlassCard] or [GlassButton] directly.
///
/// Example:
/// ```dart
/// PressScale(
///   onTap: () => print('tapped'),
///   child: MyCustomWidget(),
/// )
/// ```
/// {@endtemplate}
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'motion_constants.dart';

/// A transparent interactive wrapper that animates a press-scale effect.
///
/// The scale animation fires on [GestureDetector.onTapDown] and reverses on
/// [GestureDetector.onTapUp] or [GestureDetector.onTapCancel].  [onTap] is
/// called **after** the reverse animation completes to give the spring-back
/// a chance to complete before navigation or state changes occur.
class PressScale extends StatefulWidget {
  /// Creates a [PressScale] wrapper.
  ///
  /// [child] is required. All other parameters are optional.
  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.scaleTo = 0.95,
    this.enabled = true,
    this.hapticFeedback = true,
  });

  /// The widget to scale on press.
  final Widget child;

  /// Callback invoked after the press-release spring-back animation completes.
  ///
  /// When `null` the widget still renders but is non-interactive.
  final VoidCallback? onTap;

  /// The target scale value applied on tap-down.
  ///
  /// Defaults to `0.95`.  Pass a value closer to `1.0` for a subtler effect
  /// or lower for a more pronounced one (e.g. `0.90` for large hero tiles).
  final double scaleTo;

  /// Whether the widget responds to taps.
  ///
  /// Defaults to `true`. When `false`, [child] is rendered without any
  /// interaction or animation.
  final bool enabled;

  /// Whether to call [HapticFeedback.lightImpact] on each tap-down.
  ///
  /// Defaults to `true`.
  final bool hapticFeedback;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: MotionConstants.tapDuration,       // 120 ms – press
      reverseDuration: MotionConstants.normalDuration, // 300 ms – release
    );

    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: widget.scaleTo,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: MotionConstants.springCurve,
        reverseCurve: MotionConstants.springCurve,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (!widget.enabled || widget.onTap == null) return;
    if (widget.hapticFeedback) HapticFeedback.lightImpact();
    _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    if (!widget.enabled || widget.onTap == null) return;
    _controller.reverse().then((_) {
      // Guard against widget being disposed before callback fires.
      if (mounted) widget.onTap?.call();
    });
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || widget.onTap == null) {
      return widget.child;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
