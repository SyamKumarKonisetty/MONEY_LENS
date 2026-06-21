library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/design/design_system.dart';

/// A premium swipe wrapper wrapping standard [Dismissible] for full test compliance.
///
/// Features direction-aware haptic swipes: Edit (Swipe Right), Delete (Swipe Left).
class SwipeableActionWrapper extends StatelessWidget {
  const SwipeableActionWrapper({
    required Key key,
    required this.child,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  final Widget child;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key!,
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact();
        if (direction == DismissDirection.startToEnd) {
          onEdit();
          return false; // Spring back and do not delete
        }
        return true; // Proceed to delete
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete();
        }
      },
      background: _buildActionBg(
        align: Alignment.centerLeft,
        color: AppColors.primary,
        icon: Icons.edit_rounded,
        label: 'Edit',
      ),
      secondaryBackground: _buildActionBg(
        align: Alignment.centerRight,
        color: AppColors.expense,
        icon: Icons.delete_outline_rounded,
        label: 'Delete',
      ),
      child: child,
    );
  }

  Widget _buildActionBg({
    required Alignment align,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    final isLeft = align == Alignment.centerLeft;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLeft) ...[
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ] else ...[
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: color, size: 20),
          ],
        ],
      ),
    );
  }
}
