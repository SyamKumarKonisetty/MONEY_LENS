import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design/design_system.dart';
import '../../../../../core/ui_engine/ui_engine.dart';
import '../../../../budget/presentation/providers/budget_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../animations/dashboard_animations.dart';

/// reimagined financial health radial section utilizing custom painting and soft glow.
class FinancialHealthSection extends ConsumerWidget {
  const FinancialHealthSection({super.key});

  double _calculateHealthScore(WidgetRef ref) {
    final income = ref.watch(currentMonthIncomeProvider);
    final expenses = ref.watch(currentMonthExpensesProvider);
    final budgetSummary = ref.watch(budgetSummaryProvider);
    final totalTxs = ref.watch(totalTransactionsCountProvider);

    double score = 100.0;

    // 1. Savings Rate Deduction
    if (income > 0) {
      final savingsRate = ((income - expenses) / income) * 100.0;
      if (savingsRate < 20.0 && savingsRate > 0) {
        score -= (20.0 - savingsRate) * 1.5; // Up to 30 pts deduction
      } else if (savingsRate <= 0) {
        score -= 45.0; // Over-spending deduction
      }
    } else if (expenses > 0) {
      score -= 45.0;
    } else {
      score -= 20.0; // No transactions/income logged
    }

    // 2. Budget Utilization Deduction
    if (budgetSummary.totalLimit > 0) {
      final usagePercent = budgetSummary.usagePercent;
      if (usagePercent > 100.0) {
        score -= 25.0;
      } else if (usagePercent > 80.0) {
        score -= (usagePercent - 80.0) * 0.75;
      }
    }

    // 3. Tracking Habit Bonus/Deduction
    if (totalTxs < 5) {
      score -= 10.0; // Lack of data deduction
    } else if (totalTxs >= 15) {
      score += 5.0; // Active tracking bonus
    }

    return score.clamp(10.0, 100.0);
  }

  Map<String, dynamic> _getHealthDetails(double score) {
    if (score >= 85.0) {
      return {'label': 'Excellent', 'color': AppColors.income};
    } else if (score >= 60.0) {
      return {'label': 'Good', 'color': AppColors.warning};
    } else if (score >= 45.0) {
      return {'label': 'Average', 'color': AppColors.warning.withValues(alpha: 0.85)};
    } else {
      return {'label': 'Critical', 'color': AppColors.expense};
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = _calculateHealthScore(ref);
    final details = _getHealthDetails(score);
    final healthColor = details['color'] as Color;
    final healthLabel = details['label'] as String;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: ScaleUpEntrance(
        delay: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadius.medium,
            border: Border.all(
              color: AppColors.divider,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Radial Gauge widget
              RepaintBoundary(
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: score),
                    duration: MotionConstants.slowDuration,
                    curve: MotionConstants.smoothCurve,
                    builder: (context, val, child) {
                      return CustomPaint(
                        painter: _HealthGaugePainter(
                          score: val,
                          gaugeColor: healthColor,
                          trackColor: AppColors.divider,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                val.toStringAsFixed(0),
                                style: AppTypography.title.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22,
                                ),
                              ),
                              Text(
                                'SCORE',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xl),

              // dynamic text description based on health metrics
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FINANCIAL HEALTH',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      healthLabel.toUpperCase(),
                      style: AppTypography.title.copyWith(
                        color: healthColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getHealthAdvice(score),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
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
    );
  }

  String _getHealthAdvice(double score) {
    if (score >= 85.0) {
      return 'Exceptional budget discipline and strong savings flow. Keep matching your goals!';
    } else if (score >= 60.0) {
      return 'Solid financial stance, but you can increase your cushion by curbing non-essential spends.';
    } else if (score >= 45.0) {
      return 'Higher category outflow detected. We recommend setting category limits to recover score.';
    } else {
      return 'Alert: Outflow has breached current limits. Take control of non-essential costs.';
    }
  }
}

class _HealthGaugePainter extends CustomPainter {
  _HealthGaugePainter({
    required this.score,
    required this.gaugeColor,
    required this.trackColor,
  });

  final double score;
  final Color gaugeColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 6;
    const strokeWidth = 8.0;

    // 1. Background Track Arc
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 1.25,
      math.pi * 1.5,
      false,
      trackPaint,
    );

    // 2. Interactive Progress Arc
    final progressPaint = Paint()
      ..color = gaugeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressAngle = (score / 100.0) * (math.pi * 1.5);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 1.25,
      progressAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HealthGaugePainter oldDelegate) {
    return oldDelegate.score != score ||
        oldDelegate.gaugeColor != gaugeColor ||
        oldDelegate.trackColor != trackColor;
  }
}
