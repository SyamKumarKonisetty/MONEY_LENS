# 19: Dependencies

## Purpose
To track all external packages utilized in MoneyLens, justifying their existence to prevent bloat.

## Core Packages
| Package | Version | Purpose | Why not Native? |
|---------|---------|---------|-----------------|
| `flutter_riverpod` | `^2.6.1` | State Management | `InheritedWidget` is too boilerplate-heavy. |
| `go_router` | `^14.6.2` | Navigation | Required for robust deep-linking and guards. |
| `drift` | `^2.26.1` | SQLite ORM | Raw `sqflite` lacks type safety and stream support. |

## Utility Packages
- `fl_chart`: Industry standard for complex data visualizations.
- `intl`: Required for currency formatting and date-time localization.
- `shared_preferences`: Lightweight key-value storage for theme and PIN.
- `crypto`: SHA-256 hashing for PIN validation.

## Native Integration
- `permission_handler`: Requests runtime SMS permissions from Android.
- `share_plus`: Triggers native OS share sheets for Export functions.
- `path_provider`: Locates the secure document directories across iOS/Android.

## Code Generation (Dev Only)
- `build_runner`, `drift_dev`: Generates the boilerplate SQL database mapping.
