import 'package:flutter/foundation.dart';

/// Database health analyzer executing recovery operations if corruption is detected.
class MLBackupRecovery {
  MLBackupRecovery._();

  static bool _lastCheckSuccess = true;

  /// Returns true if the database initialized cleanly in the active session.
  static bool get lastCheckSuccess => _lastCheckSuccess;

  /// Verifies database integrity. Restores snapshot files if corruption is caught.
  static Future<void> verifyOrRestoreDatabase({
    required Future<void> Function() dbInitCallback,
    required Future<void> Function() dbRestoreCallback,
  }) async {
    try {
      await dbInitCallback();
      _lastCheckSuccess = true;
    } catch (e) {
      _lastCheckSuccess = false;
      if (kDebugMode) {
        debugPrint(
          '[BACKUP_RECOVERY] Database check failed: $e. Restoring latest safe backup.',
        );
      }
      try {
        await dbRestoreCallback();
        if (kDebugMode) {
          debugPrint(
            '[BACKUP_RECOVERY] Database restoration completed successfully.',
          );
        }
      } catch (restoreError) {
        if (kDebugMode) {
          debugPrint(
            '[BACKUP_RECOVERY] Severe database error during recovery: $restoreError.',
          );
        }
        rethrow;
      }
    }
  }
}
