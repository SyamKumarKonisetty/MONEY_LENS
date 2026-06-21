# MoneyLens
**Premium Personal Finance Companion**

MoneyLens is a meticulously designed, privacy-first personal finance application that helps you track expenses, visualize your budget, and achieve your financial goals—all completely offline.

## Features
- **Premium Glassmorphism UI**: Beautiful, fluid, 60fps animations.
- **100% Offline & Private**: Zero data collection, no cloud syncing requirements. Your data stays on your device.
- **Smart SMS Detection**: Automatically detects and categorizes transactions from bank SMS alerts (Android only).
- **Intelligent Insights**: Dynamic visual charts forecasting your spending trajectory.
- **Export & Backup**: Native PDF and CSV generation with secure local file sharing.

## Build Requirements
- Flutter SDK `^3.12.2`
- Android Studio / Xcode

## Compilation (Production)
```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

## Security & Privacy
MoneyLens utilizes local SQLite via Drift and Sandboxed application storage. We do not transmit logs, analytics, or transaction data externally.

## License
Copyright © 2026. All rights reserved.
