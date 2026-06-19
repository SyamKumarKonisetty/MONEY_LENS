import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/notification_item.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../../transactions/domain/models.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../../reports/presentation/providers/reports_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

String _normalizeDate(String input) {
  final parts = input.split('-');
  if (parts.length != 3) return input;

  return '${parts[0]}-${parts[1].padLeft(2, '0')}-${parts[2].padLeft(2, '0')}';
}

// ─── Notification Settings ──────────────────────────────────────────────────

class NotificationSettings {
  final bool enabled;
  final TimeOfDay dailyTime;
  final String weeklyDayAndTime; // e.g. "Sunday 10:00"
  final String monthlyDayAndTime; // e.g. "Last Day 10:00"
  final String reminderFrequency; // "Daily", "Weekly", "Monthly", "Never"
  final TimeOfDay reminderTime;

  NotificationSettings({
    this.enabled = true,
    this.dailyTime = const TimeOfDay(hour: 20, minute: 0),
    this.weeklyDayAndTime = 'Sunday 10:00',
    this.monthlyDayAndTime = 'Last Day 10:00',
    this.reminderFrequency = 'Daily',
    this.reminderTime = const TimeOfDay(hour: 20, minute: 0),
  });

  NotificationSettings copyWith({
    bool? enabled,
    TimeOfDay? dailyTime,
    String? weeklyDayAndTime,
    String? monthlyDayAndTime,
    String? reminderFrequency,
    TimeOfDay? reminderTime,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      dailyTime: dailyTime ?? this.dailyTime,
      weeklyDayAndTime: weeklyDayAndTime ?? this.weeklyDayAndTime,
      monthlyDayAndTime: monthlyDayAndTime ?? this.monthlyDayAndTime,
      reminderFrequency: reminderFrequency ?? this.reminderFrequency,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  final SharedPreferences _prefs;

  NotificationSettingsNotifier(this._prefs) : super(NotificationSettings()) {
    _loadSettings();
  }

  static const String _keyEnabled = 'notif_enabled';
  static const String _keyDailyHour = 'notif_daily_hour';
  static const String _keyDailyMinute = 'notif_daily_minute';
  static const String _keyWeekly = 'notif_weekly';
  static const String _keyMonthly = 'notif_monthly';
  static const String _keyReminderFrequency = 'notif_reminder_freq';
  static const String _keyReminderHour = 'notif_reminder_hour';
  static const String _keyReminderMinute = 'notif_reminder_minute';

  void _loadSettings() {
    final enabled = _prefs.getBool(_keyEnabled) ?? true;
    final hour = _prefs.getInt(_keyDailyHour) ?? 20;
    final minute = _prefs.getInt(_keyDailyMinute) ?? 0;
    final weekly = _prefs.getString(_keyWeekly) ?? 'Sunday 10:00';
    final monthly = _prefs.getString(_keyMonthly) ?? 'Last Day 10:00';
    final freq = _prefs.getString(_keyReminderFrequency) ?? 'Daily';
    final remHour = _prefs.getInt(_keyReminderHour) ?? 20;
    final remMin = _prefs.getInt(_keyReminderMinute) ?? 0;

    state = NotificationSettings(
      enabled: enabled,
      dailyTime: TimeOfDay(hour: hour, minute: minute),
      weeklyDayAndTime: weekly,
      monthlyDayAndTime: monthly,
      reminderFrequency: freq,
      reminderTime: TimeOfDay(hour: remHour, minute: remMin),
    );
  }

  Future<void> setEnabled(bool val) async {
    await _prefs.setBool(_keyEnabled, val);
    state = state.copyWith(enabled: val);
  }

  Future<void> setDailyTime(TimeOfDay time) async {
    await _prefs.setInt(_keyDailyHour, time.hour);
    await _prefs.setInt(_keyDailyMinute, time.minute);
    state = state.copyWith(dailyTime: time);
  }

  Future<void> setWeeklyTime(String val) async {
    await _prefs.setString(_keyWeekly, val);
    state = state.copyWith(weeklyDayAndTime: val);
  }

  Future<void> setMonthlyTime(String val) async {
    await _prefs.setString(_keyMonthly, val);
    state = state.copyWith(monthlyDayAndTime: val);
  }

  Future<void> setReminderFrequency(String val) async {
    await _prefs.setString(_keyReminderFrequency, val);
    state = state.copyWith(reminderFrequency: val);
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    await _prefs.setInt(_keyReminderHour, time.hour);
    await _prefs.setInt(_keyReminderMinute, time.minute);
    state = state.copyWith(reminderTime: time);
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((
      ref,
    ) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return NotificationSettingsNotifier(prefs);
    });

// ─── Notification History List ──────────────────────────────────────────────

class NotificationsListNotifier extends StateNotifier<List<NotificationItem>> {
  final SharedPreferences _prefs;
  final Ref _ref;

  NotificationsListNotifier(this._prefs, this._ref) : super([]) {
    _loadNotifications();
  }

  static const String _keyNotificationsList = 'notif_list';

  void _loadNotifications() {
    final jsonStr = _prefs.getString(_keyNotificationsList);
    if (jsonStr != null) {
      try {
        final list = jsonDecode(jsonStr) as List;
        state =
            list
                .map(
                  (item) =>
                      NotificationItem.fromJson(item as Map<String, dynamic>),
                )
                .toList()
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      } catch (_) {
        state = [];
      }
    } else {
      state = [];
    }
  }

  Future<void> _saveNotifications() async {
    final list = state.map((item) => item.toJson()).toList();
    await _prefs.setString(_keyNotificationsList, jsonEncode(list));
  }

  Future<void> addNotification({
    required String title,
    required String body,
    required String type,
    Map<String, String>? metadata,
  }) async {
    final settings = _ref.read(notificationSettingsProvider);
    if (!settings.enabled) return;

    final newItem = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
      isRead: false,
      type: type,
      metadata: metadata,
    );

    state = [newItem, ...state];
    await _saveNotifications();

    // Trigger In-App Push Banner
    _ref.read(inAppBannerProvider.notifier).showBanner(newItem);
  }

  Future<void> markAsRead(String id) async {
    state = state
        .map((item) => item.id == id ? item.copyWith(isRead: true) : item)
        .toList();
    await _saveNotifications();
  }

  Future<void> markAllAsRead() async {
    state = state.map((item) => item.copyWith(isRead: true)).toList();
    await _saveNotifications();
  }

  Future<void> deleteNotification(String id) async {
    state = state.where((item) => item.id != id).toList();
    await _saveNotifications();
  }

  Future<void> clearAll() async {
    state = [];
    await _saveNotifications();
  }
}

final notificationsListProvider =
    StateNotifierProvider<NotificationsListNotifier, List<NotificationItem>>((
      ref,
    ) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return NotificationsListNotifier(prefs, ref);
    });

// ─── In-App Push Notification Banner Overlay ────────────────────────────────

class InAppBannerNotifier extends StateNotifier<NotificationItem?> {
  InAppBannerNotifier() : super(null);

