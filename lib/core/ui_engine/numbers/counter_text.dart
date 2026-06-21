import 'package:flutter/material.dart';

import '../../design/design_system.dart';

/// A slot-machine style digit roller that animates each digit individually
/// when the displayed [value] changes.
///
/// Non-digit characters (`,`, `.`, `₹`, spaces) are displayed statically
/// between the rolling digit columns.
///
/// Example:
/// ```dart
/// CounterText(
///   value: '1,52,430.00',
///   currencySymbol: '₹',
///   style: AppTypography.displayLarge,
/// )
/// ```
class CounterText extends StatefulWidget {
  const CounterText({
    super.key,
    required this.value,
    this.currencySymbol = '₹',
    this.style,
    this.digitWidth,
    this.rollDuration = const Duration(milliseconds: 400),
    this.rollCurve = Curves.easeOutCubic,
  });

  /// The formatted string value to display, e.g. `'1,52,430.00'`.
  /// May include commas, decimal points, but NOT the currency symbol.
  final String value;

  /// Symbol prepended before the digits. Defaults to `'₹'`.
  final String currencySymbol;

  /// Text style for each digit. Defaults to [AppTypography.displayLarge].
  final TextStyle? style;

  /// Fixed width per digit column in logical pixels.
  /// When null, the width is inferred from the style font size.
  final double? digitWidth;

  /// Duration of each digit roll. Defaults to 400 ms.
  final Duration rollDuration;

  /// Curve of each digit roll. Defaults to [Curves.easeOutCubic].
  final Curve rollCurve;

  @override
  State<CounterText> createState() => _CounterTextState();
}

class _CounterTextState extends State<CounterText> {
  late String _previousValue;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;
  }

  @override
  void didUpdateWidget(CounterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      setState(() => _previousValue = oldWidget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle resolved =
        widget.style ?? AppTypography.displayLarge.copyWith(
              color: AppColors.textPrimary,
            );

    final double fontSize = resolved.fontSize ?? 36.0;
    final double colWidth = widget.digitWidth ?? (fontSize * 0.62);
    final double colHeight = fontSize * 1.2;

    // Build a unified character list for the NEW value.
    final List<String> newChars = widget.value.split('');

    return RepaintBoundary(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        // ── Currency symbol (static) ──────────────────────────────────────
        Text(
          widget.currencySymbol,
          style: resolved.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 2),
        // ── Character columns ─────────────────────────────────────────────
        ...newChars.asMap().entries.map((MapEntry<int, String> entry) {
          final int index = entry.key;
          final String newChar = entry.value;

          // Determine the matching old character at the same index.
          final String oldChar =
              index < _previousValue.length ? _previousValue[index] : newChar;

          final bool isDigit = _isDigit(newChar);

          // Non-digit characters animate only if they changed (unlikely but
          // handled gracefully).
          if (!isDigit) {
            return _StaticChar(char: newChar, style: resolved);
          }

          return _RollingDigit(
            key: ValueKey<int>(index),
            oldDigit: oldChar,
            newDigit: newChar,
            style: resolved,
            colWidth: colWidth,
            colHeight: colHeight,
            duration: widget.rollDuration,
            curve: widget.rollCurve,
          );
        }),
      ],
    ),
    );
  }

  static bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
}

// ---------------------------------------------------------------------------
// _StaticChar – renders punctuation / separators without animation
// ---------------------------------------------------------------------------

class _StaticChar extends StatelessWidget {
  const _StaticChar({required this.char, required this.style});

  final String char;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Text(char, style: style.copyWith(color: AppColors.textSecondary));
  }
}

// ---------------------------------------------------------------------------
// _RollingDigit – animates a single digit column slot-machine style
// ---------------------------------------------------------------------------

class _RollingDigit extends StatefulWidget {
  const _RollingDigit({
    super.key,
    required this.oldDigit,
    required this.newDigit,
    required this.style,
    required this.colWidth,
    required this.colHeight,
    required this.duration,
    required this.curve,
  });

  final String oldDigit;
  final String newDigit;
  final TextStyle style;
  final double colWidth;
  final double colHeight;
  final Duration duration;
  final Curve curve;

  @override
  State<_RollingDigit> createState() => _RollingDigitState();
}

class _RollingDigitState extends State<_RollingDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _offset; // 0 = show new at bottom, 1 = new in place
  late String _old;
  late String _new;

  @override
  void initState() {
    super.initState();
    _old = widget.oldDigit;
    _new = widget.newDigit;

    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _offset = CurvedAnimation(parent: _ctrl, curve: widget.curve);

    if (_old != _new) {
      _ctrl.forward();
    } else {
      _ctrl.value = 1.0; // already in position
    }
  }

  @override
  void didUpdateWidget(_RollingDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.newDigit != widget.newDigit) {
      _old = oldWidget.newDigit;
      _new = widget.newDigit;
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double h = widget.colHeight;

    return SizedBox(
      width: widget.colWidth,
      height: h,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _offset,
          builder: (BuildContext ctx, Widget? _) {
            final double t = _offset.value;
            // old digit slides upward (exits at top)
            final double oldY = -h * t;
            // new digit slides in from bottom
            final double newY = h * (1 - t);

            return Stack(
              clipBehavior: Clip.hardEdge,
              children: <Widget>[
                // Old digit
                Transform.translate(
                  offset: Offset(0, oldY),
                  child: _DigitText(
                    digit: _old,
                    style: widget.style,
                    width: widget.colWidth,
                    height: h,
                  ),
                ),
                // New digit
                Transform.translate(
                  offset: Offset(0, newY),
                  child: _DigitText(
                    digit: _new,
                    style: widget.style,
                    width: widget.colWidth,
                    height: h,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DigitText extends StatelessWidget {
  const _DigitText({
    required this.digit,
    required this.style,
    required this.width,
    required this.height,
  });

  final String digit;
  final TextStyle style;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child: Text(digit, style: style, textAlign: TextAlign.center),
      ),
    );
  }
}
