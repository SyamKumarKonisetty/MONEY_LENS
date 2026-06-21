import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/design/colors/app_colors.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/ui_engine/glass/glass_card.dart';

/// Animated radial financial health gauge (0-100 score).
class FinancialHealthGauge extends StatelessWidget {
  const FinancialHealthGauge({
    super.key,
    required this.score,
    required this.explanation,
  });

  final int score;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    final scoreColor = _getScoreColor(score);
    final ratingText = _getRatingText(score);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: GlassCard(
        isInteractive: false,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Row(
          children: [
            // Gauge Painter
            SizedBox(
              width: 110,
              height: 110,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: score / 100.0),
                duration: const Duration(milliseconds: 1400),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return CustomPaint(
                    painter: _GaugePainter(
                      progress: value,
                      color: scoreColor,
                      trackColor: context.separatorColor.withValues(alpha: 0.15),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            (value * 100).toStringAsFixed(0),
                            style: AppTypography.displayMedium.copyWith(
                              color: context.textPrimaryColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'SCORE',
                            style: AppTypography.labelSmall.copyWith(
                              color: context.textSecondaryColor,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpacing.xl),

            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: scoreColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: scoreColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      ratingText,
                      style: AppTypography.labelMedium.copyWith(
                        color: scoreColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    explanation,
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textSecondaryColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return AppColors.cyanHighlight; // Teal
    if (score >= 70) return AppColors.incomeGreen; // Green
    if (score >= 50) return AppColors.warningAmber; // Orange
    return AppColors.expenseCoral; // Red
  }

  String _getRatingText(int score) {
    if (score >= 90) return 'EXCELLENT';
    if (score >= 70) return 'GOOD';
    if (score >= 50) return 'NEEDS ATTENTION';
    return 'CRITICAL';
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _GaugePainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    // Draw full circle track
    canvas.drawCircle(center, radius, trackPaint);

    // Draw progress arc starting from top (-pi / 2)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}