  void showBanner(NotificationItem item) {
    state = item;
  }

  void dismissBanner() {
    state = null;
  }
}

final inAppBannerProvider =
    StateNotifierProvider<InAppBannerNotifier, NotificationItem?>((ref) {
      return InAppBannerNotifier();
    });

// ─── Streak & Achievements Engine ───────────────────────────────────────────

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({bool? isUnlocked, DateTime? unlockedAt}) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

class StreakState {
  final int transactionStreak;
  final int loginStreak;
  final List<Achievement> achievements;

  StreakState({
    required this.transactionStreak,
    required this.loginStreak,
    required this.achievements,
  });

  StreakState copyWith({
    int? transactionStreak,
    int? loginStreak,
    List<Achievement>? achievements,
  }) {
    return StreakState(
      transactionStreak: transactionStreak ?? this.transactionStreak,
      loginStreak: loginStreak ?? this.loginStreak,
      achievements: achievements ?? this.achievements,
    );
  }
}

class StreakNotifier extends StateNotifier<StreakState> {
  final SharedPreferences _prefs;
  final Ref _ref;

  StreakNotifier(this._prefs, this._ref)
    : super(
        StreakState(
          transactionStreak: 0,
          loginStreak: 0,
          achievements: _defaultAchievements(),
        ),
      ) {
    _initStreaks();
  }

  static const String _keyLastLoginDate = 'streak_last_login_date';
  static const String _keyLoginStreak = 'streak_login_streak';
  static const String _keyUnlockedAchievements = 'streak_unlocked_achievements';

