/// {@template motion_constants}
/// All animation durations, curves, and timing constants for the
/// MoneyLens Motion System.
///
/// Every widget in the UI Engine that performs animation must source its
/// timing values from this file so the motion language is consistent across
/// the entire app.
/// {@endtemplate}
library;

import 'package:flutter/animation.dart';

/// Centralised animation timing constants for the MoneyLens Motion System.
///
/// ### Duration tiers
/// | Tier        | Duration | Typical use                              |
/// |-------------|----------|------------------------------------------|
/// | micro       | 80 ms    | Icon morphs, colour shifts               |
/// | tap         | 120 ms   | Press-scale feedback                     |
/// | fast        | 200 ms   | Tooltips, badge appearances              |
/// | normal      | 300 ms   | State transitions, cards                 |
/// | slow        | 500 ms   | Hero / shared-element transitions        |
/// | entrance    | 600 ms   | Screen entrance, stagger parents         |
class MotionConstants {
  MotionConstants._(); // Prevent instantiation.

  // ── Durations ─────────────────────────────────────────────────────────────

  /// 80 ms – micro interactions: icon morphs, colour transitions.
  static const Duration microDuration = Duration(milliseconds: 80);

  /// 120 ms – tap feedback: press-scale animations.
  static const Duration tapDuration = Duration(milliseconds: 120);

  /// 200 ms – fast transitions: tooltips, badge appearances.
  static const Duration fastDuration = Duration(milliseconds: 200);

  /// 300 ms – normal transitions: card state changes, reveals.
  static const Duration normalDuration = Duration(milliseconds: 300);

  /// 500 ms – slow transitions: hero elements, modal entrances.
  static const Duration slowDuration = Duration(milliseconds: 500);

  /// 600 ms – entrance animations: screen-level entrance, stagger parents.
  static const Duration entranceDuration = Duration(milliseconds: 600);

  // ── Stagger ───────────────────────────────────────────────────────────────

  /// Per-item delay used in [StaggerList] to cascade list item entrances.
  static const Duration staggerDelay = Duration(milliseconds: 60);

  // ── Curves ────────────────────────────────────────────────────────────────

  /// Overshoot spring feel – used for press-release & modal entry.
  static const Curve springCurve = Curves.easeOutBack;

  /// Quick acceleration then smooth deceleration – default push transitions.
  static const Curve snappyCurve = Curves.fastOutSlowIn;

  /// Symmetric ease – continuous / looping animations.
  static const Curve smoothCurve = Curves.easeInOutCubic;

  /// Gravity-drop bounce at the end – playful confirmations.
  static const Curve bounceCurve = Curves.bounceOut;

  /// Fast start, slow end – scrolling momentum, list reveals.
  static const Curve decelerateCurve = Curves.decelerate;

  /// Ease in then ease out – generic fade transitions.
  static const Curve easeInOutCurve = Curves.easeInOut;
}
