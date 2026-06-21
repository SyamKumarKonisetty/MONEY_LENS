# Deployment Guide

This guide details the release deployment steps, environment variables, signing setup, and artifact generation.

## 1. Android Release Signing Configuration

To build a secure release APK or Android App Bundle (AAB), compile with signing configs:

1.  **Generate Upload Keystore**:
    If you don't have a keystore, generate one using `keytool`:
    ```bash
    keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
    ```
2.  **Configure Environment Variables**:
    Store variables securely in a non-committed file `android/key.properties`:
    ```properties
    storePassword=YOUR_KEYSTORE_PASSWORD
    keyPassword=YOUR_KEY_PASSWORD
    keyAlias=upload
    storeFile=upload-keystore.jks
    ```
3.  **Update Gradle Build Configuration**:
    In `/Users/vamshikatari/Documents/SYAM/MONEY_LENS/android/app/build.gradle.kts`, load these keys and configure `signingConfigs.release`.

---

## 2. Compiling Release Artifacts

Always run clean builds when compile flags change:

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Build APK (for local/adhoc distribution)
```bash
flutter build apk --release
```
The compiled output is saved at `build/app/outputs/flutter-apk/app-release.apk`.

### Build App Bundle (AAB, for Google Play Console submission)
```bash
flutter build appbundle
```
The compiled output is saved at `build/app/outputs/bundle/release/app-release.aab`.
