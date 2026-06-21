/// {@template glass_card}
/// A premium interactive glass card for the MoneyLens UI Engine.
///
/// [GlassCard] wraps [GlassSurface] and adds:
///  - A **press-scale animation** that shrinks to 0.97 on tap-down and springs
///    back on release using [Curves.easeOutBack].
///  - A top-edge gradient highlight border that simulates a light source.
///  - A diffuse primary-coloured drop shadow for depth perception.
///  - An optional [onTap] callback.
///
/// Use [GlassCard] whenever content needs to sit inside a tappable premium
/// container (dashboard tiles, transaction rows, summary panels).
/// {@endtemplate}
library;

import 'dart:ui';
import 'package:flutter/material.dart';

import '../../design/colors/app_colors.dart';
import 'glass_config.dart';
import 'glass_surface.dart';
import '../motion/motion_constants.dart';

/// A premium interactive glass card.
///
/// Example:
/// ```dart
/// GlassCard(
///   onTap: () => print('tapped'),
///   child: Text('Balance'),
/// )
/// ```
class GlassCard extends StatefulWidget {
  /// Creates a [GlassCard].
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.isInteractive = true,
    this.borderRadius,
    this.blur = GlassConfig.blurSigma,
    this.opacity = GlassConfig.cardOpacity,
    this.gradientTint,
    this.width,
    this.height,
  });

  /// The content displayed inside the card.
  final Widget child;

  /// Inner padding applied around [child].
  ///
  /// Defaults to `EdgeInsets.all(AppSpacing.md)` (16 logical pixels).
  final EdgeInsetsGeometry? padding;

  /// Called when the card is tapped.
  ///
  /// When `null` the card is non-interactive even if [isInteractive] is `true`.
  final VoidCallback? onTap;

  /// Whether the card should react to press with a scale animation.
  ///
  /// Defaults to `true`. Has no effect if [onTap] is `null`.
  final bool isInteractive;

  /// Custom border radius.  Defaults to [GlassConfig.defaultCardRadius].
  final BorderRadius? borderRadius;

  /// Blur sigma forwarded to [GlassSurface].
  final double blur;

  /// Background opacity forwarded to [GlassSurface].
  final double opacity;

  /// Optional tint gradient forwarded to [GlassSurface].
  final Gradient? gradientTint;

  /// Optional fixed width for the card.
  final double? width;

  /// Optional fixed height for the card.
  final double? height;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

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
      end: GlassConfig.cardPressScale,
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
    if (widget.isInteractive && widget.onTap != null) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.isInteractive && widget.onTap != null) {
      _controller.reverse().then((_) => widget.onTap?.call());
    }
  }

  void _onTapCancel() {
    if (widget.isInteractive) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ??
        BorderRadius.circular(GlassConfig.defaultCardRadius);

    final card = SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Ambient Sapphire Glow
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1677FF).withValues(alpha: 0.12),
                      blurRadius: 72,
                      spreadRadius: 14,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Main Glass Body
          ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF08111D).withValues(alpha: 0.92),
                      const Color(0xFF102842).withValues(alpha: 0.86),
                      const Color(0xFF07101B).withValues(alpha: 0.90),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFF3EA6FF).withValues(alpha: 0.14),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1677FF).withValues(alpha: 0.12),
                      blurRadius: 34,
                      spreadRadius: 1,
                      offset: const Offset(0, 16),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.55),
                      blurRadius: 26,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Top Specular Reflection
                    Positioned(
                      top: -80,
                      left: -30,
                      right: -30,
                      child: IgnorePointer(
                        child: Container(
                          height: 180,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.cyanHighlight.withValues(alpha: 0.08),
                                AppColors.sapphireBlue.withValues(alpha: 0.03),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Child Content
                    Padding(
                      padding: widget.padding ?? const EdgeInsets.all(16),
                      child: widget.child,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (!widget.isInteractive || widget.onTap == null) {
      return card;
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: card,
      ),
    );
  }
}
