/// Semantic types of insights supported by the MLDS Insight Engine.
library;

enum MLInsightType {
  highestExpense,
  mostFrequentMerchant,
  weekendSpending,
  dailyAverage,
  topCategory,
  budgetRisk,
  cashFlowTrend,
  savingsTrend,
  monthlyHabit,
  recurringPayment,
  unexpectedSpending,
  positiveProgress,
}

/// Severity level of the generated insight.
enum MLInsightSeverity { info, warning, critical, success }

/// Data contract representing a resolved insight from the Insight Engine.
class MLInsight {
  const MLInsight({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    required this.timestamp,
    this.categoryId,
    this.merchantName,
    this.savingAmount,
    this.impactPercentage,
    this.metadata,
  });

  final String id;
  final MLInsightType type;
  final MLInsightSeverity severity;
  final String title;
  final String message;
  final DateTime timestamp;

  /// Supporting metadata for contextual rendering
  final String? categoryId;
  final String? merchantName;
  final double? savingAmount;
  final double? impactPercentage;
  final Map<String, dynamic>? metadata;

  /// Helper to convert the data contract into a JSON-compatible map (AI System compatibility).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'severity': severity.name,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'categoryId': categoryId,
      'merchantName': merchantName,
      'savingAmount': savingAmount,
      'impactPercentage': impactPercentage,
      'metadata': metadata,
    };
  }

  /// Factory constructor to restore insight details from AI/JSON contracts.
  factory MLInsight.fromJson(Map<String, dynamic> json) {
    return MLInsight(
      id: json['id'] as String,
      type: MLInsightType.values.firstWhere((e) => e.name == json['type']),
      severity: MLInsightSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
      ),
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      categoryId: json['categoryId'] as String?,
      merchantName: json['merchantName'] as String?,
      savingAmount: (json['savingAmount'] as num?)?.toDouble(),
      impactPercentage: (json['impactPercentage'] as num?)?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// AI Data Contract Interface specifying the payload structure
/// required to feed LLMs or rules engines for generating MLDS insights.
abstract class MLAIDataContract {
  /// Defines the strict JSON schema details for AI models generating insights.
  static const String jsonSchemaSpec = '''
  {
    "\$schema": "http://json-schema.org/draft-07/schema#",
    "title": "MLDSInsightList",
    "type": "array",
    "items": {
      "type": "object",
      "properties": {
        "id": { "type": "string" },
        "type": { 
          "type": "string",
          "enum": ["highestExpense", "mostFrequentMerchant", "weekendSpending", "dailyAverage", "topCategory", "budgetRisk", "cashFlowTrend", "savingsTrend", "monthlyHabit", "recurringPayment", "unexpectedSpending", "positiveProgress"]
        },
        "severity": {
          "type": "string",
          "enum": ["info", "warning", "critical", "success"]
        },
        "title": { "type": "string" },
        "message": { "type": "string" },
        "categoryId": { "type": "string" },
        "merchantName": { "type": "string" },
        "savingAmount": { "type": "number" },
        "impactPercentage": { "type": "number" },
        "metadata": { "type": "object" }
      },
      "required": ["id", "type", "severity", "title", "message"]
    }
  }
  ''';
}
