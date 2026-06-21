import 'package:flutter/material.dart';

/// Centralized border radius system for MoneyLens V2.
class AppRadius {
  AppRadius._();

  static const double sVal = 12.0;
  static const double mVal = 18.0;
  static const double lVal = 24.0;
  static const double xlVal = 32.0;
  static const double pillVal = 999.0;

  static final BorderRadius small = BorderRadius.circular(sVal);
  static final BorderRadius medium = BorderRadius.circular(mVal);
  static final BorderRadius large = BorderRadius.circular(lVal);
  static final BorderRadius xl = BorderRadius.circular(xlVal);
  static final BorderRadius pill = BorderRadius.circular(pillVal);

  // Backward compatibility mappings (matching old system)
  static final BorderRadius circularSm = BorderRadius.circular(6.0);
  static final BorderRadius circularMd = BorderRadius.circular(8.0);
  static final BorderRadius circularLg = BorderRadius.circular(12.0);
  static final BorderRadius circularXl = BorderRadius.circular(16.0);
  static final BorderRadius circularFull = BorderRadius.circular(999.0);
  
  static final BorderRadius card = medium;
  static final BorderRadius button = small;
  static final BorderRadius bottomSheet = BorderRadius.vertical(top: Radius.circular(mVal));
}
