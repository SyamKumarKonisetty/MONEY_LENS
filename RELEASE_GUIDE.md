# Release Guide

This step-by-step guide is for the Release Manager to successfully build, verify, and publish a new stable release of MoneyLens.

## 1. Pre-Release Steps
1.  **Code Freeze**: Ensure all features are merged to the `dev` branch.
2.  **Versioning**: Update the app version in `pubspec.yaml` (e.g. `version: 1.2.0+1`). Ensure the build number after the `+` is incremented.
3.  **Run Quality Checks**:
    ```bash
    flutter clean
    flutter pub get
    dart format .
    flutter analyze
    flutter test
    ```
    Do not proceed if any tests fail or there are analyzer errors.

---

## 2. Compiling the Builds
1.  Verify R8 obfuscation is enabled in Gradle rules.
2.  Compile the production Google Play App Bundle:
    ```bash
    flutter build appbundle
    ```

---

## 3. Play Store Upload & Staged Rollout
1.  Open the **Google Play Console** and navigate to your application.
2.  Select **Testing -> Closed testing** or **Production**.
3.  Upload the `.aab` file located at `build/app/outputs/bundle/release/app-release.aab`.
4.  Provide the Release Notes extracted from `CHANGELOG.md` for this version.
5.  Set up a **Staged Rollout**: Start with **10%** of active users to monitor for crash anomalies before scaling to **100%**.
