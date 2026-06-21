# 18: Performance

## Purpose
To document the benchmarks and optimization strategies utilized to keep MoneyLens running at a smooth 60 FPS.

## Overview
A premium UI requires pristine performance. Dropped frames destroy the illusion of quality.

## Optimization Strategies

### 1. RepaintBoundary
The `AnimatedNumber` (used in the Hero Balance) updates 60 times a second. By wrapping it in a `RepaintBoundary`, we prevent the entire Dashboard widget tree from recalculating its layout.

### 2. ListView.builder
The Transactions tab uses `ListView.builder` exclusively to lazily instantiate list items only when they scroll into view.

### 3. Asynchronous Database Initialization
Drift queries are dispatched asynchronously. The UI shows a skeleton loader (`LoadingView`) while awaiting the `FutureOr`, ensuring the main isolate is never blocked.

### 4. R8 Minification
The Android `build.gradle.kts` uses `isMinifyEnabled = true` to strip unused code, drastically reducing memory footprint and APK size.

## Benchmarks
- **Target FPS**: 60
- **App Bundle Size Target**: < 40 MB
- **Perceived Startup Time Target**: < 1.0 second.
