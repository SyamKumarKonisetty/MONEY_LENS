# 09: UI Engine

## Purpose
To define the low-level custom widget rendering primitives that replace standard Flutter Material components.

## Overview
Found in `lib/core/ui_engine/`, this framework dictates the entire visual identity of MoneyLens. It enforces glassmorphism and custom progress indicators over generic Material design.

## Sub-Engines
- **Glass Engine**: `GlassSurface`, `GlassCard`. Utilizes `BackdropFilter` and `ImageFilter.blur`.
- **Motion Engine**: `PressScale`, `StaggerList`. Handles all micro-interactions.
- **Progress Engine**: `MLSpinner`, `GradientProgressBar`, `LiquidProgressRing`.
- **Number Engine**: `AnimatedNumber`, `CounterText`. Smooth slot-machine rolling digits for balances.

## Rules
- **NEVER** use `Card`, `CircularProgressIndicator`, or `LinearProgressIndicator`.
- **ALWAYS** use `GlassCard`, `MLSpinner`, and `GradientProgressBar`.

## Performance Considerations
UI Engine primitives generating high-frequency layout changes (like the Number Engine) are explicitly wrapped in `RepaintBoundary` to prevent entire screen repaints.
