import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_logger.dart';

class NotificationChannels {
  static const String idReminders = 'moneylens_reminders';
  static const String nameReminders = 'MoneyLens Reminders';
  static const String descReminders = 'Daily, weekly, and monthly financial reminders.';

  /// Creates necessary notification channels safely.
  static Future<void> createChannels(FlutterLocalNotificationsPlugin plugin) async {
    try {
      if (!Platform.isAndroid) return;

      final androidPlugin = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin == null) return;

      final channel = AndroidNotificationChannel(
        idReminders,
        nameReminders,
        description: descReminders,
        importance: Importance.high,
        enableVibration: true,
      );

      await androidPlugin.createNotificationChannel(channel);
      NotificationLogger.log('Android notification channels created safely.');
    } catch (e, stack) {
      NotificationLogger.error('Failed to create Android notification channels.', e, stack);
    }
  }

  /// Provides common details for Android/iOS payloads.
  static NotificationDetails getDefaultDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        idReminders,
        nameReminders,
        channelDescription: descReminders,
        importance: Importance.high,
        priority: Priority.high,
        color: Color(0xFF1677FF),
        icon: '@mipmap/launcher_icon',
      ),
      iOS: DarwinNotificationDetails(),
    );
  }
}
