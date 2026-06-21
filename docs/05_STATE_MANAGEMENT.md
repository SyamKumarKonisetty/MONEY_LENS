# 05: State Management

## Purpose
To outline the state management paradigm driving MoneyLens, heavily leveraging `flutter_riverpod`.

## Overview
Riverpod ensures compile-time safety and prevents memory leaks common with older Provider paradigms. It completely replaces `StatefulWidget` in complex screens.

## Architecture

![Provider Flow](diagrams/provider_flow.mmd)

### 1. Global Providers (`lib/core/providers`)
Providers that orchestrate global configurations, like `sharedPreferencesProvider` or `databaseProvider`.

### 2. Async Notifiers
Used when loading data from the database.
```dart
@riverpod
class Transactions extends _$Transactions {
  @override
  FutureOr<List<Transaction>> build() async {
    return await ref.watch(transactionRepositoryProvider).getAll();
  }
}
```

### 3. Synchronous Notifiers
Used for immediate UI state, like `ThemeMode`.

## Lifecycle Management
- Providers utilizing `.autoDispose` automatically clear memory when the user navigates away from a screen, keeping RAM usage low.
- `keepAlive` is used for the core Dashboard providers to ensure rapid multi-tab navigation without rebuilding local databases.

## Best Practices
- Define providers globally in the file they are used, or in a dedicated `providers.dart` file for features.
- Avoid modifying state outside of the Notifier's internal methods.
- Use `ref.listen` for executing side effects like SnackBar notifications or Dialogs when state transitions to an Error.
