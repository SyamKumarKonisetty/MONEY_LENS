import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:money_lens/core/design/design_system.dart';

/// A lighting-reactive surface that renders a radial gradient 'light spot'
/// following the last tap/pointer-down position.
///
/// Behaviour:
/// - On [onTapDown]: light fades IN over 100 ms at the tap position
/// - After the tap: light fades OUT over 400 ms
/// - Uses [CustomPaint] with an [ImageFilter] compositing trick so the glow
///   only applies on top of the child without altering its pixels
///
/// Example:
/// ```dart
/// SoftLight(
///   lightColor: AppColors.textPrimary,
///   lightRadius: 120,
///   child: MyCardContent(),
/// )
/// ```
class SoftLight extends StatefulWidget {
  const SoftLight({
    super.key,
    required this.child,
    this.lightColor = AppColors.textPrimary,
    this.lightRadius = 120.0,
    this.maxOpacity = 0.08,
  });

  /// The widget this light overlay sits on top of.
  final Widget child;

  /// Colour of the radial light spot. Defaults to [AppColors.textPrimary].
  final Color lightColor;

  /// Radius of the radial gradient in logical pixels. Defaults to 120.
  final double lightRadius;

  /// Peak opacity of the light centre. Defaults to 0.08 (subtle but visible).
  final double maxOpacity;

  @override
  State<SoftLight> createState() => _SoftLightState();
}

class _SoftLightState extends State<SoftLight> with TickerProviderStateMixin {
  late AnimationController _fadeInController;
  late AnimationController _fadeOutController;

  late Animation<double> _opacityAnimation;

  Offset _lightPosition = Offset.zero;
  bool _isLit = false;

  @override
  void initState() {
    super.initState();

    _fadeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // The active opacity comes from whichever controller is running.
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeInController, curve: Curves.easeOut),
    );

    _fadeInController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        // Begin fade-out immediately after fade-in completes.
        _startFadeOut();
      }
    });

    _fadeOutController.addListener(() {
      if (mounted) setState(() {});
    });

    _fadeOutController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _isLit = false);
      }
    });

    _fadeInController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _fadeOutController.stop();
    _fadeOutController.reset();

    setState(() {
      _lightPosition = details.localPosition;
      _isLit = true;
    });

    _fadeInController
      ..reset()
      ..forward();
  }

  void _startFadeOut() {
    if (!mounted) return;
    // Remap opacity to the fade-out controller.
    _opacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeInOut),
    );
    _fadeOutController
      ..reset()
      ..forward();
  }

  double get _currentOpacity {
    if (_fadeOutController.isAnimating || _fadeOutController.isCompleted) {
      return (_opacityAnimation.value * widget.maxOpacity).clamp(0.0, 1.0);
    }
    if (_fadeInController.isAnimating || _fadeInController.isCompleted) {
      return (_fadeInController.value * widget.maxOpacity).clamp(0.0, 1.0);
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: <Widget>[
          widget.child,
          if (_isLit)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _LightPainter(
                    position: _lightPosition,
                    color: widget.lightColor,
                    radius: widget.lightRadius,
                    opacity: _currentOpacity,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _LightPainter
// ---------------------------------------------------------------------------

/// Paints a radial gradient 'light spot' at [position] using [BlendMode.screen]
/// so it brightens the content beneath without flattening colours.
class _LightPainter extends CustomPainter {
  _LightPainter({
    required this.position,
    required this.color,
    required this.radius,
    required this.opacity,
  });

  final Offset position;
  final Color color;
  final double radius;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    final Paint paint = Paint()
      ..blendMode = ui.BlendMode.screen
      ..shader = RadialGradient(
        colors: <Color>[
          color.withValues(alpha: opacity),
          color.withValues(alpha: 0.0),
        ],
        stops: const <double>[0.0, 1.0],
      ).createShader(
        Rect.fromCircle(center: position, radius: radius),
      );

    canvas.drawCircle(position, radius, paint);
  }

  @override
  bool shouldRepaint(_LightPainter oldDelegate) =>
      oldDelegate.position != position ||
      oldDelegate.opacity != opacity ||
      oldDelegate.radius != radius ||
      oldDelegate.color != color;
}
