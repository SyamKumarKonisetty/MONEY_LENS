import 'package:flutter/material.dart';

/// Factors contributing to the MoneyLens Financial Health Score.
class MLHealthScoreFactors {
  const MLHealthScoreFactors({
    required this.budgetHealth, // 0.0 to 1.0 (how well they stayed within bounds)
    required this.savingsRate, // 0.0 to 1.0 (percentage of income saved, target is 30%)
    required this.cashFlowRatio, // 0.0 to 1.0 (inflow vs outflow stability)
    required this.spendingConsistency, // 0.0 to 1.0 (absence of huge unexpected spikes)
    required this.overspendingBuffer, // 0.0 to 1.0 (absence of overspent budgets)
    required this.goalProgress, // 0.0 to 1.0 (how well they are moving toward goals)
  });

  final double budgetHealth;
  final double savingsRate;
  final double cashFlowRatio;
  final double spendingConsistency;
  final double overspendingBuffer;
  final double goalProgress;

  /// Convert factors to a serialized map.
  Map<String, double> toMap() {
    return {
      'budgetHealth': budgetHealth,
      'savingsRate': savingsRate,
      'cashFlowRatio': cashFlowRatio,
      'spendingConsistency': spendingConsistency,
      'overspendingBuffer': overspendingBuffer,
      'goalProgress': goalProgress,
    };
  }
}

/// Core class defining the architecture of the Financial Health Score.
class MLHealthScore {
  const MLHealthScore({
    required this.score,
    required this.factors,
    required this.headline,
    required this.improvementAdvice,
    required this.insights,
  });

  /// The final score scaled between 0 and 100.
  final int score;

  /// Contributing factors.
  final MLHealthScoreFactors factors;

  /// High level semantic feedback (always supportive, never shaming).
  final String headline;

  /// Actionable feedback on how to improve.
  final String improvementAdvice;

  /// Supporting bullet points.
  final List<String> insights;

  /// Resolves the semantic color representing the health range:
  /// - 80-100: Peace & Stability (Emerald Green / Success)
  /// - 50-79: Balance & Structuring (Cyan / Indigo / Budget)
  /// - 0-49: Attention & Support (Muted Amber / Warning)
  /// *Note: We never use "Failure Red" for the overall score to avoid shaming the user.*
  Color resolveColor(BuildContext context) {
    if (score >= 80) {
      return const Color(0xFF30D158); // Calm green
    } else if (score >= 50) {
      return const Color(0xFF0A84FF); // Primary blue
    } else {
      return const Color(0xFFFF9F0A); // Soft amber warning (never red)
    }
  }

  /// Calculates a supportive health score from raw factors.
  static MLHealthScore calculate(MLHealthScoreFactors factors) {
    // Weighted scoring logic:
    // - Savings Rate (25%)
    // - Budget Health (20%)
    // - Cash Flow (20%)
    // - Overspending Buffer (15%)
    // - Goal Progress (10%)
    // - Spending Consistency (10%)
    final double rawScore =
        (factors.savingsRate * 25.0) +
        (factors.budgetHealth * 20.0) +
        (factors.cashFlowRatio * 20.0) +
        (factors.overspendingBuffer * 15.0) +
        (factors.goalProgress * 10.0) +
        (factors.spendingConsistency * 10.0);

    final scoreInt = rawScore.round().clamp(0, 100);

    // Supportive Copywriting engine (FTS/ECS Philosophy)
    final String headline;
    final String advice;
    final List<String> insightsList = [];

    if (scoreInt >= 80) {
      headline = 'Your finances are in a safe, steady position.';
      advice =
          'Consider accelerating your savings goal or locking surplus cash into active investment options to beat inflation.';
      insightsList.add('Savings rate is exceptionally strong.');
      insightsList.add('All active category budgets remained within bounds.');
    } else if (scoreInt >= 50) {
      headline = 'You are maintaining a balanced structure.';
      advice =
          'Focus on minor leaks in your secondary spending categories (like Entertainment or Shopping) to lift your savings cushion.';
      insightsList.add('Budget boundary control is working.');
      insightsList.add('Savings rate could be increased towards the 30% goal.');
    } else {
      headline = 'We can work on building stronger buffers together.';
      advice =
          'Try setting smaller, daily budgets and using automated alerts to reflect on unplanned expenses before they stack up.';
      insightsList.add('Frequent cash outflow spikes noticed this month.');
      insightsList.add(
        'A couple of budgets were exceeded. We can adjust limits next month.',
      );
    }

    return MLHealthScore(
      score: scoreInt,
      factors: factors,
      headline: headline,
      improvementAdvice: advice,
      insights: insightsList,
    );
  }
}
