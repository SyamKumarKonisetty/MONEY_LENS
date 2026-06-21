import 'package:flutter/material.dart';

import '../../design/design_system.dart';

/// A card that shifts its content in the direction opposite to a drag gesture,
/// creating a convincing parallax depth effect.
///
/// Features:
/// - Content shifts up to [parallaxAmount] px in the opposite direction of drag
/// - Smooth spring-back on gesture release via animated controller
/// - Uses [Transform.translate] for GPU-accelerated offset
/// - Card background + shadow are drawn separately so only the inner content
///   parallaxes, preserving the card's apparent position
///
/// Example:
/// ```dart
/// ParallaxCard(
///   parallaxAmount: 6.0,
///   child: MyCardContent(),
/// )
/// ```
class ParallaxCard extends StatefulWidget {
  const ParallaxCard({
    super.key,
    required this.child,
    this.parallaxAmount = 6.0,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.onTap,
    this.springDuration = const Duration(milliseconds: 400),
  });

  /// Widget displayed inside the card, whose position parallaxes on drag.
  final Widget child;

  /// Maximum translation offset in logical pixels. Defaults to 6.
  final double parallaxAmount;

  /// Inner padding. Defaults to [AppSpacing.md] all sides.
  final EdgeInsetsGeometry? padding;

  /// Corner radius. Defaults to [AppRadius.medium].
  final double? borderRadius;

  /// Card background. Defaults to [AppColors.card].
  final Color? backgroundColor;

  /// Optional tap callback.
  final VoidCallback? onTap;

  /// Duration of the spring-back animation. Defaults to 400 ms.
  final Duration springDuration;

  @override
  State<ParallaxCard> createState() => _ParallaxCardState();
}

class _ParallaxCardState extends State<ParallaxCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _springController;
  late Animation<Offset> _springAnimation;

  Offset _currentOffset = Offset.zero;
  Offset _dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: widget.springDuration,
    );
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!mounted) return;
    // Stop any ongoing spring-back.
    _springController.stop();

    // Clamp the accumulated offset within the allowed parallax range.
    _dragOffset = Offset(
      (_dragOffset.dx + details.delta.dx * 0.5)
          .clamp(-widget.parallaxAmount, widget.parallaxAmount),
      (_dragOffset.dy + details.delta.dy * 0.5)
          .clamp(-widget.parallaxAmount, widget.parallaxAmount),
    );

    // Content shifts OPPOSITE to drag direction (parallax illusion).
    setState(() => _currentOffset = -_dragOffset);
  }

  void _onPanEnd(DragEndDetails _) => _springBack();
  void _onPanCancel() => _springBack();

  void _springBack() {
    final Offset startOffset = _currentOffset;
    _springAnimation = Tween<Offset>(
      begin: startOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _springController,
        curve: Curves.elasticOut,
      ),
    )..addListener(() {
        if (mounted) setState(() => _currentOffset = _springAnimation.value);
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _dragOffset = Offset.zero;
        }
      });

    _springController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final double r = widget.borderRadius ?? AppRadius.mVal;
    final Color bg = widget.backgroundColor ?? AppColors.card;

    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onPanCancel: _onPanCancel,
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.30),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: Offset.zero,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(r),
          child: Transform.translate(
            offset: _currentOffset,
            child: Padding(
              padding:
                  widget.padding ?? const EdgeInsets.all(AppSpacing.md),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
