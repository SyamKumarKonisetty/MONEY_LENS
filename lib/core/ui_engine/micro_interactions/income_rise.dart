import 'package:flutter/material.dart';

import '../../design/design_system.dart';

/// A micro-interaction widget that floats a green "+₹amount" text upward and
/// fades it out when [isPlaying] becomes `true`.
///
/// The floating text:
/// - Translates Y from 0 → −40px
/// - Fades from opacity 1.0 → 0.0
/// - Duration: 800 ms with ease-out
///
/// Usage:
/// ```dart
/// IncomeRise(
///   amount: 2500.0,
///   isPlaying: _showIncome,
///   child: const Icon(Icons.account_balance_wallet_rounded),
/// )
/// ```
class IncomeRise extends StatefulWidget {
  /// Creates an [IncomeRise].
  const IncomeRise({
    super.key,
    required this.amount,
    required this.isPlaying,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.riseDistance = 40.0,
    this.currencySymbol = '₹',
  });

  /// The numeric income amount to display (e.g. 2500.0 → "+₹2,500").
  final double amount;

  /// When `true`, the rise animation plays once.
  final bool isPlaying;

  /// The widget below the floating label.
  final Widget child;

  /// Duration of the rise animation.
  final Duration duration;

  /// How many pixels the label rises before fading out.
  final double riseDistance;

  /// Currency symbol prefix.
  final String currencySymbol;

  @override
  State<IncomeRise> createState() => _IncomeRiseState();
}

class _IncomeRiseState extends State<IncomeRise>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _riseAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);

    _riseAnim = Tween<double>(begin: 0, end: -widget.riseDistance).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void didUpdateWidget(IncomeRise old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying && !old.isPlaying) {
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

  String get _formattedAmount {
    final val = widget.amount.abs();
    // Simple locale-agnostic comma formatting
    final parts = val.toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) buffer.write(',');
      buffer.write(parts[i]);
    }
    return '+${widget.currencySymbol}${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          widget.child,

          // Floating income label
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) {
              if (!_ctrl.isAnimating && !_ctrl.isCompleted) {
                return const SizedBox.shrink();
              }
              return Positioned(
                top: -20 + _riseAnim.value,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: _fadeAnim.value.clamp(0.0, 1.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.income.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.pillVal),
                        border: Border.all(
                          color: AppColors.income.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        _formattedAmount,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.income,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
