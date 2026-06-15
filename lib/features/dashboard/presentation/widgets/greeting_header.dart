import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../settings/presentation/providers/user_profile_provider.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../sms_detection/presentation/providers/sms_detection_provider.dart';

/// Dashboard greeting header with animated entrance.
///
/// Shows a time-aware greeting and current date.
class GreetingHeader extends ConsumerWidget {
  const GreetingHeader({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formattedDate() {
    final now = DateTime.now();
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final dayName = days[now.weekday - 1];
    return '$dayName, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileNotifierProvider);
    final displayName = profile.name.isEmpty ? 'Syam' : profile.name;
    final unreadCount = ref.watch(notificationsListProvider).where((n) => !n.isRead).length;
    final pendingSmsCount = ref.watch(smsDetectionNotifierProvider).where((s) => s.status == SmsDetectionStatus.pending).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Row(
        children: [
          // Greeting Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting()}, $displayName 👋',
                  style: AppTypography.displayMedium.copyWith(
                    color: context.textPrimaryColor,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _formattedDate(),
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // SMS Inbox Button with badge
              Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.sms_outlined, color: context.textPrimaryColor),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.push(AppConstants.routeSmsInbox);
                    },
                  ),
                  if (pendingSmsCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$pendingSmsCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),

              // Notifications Button with badge
              Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications_none_rounded, color: context.textPrimaryColor),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.push(AppConstants.routeNotifications);
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
