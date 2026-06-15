/// Numeric extensions for MoneyLens.
extension NumExtensions on num {
  /// Convert value to abbreviated string: 1200 → '1.2K'
  String get abbreviated {
    if (this >= 10000000) return '${(this / 10000000).toStringAsFixed(1)}Cr';
    if (this >= 100000) return '${(this / 100000).toStringAsFixed(1)}L';
    if (this >= 1000) return '${(this / 1000).toStringAsFixed(1)}K';
    return toString();
  }

  /// Returns true if the number is effectively zero.
  bool get isZero => this == 0;

  /// Clamp between 0 and 1 for opacity usage.
  double get clampedOpacity => clamp(0.0, 1.0).toDouble();
}

/// Double extensions for MoneyLens.
extension DoubleExtensions on double {
  /// Round to specified decimal places.
  double roundTo(int places) {
    final factor = 10.0 * places;
    return (this * factor).round() / factor;
  }

  /// Convert to percentage string with one decimal: 0.125 → '12.5%'
  String get asPercentage => '${(this * 100).toStringAsFixed(1)}%';
}
