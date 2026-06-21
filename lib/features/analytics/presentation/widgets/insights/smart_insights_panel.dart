import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/ui_engine/glass/glass_card.dart';
import '../../../../../core/ui_engine/glass/glass_surface.dart';
import '../../providers/analytics_cockpit_provider.dart';

/// Rotational glass smart financial insights carousel combined with searchable filters.
class SmartInsightsPanel extends ConsumerStatefulWidget {
  const SmartInsightsPanel({super.key});

  @override
  ConsumerState<SmartInsightsPanel> createState() => _SmartInsightsPanelState();
}

class _SmartInsightsPanelState extends ConsumerState<SmartInsightsPanel> {
  int _activeInsightIndex = 0;
  Timer? _rotationTimer;
  final TextEditingController _searchCtrl = TextEditingController();

  final List<Map<String, dynamic>> _baseInsights = [
    {
      'title': 'Category Distribution',
      'body': 'Food and dining accounts for 42% of your monthly outflows.',
      'icon': Icons.restaurant_rounded,
      'color': Colors.orangeAccent,
    },
    {
      'title': 'Peak Spending Day',
      'body': 'Your transaction spikes usually cluster on Friday evenings.',
      'icon': Icons.calendar_month_rounded,
      'color': Colors.cyanAccent,
    },
    {
      'title': 'Savings Achievement',
      'body': 'You saved ₹4,320 more than the same timeframe last month.',
      'icon': Icons.thumb_up_rounded,
      'color': Colors.greenAccent,
    },
    {
      'title': 'Weekly Balance Trend',
      'body': 'Outflows decreased by 18% compared to the prior 7-day period.',
      'icon': Icons.trending_down_rounded,
      'color': Colors.blueAccent,
    },
  ];

  @override
  void initState() {
    super.initState();
    _rotationTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _activeInsightIndex = (_activeInsightIndex + 1) % _baseInsights.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeInsight = _baseInsights[_activeInsightIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Column(
        children: [
          // Frosted glass search input
          GlassSurface(
            borderRadius: BorderRadius.circular(100),
            borderColor: context.separatorColor.withValues(alpha: 0.15),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) {
                ref.read(analyticsSearchQueryProvider.notifier).state = val;
              },
              style: AppTypography.bodyMedium.copyWith(color: context.textPrimaryColor),
              decoration: InputDecoration(
                hintText: 'Search analytics (e.g. food, salary)',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondaryColor.withValues(alpha: 0.6),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: context.textSecondaryColor.withValues(alpha: 0.8),
                ),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref.read(analyticsSearchQueryProvider.notifier).state = '';
                          setState(() {});
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Sliding insight card
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: GlassCard(
              key: ValueKey<int>(_activeInsightIndex),
              isInteractive: true,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: (activeInsight['color'] as Color).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      activeInsight['icon'] as IconData,
                      color: activeInsight['color'] as Color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeInsight['title'] as String,
                          style: AppTypography.labelLarge.copyWith(
                            color: context.textPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          activeInsight['body'] as String,
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.textSecondaryColor,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
