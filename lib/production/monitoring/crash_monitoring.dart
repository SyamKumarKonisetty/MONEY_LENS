import 'package:flutter/foundation.dart';

/// Data structure mapping an intercepted runtime exception.
class MLCrashReport {
  const MLCrashReport({
    required this.error,
    required this.stackTrace,
    required this.timestamp,
  });

  final String error;
  final String stackTrace;
  final DateTime timestamp;
}

/// Offline monitoring engine capturing app crashes and saving diagnostics locally.
class MLCrashMonitoring {
  MLCrashMonitoring._();

  static final List<MLCrashReport> _reports = [];

  /// Returns a read-only list of captured diagnostic crashes.
  static List<MLCrashReport> get reports => List.unmodifiable(_reports);

  /// Registers an error event into the diagnostic vault.
  static void reportError(Object error, StackTrace? stack) {
    final report = MLCrashReport(
      error: error.toString(),
      stackTrace: stack?.toString() ?? '',
      timestamp: DateTime.now(),
    );
    _reports.add(report);

    if (kDebugMode) {
      debugPrint('[CRASH_MONITOR] Exception caught: $error');
    }
  }

  /// Clears diagnostic entries.
  static void clearReports() {
    _reports.clear();
  }
}
