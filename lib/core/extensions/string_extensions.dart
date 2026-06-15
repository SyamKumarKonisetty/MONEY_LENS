/// String extensions for MoneyLens.
extension StringExtensions on String {
  /// Capitalize the first character.
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize each word.
  String get titleCase {
    return split(' ').map((word) => word.capitalized).join(' ');
  }

  /// Returns true if the string is null or empty after trimming.
  bool get isBlankOrEmpty => trim().isEmpty;

  /// Truncate string with ellipsis: 'Hello world' → 'Hello...'
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - 3)}...';
  }

  /// Extract initials from a name: 'Syam Kumar' → 'SK'
  String get initials {
    final parts = trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}

/// Nullable string extensions.
extension NullableStringExtensions on String? {
  /// Returns true if null or blank.
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;

  /// Returns the value or empty string.
  String get orEmpty => this ?? '';
}
