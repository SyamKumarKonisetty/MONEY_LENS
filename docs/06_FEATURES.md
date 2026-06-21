# 06: Features

## Purpose
A comprehensive breakdown of all features shipped in MoneyLens Version 1.2.0.

## 1. Authentication (PIN)
- **Workflow**: Sets a hashed PIN in SharedPreferences. Gates access using GoRouter's redirection logic. Includes a recovery mechanism based on a local security question.

## 2. Dashboard
- **Workflow**: Renders an immediate snapshot of the user's financial health. Displays the Hero Balance widget (AnimatedNumber), recent transactions, and Quick Actions.

## 3. Transactions List
- **Workflow**: A lazy-loading, paginated (implicitly via Drift constraints) list of all transactions, grouped by month/day headers.

## 4. Analytics
- **Workflow**: Aggregates categorical spending into a visual ring (LiquidProgressRing). Compares monthly spend velocity against previous periods.

## 5. Settings
- **Workflow**: Manages theme preferences, PIN reset, and export/backup functions.

## 6. Inbox & Smart Detection
- **Workflow**: Catches incoming SMS, validates them, and pushes them to a review queue. Prevents the database from filling up with false positives or spam by requiring a single tap "Approve".

## Future Features
- Budget Overviews (Dynamic pacing).
- Split Transactions.
- Subscription Tracking.
