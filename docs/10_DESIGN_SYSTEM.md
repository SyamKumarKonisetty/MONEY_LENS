# 10: Design System

## Purpose
To define the high-level layout composition and aesthetic tokens used across MoneyLens.

## Overview
While the UI Engine provides the primitive "bricks" (like `GlassCard`), the Design System (`lib/design_system/`) provides the "buildings" (like `InsightsComponents`, `FinancialCharts`).

## Tokens (`AppColors`, `AppTypography`)
- **Colors**: Strict adherence to HSL-calculated palettes. Pure white and pure black are avoided in favor of tinted deep colors (e.g. `Color(0xFF1677FF)` for Primary).
- **Typography**: Handled globally. Usually defaults to Google Fonts `Inter` or `Outfit`.

## Layout Widgets
- `PrimaryButton`: Full width, premium interaction.
- `LoadingView`: Full screen blurred loading skeleton.
- `DangerButton`: Red-tinted glass button for destructive actions.

## Rules
Feature developers should never define raw Colors in their UI code. All colors must be read from `context.theme.primaryColor` or the `AppColors` token repository.
