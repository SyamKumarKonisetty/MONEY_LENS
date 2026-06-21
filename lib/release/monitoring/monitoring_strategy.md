# Production Monitoring Strategy

This document outlines the architecture for integrating crash monitoring and performance diagnostics in MoneyLens V2, keeping user privacy at the core of all implementations.

## 1. Privacy-First Monitoring Principles

1.  **Opt-In Consent**: Monitoring services are disabled by default. Telemetry, error reports, and crash logs may only be sent after explicit user consent is configured under Settings.
2.  **No PII or Financial Data**: All print logs, breadcrumbs, and variables must be sanitized. Under no circumstances should the local SQLite database entries, user profile names, SMS content, or PIN hashes be included in crash logs.
3.  **Local Redaction**: Any logging strings must filter through `MLSensitiveDataFilter` to mask sensitive transaction metrics before transmitting to external servers.

---

## 2. Integration Architectures (Future Implementations)

The app is prepared for the following optional service hooks:

### A. Sentry SDK (Recommended for Dart & Native Crash Logging)
- **Integration**:
    ```dart
    import 'package:sentry_flutter/sentry_flutter.dart';
    
    Future<void> initSentry(VoidCallback appRunner) async {
      await SentryFlutter.init(
        (options) {
          options.dsn = 'https://examplePublicKey@o0.ingest.sentry.io/0';
          options.tracesSampleRate = 0.1; // Capture 10% of transactions for performance monitoring
          options.beforeSend = (event, {hint}) {
            // Apply MLSensitiveDataFilter to event details and breadcrumbs
            return event;
          };
        },
        appRunner: appRunner,
      );
    }
    ```

### B. Firebase Crashlytics (Recommended for Android Native Crash Logs)
- **Integration**:
    - Add Firebase plugins in Gradle scripts.
    - Capture uncaught Flutter errors reactively:
    ```dart
    FlutterError.onError = (errorDetails) {
      if (userConsentEnabled) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      }
    };
    ```
