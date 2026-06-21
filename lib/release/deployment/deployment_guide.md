# Deployment and Release Pipeline Guide

This guide outlines the production deployment stages, build parameters, and validation pipelines for releasing MoneyLens to Google Play.

## 1. Release Architecture & Stages

```
[ Development ] ──(Build Verification)──> [ Internal Testing ]
                                                   │
                                            (QA Certification)
                                                   ▼
[ Production Release ] <──(Open Rollout)── [ Closed Testing ]
```

### Stage 1: Development
- **Purpose**: Local code changes, feature branches, and test executions.
- **Builds**: Debug and Profile configurations (`flutter run`, `flutter run --profile`).
- **Signing**: Done automatically with the debug keystore.
- **Triggers**: Static checks (`flutter analyze`), unit and widget tests (`flutter test`).

### Stage 2: Internal Testing
- **Purpose**: Shared with internal developers and design team members (max 100 testers).
- **Format**: Android App Bundle (AAB) uploaded to Google Play Console.
- **Verification**: Fast feedback on installation, launch, haptics, and basic UI interaction.

### Stage 3: Closed Testing (Alpha/Beta)
- **Purpose**: Release to a larger, closed list of trusted beta testers.
- **Format**: Google Play App Bundle (AAB).
- **Verification**: Verifying SQLite migrations, permission denials, low memory behaviors, and crash stability reports.

### Stage 4: Open Testing / Production
- **Purpose**: Public release on the Google Play Store.
- **Rollout**: Staged rollout starting at 10%, scaling to 50%, and then 100% after monitoring crash reports.

---

## 2. Play Store Release Checklist

Before compiling and uploading any build to the Google Play Console, verify:

1.  **Version Configuration** (`pubspec.yaml`):
    - Increment `versionCode` (integer, e.g., `2`) for every new build submission.
    - Match `versionName` (semantic version string, e.g., `1.2.0`) with release milestones.
2.  **App Signature**:
    - Build signing must use the secure production upload keystore configured in `android/key.properties` (do not commit this keystore or password file to git).
3.  **ProGuard / R8 Verification**:
    - Ensure R8 code optimization is enabled in `android/app/build.gradle.kts` (`isMinifyEnabled = true`, `isShrinkResources = true`).
4.  **Target API Compliance**:
    - Target SDK must match the latest Google Play requirement (Target SDK 36, Compile SDK 36).
