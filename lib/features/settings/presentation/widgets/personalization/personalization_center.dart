import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/ui_engine/glass/glass_card.dart';
import '../../../../../core/design/colors/app_colors.dart';
import '../../providers/settings_provider.dart';


class PersonalizationCenter extends ConsumerStatefulWidget {
  const PersonalizationCenter({super.key});

  @override
  ConsumerState<PersonalizationCenter> createState() => _PersonalizationCenterState();
}

class _PersonalizationCenterState extends ConsumerState<PersonalizationCenter> {
  static const String _prefAccentKey = 'personal_accent_color';
  static const String _prefCurrencyKey = 'personal_currency';
  static const String _prefDateFormatKey = 'personal_date_format';
  static const String _prefReduceMotionKey = 'personal_reduce_motion';

  final List<Color> _accentColors = [
    AppColors.sapphireBlue, // Classic Blue
    AppColors.categoryPalette[4], // Purple
    AppColors.incomeGreen, // Emerald
    AppColors.warningAmber, // Orange
    AppColors.expenseCoral, // Rose
  ];

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(sharedPreferencesProvider);

    final selectedAccentIdx = prefs.getInt(_prefAccentKey) ?? 0;
    final currency = prefs.getString(_prefCurrencyKey) ?? '₹ (INR)';
    final dateFormat = prefs.getString(_prefDateFormatKey) ?? 'dd/MM/yyyy';
    final reduceMotion = prefs.getBool(_prefReduceMotionKey) ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: GlassCard(
        isInteractive: false,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personalization',
                      style: AppTypography.titleMedium.copyWith(
                        color: context.textPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Customize your dashboard aesthetics',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.palette_outlined, color: context.primaryColor, size: 20),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Divider(height: 1, color: context.separatorColor.withValues(alpha: 0.3)),



            // Accent Color Grid
            Text(
              'Accent Color Theme',
              style: AppTypography.bodyMedium.copyWith(
                color: context.textPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: List.generate(_accentColors.length, (idx) {
                final color = _accentColors[idx];
                final isSelected = selectedAccentIdx == idx;
                return GestureDetector(
                  onTap: () async {
                    await prefs.setInt(_prefAccentKey, idx);
                    setState(() {});
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: AppSpacing.md),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.textPrimary : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                    child: isSelected
                        ? Icon(Icons.check_rounded, color: AppColors.textPrimary, size: 16)
                        : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.lg),
            Divider(height: 1, color: context.separatorColor.withValues(alpha: 0.3)),
            const SizedBox(height: AppSpacing.md),

            // Currency selector
            _dropdownRow(
              title: 'Currency Symbol',
              value: currency,
              items: ['₹ (INR)', '\$ (USD)', '€ (EUR)', '£ (GBP)'],
              onChanged: (val) async {
                if (val != null) {
                  await prefs.setString(_prefCurrencyKey, val);
                  setState(() {});
                }
              },
            ),

            // Date Format selector
            _dropdownRow(
              title: 'Date Format',
              value: dateFormat,
              items: ['dd/MM/yyyy', 'MM/dd/yyyy', 'yyyy-MM-dd'],
              onChanged: (val) async {
                if (val != null) {
                  await prefs.setString(_prefDateFormatKey, val);
                  setState(() {});
                }
              },
            ),

            // Reduce Motion flag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reduce Motion',
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.textPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Disable resource-heavy dashboard scales',
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: reduceMotion,
                  onChanged: (val) async {
                    await prefs.setBool(_prefReduceMotionKey, val);
                    setState(() {});
                  },
                  activeThumbColor: context.primaryColor,
                  activeTrackColor: context.primaryColor.withValues(alpha: 0.4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdownRow({
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          DropdownButton<String>(
            value: value,
            dropdownColor: context.surfaceColor,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down_rounded),
            style: TextStyle(color: context.textPrimaryColor, fontSize: 13),
            items: items.map((String val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text(val),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
