import 'package:flutter/material.dart';
import '../animations/animation_constants.dart';

/// Wraps a screen's content with a fade + slide entrance animation.
///
/// Apply this as the root of each screen's build method for
/// a consistent, premium entrance animation across all tabs.
///
/// Example:
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return AnimatedPageWrapper(
///     child: Column(children: [...]),
///   );
/// }
/// ```
class AnimatedPageWrapper extends StatefulWidget {
  const AnimatedPageWrapper({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;

  /// Optional delay before the animation starts.
  final Duration delay;

  @override
  State<AnimatedPageWrapper> createState() => _AnimatedPageWrapperState();
}

class _AnimatedPageWrapperState extends State<AnimatedPageWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.slow,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: AppAnimations.decelerate),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: AppAnimations.smooth),
        );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
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
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

/// Staggered list item animation wrapper.
///
/// Wrap each item in a list to create a staggered entrance effect.
class StaggeredListItem extends StatefulWidget {
  const StaggeredListItem({
    super.key,
    required this.child,
    required this.index,
    this.baseDelay = 0,
  });

  final Widget child;
  final int index;

  /// Base delay in milliseconds added to each item's stagger.
  final int baseDelay;

  @override
  State<StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<StaggeredListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.medium,
    );

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.decelerate),
    );

    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _controller, curve: AppAnimations.smooth),
        );

    final delay =
        widget.baseDelay +
        (widget.index * AppAnimations.staggerDelay.inMilliseconds);

    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
