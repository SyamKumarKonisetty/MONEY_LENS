import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_initializer.dart';
import 'notification_scheduler.dart';
import 'notification_permissions.dart';

/// Centralized Singleton facade for the MoneyLens Notification Engine V2.
/// Guarantees a zero-crash architecture.
class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static const int idDailyReminder = NotificationScheduler.idDailyReminder;
  static const int idBudgetWarning = NotificationScheduler.idBudgetWarning;
  static const int idWeeklySummary = NotificationScheduler.idWeeklySummary;
  static const int idMonthlyReport = NotificationScheduler.idMonthlyReport;
  static const int idGoalAchievement = NotificationScheduler.idGoalAchievement;
  static const int idInactiveReminder = NotificationScheduler.idInactiveReminder;

  /// Fire-and-forget initialization. Never throws.
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = await NotificationInitializer.init(_plugin);
  }

  /// Request permissions dynamically.
  Future<void> requestPermissions() async {
    await NotificationPermissions.requestPermissions(_plugin);
  }

  // --- SCHEDULING DELEGATES ---

  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    await NotificationScheduler.scheduleDailyReminder(_plugin, time);
  }

  Future<void> scheduleWeeklySummary(int weekday, TimeOfDay time) async {
    await NotificationScheduler.scheduleWeeklySummary(_plugin, weekday, time);
  }

  Future<void> scheduleMonthlyReport(int dayOfMonth, TimeOfDay time) async {
    await NotificationScheduler.scheduleMonthlyReport(_plugin, dayOfMonth, time);
  }

  Future<void> scheduleInactiveReminder(int daysFromNow) async {
    await NotificationScheduler.scheduleInactiveReminder(_plugin, daysFromNow);
  }

  Future<void> showBudgetWarning(String categoryName) async {
    await NotificationScheduler.showBudgetWarning(_plugin, categoryName);
  }

  Future<void> showGoalAchievement() async {
    await NotificationScheduler.showGoalAchievement(_plugin);
  }

  Future<void> cancelNotification(int id) async {
    await NotificationScheduler.cancel(_plugin, id);
  }

  Future<void> cancelAll() async {
    await NotificationScheduler.cancelAll(_plugin);
  }
}
