/// {@template stagger_list}
/// Staggered list entrance animation widgets for the MoneyLens Motion System.
///
/// This file provides two public widgets:
///
/// - **[StaggerList]** – wraps a list of children and animates them in with a
///   configurable cascade delay.  Each item fades + slides in from the
///   configured [direction].
///
/// - **[StaggerItem]** – a standalone item wrapper for use when you need to
///   add a staggered item inside a pre-existing layout (e.g. a custom
///   [ListView.builder]).
///
/// ### Example – StaggerList
/// ```dart
/// StaggerList(
///   direction: StaggerDirection.bottom,
///   children: [
///     TransactionRow(tx: tx1),
///     TransactionRow(tx: tx2),
///     TransactionRow(tx: tx3),
///   ],
/// )
/// ```
///
/// ### Example – StaggerItem in ListView.builder
/// ```dart
/// ListView.builder(
///   itemCount: items.length,
///   itemBuilder: (ctx, i) => StaggerItem(
///     index: i,
///     direction: StaggerDirection.bottom,
///     child: MyRow(item: items[i]),
///   ),
/// )
/// ```
/// {@endtemplate}
library;

import 'package:flutter/material.dart';

import 'motion_constants.dart';

/// The axis from which list items enter the screen.
enum StaggerDirection {
  /// Items slide in from below (default).
  bottom,

  /// Items slide in from above.
  top,

  /// Items slide in from the left.
  left,

  /// Items slide in from the right.
  right,
}

/// Converts a [StaggerDirection] to the starting [Offset] for a slide tween.
Offset _directionToOffset(StaggerDirection direction) {
  switch (direction) {
    case StaggerDirection.bottom:
      return const Offset(0, 0.30);
    case StaggerDirection.top:
      return const Offset(0, -0.30);
    case StaggerDirection.left:
      return const Offset(-0.30, 0);
    case StaggerDirection.right:
      return const Offset(0.30, 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// StaggerList
// ─────────────────────────────────────────────────────────────────────────────

/// A [Column]-based widget that renders [children] with a staggered entrance.
///
/// Each child is wrapped in a [StaggerItem] with an index-derived delay so
/// items cascade in one after another.
///
/// The [staggerDelay] between consecutive items defaults to
/// [MotionConstants.staggerDelay] (60 ms).
class StaggerList extends StatelessWidget {
  /// Creates a [StaggerList].
  const StaggerList({
    super.key,
    required this.children,
    this.direction = StaggerDirection.bottom,
    this.staggerDelay,
    this.initialDelay = Duration.zero,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  /// The list of widgets to animate in sequence.
  final List<Widget> children;

  /// Direction from which each item enters.
  final StaggerDirection direction;

  /// Delay between consecutive items.
  ///
  /// Defaults to [MotionConstants.staggerDelay] (60 ms).
  final Duration? staggerDelay;

  /// Optional initial delay before the first item begins animating.
  final Duration initialDelay;

  /// [MainAxisAlignment] passed to the internal [Column].
  final MainAxisAlignment mainAxisAlignment;

  /// [CrossAxisAlignment] passed to the internal [Column].
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final delay = staggerDelay ?? MotionConstants.staggerDelay;
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < children.length; i++)
          StaggerItem(
            index: i,
            direction: direction,
            staggerDelay: delay,
            initialDelay: initialDelay,
            child: children[i],
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// StaggerItem
// ─────────────────────────────────────────────────────────────────────────────

/// An individual stagger-animated item wrapper.
///
/// Plays a fade + fractional slide entrance animation whose start is offset by
/// `initialDelay + index × staggerDelay`.
///
/// The animation begins as soon as the widget is mounted and plays once.
/// The [AnimationController] is properly disposed on widget removal.
class StaggerItem extends StatefulWidget {
  /// Creates a [StaggerItem].
  ///
  /// [index] and [child] are required.
  const StaggerItem({
    super.key,
    required this.index,
    required this.child,
    this.direction = StaggerDirection.bottom,
    this.staggerDelay,
    this.initialDelay = Duration.zero,
    this.entranceDuration,
  });

  /// Zero-based position in the list used to compute the start delay.
  final int index;

  /// The widget to animate.
  final Widget child;

  /// Direction from which this item enters.
  final StaggerDirection direction;

  /// Per-item delay. Defaults to [MotionConstants.staggerDelay] (60 ms).
  final Duration? staggerDelay;

  /// Delay before the first item (index 0) starts. Defaults to [Duration.zero].
  final Duration initialDelay;

  /// Duration of the entrance animation itself.
  ///
  /// Defaults to [MotionConstants.entranceDuration] (600 ms).
  final Duration? entranceDuration;

  @override
  State<StaggerItem> createState() => _StaggerItemState();
}

class _StaggerItemState extends State<StaggerItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    final duration =
        widget.entranceDuration ?? MotionConstants.entranceDuration;

    _controller = AnimationController(vsync: this, duration: duration);

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _slide = Tween<Offset>(
      begin: _directionToOffset(widget.direction),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Stagger start
    final itemDelay = widget.staggerDelay ?? MotionConstants.staggerDelay;
    final totalDelay = widget.initialDelay +
        Duration(milliseconds: itemDelay.inMilliseconds * widget.index);

    if (totalDelay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(totalDelay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
