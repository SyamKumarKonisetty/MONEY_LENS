/// Supported deployment environments.
enum MLEnvironment { development, staging, production }

/// System managing release pipelines, active environments, and feature flags.
class MLReleasePipeline {
  MLReleasePipeline._();

  /// The active environment targeting production release.
  static const MLEnvironment environment = MLEnvironment.production;

  /// Determines whether log printing is enabled. Redacted in production.
  static bool get enableLogging => environment != MLEnvironment.production;

  /// Feature flag: Auto-parsing SMS inbox events.
  static const bool enableSmsInboxAutomation = true;

  /// Feature flag: Local CSV import and export.
  static const bool enableCsvBackupFeature = true;

  /// Feature flag: Future AI insight generators.
  static const bool enableAiNarratives = false;
}
