# 24: Release Guide

## Purpose
To provide the exact technical sequence required to cut a production release of MoneyLens.

## 1. Version Bump
1. Open `pubspec.yaml`.
2. Increment the version number according to Semantic Versioning (e.g., `1.2.0+1` -> `1.2.1+2`).
3. The number after the `+` is the `versionCode` for Google Play. It must ALWAYS increase.

## 2. QA Sanity Check
- Run `dart fix --apply` and `flutter analyze` ensuring 0 warnings.
- Execute the Manual Checklist in [17_TESTING.md](17_TESTING.md).

## 3. Generate AppBundle (AAB)
The AppBundle is required for Google Play as it optimizes downloads per device.
```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

## 4. Universal APK (Optional, for GitHub Releases)
```bash
flutter build apk --release --split-per-abi
```

## 5. Deployment
- Log into Google Play Console.
- Navigate to Production -> Create New Release.
- Upload the `.aab` file from `build/app/outputs/bundle/release/app-release.aab`.
- Paste the `release_notes.md` into the What's New section.
- Rollout to 100%.
