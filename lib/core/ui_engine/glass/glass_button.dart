/// {@template glass_button}
/// A glass-morphic button for the MoneyLens UI Engine.
///
/// [GlassButton] presents a pill-shaped (or custom-radius) interactive button
/// with:
///  - A blurred glass background via [GlassSurface].
///  - An optional brand [gradient] fill on top of the glass layer.
///  - A hairline gradient border drawn around the full perimeter.
///  - A **press animation** that scales to 0.95 and reduces opacity to 0.80 on
///    tap-down, then springs back smoothly on release.
///  - HapticFeedback on tap-down (handled via [PressScale] or directly here).
///
/// The button is full-width by default and 52 logical pixels tall.
/// {@endtemplate}
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_config.dart';
import 'glass_surface.dart';
import '../motion/motion_constants.dart';
import 'package:money_lens/core/design/design_system.dart';

/// A glass-morphic, animated button.
///
/// Example – primary gradient button:
/// ```dart
/// GlassButton(
///   label: 'Add Transaction',
///   icon: Icons.add,
///   gradient: LinearGradient(
///     colors: [Color(0xFF1677FF), Color(0xFF3EA6FF)],
///   ),
///   onTap: () {},
/// )
/// ```
///
/// Example – ghost glass button:
/// ```dart
/// GlassButton(
///   label: 'Cancel',
///   onTap: () => Navigator.pop(context),
/// )
/// ```
class GlassButton extends StatefulWidget {
  /// Creates a [GlassButton].
  const GlassButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.gradient,
    this.width,
    this.height = GlassConfig.buttonHeight,
    this.borderRadius,
    this.textStyle,
    this.foregroundColor,
    this.blur = GlassConfig.blurSigma,
    this.opacity = GlassConfig.backgroundOpacity,
    this.enabled = true,
  });

  /// The button label text.
  final String label;

  /// Callback invoked after the press-release animation completes.
  final VoidCallback? onTap;

  /// Optional leading icon shown to the left of [label].
  final IconData? icon;

  /// Optional gradient painted above the glass fill.
  ///
  /// When provided (e.g. the app's primary gradient), the button appears as a
  /// solid-gradient CTA. When `null` the button is a transparent glass ghost.
  final Gradient? gradient;

  /// Fixed width; defaults to `double.infinity` (full-width).
  final double? width;

  /// Height of the button in logical pixels. Defaults to 52.
  final double height;

  /// Custom border radius. Defaults to a full pill ([GlassConfig.defaultButtonRadius]).
  final BorderRadius? borderRadius;

  /// Custom text style for the label.
  final TextStyle? textStyle;

  /// Foreground colour for icon and text. Defaults to [AppColors.textPrimary].
  final Color? foregroundColor;

  /// Blur sigma forwarded to the backdrop filter.
  final double blur;

  /// Background fill opacity for the glass layer.
  final double opacity;

  /// Whether the button responds to input. Defaults to `true`.
  final bool enabled;

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MotionConstants.tapDuration,
      reverseDuration: MotionConstants.normalDuration,
    );

    _scale = Tween<double>(
      begin: 1.0,
      end: GlassConfig.buttonPressScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: MotionConstants.springCurve,
      reverseCurve: MotionConstants.springCurve,
    ));

    _opacity = Tween<double>(
      begin: 1.0,
      end: GlassConfig.buttonPressOpacity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: MotionConstants.snappyCurve,
      reverseCurve: MotionConstants.snappyCurve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (!widget.enabled || widget.onTap == null) return;
    HapticFeedback.lightImpact();
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    if (!widget.enabled || widget.onTap == null) return;
    _controller.reverse().then((_) => widget.onTap?.call());
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ??
        BorderRadius.circular(GlassConfig.defaultButtonRadius);

    final fg = widget.foregroundColor ?? AppColors.textPrimary;

    final bool hasGradient = widget.gradient != null;

    final button = SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height,
      child: GlassSurface(
        blur: widget.blur,
        opacity: widget.opacity,
        borderRadius: radius,
        gradientTint: widget.gradient,
        showBorder: true,
        borderColor: hasGradient
            ? Colors.white.withValues(alpha: 0.40) // Stronger specular for CTA
            : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Content ──────────────────────────────────────────
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: fg, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label,
                    style: widget.textStyle ??
                        TextStyle(
                          color: fg,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                  ),
                ],
              ),
            ),

            // ── Disabled overlay ─────────────────────────────────
            if (!widget.enabled)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.40),
                ),
              ),
          ],
        ),
      ),
    );

    if (!widget.enabled || widget.onTap == null) return button;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: Opacity(
            opacity: _opacity.value,
            child: child,
          ),
        ),
        child: button,
      ),
    );
  }
}
