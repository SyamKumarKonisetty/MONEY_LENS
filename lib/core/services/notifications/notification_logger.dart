import 'package:flutter/foundation.dart';

/// Centralized logger for notification subsystem.
/// Logs are only printed in debug mode to prevent leakage in production.
class NotificationLogger {
  static void log(String message) {
    if (kDebugMode) {
      debugPrint('[NotificationEngine] $message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[NotificationEngine][ERROR] $message');
      if (error != null) {
        debugPrint(error.toString());
      }
      if (stackTrace != null) {
        debugPrint(stackTrace.toString());
      }
    }
  }
}
