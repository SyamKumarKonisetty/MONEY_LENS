# 16: Play Store

## Purpose
To document the process of preparing and releasing MoneyLens to the Google Play Store.

## Overview
Releasing requires strict adherence to Android's Data Safety and permission declarations.

## Assets
- **Launcher Icon**: Adaptive icon generated using `flutter_launcher_icons`. Resides in `assets/icon/app_icon.png`.
- **Feature Graphic**: Required 1024x500 banner for the store listing.
- **Screenshots**: High-fidelity renderings of the Dashboard, Insights, and Inbox.

## Data Safety
MoneyLens claims **Zero Data Collection**. Because the SQLite database and SharedPreferences remain strictly local, the Play Store Data Safety form requires no declarations of data sharing.

## Permissions
The `AndroidManifest.xml` declares:
- `RECEIVE_SMS`
- `READ_SMS`
Because these are sensitive permissions, the Play Store review requires a core-feature justification. The "Automated Expense Tracking" justification is provided in the console.

## Release Checklist
See [24_RELEASE_GUIDE.md](24_RELEASE_GUIDE.md) for the exact CLI commands required to generate the App Bundle.
