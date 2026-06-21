import 'package:flutter/material.dart';

import '../../design/design_system.dart';

/// A premium floating card with layered shadows that simulate real depth.
///
/// Features:
/// - Layered shadows: soft black offset + optional primary glow ring
/// - Interactive press: shadows compress when tapped (card 'presses in')
/// - Gradient top-border: 1 px line, transparent → white 20% → transparent
/// - Background: [AppColors.card]
/// - Configurable [elevation] multiplier (1.0–4.0)
///
/// Example:
/// ```dart
/// FloatingCard(
///   elevation: 2.0,
///   onTap: () {},
///   child: Text('Hello'),
/// )
/// ```
class FloatingCard extends StatefulWidget {
  const FloatingCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.elevation = 2.0,
    this.borderRadius,
    this.backgroundColor,
  }) : assert(elevation >= 1.0 && elevation <= 4.0,
            'elevation must be between 1.0 and 4.0');

  /// Content of the card.
  final Widget child;

  /// Inner padding. Defaults to [AppSpacing.md] on all sides.
  final EdgeInsetsGeometry? padding;

  /// Optional tap callback. When non-null, the card responds to press.
  final VoidCallback? onTap;

  /// Elevation multiplier (1.0–4.0) that scales shadow sizes. Defaults to 2.0.
  final double elevation;

  /// Corner radius. Defaults to [AppRadius.medium].
  final double? borderRadius;

  /// Card background. Defaults to [AppColors.card].
  final Color? backgroundColor;

  @override
  State<FloatingCard> createState() => _FloatingCardState();
}

class _FloatingCardState extends State<FloatingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pressAnimation = CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap == null) return;
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _release();
    widget.onTap?.call();
  }

  void _onTapCancel() => _release();

  void _release() {
    if (!mounted) return;
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final double r = widget.borderRadius ?? AppRadius.mVal;
    final Color bg = widget.backgroundColor ?? AppColors.card;
    final double e = widget.elevation;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _pressAnimation,
        builder: (BuildContext ctx, Widget? child) {
          // Interpolate shadow intensity: full at 0 (rest) → reduced at 1 (pressed).
          final double shadowScale = 1.0 - _pressAnimation.value * 0.6;
          final double translateY = _pressAnimation.value * 1.5;

          return Transform.translate(
            offset: Offset(0, translateY),
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(r),
                boxShadow: _buildShadows(e, shadowScale),
              ),
              child: child,
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(r),
          child: Stack(
            children: <Widget>[
              // ── Card content ──────────────────────────────────────────
              Padding(
                padding: widget.padding ??
                    const EdgeInsets.all(AppSpacing.md),
                child: widget.child,
              ),
              // ── Gradient top border ───────────────────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _TopBorderLine(borderRadius: r),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<BoxShadow> _buildShadows(double elevation, double scale) {
    return <BoxShadow>[
      // Layer 1: soft dark drop shadow
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.35 * scale),
        blurRadius: 12 * elevation * scale,
        spreadRadius: 0,
        offset: Offset(0, 4 * elevation * scale),
      ),
      // Layer 2: secondary soft shadow for depth
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.18 * scale),
        blurRadius: 6 * elevation * scale,
        offset: Offset(0, 2 * elevation * scale),
      ),
      // Layer 3: primary colour glow (subtle ring)
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.04 * elevation),
        blurRadius: 20 * elevation,
        spreadRadius: 0,
        offset: Offset.zero,
      ),
    ];
  }
}

// ---------------------------------------------------------------------------
// _TopBorderLine
// ---------------------------------------------------------------------------

/// Renders a 1 px gradient line at the top edge of the card.
class _TopBorderLine extends StatelessWidget {
  const _TopBorderLine({required this.borderRadius});

  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
        ),
        gradient: const LinearGradient(
          colors: <Color>[
            Colors.transparent,
            Color(0x33FFFFFF), // white ~20 %
            Colors.transparent,
          ],
          stops: <double>[0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}
