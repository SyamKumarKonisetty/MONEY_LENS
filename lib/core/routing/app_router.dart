import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/transactions/presentation/transactions_screen.dart';
import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/budget/presentation/budget_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/sms_detection/presentation/sms_inbox_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/presentation/pin_login_screen.dart';
import '../constants/app_constants.dart';
import 'app_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// MoneyLens GoRouter provider with authentication gates.
final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppConstants.routeDashboard,
    debugLogDiagnostics: false,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isPinSetup = authNotifier.isPinSetup;
      final isAuthenticated = authNotifier.isAuthenticated;

      final loggingIn = state.matchedLocation == '/pin-login';
      final settingUpPin = state.matchedLocation == '/pin-setup';

      if (!isPinSetup) {
        if (!settingUpPin) return '/pin-setup';
        return null;
      }

      if (!isAuthenticated) {
        if (!loggingIn) return '/pin-login';
        return null;
      }

      if (loggingIn || settingUpPin || state.matchedLocation == '/sms-setup') {
        return AppConstants.routeDashboard;
      }

      return null;
    },
    routes: [
      // ─── Authentication Routes ──────────────────────────────────────────
      GoRoute(
        path: '/pin-setup',
        builder: (context, state) => const PinLoginScreen(isSetupMode: true),
      ),
      GoRoute(
        path: '/pin-login',
        builder: (context, state) => const PinLoginScreen(isSetupMode: false),
      ),

      // ─── Main Scaffold Shell ────────────────────────────────────────────
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
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            const MaterialPage(fullscreenDialog: true, child: BudgetScreen()),
      ),
      GoRoute(
        path: AppConstants.routeReports,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            const MaterialPage(fullscreenDialog: true, child: ReportsScreen()),
      ),
      GoRoute(
        path: AppConstants.routeNotifications,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true,
          child: NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: AppConstants.routeSmsInbox,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            const MaterialPage(fullscreenDialog: true, child: SmsInboxScreen()),
      ),
    ],
  );
});
