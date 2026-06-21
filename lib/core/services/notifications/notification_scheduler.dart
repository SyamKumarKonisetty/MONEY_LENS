import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'notification_logger.dart';
import 'timezone_service.dart';
import 'notification_channels.dart';

class NotificationScheduler {
  // Static IDs to prevent duplicates
  static const int idDailyReminder = 100;
  static const int idBudgetWarning = 101;
  static const int idWeeklySummary = 102;
  static const int idMonthlyReport = 103;
  static const int idGoalAchievement = 104;
  static const int idInactiveReminder = 105;

  /// Helper to calculate the next instance of a specific TimeOfDay safely.
  static tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = TimezoneService.now();
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Helper to calculate the next instance of a specific weekday safely.
  static tz.TZDateTime _nextInstanceOfWeekday(int weekday, TimeOfDay time) {
    var scheduledDate = _nextInstanceOfTime(time);
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Safe scheduling executor wrapper.
  static Future<void> _safeSchedule(FlutterLocalNotificationsPlugin plugin, Future<void> Function() scheduleTask) async {
    if (!TimezoneService.isInitialized) {
      NotificationLogger.log('Skipped scheduling: TimezoneService not initialized properly.');
      return;
    }
    try {
      await scheduleTask();
    } catch (e, stack) {
      NotificationLogger.error('Failed during notification scheduling execution.', e, stack);
    }
  }

  static Future<void> scheduleDailyReminder(FlutterLocalNotificationsPlugin plugin, TimeOfDay time) async {
    await _safeSchedule(plugin, () async {
      final scheduledDate = _nextInstanceOfTime(time);
      await plugin.zonedSchedule(
        idDailyReminder,
        'Daily Check-in',
        'Did you spend anything today?\nKeep your financial journal up to date.',
        scheduledDate,
        NotificationChannels.getDefaultDetails(),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      NotificationLogger.log('Scheduled Daily Reminder for $timeStr');
    });
  }

  static Future<void> scheduleWeeklySummary(FlutterLocalNotificationsPlugin plugin, int weekday, TimeOfDay time) async {
    await _safeSchedule(plugin, () async {
      final scheduledDate = _nextInstanceOfWeekday(weekday, time);
      await plugin.zonedSchedule(
        idWeeklySummary,
        'Weekly Summary',
        'Your financial summary for the week is ready.',
        scheduledDate,
        NotificationChannels.getDefaultDetails(),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    });
  }

  static Future<void> scheduleMonthlyReport(FlutterLocalNotificationsPlugin plugin, int dayOfMonth, TimeOfDay time) async {
    await _safeSchedule(plugin, () async {
      final now = TimezoneService.now();
      int targetMonth = now.month;
      int targetYear = now.year;

      if (now.day > dayOfMonth || (now.day == dayOfMonth && (now.hour > time.hour || (now.hour == time.hour && now.minute >= time.minute)))) {
        targetMonth++;
        if (targetMonth > 12) {
          targetMonth = 1;
          targetYear++;
        }
      }

      int safeDay = dayOfMonth;
      final daysInMonth = DateTime(targetYear, targetMonth + 1, 0).day;
      if (safeDay > daysInMonth) safeDay = daysInMonth;

      final nextDate = tz.TZDateTime(tz.local, targetYear, targetMonth, safeDay, time.hour, time.minute);

      await plugin.zonedSchedule(
        idMonthlyReport,
        'Monthly Report',
        'Your monthly financial report is ready to view.',
        nextDate,
        NotificationChannels.getDefaultDetails(),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      );
    });
  }

  static Future<void> scheduleInactiveReminder(FlutterLocalNotificationsPlugin plugin, int daysFromNow) async {
    await _safeSchedule(plugin, () async {
      final scheduledDate = TimezoneService.now().add(Duration(days: daysFromNow));
      await plugin.zonedSchedule(
        idInactiveReminder,
        'We miss you!',
        "Track today's spending to keep your insights accurate.",
        scheduledDate,
        NotificationChannels.getDefaultDetails(),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    });
  }

  static Future<void> showBudgetWarning(FlutterLocalNotificationsPlugin plugin, String categoryName) async {
    try {
      await plugin.show(
        idBudgetWarning,
        'Budget Warning',
        "You're close to reaching your $categoryName budget.",
        NotificationChannels.getDefaultDetails(),
      );
    } catch (e, stack) {
      NotificationLogger.error('Failed to show budget warning.', e, stack);
    }
  }

  static Future<void> showGoalAchievement(FlutterLocalNotificationsPlugin plugin) async {
    try {
      await plugin.show(
        idGoalAchievement,
        'Goal Achieved!',
        'Congratulations! You stayed within your monthly budget.',
        NotificationChannels.getDefaultDetails(),
      );
    } catch (e, stack) {
      NotificationLogger.error('Failed to show goal achievement.', e, stack);
    }
  }

  static Future<void> cancel(FlutterLocalNotificationsPlugin plugin, int id) async {
    try {
      await plugin.cancel(id);
      NotificationLogger.log('Cancelled notification id $id');
    } catch (e, stack) {
      NotificationLogger.error('Failed to cancel notification id $id.', e, stack);
    }
  }

  static Future<void> cancelAll(FlutterLocalNotificationsPlugin plugin) async {
    try {
      await plugin.cancelAll();
      NotificationLogger.log('Cancelled all notifications');
    } catch (e, stack) {
      NotificationLogger.error('Failed to cancel all notifications.', e, stack);
    }
  }
}
