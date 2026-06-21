import '../metrics/metrics.dart';
import '../insights/insights.dart';


/// Supported financial report formats.
enum MLReportFormat { daily, weekly, monthly, csv }

/// Structured document containing periodic financial aggregations and summaries.
class MLFinancialReport {
  const MLFinancialReport({
    required this.id,
    required this.title,
    required this.format,
    required this.generatedAt,
    required this.metrics,
    required this.insights,
    required this.startDate,
    required this.endDate,
  });

  final String id;
  final String title;
  final MLReportFormat format;
  final DateTime generatedAt;
  final List<MLMetric> metrics;
  final List<MLInsight> insights;
  final DateTime startDate;
  final DateTime endDate;
}

/// Helper utility to export list of metrics and events into standard CSV formats.
class MLReportExporter {
  MLReportExporter._();

  /// Converts a report's metrics and metadata into a CSV format string.
  static String exportMetricsToCsv(List<MLMetric> metrics) {
    final buffer = StringBuffer();
    // Headers
    buffer.writeln('Label,Value,Priority');
    for (final metric in metrics) {
      final cleanLabel = metric.label.replaceAll('"', '""');
      final cleanVal = metric.formattedValue.replaceAll('"', '""');
      buffer.writeln('"$cleanLabel","$cleanVal","${metric.priority.name}"');
    }
    return buffer.toString();
  }
}
