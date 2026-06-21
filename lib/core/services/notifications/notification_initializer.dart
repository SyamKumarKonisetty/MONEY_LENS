import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_logger.dart';
import 'timezone_service.dart';
import 'notification_channels.dart';

class NotificationInitializer {
  /// Safely initializes the plugin and timezone dependencies.
  static Future<bool> init(FlutterLocalNotificationsPlugin plugin) async {
    try {
      // 1. Initialize Timezones safely (never throws)
      await TimezoneService.init();

      // 2. Initialize the local notifications plugin
      const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

      final result = await plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // 3. Create channels
      await NotificationChannels.createChannels(plugin);

      NotificationLogger.log('Notification engine initialized successfully.');
      return result ?? false;
    } catch (e, stack) {
      NotificationLogger.error('Critical failure in notification initialization.', e, stack);
      // Return true or false? If it fails, we just say it failed (false)
      // but we do NOT throw, so the app startup doesn't crash.
      return false;
    }
  }

  static void _onNotificationTap(NotificationResponse response) {
    NotificationLogger.log('Notification tapped: ${response.id}');
    // Routing logic can be added here
  }
}
