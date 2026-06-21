import 'package:flutter/material.dart';
import '../foundations/typography.dart';

/// MoneyLens Design System (MLDS) Financial Typography Component.
///
/// Implements the formatting and layout rules for monetary amounts:
/// 1. Currency Symbol: Rendered slightly smaller than the main value.
/// 2. Main Amount: Largest text size, high priority.
/// 3. Decimals: Slightly reduced emphasis (smaller text).
/// 4. Tabular Figures: Enabled by default to prevent digit jumping during updates.
///
/// Example:
/// ```dart
/// MLMoneyDisplay.hero(
///   amount: 48520.50,
///   currency: '₹',
/// )
/// ```
abstract class MLMoneyDisplay extends StatelessWidget {
  const MLMoneyDisplay({super.key});

  /// Hero balance / summary display (e.g., Dashboard Balance).
  const factory MLMoneyDisplay.hero({
    required double amount,
    required String currency,
    Key? key,
    Color? color,
    bool showSign,
  }) = _MLHeroMoneyDisplayImpl;

  /// Standard inline list display (e.g., Transaction Row).
  const factory MLMoneyDisplay.standard({
    required double amount,
    required String currency,
    Key? key,
    Color? color,
    bool isIncome,
    bool showSign,
  }) = _MLStandardMoneyDisplayImpl;
}

class _MLMoneyParts {
  _MLMoneyParts({
    required this.sign,
    required this.symbol,
    required this.integerPart,
    required this.decimalPart,
  });

  final String sign;
  final String symbol;
  final String integerPart;
  final String decimalPart;

  factory _MLMoneyParts.fromDouble(
    double amount,
    String currency,
    bool showSign,
  ) {
    final absAmount = amount.abs();
    final signStr = amount < 0 ? '-' : (showSign ? '+' : '');

    // Format to 2 decimal places with thousands separators.
    // Basic custom formatting to support decimal parsing.
    final fixedStr = absAmount.toStringAsFixed(2);
    final dotIndex = fixedStr.indexOf('.');
    final dec = fixedStr.substring(dotIndex); // Includes the '.' e.g. '.50'

    final intVal = fixedStr.substring(0, dotIndex);
    // Add commas for thousands separators (simple regex or loop)
    final buffer = StringBuffer();
    final intLen = intVal.length;
    for (int i = 0; i < intLen; i++) {
      buffer.write(intVal[i]);
      final remaining = intLen - 1 - i;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(',');
      }
    }

    return _MLMoneyParts(
      sign: signStr,
      symbol: currency,
      integerPart: buffer.toString(),
      decimalPart: dec,
    );
  }
}

class _MLHeroMoneyDisplayImpl extends MLMoneyDisplay {
  const _MLHeroMoneyDisplayImpl({
    required this.amount,
    required this.currency,
    super.key,
    this.color,
    this.showSign = false,
  });

  final double amount;
  final String currency;
  final Color? color;
  final bool showSign;

  @override
  Widget build(BuildContext context) {
    final parts = _MLMoneyParts.fromDouble(amount, currency, showSign);
    final baseColor = color ?? Theme.of(context).textTheme.bodyLarge?.color;

    return RichText(
      text: TextSpan(
        style: MLTypography.heroAmount.copyWith(color: baseColor),
        children: [
          if (parts.sign.isNotEmpty)
            TextSpan(
              text: '${parts.sign} ',
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          // Currency symbol: smaller and lighter
          TextSpan(
            text: parts.symbol,
            style: TextStyle(
              fontSize: MLTypography.heroAmount.fontSize! * 0.65,
              fontWeight: FontWeight.w500,
            ),
          ),
          const TextSpan(text: ' '),
          // Main amount: largest and boldest
          TextSpan(
            text: parts.integerPart,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          // Decimals: reduced size and opacity
          TextSpan(
            text: parts.decimalPart,
            style: TextStyle(
              fontSize: MLTypography.heroAmount.fontSize! * 0.60,
              fontWeight: FontWeight.w500,
              color: baseColor?.withAlpha(179),
            ),
          ),
        ],
      ),
    );
  }
}

class _MLStandardMoneyDisplayImpl extends MLMoneyDisplay {
  const _MLStandardMoneyDisplayImpl({
    required this.amount,
    required this.currency,
    super.key,
    this.color,
    this.isIncome,
    this.showSign = true,
  });

  final double amount;
  final String currency;
  final Color? color;
  final bool? isIncome;
  final bool showSign;

  @override
  Widget build(BuildContext context) {
    final resolvedIncome = isIncome ?? (amount >= 0);
    final parts = _MLMoneyParts.fromDouble(amount, currency, showSign);

    // Resolve color contextually from theme if not specified
    Color defaultColor;
    if (color != null) {
      defaultColor = color!;
    } else {
      defaultColor = resolvedIncome
          ? const Color(0xFF34C759) // Green (Income) fallback
          : const Color(0xFFFF3B30); // Red (Expense) fallback
    }

    return RichText(
      text: TextSpan(
        style: MLTypography.moneyMedium.copyWith(color: defaultColor),
        children: [
          if (parts.sign.isNotEmpty)
            TextSpan(
              text: '${parts.sign} ',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          // Currency: slightly smaller
          TextSpan(
            text: parts.symbol,
            style: TextStyle(
              fontSize: MLTypography.moneyMedium.fontSize! * 0.8,
              fontWeight: FontWeight.w500,
            ),
          ),
          const TextSpan(text: ' '),
          // Main amount
          TextSpan(
            text: parts.integerPart,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          // Decimals: reduced size and opacity
          TextSpan(
            text: parts.decimalPart,
            style: TextStyle(
              fontSize: MLTypography.moneyMedium.fontSize! * 0.75,
              fontWeight: FontWeight.w400,
              color: defaultColor.withAlpha(204),
            ),
          ),
        ],
      ),
    );
  }
}
