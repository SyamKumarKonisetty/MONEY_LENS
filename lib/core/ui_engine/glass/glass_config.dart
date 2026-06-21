/// {@template glass_config}
/// Centralised configuration constants for the MoneyLens glass-morphism system.
///
/// All blur, opacity, and border values used across [GlassSurface], [GlassCard],
/// [GlassButton], [GlassDialog], and [GlassBottomSheet] are derived from these
/// constants so that the visual language can be tuned from a single source.
/// {@endtemplate}
library;

/// Configuration constants for the MoneyLens Glass System.
///
/// Import this file wherever a glass component needs access to default values.
class GlassConfig {
  GlassConfig._(); // Prevent instantiation.

  // ── Blur ─────────────────────────────────────────────────────────────────

  /// Extreme backdrop blur sigma applied to liquid glass surfaces.
  static const double blurSigma = 32.0;

  /// Heavy blur sigma used on scrim overlays (e.g. dialogs, bottom sheets).
  static const double scrimBlurSigma = 24.0;

  // ── Border & Edge ────────────────────────────────────────────────────────

  /// Width of the glass border stroke in logical pixels.
  static const double borderWidth = 1.0;

  /// Opacity of the standard border edge.
  static const double borderOpacity = 0.10;

  /// Opacity of the strong specular top-edge highlight.
  static const double edgeHighlightOpacity = 0.22;

  // ── Background & Noise ───────────────────────────────────────────────────

  /// Default background fill opacity for generic glass surfaces.
  static const double backgroundOpacity = 0.10;

  /// Background fill opacity used specifically for card surfaces.
  static const double cardOpacity = 0.15;

  /// Subtle colour tint overlay placed above the blur layer.
  static const double tintOpacity = 0.04;

  /// Opacity of the microscopic procedural noise layer.
  static const double noiseOpacity = 0.03;

  /// Opacity of the ambient blue glow surrounding the glass.
  static const double ambientGlowOpacity = 0.10;

  // ── Press Interaction & Animations ───────────────────────────────────────

  /// Scale factor applied to interactive glass surfaces on press.
  static const double cardPressScale = 0.95;

  /// Scale factor applied to glass buttons on press.
  static const double buttonPressScale = 0.92;

  /// Opacity factor applied to glass buttons on press.
  static const double buttonPressOpacity = 0.85;

  /// Duration for the continuous slow light sweep across glass surfaces.
  static const Duration sweepDuration = Duration(seconds: 8);

  // ── Geometry ──────────────────────────────────────────────────────────────

  /// Default border radius for glass cards.
  static const double defaultCardRadius = 24.0;

  /// Default border radius for glass buttons.
  static const double defaultButtonRadius = 999.0; // pill

  /// Default height for glass buttons (logical pixels).
  static const double buttonHeight = 52.0;
}
