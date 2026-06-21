// MoneyLens UI Experience Engine — Master Barrel File
//
// Import this single file to access every premium UI component:
// ```dart
// import 'package:money_lens/core/ui_engine/ui_engine.dart';
// // or relative:
// import '../core/ui_engine/ui_engine.dart';
// ```
// ─── Glass System ─────────────────────────────────────────────────────────────
// Blur, transparency, soft borders, gradient reflections.
export 'glass/glass_config.dart';
export 'glass/glass_surface.dart';
export 'glass/glass_card.dart';
export 'glass/glass_button.dart';
export 'glass/glass_dialog.dart';
export 'glass/glass_bottom_sheet.dart';
export 'glass/glass_search.dart';
export 'glass/glass_fab.dart';
export 'glass/glass_chip.dart';
export 'glass/glass_navigation.dart';

// ─── Motion System ────────────────────────────────────────────────────────────
// Durations, curves, press-scale wrapper, stagger lists, page transitions.
export 'motion/motion_constants.dart';
export 'motion/press_scale.dart';
export 'motion/stagger_list.dart';
export 'motion/page_transition.dart';

// ─── Progress Engine ──────────────────────────────────────────────────────────
// Custom progress indicators — no LinearProgressIndicator anywhere.
export 'progress/liquid_progress_ring.dart';
export 'progress/gradient_progress_bar.dart';
export 'progress/breathing_glow.dart';
export 'progress/ml_spinner.dart';

// ─── Number Engine ────────────────────────────────────────────────────────────
// Animated money counters, digit rollers, rise/fall particles.
export 'numbers/animated_number.dart';
export 'numbers/counter_text.dart';

// ─── Card Engine ──────────────────────────────────────────────────────────────
// Floating depth cards, animated gradient borders, parallax gesture cards.
export 'cards/floating_card.dart';
export 'cards/gradient_border_card.dart';
export 'cards/parallax_card.dart';

// ─── Lighting Engine ──────────────────────────────────────────────────────────
// Reactive light spots, soft glow containers, pulsing indicators.
export 'lighting/soft_light.dart';
export 'lighting/glow_container.dart';

// ─── Chart Engine ─────────────────────────────────────────────────────────────
// Custom animated charts — pure CustomPainter, no fl_chart dependency.
export 'charts/animated_pie_chart.dart';
export 'charts/animated_bar_chart.dart';
export 'charts/spending_ring.dart';

// ─── Navigation Engine ────────────────────────────────────────────────────────
// Glass floating nav bar, macOS-dock magnification tray.
export 'navigation/glass_nav_bar.dart';
export 'navigation/floating_dock.dart';

// ─── Floating Action System ───────────────────────────────────────────────────
// Glass radial expandable FAB replacing Material FloatingActionButton.
export 'fab/glass_fab.dart';

// ─── Empty State Engine ───────────────────────────────────────────────────────
// Animated illustrated empty states with floating illustration loop.
export 'empty_states/empty_state_view.dart';

// ─── Micro-Interaction Engine ─────────────────────────────────────────────────
// Delete ripple, success pulse rings, income rise particle.
export 'micro_interactions/delete_ripple.dart';
export 'micro_interactions/success_pulse.dart';
export 'micro_interactions/income_rise.dart';
