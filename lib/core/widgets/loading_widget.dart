import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Shimmer loading skeleton widget.
///
/// Used as a placeholder while content is loading.
/// Provides premium loading feedback instead of a spinner.
class LoadingWidget extends StatefulWidget {
  const LoadingWidget({super.key});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(
      begin: -1.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonBlock(animation: _animation, height: 180),
          const SizedBox(height: AppSpacing.cardGap),
          Row(
            children: [
              Expanded(
                child: _SkeletonBlock(animation: _animation, height: 90),
              ),
              const SizedBox(width: AppSpacing.cardGap),
              Expanded(
                child: _SkeletonBlock(animation: _animation, height: 90),
              ),
              const SizedBox(width: AppSpacing.cardGap),
              Expanded(
                child: _SkeletonBlock(animation: _animation, height: 90),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          _SkeletonBlock(
            animation: _animation,
            height: 20,
            borderRadius: AppRadius.circularSm,
          ),
          const SizedBox(height: AppSpacing.xl),
          for (int i = 0; i < 5; i++) ...[
            _SkeletonListTile(animation: _animation),
            const SizedBox(height: AppSpacing.cardGap),
          ],
        ],
      ),
    );
  }
}

/// Individual skeleton block for shimmer effect.
class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({
    required this.animation,
    required this.height,
    this.width = double.infinity,
    this.borderRadius,
  });

  final Animation<double> animation;
  final double height;
  final double width;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final highlightColor = isDark
        ? AppColors.surfaceVariantDark
        : const Color(0xFFE8E8ED);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => ClipRRect(
        borderRadius: borderRadius ?? AppRadius.card,
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + animation.value, 0),
              end: Alignment(animation.value, 0),
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.1, 0.5, 0.9],
            ),
          ),
        ),
      ),
    );
  }
}

/// Skeleton list tile.
class _SkeletonListTile extends StatelessWidget {
  const _SkeletonListTile({required this.animation});
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SkeletonBlock(
          animation: animation,
          height: 48,
          width: 48,
          borderRadius: BorderRadius.circular(12),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SkeletonBlock(
                animation: animation,
                height: 14,
                borderRadius: AppRadius.circularSm,
              ),
              const SizedBox(height: 6),
              _SkeletonBlock(
                animation: animation,
                height: 11,
                width: 120,
                borderRadius: AppRadius.circularSm,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        _SkeletonBlock(
          animation: animation,
          height: 16,
          width: 64,
          borderRadius: AppRadius.circularSm,
        ),
      ],
    );
  }
}
