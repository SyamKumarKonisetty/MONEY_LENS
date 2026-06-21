import 'package:flutter/material.dart';
import '../../foundations/colors.dart';
import '../../foundations/curves.dart';
import '../../foundations/duration.dart';
import '../../foundations/spacing.dart';

/// MoneyLens Design System (MLDS) Scaffold Layout.
///
/// Wraps screen content, handling background colors, standard transition animations,
/// page entry, and bottom/floating navigation rails.
class MLScaffold extends StatefulWidget {
  const MLScaffold({
    required this.body,
    super.key,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.animateEntrance = true,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool animateEntrance;

  @override
  State<MLScaffold> createState() => _MLScaffoldState();
}

class _MLScaffoldState extends State<MLScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: MLDuration.normal);
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.04), end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: MLCurves.pageForward),
        );

    if (widget.animateEntrance) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget currentBody = widget.body;
    if (widget.animateEntrance) {
      currentBody = AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(opacity: _fadeAnimation, child: child),
          );
        },
        child: currentBody,
      );
    }

    return Scaffold(
      backgroundColor: MLColors.background(context),
      appBar: widget.appBar,
      body: currentBody,
      bottomNavigationBar: widget.bottomNavigationBar,
      floatingActionButton: widget.floatingActionButton,
    );
  }
}

/// A standard content block container designed to align elements contextually.
class MLContentArea extends StatelessWidget {
  const MLContentArea({
    required this.child,
    super.key,
    this.padding,
    this.constraints,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BoxConstraints? constraints;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: constraints,
      padding: padding,
      color: color,
      child: child,
    );
  }
}

/// Header hero section for presenting high-priority numerical financial summaries.
class MLHeroArea extends StatelessWidget {
  const MLHeroArea({
    required this.child,
    super.key,
    this.height,
    this.gradient,
    this.color,
    this.padding,
    this.alignment = Alignment.centerLeft,
  });

  final Widget child;
  final double? height;
  final Gradient? gradient;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      alignment: alignment,
      padding: padding ?? const EdgeInsets.all(MLSpacing.pagePadding),
      decoration: BoxDecoration(color: color, gradient: gradient),
      child: SafeArea(bottom: false, child: child),
    );
  }
}