  static List<Achievement> _defaultAchievements() {
    return [
      Achievement(
        id: 'first_expense',
        title: 'First Step',
        description: 'First Expense Logged',
        icon: '🎯',
      ),
      Achievement(
        id: 'tx_100',
        title: 'Centurion',
        description: 'Log 100 Transactions',
        icon: '💯',
      ),
      Achievement(
        id: 'streak_30',
        title: 'Consistent Sage',
        description: 'Achieve a 30-Day App Streak',
        icon: '🔥',
      ),
      Achievement(
        id: 'budget_master',
        title: 'Budget Master',
        description: 'Set 3 category limits and stay under them',
        icon: '👑',
      ),
      Achievement(
        id: 'savings_champion',
        title: 'Savings Champion',
        description: 'Save over 30% of monthly income',
        icon: '💰',
      ),
    ];
  }

  void _initStreaks() {
    _loadLoginStreak();
    _checkStreaksAndAchievements();
  }

  void _loadLoginStreak() {
    final lastLoginStr = _prefs.getString(_keyLastLoginDate);
    var streak = _prefs.getInt(_keyLoginStreak) ?? 0;
    final today = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(today);

    if (lastLoginStr != null) {
      DateTime lastLogin;
      try {
        lastLogin = DateTime.parse(_normalizeDate(lastLoginStr));
      } catch (e) {
        lastLogin = DateTime.now();
      }
      final lastLoginDay = DateTime(
        lastLogin.year,
        lastLogin.month,
        lastLogin.day,
      );
      final currentDay = DateTime(today.year, today.month, today.day);
      final diff = currentDay.difference(lastLoginDay).inDays;

      if (diff == 1) {
        streak += 1;
      } else if (diff > 1) {
        streak = 1;
      }
    } else {
      streak = 1;
    }

    _prefs.setString(_keyLastLoginDate, todayStr);
    _prefs.setInt(_keyLoginStreak, streak);

    state = state.copyWith(loginStreak: streak);
  }

  void _checkStreaksAndAchievements() {
    final transactions = _ref.watch(allTransactionsProvider);
    final budgets = _ref.watch(liveBudgetsProvider);
    final summary = _ref.watch(reportsSummaryProvider);

    // 1. Transaction Streak Calculation
    final txStreak = _calculateTransactionStreak(transactions);

    // 2. Load Unlocked Achievements
    final unlockedIds = _prefs.getStringList(_keyUnlockedAchievements) ?? [];
    final currentAchievements = state.achievements.map((ach) {
      if (unlockedIds.contains(ach.id)) {
        return ach.copyWith(isUnlocked: true, unlockedAt: DateTime.now());
      }
      return ach;
    }).toList();

    var updatedAchievements = List<Achievement>.from(currentAchievements);
    final List<String> newlyUnlockedIds = [];

    // Check unlocks
    for (var i = 0; i < updatedAchievements.length; i++) {
      final ach = updatedAchievements[i];
      if (ach.isUnlocked) continue;

      var unlock = false;
      switch (ach.id) {
        case 'first_expense':
          unlock = transactions
              .where((t) => t.type == TransactionType.expense)
              .isNotEmpty;
          break;
        case 'tx_100':
          unlock = transactions.length >= 100;
          break;
        case 'streak_30':
          unlock = txStreak >= 30 || state.loginStreak >= 30;
          break;
        case 'budget_master':
          unlock =
              budgets.length >= 3 &&
              budgets.every((b) => b.spentAmount <= b.monthlyLimit);
          break;
        case 'savings_champion':
          unlock = summary.savingsRate >= 30.0;
          break;
      }

      if (unlock) {
        updatedAchievements[i] = ach.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
        newlyUnlockedIds.add(ach.id);

        // Notify user about Achievement Unlock!
        Future.delayed(const Duration(milliseconds: 500), () {
          _ref
              .read(notificationsListProvider.notifier)
              .addNotification(
                title: '🏆 Achievement Unlocked!',
                body:
                    'Congratulations! You unlocked the "${ach.title}" badge: ${ach.description}.',
                type: 'achievement',
                metadata: {'badgeId': ach.id},
              );
        });
      }
    }

    if (newlyUnlockedIds.isNotEmpty) {
      unlockedIds.addAll(newlyUnlockedIds);
      _prefs.setStringList(_keyUnlockedAchievements, unlockedIds);
    }

    state = StreakState(
      transactionStreak: txStreak,
      loginStreak: state.loginStreak,
      achievements: updatedAchievements,
    );
  }

