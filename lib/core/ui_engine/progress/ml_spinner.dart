import 'package:flutter/material.dart';
import '../../design/design_system.dart';

/// A premium rotational spinner using an icon, replacing CircularProgressIndicator.
/// It uses a sleek `Icons.donut_large_rounded` (or custom icon) that rotates smoothly.
class MLSpinner extends StatefulWidget {
  const MLSpinner({
    super.key,
    this.size = 24.0,
    this.color,
    this.icon = Icons.donut_large_rounded,
    this.duration = const Duration(seconds: 1),
  });

  /// The size of the spinner icon.
  final double size;

  /// The color of the spinner. Defaults to primary color.
  final Color? color;

  /// The icon to rotate.
  final IconData icon;

  /// Duration for one full rotation.
  final Duration duration;

  @override
  State<MLSpinner> createState() => _MLSpinnerState();
}

class _MLSpinnerState extends State<MLSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: RotationTransition(
        turns: _controller,
        child: Icon(
          widget.icon,
          size: widget.size,
          color: widget.color ?? AppColors.primary,
        ),
      ),
    );
  }
}
