import 'package:flutter/material.dart';

/// springy press-scale micro-interaction widget.
class SpringyPress extends StatefulWidget {
  const SpringyPress({
    super.key,
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final VoidCallback onTap;

  @override
  State<SpringyPress> createState() => _SpringyPressState();
}

class _SpringyPressState extends State<SpringyPress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}

/// Shakes the child horizontally to represent validation failures or errors.
class MicroShake extends StatefulWidget {
  const MicroShake({
    super.key,
    required this.child,
    required this.shakeTrigger,
  });

  final Widget child;
  final bool shakeTrigger;

  @override
  State<MicroShake> createState() => _MicroShakeState();
}

class _MicroShakeState extends State<MicroShake>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _offset = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 10.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -10.0, end: 8.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 8.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant MicroShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shakeTrigger != oldWidget.shakeTrigger && widget.shakeTrigger) {
      _ctrl.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offset,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_offset.value, 0.0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
