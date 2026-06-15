import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/transactions/presentation/transactions_screen.dart';
import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/budget/presentation/budget_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/sms_detection/presentation/sms_inbox_screen.dart';
import '../constants/app_constants.dart';
import 'app_scaffold.dart';

/// MoneyLens GoRouter configuration.
///
/// Architecture:
/// ```
/// GoRouter
/// └── StatefulShellRoute.indexedStack (tab state preservation)
///     ├── /dashboard        → DashboardScreen
///     │   ├── /budget       → BudgetScreen   (Phase 3 placeholder)
///     │   └── /reports      → ReportsScreen  (Phase 3 placeholder)
///     ├── /transactions     → TransactionsScreen
///     ├── /analytics        → AnalyticsScreen
///     └── /settings         → SettingsScreen
/// ```
///
/// Budget and Reports are pushed as full-screen modal routes from the
/// Dashboard's Quick Actions, keeping them outside the tab shell so the
/// bottom nav bar is hidden on those pages (full-focus experience).
final appRouter = GoRouter(
  initialLocation: AppConstants.routeDashboard,
  debugLogDiagnostics: false,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppScaffold(navigationShell: navigationShell);
      },
      branches: [
        // ─── Dashboard ──────────────────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppConstants.routeDashboard,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: DashboardScreen()),
            ),
          ],
        ),

        // ─── Transactions ────────────────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppConstants.routeTransactions,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: TransactionsScreen()),
            ),
          ],
        ),

        // ─── Analytics ──────────────────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppConstants.routeAnalytics,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: AnalyticsScreen()),
            ),
          ],
        ),

        // ─── Settings ────────────────────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppConstants.routeSettings,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: SettingsScreen()),
            ),
          ],
        ),
      ],
    ),

    // ─── Full-screen modal routes (outside tab shell) ──────────────────
    GoRoute(
      path: AppConstants.routeBudget,
      pageBuilder: (context, state) => const MaterialPage(
        fullscreenDialog: true,
        child: BudgetScreen(),
      ),
    ),
    GoRoute(
      path: AppConstants.routeReports,
      pageBuilder: (context, state) => const MaterialPage(
        fullscreenDialog: true,
        child: ReportsScreen(),
      ),
    ),
    GoRoute(
      path: AppConstants.routeNotifications,
      pageBuilder: (context, state) => const MaterialPage(
        fullscreenDialog: true,
        child: NotificationsScreen(),
      ),
    ),
    GoRoute(
      path: AppConstants.routeSmsInbox,
      pageBuilder: (context, state) => const MaterialPage(
        fullscreenDialog: true,
        child: SmsInboxScreen(),
      ),
    ),
  ],
);
