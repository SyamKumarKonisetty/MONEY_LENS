import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design/design_system.dart';

// ─────────────────────────────────────────────
// Enums & model
// ─────────────────────────────────────────────

/// Preset illustration themes for [EmptyStateView].
enum EmptyStateTheme {
  /// No transactions found — wallet illustration.
  wallet,

  /// No chart data — chart illustration.
  chart,

  /// No search results — magnifier illustration.
  search,
}

// ─────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────

/// A beautiful animated empty-state view with theme-based illustrations.
///
/// The illustration floats on a loop (translateY 0 → −8 → 0) using a
/// [RepeatableAnimation]. Supports three preset themes: [EmptyStateTheme.wallet],
/// [EmptyStateTheme.chart], and [EmptyStateTheme.search].
///
/// Usage:
/// ```dart
/// EmptyStateView(
///   theme: EmptyStateTheme.wallet,
///   title: 'No Transactions',
///   subtitle: 'Add your first transaction to get started.',
///   actionLabel: 'Add Transaction',
///   onAction: () {},
/// )
/// ```
class EmptyStateView extends StatefulWidget {
  /// Creates an [EmptyStateView].
  const EmptyStateView({
    super.key,
    required this.theme,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.illustrationSize = 160.0,
  });

  /// Preset illustration theme.
  final EmptyStateTheme theme;

  /// Bold title text.
  final String title;

  /// Descriptive subtitle text.
  final String subtitle;

  /// Label for the optional CTA button.
  final String? actionLabel;

  /// Callback for the CTA button.
  final VoidCallback? onAction;

  /// Size of the illustration box.
  final double illustrationSize;

  @override
  State<EmptyStateView> createState() => _EmptyStateViewState();
}

