import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'notification_logger.dart';

class TimezoneService {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  /// Initializes timezone data and sets the local location safely.
  /// Never throws an exception. Falls back to UTC if detection fails.
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();
      String timeZoneName = 'UTC'; // Fallback

      try {
        final dynamic result = await FlutterTimezone.getLocalTimezone();
        
        // Defensive type checking to handle different flutter_timezone versions
        if (result is String) {
          timeZoneName = result;
        } else if (result != null) {
          // Attempt to extract .name property if it's an object (TimezoneInfo)
          try {
            timeZoneName = (result as dynamic).name.toString();
          } catch (_) {
            timeZoneName = result.toString();
          }
        }
      } catch (e, stack) {
        NotificationLogger.error('Failed to detect local timezone. Falling back to UTC.', e, stack);
      }

      // Ensure the timezone name is valid within the tz database
      try {
        final location = tz.getLocation(timeZoneName);
        tz.setLocalLocation(location);
        _isInitialized = true;
        NotificationLogger.log('Timezone initialized successfully: $timeZoneName');
      } catch (e, stack) {
        NotificationLogger.error('Invalid timezone returned ($timeZoneName), falling back to UTC.', e, stack);
        tz.setLocalLocation(tz.getLocation('UTC'));
        _isInitialized = true;
      }
    } catch (e, stack) {
      NotificationLogger.error('Critical failure in timezone initialization.', e, stack);
      // Even if everything fails, we mark initialized as true so we don't infinitely retry and crash
      _isInitialized = true;
    }
  }

  /// Helper to get the current localized time
  static tz.TZDateTime now() {
    if (!_isInitialized) {
      return tz.TZDateTime.now(tz.UTC);
    }
    return tz.TZDateTime.now(tz.local);
  }
}
