import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Currency formatting utilities for MoneyLens.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _inrFull = NumberFormat.currency(
    locale: AppConstants.currencyLocale,
    symbol: AppConstants.currencySymbol,
    decimalDigits: 2,
  );

  static final NumberFormat _inrNoDecimals = NumberFormat.currency(
    locale: AppConstants.currencyLocale,
    symbol: AppConstants.currencySymbol,
    decimalDigits: 0,
  );

  /// Format as compact INR: ₹1.2K, ₹4.5L, ₹1.2Cr
  static String compact(double amount) {
    final absAmount = amount.abs();
    final sign = amount < 0 ? '−' : ''; // Use correct minus sign character

    String formatted;
    if (absAmount < 1000) {
      formatted = _inrNoDecimals.format(absAmount);
    } else if (absAmount < 100000) {
      // Thousands: 1K to 99.9K
      final thousands = absAmount / 1000;
      final valueStr = thousands.toStringAsFixed(thousands >= 10 ? 1 : 2);
      final cleanedStr = _cleanTrailingZeros(valueStr);
      formatted = '${AppConstants.currencySymbol}${cleanedStr}K';
    } else if (absAmount < 10000000) {
      // Lakhs: 1L to 99.9L
      final lakhs = absAmount / 100000;
      final valueStr = lakhs.toStringAsFixed(lakhs >= 10 ? 1 : 2);
      final cleanedStr = _cleanTrailingZeros(valueStr);
      formatted = '${AppConstants.currencySymbol}${cleanedStr}L';
    } else {
      // Crores: >= 1Cr
      final crores = absAmount / 10000000;
      final valueStr = crores.toStringAsFixed(crores >= 10 ? 1 : 2);
      final cleanedStr = _cleanTrailingZeros(valueStr);
      formatted = '${AppConstants.currencySymbol}${cleanedStr}Cr';
    }

    return '$sign$formatted';
  }

  static String _cleanTrailingZeros(String str) {
    if (!str.contains('.')) return str;
    var cleaned = str;
    while (cleaned.endsWith('0')) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }
    if (cleaned.endsWith('.')) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }
    return cleaned;
  }

  /// Format as full INR with 2 decimal places: ₹1,234.56
  static String full(double amount) => _inrFull.format(amount);

  /// Format as INR without decimals: ₹1,234
  static String noDecimals(double amount) => _inrNoDecimals.format(amount);

  /// Format with sign prefix: +₹500 or −₹500
  static String signed(double amount, {bool isExpense = true}) {
    final formatted = full(amount.abs());
    return isExpense ? '−$formatted' : '+$formatted';
  }

  /// Format change delta with sign and percentage: +12.5%
  static String percentage(double value) {
    final sign = value >= 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(1)}%';
  }
}
