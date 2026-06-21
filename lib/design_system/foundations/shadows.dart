import 'package:flutter/material.dart';

/// Shadow tokens for MoneyLens Design System (MLDS).
///
/// Under MLDS, shadows are used very sparingly, inspired by Apple's soft depth
/// to create subtle elevation without visually cluttering surfaces.
class MLShadows {
  MLShadows._();

  /// Soft elevation shadow (e.g., list cards).
  static final List<BoxShadow> soft = [
    const BoxShadow(
      color: Color(0x0A000000), // Black with 4% opacity
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  /// Medium elevation shadow (e.g., floating action buttons).
  static final List<BoxShadow> medium = [
    const BoxShadow(
      color: Color(0x14000000), // Black with 8% opacity
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  /// Heavy elevation shadow (e.g., dropdown menus, popovers).
  static final List<BoxShadow> heavy = [
    const BoxShadow(
      color: Color(0x1F000000), // Black with 12% opacity
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];

  /// Elevated overlay/dialog shadow.
  static final List<BoxShadow> dialog = [
    const BoxShadow(
      color: Color(0x29000000), // Black with 16% opacity
      offset: Offset(0, 16),
      blurRadius: 32,
      spreadRadius: 0,
    ),
  ];

  /// No shadow placeholder.
  static const List<BoxShadow> none = [];
}
