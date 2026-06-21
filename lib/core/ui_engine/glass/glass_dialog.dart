/// {@template glass_dialog}
/// A premium glass-morphic dialog for the MoneyLens UI Engine.
///
/// [GlassDialog] replaces the default Material [AlertDialog] with a surface
/// that matches the MoneyLens glass design language:
///  - The scrim behind the dialog is blurred (sigma 12) via [BackdropFilter].
///  - The dialog itself is a [GlassSurface] with a 1-px gradient border.
///  - Entry animation: scale 0.85 → 1.0 + fade-in using [Curves.easeOutBack].
///  - Exit animation: scale 1.0 → 0.90 + fade-out.
///
/// Use the static [showGlassDialog] method to present the dialog:
///
/// ```dart
/// await GlassDialog.show(
///   context,
///   title: 'Delete Transaction?',
///   body: Text('This action cannot be undone.'),
///   actions: [
///     GlassDialogAction(label: 'Cancel', onTap: () => Navigator.pop(context)),
///     GlassDialogAction(
///       label: 'Delete',
///       isPrimary: true,
///       onTap: () { /* delete */ Navigator.pop(context); },
///     ),
///   ],
/// );
/// ```
/// {@endtemplate}
library;

import 'dart:ui';

import 'package:flutter/material.dart';

import 'glass_config.dart';
import 'glass_surface.dart';
import 'glass_button.dart';
import '../motion/motion_constants.dart';
import 'package:money_lens/core/design/design_system.dart';

/// Describes a single action button shown at the bottom of a [GlassDialog].
@immutable
class GlassDialogAction {
  /// Creates a [GlassDialogAction].
  const GlassDialogAction({
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  /// Text label shown on the button.
  final String label;

  /// Callback invoked when the action button is tapped.
  final VoidCallback onTap;

  /// When `true`, the button is rendered with the app's primary gradient.
  ///
  /// Use for the affirmative / destructive action. Defaults to `false`.
  final bool isPrimary;
}

/// A premium glass-morphic dialog widget.
///
/// Do not use this widget directly in a widget tree; use [GlassDialog.show].
class GlassDialog extends StatefulWidget {
  /// Creates a [GlassDialog].
  const GlassDialog({
    super.key,
    required this.title,
    required this.body,
    required this.actions,
    this.titleStyle,
    this.borderRadius,
    this.primaryGradient,
  });

  /// Title text displayed at the top of the dialog.
  final String title;

  /// Arbitrary widget rendered as the dialog body below the title.
  final Widget body;

  /// List of action buttons shown at the bottom of the dialog.
  final List<GlassDialogAction> actions;

  /// Custom text style for [title]. Defaults to 18 sp, weight 600, white.
  final TextStyle? titleStyle;

  /// Custom border radius for the dialog surface. Defaults to 24.
  final BorderRadius? borderRadius;

  /// Gradient used for primary action buttons.
  ///
  /// Defaults to the app primary blue gradient.
  final Gradient? primaryGradient;

  /// Presents a [GlassDialog] above the current route.
  ///
  /// Returns a [Future] that completes when the dialog is dismissed.
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget body,
    required List<GlassDialogAction> actions,
    TextStyle? titleStyle,
    BorderRadius? borderRadius,
    Gradient? primaryGradient,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: MotionConstants.normalDuration,
      pageBuilder: (ctx, animation, secondaryAnimation) => GlassDialog(
        title: title,
        body: body,
        actions: actions,
        titleStyle: titleStyle,
        borderRadius: borderRadius,
        primaryGradient: primaryGradient,
      ),
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        // Scale 0.85 → 1.0 with easeOutBack overshoot
        final scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: MotionConstants.springCurve,
            reverseCurve: Curves.easeInCubic,
          ),
        );
        final fadeAnim = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
          reverseCurve: Curves.easeIn,
        );
        return FadeTransition(
          opacity: fadeAnim,
          child: ScaleTransition(scale: scaleAnim, child: child),
        );
      },
    );
  }

  @override
  State<GlassDialog> createState() => _GlassDialogState();
}

class _GlassDialogState extends State<GlassDialog> {
  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(24);
    final defaultGradient = const LinearGradient(
      colors: [Color(0xFF1677FF), Color(0xFF3EA6FF)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
    final primaryGradient = widget.primaryGradient ?? defaultGradient;

    return Stack(
      children: [
        // ── Blurred scrim ─────────────────────────────────────────────────
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: GlassConfig.scrimBlurSigma,
                sigmaY: GlassConfig.scrimBlurSigma,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                ),
              ),
            ),
          ),
        ),

        // ── Dialog surface ────────────────────────────────────────────────
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Material(
              color: Colors.transparent,
              child: GlassSurface(
                borderRadius: radius,
                blur: GlassConfig.blurSigma,
                opacity: 0.14,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      Text(
                        widget.title,
                        style: widget.titleStyle ??
                            TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                            ),
                      ),

                      const SizedBox(height: 12),

                      // Body
                      DefaultTextStyle(
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.70),
                          fontSize: 15,
                          height: 1.5,
                        ),
                        child: widget.body,
                      ),

                      const SizedBox(height: 24),

                      // Actions
                      if (widget.actions.isNotEmpty)
                        _ActionsRow(
                          actions: widget.actions,
                          primaryGradient: primaryGradient,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Internal widget that renders the dialog action buttons.
class _ActionsRow extends StatelessWidget {
  const _ActionsRow({
    required this.actions,
    required this.primaryGradient,
  });

  final List<GlassDialogAction> actions;
  final Gradient primaryGradient;

  @override
  Widget build(BuildContext context) {
    if (actions.length == 1) {
      final a = actions.first;
      return GlassButton(
        label: a.label,
        onTap: a.onTap,
        gradient: a.isPrimary ? primaryGradient : null,
        height: 48,
      );
    }

    return Row(
      children: [
        for (int i = 0; i < actions.length; i++) ...[
          Expanded(
            child: GlassButton(
              label: actions[i].label,
              onTap: actions[i].onTap,
              gradient: actions[i].isPrimary ? primaryGradient : null,
              height: 48,
            ),
          ),
          if (i < actions.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }
}
