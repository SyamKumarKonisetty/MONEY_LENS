import 'package:flutter/material.dart';

import '../../design/design_system.dart';

/// A success micro-interaction widget that plays two staggered expanding rings
/// (radar-ping style) over the [child] widget.
///
/// The two rings:
/// - Scale from 0.5 → 2.0
/// - Fade from opacity 0.6 → 0
/// - Are staggered 150 ms apart
/// - Complete in 700 ms total
///
/// Usage:
/// ```dart
/// SuccessPulse(
///   isPlaying: _showSuccess,
///   child: Icon(Icons.check_circle, color: AppColors.income),
/// )
/// ```
class SuccessPulse extends StatefulWidget {
  /// Creates a [SuccessPulse].
  const SuccessPulse({
    super.key,
    required this.isPlaying,
    required this.child,
    this.color = AppColors.income,
    this.duration = const Duration(milliseconds: 700),
    this.staggerDelay = const Duration(milliseconds: 150),
    this.size = 80.0,
  });

  /// When `true`, the pulse animation plays once.
  final bool isPlaying;

  /// The widget at the center of the rings.
  final Widget child;

  /// Color of the expanding rings. Defaults to [AppColors.income].
  final Color color;

  /// Total animation duration.
  final Duration duration;

  /// Delay between the two rings.
  final Duration staggerDelay;

  /// Diameter of the ring animation area.
  final double size;

  @override
  State<SuccessPulse> createState() => _SuccessPulseState();
}

class _SuccessPulseState extends State<SuccessPulse>
    with TickerProviderStateMixin {
  late final AnimationController _ring1Ctrl;
  late final AnimationController _ring2Ctrl;

  late final Animation<double> _scale1;
  late final Animation<double> _fade1;
  late final Animation<double> _scale2;
  late final Animation<double> _fade2;

  @override
  void initState() {
    super.initState();
    _ring1Ctrl = AnimationController(vsync: this, duration: widget.duration);
    _ring2Ctrl = AnimationController(vsync: this, duration: widget.duration);

    _scale1 = Tween<double>(begin: 0.5, end: 2.0).animate(
      CurvedAnimation(parent: _ring1Ctrl, curve: Curves.easeOut),
    );
    _fade1 = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _ring1Ctrl, curve: Curves.easeIn),
    );

    _scale2 = Tween<double>(begin: 0.5, end: 2.0).animate(
      CurvedAnimation(parent: _ring2Ctrl, curve: Curves.easeOut),
    );
    _fade2 = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _ring2Ctrl, curve: Curves.easeIn),
    );
  }

  @override
  void didUpdateWidget(SuccessPulse old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying && !old.isPlaying) {
      _ring1Ctrl
        ..reset()
        ..forward();
      Future.delayed(widget.staggerDelay, () {
        if (mounted) {
          _ring2Ctrl
            ..reset()
            ..forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _ring1Ctrl.dispose();
    _ring2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ring 1
            AnimatedBuilder(
              animation: _ring1Ctrl,
              builder: (context, child) {
                return _Ring(
                  scale: _scale1.value,
                  opacity: _fade1.value,
                  color: widget.color,
                  baseSize: widget.size,
                );
              },
            ),

            // Ring 2
            AnimatedBuilder(
              animation: _ring2Ctrl,
              builder: (context, child) {
                return _Ring(
                  scale: _scale2.value,
                  opacity: _fade2.value,
                  color: widget.color,
                  baseSize: widget.size,
                );
              },
            ),

            // Child
            widget.child,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Ring widget
// ─────────────────────────────────────────────

class _Ring extends StatelessWidget {
  const _Ring({
    required this.scale,
    required this.opacity,
    required this.color,
    required this.baseSize,
  });

  final double scale;
  final double opacity;
  final Color color;
  final double baseSize;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Container(
          width: baseSize * 0.55,
          height: baseSize * 0.55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
