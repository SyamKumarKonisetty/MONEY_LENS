import 'package:flutter/material.dart';
import '../../../../../core/ui_engine/ui_engine.dart';

/// Helper widget to fade and slide down any section during entry.
class FadeDownEntrance extends StatefulWidget {
  const FadeDownEntrance({
    required this.child,
    this.delay = Duration.zero,
    super.key,
  });

  final Widget child;
  final Duration delay;

  @override
  State<FadeDownEntrance> createState() => _FadeDownEntranceState();
}

class _FadeDownEntranceState extends State<FadeDownEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MotionConstants.normalDuration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: MotionConstants.smoothCurve,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: MotionConstants.springCurve,
    ));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Helper widget to scale up and fade in any card using a spring curve.
class ScaleUpEntrance extends StatefulWidget {
  const ScaleUpEntrance({
    required this.child,
    this.delay = Duration.zero,
    super.key,
  });

  final Widget child;
  final Duration delay;

  @override
  State<ScaleUpEntrance> createState() => _ScaleUpEntranceState();
}

class _ScaleUpEntranceState extends State<ScaleUpEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MotionConstants.slowDuration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: MotionConstants.smoothCurve,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: MotionConstants.springCurve,
    ));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
