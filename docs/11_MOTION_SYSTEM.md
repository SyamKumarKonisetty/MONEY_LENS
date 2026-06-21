# 11: Motion System

## Purpose
To document the animation philosophy and standards that make MoneyLens feel alive and responsive.

## Overview
Motion is not an afterthought in MoneyLens; it communicates hierarchy and state.

## Constants
Found in `AppAnimations` and `MotionConstants`:
- **Micro**: `80ms`. Used for immediate tap feedback.
- **Fast**: `200ms`. Used for button scale down.
- **Normal**: `300ms`. Standard layout transitions.
- **Slow**: `500ms`. Complex hero animations.

## Curves
- `Curves.easeOutBack`: The standard "Spring" curve used for button presses to simulate physical tactile feedback.
- `Curves.easeOutCubic`: Used for smooth sliding transitions.

## Interaction Philosophy
Every interactive element must respond to touch. Standard buttons are wrapped in `AnimatedButton` or `PressScale`, which scales the widget down to `0.95` on `TapDown` and triggers a `HapticFeedback.lightImpact()`.
