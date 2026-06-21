library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/design/colors/app_colors.dart';
import '../../../../../core/ui_engine/motion/motion_constants.dart';

/// Renders amount text with a count animation and proper currency signs.
///
/// Incomes show +₹X,XXX.XX in green, while expenses show -₹X,XXX.XX in red.
class AnimatedAmountText extends StatelessWidget {
  const AnimatedAmountText({
    super.key,
    required this.amount,
    required this.isIncome,
    this.style,
  });

  final double amount;
  final bool isIncome;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: amount),
      duration: MotionConstants.slowDuration,
      curve: MotionConstants.smoothCurve,
      builder: (context, value, child) {
        final formatted = formatter.format(value);
        return Text(
          '${isIncome ? "+" : "-"}$formatted',
          style: (style ?? const TextStyle()).copyWith(
            color: isIncome ? AppColors.income : AppColors.expense,
            fontWeight: FontWeight.w700,
          ),
        );
      },
    );
  }
}

/// Cascading stagger visual entrance transition wrapper.
class StaggeredTimelineEntrance extends StatefulWidget {
  const StaggeredTimelineEntrance({
    super.key,
    required this.child,
    required this.index,
    this.baseDelay = 35,
  });

  final Widget child;
  final int index;
  final int baseDelay;

  @override
  State<StaggeredTimelineEntrance> createState() => _StaggeredTimelineEntranceState();
}

class _StaggeredTimelineEntranceState extends State<StaggeredTimelineEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _yOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MotionConstants.normalDuration,
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _yOffset = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: MotionConstants.springCurve,
      ),
    );

    final delay = widget.baseDelay * widget.index;
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, _yOffset.value),
            child: widget.child,
          ),
        );
      },
    );
  }
}
