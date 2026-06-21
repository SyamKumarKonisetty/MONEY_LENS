import 'package:flutter/animation.dart';

/// Centralized animation durations and curves for MoneyLens V2.
class AppAnimations {
  AppAnimations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  static const Curve ease = Curves.easeInOut;
  static const Curve spring = Curves.fastOutSlowIn;
  static const Curve bounce = Curves.bounceOut;
}
