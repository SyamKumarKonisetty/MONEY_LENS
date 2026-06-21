import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/design/design_system.dart';
import '../../../../../core/ui_engine/ui_engine.dart';
import '../../../../settings/presentation/providers/user_profile_provider.dart';
import '../../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../../sms_detection/presentation/providers/sms_detection_provider.dart';
import '../animations/dashboard_animations.dart';

/// Reimagined Hero Greeting Header featuring high-end visual rhythm and soft entries.
class GreetingHeader extends ConsumerWidget {
  const GreetingHeader({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning,';
    if (hour >= 12 && hour < 17) return 'Good Afternoon,';
    if (hour >= 17 && hour < 21) return 'Good Evening,';
    return 'Good Night,';
  }

  String _formattedDate() {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const days = [
      'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
    ];
    // weekday is 1 for Monday, 7 for Sunday in DateTime
    final weekdayIndex = now.weekday % 7;
    return '${days[weekdayIndex]} • ${now.day} ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileNotifierProvider);
    final displayName = profile.name.isEmpty ? 'HERO' : profile.name;
    final unreadCount = ref
        .watch(notificationsListProvider)
        .where((n) => !n.isRead)
        .length;
    final pendingSmsCount = ref.watch(smsDetectionNotifierProvider).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: FadeDownEntrance(
        delay: const Duration(milliseconds: 100),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Column: Greetings & Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _greeting(),
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$displayName 👋',
                    style: AppTypography.displayMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formattedDate(),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),

            // Right Row: Messaging, Notification Icons & Profile Avatar
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // SMS Inbox Icon
                _HeaderIconButton(
                  icon: Icons.sms_rounded,
                  badgeCount: pendingSmsCount,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push(AppConstants.routeSmsInbox);
                  },
                ),
                const SizedBox(width: AppSpacing.sm),

                // Notifications Icon
                _HeaderIconButton(
                  icon: Icons.notifications_rounded,
                  badgeCount: unreadCount,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push(AppConstants.routeNotifications);
                  },
                ),
                const SizedBox(width: AppSpacing.md),

                // User Avatar with spring entrance scaling
                ScaleUpEntrance(
                  delay: const Duration(milliseconds: 250),
                  child: PressScale(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push(AppConstants.routeSettings);
                    },
                    child: Avatar(
                      name: displayName,
                      size: 46.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.badgeCount,
    required this.onTap,
  });

  final IconData icon;
  final int badgeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ScaleUpEntrance(
      delay: const Duration(milliseconds: 200),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PressScale(
            onTap: onTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.card,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.divider,
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: ScaleUpEntrance(
                delay: const Duration(milliseconds: 400),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
