import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../animations/app_animations.dart';

/// A button wrapper that animates (scales down) when pressed, providing micro-tactile feel.
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.95,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.fast,
    );
    _animation = Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      HapticFeedback.lightImpact();
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse().then((_) {
        widget.onTap!();
      });
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        behavior: HitTestBehavior.opaque,
        child: ScaleTransition(
          scale: _animation,
          child: widget.child,
        ),
      ),
    );
  }
}