  int _calculateTransactionStreak(List<Transaction> transactions) {
    if (transactions.isEmpty) return 0;

    final dates =
        transactions
            .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    if (dates.isEmpty) return 0;

    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final yesterday = today.subtract(const Duration(days: 1));

    if (dates.first != today && dates.first != yesterday) {
      return 0;
    }

    var streak = 1;
    var current = dates.first;

    for (var i = 1; i < dates.length; i++) {
      final expected = current.subtract(const Duration(days: 1));
      if (dates[i] == expected) {
        streak++;
        current = dates[i];
      } else if (dates[i].isBefore(expected)) {
        break; // streak broken
      }
    }

    return streak;
  }
}

final streakNotifierProvider =
    StateNotifierProvider<StreakNotifier, StreakState>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return StreakNotifier(prefs, ref);
    });

// ─── Scheduled Notification & Reminder Simulator ─────────────────────────────

class ScheduledNotificationSimulator {
  final Ref _ref;

  ScheduledNotificationSimulator(this._ref);

  void triggerDailySummary() {
    final transactions = _ref.read(allTransactionsProvider);
    final today = DateTime.now();
    final todayTxs = transactions
        .where(
          (t) =>
              t.date.year == today.year &&
              t.date.month == today.month &&
              t.date.day == today.day,
        )
        .toList();

    final spent = todayTxs
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final income = todayTxs
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final net = income - spent;

    // Get Top Category
    var topCat = 'None';
    if (todayTxs.isNotEmpty) {
      final categories = <String, double>{};
      for (final t in todayTxs.where(
        (t) => t.type == TransactionType.expense,
      )) {
        categories[t.categoryId] = (categories[t.categoryId] ?? 0.0) + t.amount;
      }
      if (categories.isNotEmpty) {
        final sorted = categories.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        topCat = sorted.first.key;
        // capitalize
        topCat = topCat[0].toUpperCase() + topCat.substring(1);
      }
    }

    final count = todayTxs.length;
    _ref
        .read(notificationsListProvider.notifier)
        .addNotification(
          title: '🌅 Daily Spending Summary',
          body: spent > 0
              ? 'You spent ₹${spent.toStringAsFixed(0)} today across $count transactions. Top category was $topCat.'
              : 'Zero spending recorded today! Great job staying under budget.',
          type: 'summary',
          metadata: {
            'spent': spent.toString(),
            'income': income.toString(),
            'savings': net.toString(),
            'topCategory': topCat,
          },
        );
  }

  void triggerNoEntryReminder() {
    final transactions = _ref.read(allTransactionsProvider);
    final today = DateTime.now();
    final todayTxs = transactions
        .where(
          (t) =>
              t.date.year == today.year &&
              t.date.month == today.month &&
              t.date.day == today.day,
        )
        .toList();

    if (todayTxs.isEmpty) {
      _ref
          .read(notificationsListProvider.notifier)
          .addNotification(
            title: '🤔 Did you spend money today?',
            body:
                'You haven\'t logged any transactions today. Tap to add an expense.',
            type: 'reminder',
          );
    }
  }

  void checkBudgetWarnings() {
    final budgets = _ref.read(liveBudgetsProvider);
    for (final b in budgets) {
      final utilization = b.monthlyLimit > 0
          ? (b.spentAmount / b.monthlyLimit)
          : 0.0;
      final categoryName =
          b.category[0].toUpperCase() + b.category.substring(1);

      if (utilization >= 1.0) {
        _ref
            .read(notificationsListProvider.notifier)
            .addNotification(
              title: '🚨 Budget Exceeded!',
              body:
                  'Your $categoryName monthly budget of ₹${b.monthlyLimit.toStringAsFixed(0)} has been exceeded!',
              type: 'budget',
              metadata: {'category': b.category},
            );
      } else if (utilization >= 0.90) {
        _ref
            .read(notificationsListProvider.notifier)
            .addNotification(
              title: '⚠️ Budget Warning (90%)',
              body:
                  'Your $categoryName budget is 90% exhausted. (Spent ₹${b.spentAmount.toStringAsFixed(0)} of ₹${b.monthlyLimit.toStringAsFixed(0)}).',
              type: 'budget',
              metadata: {'category': b.category},
            );
      } else if (utilization >= 0.80) {
        _ref
            .read(notificationsListProvider.notifier)
            .addNotification(
              title: '⚠️ Budget Warning (80%)',
              body:
                  'Your $categoryName budget is 80% exhausted. (Spent ₹${b.spentAmount.toStringAsFixed(0)} of ₹${b.monthlyLimit.toStringAsFixed(0)}).',
              type: 'budget',
              metadata: {'category': b.category},
            );
      }
    }
  }

