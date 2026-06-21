import 'package:flutter/material.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/ui_engine/glass/glass_card.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../providers/analytics_cockpit_provider.dart';

/// Top 5 ranking merchant spend list card.
class TopMerchants extends StatelessWidget {
  const TopMerchants({
    super.key,
    required this.merchants,
  });

  final List<MerchantSpend> merchants;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: GlassCard(
        isInteractive: false,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TOP MERCHANTS',
              style: AppTypography.labelSmall.copyWith(
                color: context.textSecondaryColor,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            if (merchants.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text(
                    'No merchant expenses found.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                ),
              )
            else
              Column(
                children: List.generate(merchants.length, (index) {
                  final item = merchants[index];
                  final isLast = index == merchants.length - 1;
                  final initials = item.name.substring(0, index == 0 ? 1 : 2).toUpperCase();

                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
                    child: Row(
                      children: [
                        // Ranking Badge & Logo Circle
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: context.primaryColor.withValues(
                              alpha: index == 0 ? 0.2 : 0.08,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: index == 0
                                  ? context.primaryColor.withValues(alpha: 0.3)
                                  : context.separatorColor.withValues(alpha: 0.15),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: AppTypography.labelMedium.copyWith(
                                color: index == 0 ? context.primaryColor : context.textPrimaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),

                        // Merchant details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelLarge.copyWith(
                                  color: context.textPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                '${item.transactionCount} transactions',
                                style: AppTypography.labelSmall.copyWith(
                                  color: context.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Spend values & trend
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyFormatter.full(item.amount),
                              style: AppTypography.labelLarge.copyWith(
                                color: context.textPrimaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.arrow_downward_rounded,
                                  size: 10,
                                  color: Colors.greenAccent,
                                ),
                                Text(
                                  '${item.trendPercentage.abs()}%',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: Colors.greenAccent,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }
}
