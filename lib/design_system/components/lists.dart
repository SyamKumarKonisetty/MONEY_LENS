import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../foundations/colors.dart';
import '../foundations/radius.dart';
import '../foundations/spacing.dart';
import '../foundations/typography.dart';
import '../animations/haptics.dart';
import 'package:money_lens/core/design/design_system.dart';

/// MoneyLens Design System (MLDS) List and Tile Components interface.
abstract class MLListTile extends StatelessWidget {
  const MLListTile({super.key});

  /// Standard transaction/expense history tile.
  const factory MLListTile.transaction({
    required String title,
    required double amount,
    required DateTime date,
    required String category,
    Key? key,
    bool isIncome,
    String? note,
    VoidCallback? onTap,
  }) = _MLTransactionTile;

  /// General menu/settings list tile.
  const factory MLListTile.menu({
    required String title,
    required IconData icon,
    Key? key,
    String? subtitle,
    Color? iconColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) = _MLMenuTile;
}

class _MLTransactionTile extends MLListTile {
  const _MLTransactionTile({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    super.key,
    this.isIncome = false,
    this.note,
    this.onTap,
  });

  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final bool isIncome;
  final String? note;
  final VoidCallback? onTap;

  IconData _getCategoryIcon(String cat) {
    switch (cat.toLowerCase().trim()) {
      case 'food':
      case 'dining':
        return Icons.restaurant_rounded;
      case 'transport':
      case 'travel':
        return Icons.directions_car_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'healthcare':
      case 'medical':
        return Icons.medical_services_rounded;
      case 'entertainment':
      case 'leisure':
        return Icons.local_play_rounded;
      case 'utilities':
      case 'bills':
        return Icons.power_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'salary':
      case 'income':
        return Icons.account_balance_wallet_rounded;
      case 'freelance':
      case 'bonus':
        return Icons.monetization_on_rounded;
      default:
        return Icons.payments_rounded;
    }
  }

  Color _getCategoryColor(BuildContext context, String cat) {
    switch (cat.toLowerCase().trim()) {
      case 'food':
      case 'dining':
        return const Color(0xFFFF6B35);
      case 'transport':
      case 'travel':
        return const Color(0xFF6366F1);
      case 'shopping':
        return const Color(0xFFEC4899);
      case 'healthcare':
      case 'medical':
        return const Color(0xFF10B981);
      case 'entertainment':
      case 'leisure':
        return const Color(0xFF8B5CF6);
      case 'utilities':
      case 'bills':
        return const Color(0xFF06B6D4);
      case 'education':
        return const Color(0xFFF59E0B);
      case 'salary':
      case 'income':
        return MLColors.income(context);
      default:
        return MLColors.primary(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(context, category);
    final icon = _getCategoryIcon(category);
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final formattedAmount = '${isIncome ? "+" : "-"}${formatCurrency.format(amount)}';
    final amountColor = isIncome ? MLColors.income(context) : MLColors.expense(context);

    Widget current = Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: MLColors.surfaceCard(context),
        borderRadius: MLRadius.mediumBorderRadius,
      ),
      child: ListTile(
        onTap: onTap != null
            ? () {
                MLHaptics.selection();
                onTap!();
              }
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: MLSpacing.lg,
          vertical: MLSpacing.sm,
        ),
        leading: CircleAvatar(
          backgroundColor: catColor.withValues(alpha: 0.15),
          radius: 20,
          child: Icon(icon, color: catColor, size: 20),
        ),
        title: Text(
          title,
          style: MLTypography.titleMedium.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textPrimary
                : Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  DateFormat('dd MMM yyyy').format(date),
                  style: MLTypography.caption.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textPrimary.withValues(alpha: 0.24)
                        : Colors.black45,
                  ),
                ),
                if (note != null && note!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note!,
                      style: MLTypography.caption.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.textPrimary.withValues(alpha: 0.24)
                            : Colors.black38,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Text(
          formattedAmount,
          style: MLTypography.moneyMedium.copyWith(
            color: amountColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    return current;
  }
}

class _MLMenuTile extends MLListTile {
  const _MLMenuTile({
    required this.title,
    required this.icon,
    super.key,
    this.subtitle,
    this.iconColor,
    this.trailing,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final String? subtitle;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final defaultIconColor = iconColor ?? MLColors.primary(context);

    return ListTile(
      onTap: onTap != null
          ? () {
              MLHaptics.selection();
              onTap!();
            }
          : null,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: MLSpacing.pagePadding,
        vertical: MLSpacing.sm,
      ),
      leading: Icon(icon, color: defaultIconColor, size: 24),
      title: Text(
        title,
        style: MLTypography.titleMedium.copyWith(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.textPrimary
              : Colors.black87,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: MLTypography.caption.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textPrimary.withValues(alpha: 0.24)
                    : Colors.black54,
              ),
            )
          : null,
      trailing: trailing ??
          Icon(
            Icons.chevron_right_rounded,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textPrimary.withValues(alpha: 0.24)
                : Colors.black26,
            size: 20,
          ),
    );
  }
}