  void triggerWeeklyFinancialReport() {
    final transactions = _ref.read(allTransactionsProvider);
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));

    final weekTxs = transactions
        .where((t) => t.date.isAfter(oneWeekAgo))
        .toList();
    final spent = weekTxs
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final income = weekTxs
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final savings = income - spent;

    var topCat = 'None';
    if (weekTxs.isNotEmpty) {
      final categories = <String, double>{};
      for (final t in weekTxs.where((t) => t.type == TransactionType.expense)) {
        categories[t.categoryId] = (categories[t.categoryId] ?? 0.0) + t.amount;
      }
      if (categories.isNotEmpty) {
        final sorted = categories.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        topCat = sorted.first.key;
        topCat = topCat[0].toUpperCase() + topCat.substring(1);
      }
    }

    _ref
        .read(notificationsListProvider.notifier)
        .addNotification(
          title: '📊 Weekly Financial Report',
          body:
              'This week: Income: ₹${income.toStringAsFixed(0)} | Spent: ₹${spent.toStringAsFixed(0)} | Savings: ₹${savings.toStringAsFixed(0)}. Top category: $topCat.',
          type: 'weekly',
          metadata: {
            'spent': spent.toString(),
            'income': income.toString(),
            'savings': savings.toString(),
            'topCategory': topCat,
          },
        );
  }

  void triggerMonthEndSummary() {
    final transactions = _ref.read(allTransactionsProvider);
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final monthTxs = transactions
        .where(
          (t) => t.date.isAfter(
            startOfMonth.subtract(const Duration(milliseconds: 1)),
          ),
        )
        .toList();
    final spent = monthTxs
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final income = monthTxs
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final savings = income - spent;
    final savingsRate = income > 0 ? (savings / income) * 100.0 : 0.0;

    // Largest Expense
    Transaction? largestExp;
    final expensesList = monthTxs
        .where((t) => t.type == TransactionType.expense)
        .toList();
    if (expensesList.isNotEmpty) {
      expensesList.sort((a, b) => b.amount.compareTo(a.amount));
      largestExp = expensesList.first;
    }

    var topCat = 'None';
    if (monthTxs.isNotEmpty) {
      final categories = <String, int>{};
      for (final t in monthTxs.where(
        (t) => t.type == TransactionType.expense,
      )) {
        categories[t.categoryId] = (categories[t.categoryId] ?? 0) + 1;
      }
      if (categories.isNotEmpty) {
        final sorted = categories.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        topCat = sorted.first.key;
        topCat = topCat[0].toUpperCase() + topCat.substring(1);
      }
    }

    // Financial Score simulation
    final budgetAdherence = 80.0; // simulated
    final consistency = 75.0; // simulated
    final financialScore =
        (savingsRate.clamp(0.0, 100.0) * 0.4) +
        (budgetAdherence * 0.4) +
        (consistency * 0.2);

    _ref
        .read(notificationsListProvider.notifier)
        .addNotification(
          title: '🗓️ Month-End Financial Summary',
          body:
              'Financial Score: ${financialScore.toStringAsFixed(0)}/100. Income: ₹${income.toStringAsFixed(0)} | Spent: ₹${spent.toStringAsFixed(0)} | Savings: ₹${savings.toStringAsFixed(0)}. Top category: $topCat.',
          type: 'monthly',
          metadata: {
            'spent': spent.toString(),
            'income': income.toString(),
            'savings': savings.toString(),
            'score': financialScore.toStringAsFixed(0),
            'largestExpense': largestExp != null
                ? '${largestExp.title} (₹${largestExp.amount.toStringAsFixed(0)})'
                : 'None',
            'topCategory': topCat,
          },
        );
  }
}

final notificationSimulatorProvider = Provider<ScheduledNotificationSimulator>((
  ref,
) {
  return ScheduledNotificationSimulator(ref);
});
