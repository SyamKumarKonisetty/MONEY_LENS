import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../auth/presentation/change_pin_sheet.dart';
import '../../providers/settings_provider.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/ui_engine/glass/glass_card.dart';

class SecurityCenter extends ConsumerStatefulWidget {
  const SecurityCenter({super.key});

  @override
  ConsumerState<SecurityCenter> createState() => _SecurityCenterState();
}

class _SecurityCenterState extends ConsumerState<SecurityCenter> {

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(sharedPreferencesProvider);

    final hasPin = prefs.getString('auth_pin') != null;

    int scorePct = 50;
    if (hasPin) scorePct = 100;

    final scoreColor = scorePct >= 80
        ? context.successColor
        : (scorePct >= 65 ? Colors.orange : context.errorColor);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: GlassCard(
        isInteractive: false,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CustomPaint(
                    painter: _SecurityScorePainter(
                      score: scorePct / 100.0,
                      color: scoreColor,
                    ),
                    child: Center(
                      child: Text(
                        '$scorePct%',
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Security Shield',
                        style: AppTypography.titleMedium.copyWith(
                          color: context.textPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        scorePct >= 80 ? 'Your vault is fully secure' : 'Complete setup to increase score',
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Divider(height: 1, color: context.separatorColor.withValues(alpha: 0.3)),
            const SizedBox(height: AppSpacing.md),

            // Passcode PIN Config
            _tile(
              icon: Icons.lock_outline_rounded,
              title: 'Change Passcode PIN',
              subtitle: hasPin ? '4-digit PIN is active' : 'Setup security PIN',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  useRootNavigator: true,
                  builder: (_) => const ChangePinSheet(),
                ).then((_) => setState(() {}));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(icon, color: context.textSecondaryColor, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing else const Icon(Icons.chevron_right_rounded, size: 16),
          ],
        ),
      ),
    );
  }




}

class _SecurityScorePainter extends CustomPainter {
  final double score;
  final Color color;

  _SecurityScorePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.570796, // -pi / 2
      score * 6.283185, // score * 2 * pi
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SecurityScorePainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.color != color;
  }
}
