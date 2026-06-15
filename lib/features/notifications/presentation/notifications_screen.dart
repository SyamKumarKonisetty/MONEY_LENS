import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import 'providers/notifications_provider.dart';
import 'settings/reminder_settings_sheet.dart';
import '../domain/entities/notification_item.dart';
import '../../transactions/presentation/widgets/add_expense_bottom_sheet.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsListProvider);
    final streak = ref.watch(streakNotifierProvider);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // AppBar
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.textPrimaryColor, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Notification Center',
              style: AppTypography.titleLarge.copyWith(
                color: context.textPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              if (notifications.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.done_all_rounded, color: context.primaryColor, size: 22),
                  tooltip: 'Mark all as read',
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ref.read(notificationsListProvider.notifier).markAllAsRead();
                  },
                ),
              IconButton(
                icon: Icon(Icons.delete_sweep_rounded, color: context.errorColor, size: 22),
                tooltip: 'Clear all history',
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _showClearAllDialog(context);
                },
              ),
              IconButton(
                icon: Icon(Icons.settings_rounded, color: context.textPrimaryColor, size: 20),
                onPressed: () => _showSettingsSheet(context),
              ),
            ],
          ),

          // Streak Summary Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding, vertical: AppSpacing.sm),
              child: _buildStreakCard(context, streak),
            ),
          ),

          // Tabs
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
              child: TabBar(
                controller: _tabController,
                indicatorColor: context.primaryColor,
                labelColor: context.primaryColor,
                unselectedLabelColor: context.textSecondaryColor,
                labelStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'Notifications'),
                  Tab(text: 'Badges'),
                  Tab(text: 'Simulate'),
                ],
              ),
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationsList(context, notifications),
                _buildBadgesGrid(context, streak.achievements),
                _buildSimulatePanel(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
        title: const Text('Clear All Notifications?'),
        content: const Text('Are you sure you want to clear your local notification history? This action cannot be undone.'),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: context.textSecondaryColor)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text('Clear All', style: TextStyle(color: context.errorColor, fontWeight: FontWeight.bold)),
            onPressed: () {
              ref.read(notificationsListProvider.notifier).clearAll();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const ReminderSettingsSheet(),
    );
  }

  Widget _buildStreakCard(BuildContext context, StreakState streak) {
    final isDark = context.isDark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: context.separatorColor.withValues(alpha: isDark ? 0.3 : 0.6),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STREAK PROGRESS',
                  style: AppTypography.labelSmall.copyWith(
                    color: context.textSecondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(
                      '🔥 ${streak.transactionStreak} Days',
                      style: AppTypography.displayMedium.copyWith(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Consecutive days with logged expenses.',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.card,
            ),
            child: Column(
              children: [
                const Text(
                  '📱 Visits',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  '${streak.loginStreak} Days',
                  style: TextStyle(
                    color: context.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(BuildContext context, List<NotificationItem> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.notifications_none_rounded, size: 48, color: context.textSecondaryColor),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No notifications',
              style: AppTypography.titleMedium.copyWith(
                color: context.textPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your notifications and summary reports will appear here.',
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, idx) {
        final item = list[idx];
        return Dismissible(
          key: Key(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: AppSpacing.xl),
            decoration: BoxDecoration(
              color: context.errorColor,
              borderRadius: AppRadius.card,
            ),
            child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
          ),
          onDismissed: (_) {
            ref.read(notificationsListProvider.notifier).deleteNotification(item.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notification deleted'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 1),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: AppRadius.card,
              border: Border.all(
                color: item.isRead
                    ? context.separatorColor.withValues(alpha: context.isDark ? 0.3 : 0.6)
                    : context.primaryColor.withValues(alpha: 0.5),
              ),
            ),
            child: InkWell(
              onTap: () {
                ref.read(notificationsListProvider.notifier).markAsRead(item.id);
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: item.isRead ? Colors.transparent : context.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.title,
                              style: AppTypography.titleMedium.copyWith(
                                color: context.textPrimaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              DateFormat('jm').format(item.timestamp),
                              style: AppTypography.labelSmall.copyWith(
                                color: context.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.body,
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
                        if (item.type == 'reminder') ...[
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  ref.read(notificationsListProvider.notifier).deleteNotification(item.id);
                                },
                                child: const Text('Skip', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
                                ),
                                onPressed: () {
                                  ref.read(notificationsListProvider.notifier).markAsRead(item.id);
                                  showAddTransactionSheet(context);
                                },
                                child: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('yyyy-MM-dd').format(item.timestamp),
                          style: AppTypography.labelSmall.copyWith(
                            color: context.textSecondaryColor.withValues(alpha: 0.6),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadgesGrid(BuildContext context, List<Achievement> badges) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.85,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final b = badges[index];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: AppRadius.card,
            border: Border.all(
              color: b.isUnlocked
                  ? context.primaryColor.withValues(alpha: 0.3)
                  : context.separatorColor.withValues(alpha: context.isDark ? 0.3 : 0.6),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                b.icon,
                style: TextStyle(
                  fontSize: 48,
                  color: b.isUnlocked ? null : Colors.grey.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                b.title,
                style: AppTypography.titleMedium.copyWith(
                  color: b.isUnlocked ? context.textPrimaryColor : context.textSecondaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                b.description,
                style: AppTypography.labelSmall.copyWith(
                  color: context.textSecondaryColor,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: b.isUnlocked
                      ? context.primaryColor.withValues(alpha: 0.12)
                      : Colors.grey.withValues(alpha: 0.12),
                  borderRadius: AppRadius.circularFull,
                ),
                child: Text(
                  b.isUnlocked ? 'Unlocked' : 'Locked',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: b.isUnlocked ? context.primaryColor : context.textSecondaryColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimulatePanel(BuildContext context) {
    final simulator = ref.watch(notificationSimulatorProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Simulator Controls',
            style: AppTypography.titleLarge.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Use these buttons to instantly trigger scheduled notifications and check alert logic in the local sandbox.',
            style: AppTypography.bodySmall.copyWith(color: context.textSecondaryColor),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildSimButton(
            context,
            icon: Icons.wb_twilight_rounded,
            title: 'Daily Spending Summary',
            desc: 'Triggers evening notification summarizing today\'s spending totals.',
            onTap: () {
              simulator.triggerDailySummary();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Triggered Daily Summary'), duration: Duration(seconds: 1)),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSimButton(
            context,
            icon: Icons.chat_bubble_outline_rounded,
            title: 'No-Entry Reminder',
            desc: 'Triggers notification prompt if no transactions have been logged today.',
            onTap: () {
              simulator.triggerNoEntryReminder();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Triggered No-Entry Check'), duration: Duration(seconds: 1)),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSimButton(
            context,
            icon: Icons.warning_amber_rounded,
            title: 'Budget Alert Check',
            desc: 'Evaluates active budgets and triggers 80%/90%/100% alerts accordingly.',
            onTap: () {
              simulator.checkBudgetWarnings();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Triggered Budget Warning Check'), duration: Duration(seconds: 1)),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSimButton(
            context,
            icon: Icons.bar_chart_rounded,
            title: 'Weekly Financial Report',
            desc: 'Triggers weekly summary of income, expenses, top category and savings rate.',
            onTap: () {
              simulator.triggerWeeklyFinancialReport();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Triggered Weekly Financial Report'), duration: Duration(seconds: 1)),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSimButton(
            context,
            icon: Icons.calendar_month_rounded,
            title: 'Month-End Summary',
            desc: 'Generates financial health score, largest expense, and category analysis.',
            onTap: () {
              simulator.triggerMonthEndSummary();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Triggered Month-End Financial Summary'), duration: Duration(seconds: 1)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSimButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String desc,
    required VoidCallback onTap,
  }) {
    return Card(
      color: context.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(color: context.separatorColor.withValues(alpha: context.isDark ? 0.3 : 0.6)),
      ),
      elevation: 0,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.primaryColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: context.primaryColor, size: 20),
        ),
        title: Text(title, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(desc, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
      ),
    );
  }
}
