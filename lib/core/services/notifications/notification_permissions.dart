import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_logger.dart';

class NotificationPermissions {
  /// Safely requests permissions across different Android/iOS versions.
  static Future<void> requestPermissions(FlutterLocalNotificationsPlugin plugin) async {
    try {
      if (Platform.isAndroid) {
        final androidPlugin = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        if (androidPlugin != null) {
          // Request POST_NOTIFICATIONS (Android 13+)
          try {
            await androidPlugin.requestNotificationsPermission();
            NotificationLogger.log('Requested Android notification permissions.');
          } catch (e, stack) {
            NotificationLogger.error('Failed to request notifications permission.', e, stack);
          }

          // Request SCHEDULE_EXACT_ALARM (Android 12+)
          try {
            await androidPlugin.requestExactAlarmsPermission();
            NotificationLogger.log('Requested exact alarms permission.');
          } catch (e, stack) {
            NotificationLogger.error('Failed to request exact alarms permission.', e, stack);
          }
        }
      } else if (Platform.isIOS) {
        final iosPlugin = plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        if (iosPlugin != null) {
          try {
            await iosPlugin.requestPermissions(alert: true, badge: true, sound: true);
            NotificationLogger.log('Requested iOS notification permissions.');
          } catch (e, stack) {
            NotificationLogger.error('Failed to request iOS permissions.', e, stack);
          }
        }
      }
    } catch (e, stack) {
      NotificationLogger.error('Critical failure in requestPermissions.', e, stack);
    }
  }
}
