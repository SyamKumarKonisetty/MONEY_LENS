import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';
import 'primary_button.dart';

/// A premium, animated Empty State view with radial glow highlights and a CTA button.
class EmptyState extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? accentColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.accentColor,
  });

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = widget.accentColor ?? AppColors.primary;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Radial Glow Pulsing Icon
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final double currentSize = 72 + 8 * _animation.value;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: currentSize + 16,
                        height: currentSize + 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withValues(alpha: 0.04 + 0.03 * _animation.value),
                        ),
                      ),
                      Container(
                        width: currentSize,
                        height: currentSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withValues(alpha: 0.08),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.15),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          widget.icon,
                          color: accent,
                          size: 28,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Title
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: AppTypography.headline.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              // Subtitle
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: AppTypography.subtitle.copyWith(
                  height: 1.5,
                ),
              ),

              // Action CTA button
              if (widget.actionLabel != null && widget.onAction != null) ...[
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: widget.actionLabel!,
                  onTap: widget.onAction,
                  height: 44,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
