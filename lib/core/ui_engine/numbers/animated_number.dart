import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../design/design_system.dart';

// ---------------------------------------------------------------------------
// Formatters
// ---------------------------------------------------------------------------

/// Indian number system formatter (e.g. ₹52,430.00).
final NumberFormat _indianFull = NumberFormat('#,##,###.##', 'en_IN');

/// Returns a compact Indian-locale string:
///   < 1 000       →  "999"
///   ≥ 1 000       →  "1.2K"
///   ≥ 1 00 000    →  "1.2L"
///   ≥ 1 00 00 000 →  "1.2Cr"
String _compactIndian(double value) {
  if (value.abs() >= 10000000) {
    return '${(value / 10000000).toStringAsFixed(1)}Cr';
  } else if (value.abs() >= 100000) {
    return '${(value / 100000).toStringAsFixed(1)}L';
  } else if (value.abs() >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}K';
  }
  return value.toStringAsFixed(0);
}

/// Full Indian locale formatted string (e.g. ₹1,52,430.00).
String _fullIndian(double value) {
  try {
    return _indianFull.format(value);
  } catch (_) {
    return value.toStringAsFixed(2);
  }
}

// ---------------------------------------------------------------------------
// AnimatedNumber
// ---------------------------------------------------------------------------

/// Animates a [double] value from its previous state to [value] over
/// [duration] using [curve].
///
/// Supports:
/// - [prefix] – prepended symbol (default `'₹'`)
/// - [isCompact] – `true` → `1.2L`, `false` → full `₹52,430.00`
/// - [style] – override [TextStyle]
///
/// Example:
/// ```dart
/// AnimatedNumber(value: balance, isCompact: false)
/// ```
class AnimatedNumber extends StatelessWidget {
  const AnimatedNumber({
    super.key,
    required this.value,
    this.prefix = '₹',
    this.style,
    this.isCompact = false,
    this.duration = const Duration(milliseconds: 1200),
    this.curve = Curves.easeOutCubic,
  });

  /// The target numeric value.
  final double value;

  /// Symbol prepended to the formatted number. Defaults to `'₹'`.
  final String prefix;

  /// Text style. Defaults to [AppTypography.title] in white.
  final TextStyle? style;

  /// When `true`, formats compactly (e.g. `₹1.2L`). Defaults to `false`.
  final bool isCompact;

  /// Duration of the counter animation. Defaults to 1200 ms.
  final Duration duration;

  /// Curve of the counter animation. Defaults to [Curves.easeOutCubic].
  final Curve curve;

  String _format(double v) {
    if (isCompact) return '$prefix${_compactIndian(v)}';
    return '$prefix${_fullIndian(v)}';
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle resolved =
        style ?? AppTypography.title.copyWith(color: AppColors.textPrimary);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: value),
      duration: duration,
      curve: curve,
      builder: (BuildContext ctx, double animatedValue, Widget? _) {
        return RepaintBoundary(
          child: Text(
            _format(animatedValue),
            style: resolved,
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// MoneyRiseText
// ---------------------------------------------------------------------------

/// Extends [AnimatedNumber] with a rising/falling delta particle.
///
/// When [value] increases relative to the previous value, a small `+amount`
/// label floats upward and fades out in [AppColors.income].
///
/// When [value] decreases, a `-amount` label drops and fades in
/// [AppColors.expense].
class MoneyRiseText extends StatefulWidget {
  const MoneyRiseText({
    super.key,
    required this.value,
    this.prefix = '₹',
    this.style,
    this.isCompact = false,
    this.duration = const Duration(milliseconds: 1200),
    this.curve = Curves.easeOutCubic,
    this.particleDuration = const Duration(milliseconds: 900),
  });

  /// The target numeric value.
  final double value;

  /// Symbol prepended to the formatted number. Defaults to `'₹'`.
  final String prefix;

  /// Text style for the main number.
  final TextStyle? style;

  /// Whether to display compact format.
  final bool isCompact;

  /// Duration of the main counter animation.
  final Duration duration;

  /// Curve of the main counter animation.
  final Curve curve;

  /// Duration of the rise/fall particle animation.
  final Duration particleDuration;

  @override
  State<MoneyRiseText> createState() => _MoneyRiseTextState();
}

class _MoneyRiseTextState extends State<MoneyRiseText>
    with TickerProviderStateMixin {
  double _previousValue = 0;
  double _delta = 0;

  late AnimationController _particleController;
  late Animation<double> _particleOffset;
  late Animation<double> _particleOpacity;

  bool _particleVisible = false;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;

    _particleController = AnimationController(
      vsync: this,
      duration: widget.particleDuration,
    );

    _particleOffset = Tween<double>(begin: 0, end: -30).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeOut),
    );

    _particleOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0),
        weight: 80,
      ),
    ]).animate(_particleController);

    _particleController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _particleVisible = false);
      }
    });
  }

  @override
  void didUpdateWidget(MoneyRiseText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _delta = widget.value - _previousValue;
      _previousValue = widget.value;
      _triggerParticle();
    }
  }

  void _triggerParticle() {
    if (!mounted) return;
    final bool rising = _delta > 0;

    // Re-configure offset direction based on delta sign.
    _particleOffset = Tween<double>(
      begin: 0,
      end: rising ? -30.0 : 30.0,
    ).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeOut),
    );

    setState(() => _particleVisible = true);
    _particleController
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  String _formatDelta(double d) {
    final String sign = d > 0 ? '+' : '';
    if (widget.isCompact) {
      return '$sign${widget.prefix}${_compactIndian(d.abs())}';
    }
    return '$sign${widget.prefix}${_fullIndian(d.abs())}';
  }

  @override
  Widget build(BuildContext context) {
    final bool rising = _delta >= 0;
    final Color particleColor =
        rising ? AppColors.income : AppColors.expense;

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        // ── Main animated number ─────────────────────────────────────────
        AnimatedNumber(
          value: widget.value,
          prefix: widget.prefix,
          style: widget.style,
          isCompact: widget.isCompact,
          duration: widget.duration,
          curve: widget.curve,
        ),
        // ── Rise/fall particle ───────────────────────────────────────────
        if (_particleVisible)
          Positioned(
            top: null,
            right: 0,
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (BuildContext ctx, Widget? _) {
                return Transform.translate(
                  offset: Offset(0, _particleOffset.value),
                  child: Opacity(
                    opacity: _particleOpacity.value.clamp(0.0, 1.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: particleColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.pillVal),
                      ),
                      child: Text(
                        _formatDelta(_delta),
                        style: AppTypography.caption.copyWith(
                          color: particleColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
