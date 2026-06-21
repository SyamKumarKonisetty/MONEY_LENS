import 'package:flutter/material.dart';

/// Represents a dynamic storytelling item displayed on the Hero Dashboard.
class DashboardStory {
  const DashboardStory({
    required this.message,
    required this.icon,
    required this.color,
    this.categoryName,
    this.percentageChange,
  });

  /// The narrative message text (e.g. "You spent ₹420 today.")
  final String message;

  /// The associated visual icon.
  final IconData icon;

  /// Theme accent color for this story.
  final Color color;

  /// Optional spending category highlighted.
  final String? categoryName;

  /// Optional percentage balance movement.
  final double? percentageChange;
}

/// Represents a premium smart financial insight.
class SmartInsight {
  const SmartInsight({
    required this.icon,
    required this.color,
    required this.headline,
    required this.subtitle,
  });

  /// The leading icon.
  final IconData icon;

  /// The visual color theme.
  final Color color;

  /// Bold main statement.
  final String headline;

  /// Supporting descriptions.
  final String subtitle;
}
