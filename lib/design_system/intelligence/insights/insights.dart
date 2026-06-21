/// Severity levels for financial insights.
enum MLInsightSeverity { info, success, warning, critical }

/// Extensible categories of insights supported by the framework.
enum MLInsightType {
  highestExpense,
  topMerchant,
  weekendSpending,
  budgetRisk,
  savingsOpportunity,
  cashFlowHealth,
  subscriptionDetection,
  categoryGrowth,
  overspendingWarning,
  positiveProgress,
  achievement,
  upcomingSalary,
  recurringBills,
}

/// Data contract representing a generated insight.
class MLInsight {
  const MLInsight({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    required this.timestamp,
    this.contextualTags = const [],
    this.metadata = const {},
  });

  final String id;
  final MLInsightType type;
  final MLInsightSeverity severity;
  final String title;
  final String message;
  final DateTime timestamp;
  final List<String> contextualTags;
  final Map<String, dynamic> metadata;

  /// Serializes the insight to a JSON structure for future AI/API sync compatibility.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'severity': severity.name,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'contextualTags': contextualTags,
      'metadata': metadata,
    };
  }

  /// Deserializes an insight from a JSON payload.
  factory MLInsight.fromJson(Map<String, dynamic> json) {
    return MLInsight(
      id: json['id'] as String,
      type: MLInsightType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => MLInsightType.highestExpense,
      ),
      severity: MLInsightSeverity.values.firstWhere(
        (s) => s.name == json['severity'],
        orElse: () => MLInsightSeverity.info,
      ),
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      contextualTags: List<String>.from(json['contextualTags'] as List? ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }
}
