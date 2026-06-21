/// Validator and sanitizer engine for text, numeric figures, and CSV datasets.
class MLInputValidator {
  MLInputValidator._();

  static final RegExp _maliciousSqlRegex = RegExp(
    r"('|--|union|select|insert|delete|drop|update|alter|create|truncate)\b",
    caseSensitive: false,
  );
  static final RegExp _scriptRegex = RegExp(
    r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>',
    caseSensitive: false,
  );

  /// Validates that text does not contain SQL injection keywords or script tags.
  static bool isValidInput(String input) {
    if (_maliciousSqlRegex.hasMatch(input)) return false;
    if (_scriptRegex.hasMatch(input)) return false;
    return true;
  }

  /// Sanitizes input, removing script blocks and escaping single quotes.
  static String sanitize(String input) {
    var result = input;
    result = result.replaceAll(_scriptRegex, '');
    result = result.replaceAll("'", "''");
    return result.trim();
  }

  /// Extracts numeric figures safely, stripping illegal characters.
  static double? parseAmount(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^\d\.-]'), '');
    return double.tryParse(cleaned);
  }
}