class _EmptyStateViewState extends State<EmptyStateView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _floatAnim,
                builder: (_, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatAnim.value),
                    child: child,
                  );
                },
                child: SizedBox(
                  width: widget.illustrationSize,
                  height: widget.illustrationSize,
                  child: CustomPaint(
                    painter: _IllustrationPainter(theme: widget.theme),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Title
            Text(
              widget.title,
              style: AppTypography.title.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.xs),

            // Subtitle
            Text(
              widget.subtitle,
              style: AppTypography.subtitle.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            if (widget.actionLabel != null && widget.onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              _ActionButton(
                label: widget.actionLabel!,
                onTap: widget.onAction!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CTA button
// ─────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.pillVal),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          label,
          style: AppTypography.button.copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Illustration painter
// ─────────────────────────────────────────────

class _IllustrationPainter extends CustomPainter {
  const _IllustrationPainter({required this.theme});

  final EmptyStateTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    switch (theme) {
      case EmptyStateTheme.wallet:
        _paintWallet(canvas, size);
      case EmptyStateTheme.chart:
        _paintChart(canvas, size);
      case EmptyStateTheme.search:
        _paintSearch(canvas, size);
    }
  }

  // ── Wallet illustration ───────────────────

  void _paintWallet(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Background glow ring
    _drawGlowCircle(canvas, Offset(cx, cy), 70, AppColors.primary, 0.12);
    _drawGlowCircle(canvas, Offset(cx, cy), 52, AppColors.primary, 0.08);

    // Wallet body
    final walletPaint = Paint()
      ..color = AppColors.card
      ..style = PaintingStyle.fill;
    final walletRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 8), width: 80, height: 56),
      const Radius.circular(14),
    );
    canvas.drawRRect(walletRect, walletPaint);

    // Wallet flap
    final flapPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 40, cy - 16, 80, 26),
        const Radius.circular(14),
      ),
      flapPaint,
    );

    // Coin slot
    final slotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 14, cy + 2, 22, 14),
        const Radius.circular(7),
      ),
      slotPaint,
    );

    // Coin dot
    canvas.drawCircle(
      Offset(cx + 25, cy + 9),
      5,
      Paint()..color = AppColors.primaryLight.withValues(alpha: 0.8),
    );

    // Floating coins
    _drawCoin(canvas, Offset(cx - 44, cy - 28), 10, AppColors.warning);
    _drawCoin(canvas, Offset(cx + 46, cy - 22), 7, AppColors.income);
    _drawCoin(canvas, Offset(cx - 30, cy + 44), 6, AppColors.primaryLight);

    // Dots
    _drawDots(canvas, size);
  }

  void _drawCoin(Canvas canvas, Offset center, double r, Color color) {
    canvas.drawCircle(center, r,
        Paint()..color = color.withValues(alpha: 0.7));
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  // ── Chart illustration ────────────────────

  void _paintChart(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    _drawGlowCircle(canvas, Offset(cx, cy), 70, AppColors.categoryFood, 0.10);

    final colors = [
      AppColors.categoryFood,
      AppColors.categoryTransport,
      AppColors.categoryHealthcare,
      AppColors.categoryEntertainment,
    ];
    final heights = [55.0, 80.0, 40.0, 65.0];
    const barW = 18.0;
    const spacing = 10.0;
    final totalW = colors.length * barW + (colors.length - 1) * spacing;
    double x = cx - totalW / 2;

    for (int i = 0; i < colors.length; i++) {
      final h = heights[i];
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, cy + 28 - h, barW, h),
        topLeft: const Radius.circular(5),
        topRight: const Radius.circular(5),
      );
      canvas.drawRRect(
        rect,
        Paint()..color = colors[i].withValues(alpha: 0.85),
      );
      x += barW + spacing;
    }

    // X axis
    canvas.drawLine(
      Offset(cx - totalW / 2 - 6, cy + 28),
      Offset(cx + totalW / 2 + 6, cy + 28),
      Paint()
        ..color = AppColors.divider
        ..strokeWidth = 1.5,
    );

    // Trend line
    final linePaint = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(cx - 44, cy - 12)
      ..quadraticBezierTo(cx - 10, cy - 40, cx + 8, cy - 22)
      ..quadraticBezierTo(cx + 30, cy - 5, cx + 44, cy - 30);
    canvas.drawPath(path, linePaint);
    canvas.drawCircle(
      Offset(cx + 44, cy - 30),
      4,
      Paint()..color = AppColors.primaryLight,
    );

    _drawDots(canvas, size);
  }

  // ── Search illustration ───────────────────

  void _paintSearch(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    _drawGlowCircle(canvas, Offset(cx - 8, cy - 8), 68, AppColors.warning, 0.10);

    // Magnifier circle
    final circlePaint = Paint()
      ..color = AppColors.card
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - 10, cy - 10), 44, circlePaint);

    final ringPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(cx - 10, cy - 10), 36, ringPaint);

    // Handle
    canvas.drawLine(
      Offset(cx - 10 + 36 * math.cos(math.pi * 0.75),
          cy - 10 + 36 * math.sin(math.pi * 0.75)),
      Offset(cx + 32, cy + 32),
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.8)
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );

    // Inner lines (no results)
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(cx - 28, cy - 18 + i * 12.0),
        Offset(cx + 8, cy - 18 + i * 12.0),
        Paint()
          ..color = AppColors.divider.withValues(alpha: 0.8)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }

    _drawDots(canvas, size);
  }

  // ── Shared helpers ────────────────────────

  void _drawGlowCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double alpha,
  ) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );
  }

  void _drawDots(Canvas canvas, Size size) {
    final positions = [
      Offset(size.width * 0.1, size.height * 0.2),
      Offset(size.width * 0.88, size.height * 0.15),
      Offset(size.width * 0.82, size.height * 0.78),
      Offset(size.width * 0.14, size.height * 0.82),
    ];
    for (final pos in positions) {
      canvas.drawCircle(
        pos,
        3,
        Paint()..color = AppColors.divider.withValues(alpha: 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(_IllustrationPainter old) => old.theme != theme;
}
