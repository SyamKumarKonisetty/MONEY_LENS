import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Quick action buttons on the dashboard.
///
/// 4 functional action chips:
/// - Add     → Opens Add Transaction bottom sheet
/// - Scan    → Opens Coming Soon sheet (Receipt OCR, Phase 3)
/// - Budget  → Navigates to Budget screen (Phase 3 placeholder)
/// - Reports → Navigates to Reports screen (Phase 3 placeholder)
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({
    super.key,
    required this.onAdd,
    required this.onScan,
    required this.onBudget,
    required this.onReports,
  });

  final VoidCallback onAdd;
  final VoidCallback onScan;
  final VoidCallback onBudget;
  final VoidCallback onReports;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem(
        icon: Icons.add_rounded,
        label: 'Add',
        color: const Color(0xFF007AFF),
        onTap: onAdd,
      ),
      _ActionItem(
        icon: Icons.qr_code_scanner_rounded,
        label: 'Scan',
        color: const Color(0xFF34C759),
        onTap: onScan,
      ),
      _ActionItem(
        icon: Icons.pie_chart_rounded,
        label: 'Budget',
        color: const Color(0xFF8B5CF6),
        onTap: onBudget,
      ),
      _ActionItem(
        icon: Icons.bar_chart_rounded,
        label: 'Reports',
        color: const Color(0xFFFF9F0A),
        onTap: onReports,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((action) => _ActionChip(item: action)).toList(),
      ),
    );
  }
}

class _ActionItem {
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

class _ActionChip extends StatefulWidget {
  const _ActionChip({required this.item});
  final _ActionItem item;

  @override
  State<_ActionChip> createState() => _ActionChipState();
}

class _ActionChipState extends State<_ActionChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.88,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTapDown(TapDownDetails _) async {
    await _controller.reverse();
  }

  Future<void> _onTapUp(TapUpDetails _) async {
    await _controller.forward();
    widget.item.onTap();
  }

  Future<void> _onTapCancel() async {
    await _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: AppRadius.circularLg,
                border: Border.all(
                  color: item.color.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(item.icon, color: item.color, size: 28),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              item.label,
              style: AppTypography.labelSmall.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
