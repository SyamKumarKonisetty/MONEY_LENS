import 'package:flutter/material.dart';

import '../../design/design_system.dart';

/// A micro-interaction widget that plays a shrink-and-red-ripple animation
/// when [isDeleting] becomes `true`.
///
/// The animation sequence:
/// 1. Scale 1.0 → 0.0 (400 ms, ease-in)
/// 2. Opacity 1.0 → 0.0 (fades with scale)
/// 3. A red ripple circle expands from the widget's center
/// 4. [onDeleteComplete] is called after the animation finishes
///
/// Usage:
/// ```dart
/// DeleteRipple(
///   isDeleting: _isDeleting,
///   onDeleteComplete: () {
///     setState(() => _items.remove(item));
///   },
///   child: TransactionCard(transaction: item),
/// )
/// ```
class DeleteRipple extends StatefulWidget {
  /// Creates a [DeleteRipple].
  const DeleteRipple({
    super.key,
    required this.child,
    required this.isDeleting,
    required this.onDeleteComplete,
    this.duration = const Duration(milliseconds: 400),
  });

  /// The widget to animate.
  final Widget child;

  /// When `true`, the delete animation starts.
  final bool isDeleting;

  /// Called after the delete animation completes.
  final VoidCallback onDeleteComplete;

  /// Duration of the animation.
  final Duration duration;

  @override
  State<DeleteRipple> createState() => _DeleteRippleState();
}

class _DeleteRippleState extends State<DeleteRipple>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;
  late final Animation<double> _rippleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);

    _scaleAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );
    _opacityAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
    _rippleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOut),
      ),
    );

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onDeleteComplete();
      }
    });
  }

  @override
  void didUpdateWidget(DeleteRipple old) {
    super.didUpdateWidget(old);
    if (widget.isDeleting && !old.isDeleting) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Ripple overlay
            if (_ctrl.isAnimating || _ctrl.isCompleted)
              Positioned.fill(
                child: CustomPaint(
                  painter: _RipplePainter(progress: _rippleAnim.value),
                ),
              ),

            // Child with scale + fade
            Opacity(
              opacity: _opacityAnim.value,
              child: Transform.scale(
                scale: _scaleAnim.value,
                child: child,
              ),
            ),
          ],
        );
      },
      child: widget.child,
    );
  }
}

// ─────────────────────────────────────────────
// Ripple painter
// ─────────────────────────────────────────────

class _RipplePainter extends CustomPainter {
  _RipplePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.shortestSide * 0.8;
    final radius = maxRadius * progress;

    final alpha = (1.0 - progress).clamp(0.0, 1.0);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.expense.withValues(alpha: alpha * 0.35)
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.expense.withValues(alpha: alpha * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_RipplePainter old) => old.progress != progress;
}
