import 'package:flutter/material.dart';

/// MoneyLens Design System (MLDS) Brand gradient presets.
class MLGradients {
  MLGradients._();

  static const Gradient primary = LinearGradient(
    colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient success = LinearGradient(
    colors: [Color(0xFF34C759), Color(0xFF30B0C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
