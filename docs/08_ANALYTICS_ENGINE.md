# 08: Analytics Engine

## Purpose
To compute and format aggregate financial data for visual display in the Analytics and Dashboard tabs.

## Overview
The Analytics Engine is purely mathematical. It resides in the Business Logic layer and relies on complex Riverpod providers to reduce `List<Transaction>` into actionable data structures.

## Core Computations

### 1. Monthly Aggregation
Groups transactions using `intl` date formatting to generate monthly summaries. Used for the primary charts.

### 2. Category Velocity
Calculates `(Category Spend / Category Budget) * 100`. The result dictates the fill percentage and color logic of the `GradientProgressBar` (Green -> Yellow -> Red).

### 3. Forecast Formula
Projects end-of-month spend based on the current run rate:
`Projected = (Current Spend / Current Day of Month) * Total Days in Month`

## Dependencies
- `fl_chart`: For drawing Bezier curves and pie segments.
- `intl`: For date manipulation and grouping logic.

## Future Improvements
- Heatmap calendars for spending frequency.
- Outlier detection (highlighting transactions that deviate > 2 Std Dev from the categorical mean).
