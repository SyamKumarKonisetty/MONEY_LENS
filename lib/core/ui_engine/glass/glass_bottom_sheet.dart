/// {@template glass_bottom_sheet}
/// A premium glass-morphic bottom sheet for the MoneyLens UI Engine.
///
/// [GlassBottomSheet] provides:
///  - A blurred scrim (sigma 12) that dims and frosts the content behind.
///  - A glass surface that slides up from the bottom with a spring animation.
///  - A 40 × 4 drag handle at the top, rendered as a rounded capsule.
///  - An optional title shown below the drag handle.
///  - A [SafeArea] inset at the bottom so content does not bleed under the
///    system navigation bar.
///  - A [DraggableScrollableSheet]-style feel via a fixed [heightFactor].
///
/// Use [GlassBottomSheet.show] to present the sheet from any [BuildContext]:
///
/// ```dart
/// GlassBottomSheet.show(
///   context,
///   title: 'Filter Transactions',
///   heightFactor: 0.6,
///   child: FilterPanel(),
/// );
/// ```
/// {@endtemplate}
library;

import 'dart:ui';

import 'package:flutter/material.dart';

import 'glass_config.dart';
import 'glass_surface.dart';
import '../motion/motion_constants.dart';
import 'package:money_lens/core/design/design_system.dart';

/// A premium glass-morphic bottom sheet with blurred scrim and spring animation.
class GlassBottomSheet extends StatefulWidget {
  /// Creates a [GlassBottomSheet].
  const GlassBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.heightFactor = 0.55,
    this.borderRadius,
    this.onDismiss,
  })  : assert(
          heightFactor > 0.0 && heightFactor <= 1.0,
          'heightFactor must be in the range (0, 1].',
        );

  /// Content displayed inside the bottom sheet below the drag handle and title.
  final Widget child;

  /// Optional title rendered below the drag handle.
  final String? title;

  /// Fraction of the screen height occupied by the sheet.
  ///
  /// Value must be in the range `(0.0, 1.0]`. Defaults to `0.55`.
  final double heightFactor;

  /// Custom border radius for the top corners of the sheet.
  ///
  /// Defaults to `BorderRadius.vertical(top: Radius.circular(28))`.
  final BorderRadius? borderRadius;

  /// Called when the scrim or back gesture dismisses the sheet.
  final VoidCallback? onDismiss;

  /// Presents a [GlassBottomSheet] above the current route.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    double heightFactor = 0.55,
    BorderRadius? borderRadius,
    bool isDismissible = true,
    VoidCallback? onDismiss,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: MotionConstants.slowDuration,
      pageBuilder: (ctx, animation, secondaryAnimation) => GlassBottomSheet(
        title: title,
        heightFactor: heightFactor,
        borderRadius: borderRadius,
        onDismiss: onDismiss ?? () => Navigator.of(ctx).pop(),
        child: child,
      ),
      transitionBuilder: (ctx, animation, _, child) {
        // Slide up from bottom with spring
        final slideAnim = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: MotionConstants.springCurve,
            reverseCurve: MotionConstants.snappyCurve,
          ),
        );
        final fadeAnim = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
          reverseCurve: Curves.easeIn,
        );
        return FadeTransition(
          opacity: fadeAnim,
          child: SlideTransition(position: slideAnim, child: child),
        );
      },
    );
  }

  @override
  State<GlassBottomSheet> createState() => _GlassBottomSheetState();
}

class _GlassBottomSheetState extends State<GlassBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ??
        const BorderRadius.vertical(top: Radius.circular(28));

    final screenHeight = MediaQuery.sizeOf(context).height;
    final sheetHeight = screenHeight * widget.heightFactor;

    return Stack(
      children: [
        // ── Blurred scrim ─────────────────────────────────────────────────
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              widget.onDismiss?.call();
              Navigator.of(context).pop();
            },
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: GlassConfig.scrimBlurSigma,
                sigmaY: GlassConfig.scrimBlurSigma,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.40),
                ),
              ),
            ),
          ),
        ),

        // ── Sheet surface ─────────────────────────────────────────────────
        Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              height: sheetHeight,
              child: GlassSurface(
                blur: GlassConfig.blurSigma,
                opacity: 0.14,
                borderRadius: radius,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Drag handle ───────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 4),
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),

                    // ── Optional title ────────────────────────────────────
                    if (widget.title != null) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                        child: Text(
                          widget.title!,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],

                    // ── Divider ───────────────────────────────────────────
                    Divider(
                      color: Colors.white.withValues(alpha: 0.08),
                      thickness: 1,
                      height: 1,
                    ),

                    // ── Child content + SafeArea ──────────────────────────
                    Expanded(
                      child: SafeArea(
                        top: false,
                        child: widget.child,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
