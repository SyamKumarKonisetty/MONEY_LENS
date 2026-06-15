import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../providers/notifications_provider.dart';
import '../../../transactions/presentation/widgets/add_expense_bottom_sheet.dart';

class InAppNotificationBanner extends ConsumerStatefulWidget {
  const InAppNotificationBanner({super.key});

  @override
  ConsumerState<InAppNotificationBanner> createState() => _InAppNotificationBannerState();
}

class _InAppNotificationBannerState extends ConsumerState<InAppNotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = ref.watch(inAppBannerProvider);

    if (item == null) {
      return const SizedBox.shrink();
    }

    // Start slide in
    _controller.forward();

    // Reset dismiss timer
    _dismissTimer?.cancel();
    if (item.type != 'reminder') {
      _dismissTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) {
          _controller.reverse().then((_) {
            ref.read(inAppBannerProvider.notifier).dismissBanner();
          });
        }
      });
    }

    final isDark = context.isDark;

    return SlideTransition(
      position: _offsetAnimation,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding,
            vertical: AppSpacing.md,
          ),
          child: Material(
            elevation: 8,
            color: Colors.transparent,
            borderRadius: AppRadius.card,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
                borderRadius: AppRadius.card,
                border: Border.all(
                  color: context.separatorColor.withValues(alpha: isDark ? 0.3 : 0.6),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: context.primaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.type == 'achievement'
                          ? Icons.emoji_events_rounded
                          : item.type == 'budget'
                              ? Icons.warning_amber_rounded
                              : item.type == 'reminder'
                                  ? Icons.chat_bubble_outline_rounded
                                  : Icons.notifications_active_rounded,
                      color: context.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: AppTypography.titleMedium.copyWith(
                            color: context.textPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.body,
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textSecondaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.type == 'reminder') ...[
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  _controller.reverse().then((_) {
                                    ref.read(inAppBannerProvider.notifier).dismissBanner();
                                  });
                                },
                                child: const Text('Skip', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                                  minimumSize: Size.zero,
                                ),
                                onPressed: () {
                                  _controller.reverse().then((_) {
                                    ref.read(inAppBannerProvider.notifier).dismissBanner();
                                    showAddTransactionSheet(context);
                                  });
                                },
                                child: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: context.textSecondaryColor, size: 18),
                    onPressed: () {
                      _controller.reverse().then((_) {
                        ref.read(inAppBannerProvider.notifier).dismissBanner();
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
