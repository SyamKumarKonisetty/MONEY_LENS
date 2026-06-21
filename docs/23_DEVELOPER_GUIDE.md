# 23: Developer Guide

## Purpose
Onboarding instructions for new engineers to run the MoneyLens project locally.

## Prerequisites
- Flutter SDK `^3.12.2`
- Android Studio / Xcode
- Git

## 1. Clone & Install
```bash
git clone <repository_url>
cd MONEY_LENS
flutter pub get
```

## 2. Code Generation (Drift & Riverpod)
MoneyLens relies heavily on code generation for the database layer and state management. You must run the build runner before the app will compile.
```bash
dart run build_runner build --delete-conflicting-outputs
```
*Note: If you make changes to a `.g.dart` dependency, run the command again.*

## 3. Run Development Build
```bash
flutter run
```

## 4. Run Tests
```bash
flutter test
```

## Troubleshooting
- **Missing `*.g.dart` errors**: Run the `build_runner` command.
- **Podfile errors (iOS)**: Run `cd ios && pod install && cd ..`
- **SMS Permission denied**: Ensure you are testing on a physical Android device, as iOS simulators and standard Android emulators do not handle SMS intents cleanly.
