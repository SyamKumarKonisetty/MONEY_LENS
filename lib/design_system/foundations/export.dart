/// Supported export formats in MLDS.
enum MLExportFormat { csv, pdf, excel, image, share }

/// Represents the status of an export action.
enum MLExportStatus { idle, preparing, writing, success, failed }

/// Config class defining the data contract for exporting financial logs.
class MLExportConfig {
  const MLExportConfig({
    required this.format,
    required this.fileName,
    this.includeBudgets = true,
    this.includeGoals = true,
    this.includeTransactions = true,
    this.customStartDate,
    this.customEndDate,
  });

  final MLExportFormat format;
  final String fileName;
  final bool includeBudgets;
  final bool includeGoals;
  final bool includeTransactions;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
}

/// Export engine interface detailing features to support.
abstract class MLExportResult {
  const MLExportResult({
    required this.config,
    required this.status,
    this.filePath,
    this.errorMessage,
  });

  final MLExportConfig config;
  final MLExportStatus status;
  final String? filePath;
  final String? errorMessage;
}
