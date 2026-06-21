/// Risk levels calculated by the Health Engine.
enum MLHealthRisk { low, medium, high }

/// Data container and score calculator for overall Financial Health.
class MLFinancialHealth {
  const MLFinancialHealth({
    required this.score,
    required this.budgetScore,
    required this.cashFlowScore,
    required this.savingsScore,
    required this.consistencyScore,
    required this.goalProgressScore,
    required this.riskLevel,
    required this.headline,
    required this.educationalNote,
  });

  final int score; // 0 - 100
  final double budgetScore; // 0.0 - 1.0
  final double cashFlowScore; // 0.0 - 1.0
  final double savingsScore; // 0.0 - 1.0
  final double consistencyScore; // 0.0 - 1.0
  final double goalProgressScore; // 0.0 - 1.0
  final MLHealthRisk riskLevel;
  final String headline;
  final String educationalNote;

  /// Factory constructor to compute health metrics programmatically.
  factory MLFinancialHealth.calculate({
    required double totalIncome,
    required double totalExpenses,
    required double budgetLimit,
    required double savingsGoal,
    required int consecutiveLoggedDays,
    required double maxSingleExpense,
  }) {
    // 1. Budget Adherence Score (Weight: 20%)
    double budgetScore = 1.0;
    if (budgetLimit > 0 && totalExpenses > budgetLimit) {
      final overspend = (totalExpenses - budgetLimit) / budgetLimit;
      budgetScore = (1.0 - overspend).clamp(0.0, 1.0);
    }

    // 2. Cash Flow Health (Weight: 30%)
    double cashFlowScore = 0.0;
    if (totalIncome > 0) {
      final savingsRate = (totalIncome - totalExpenses) / totalIncome;
      cashFlowScore = (savingsRate / 0.30).clamp(
        0.0,
        1.0,
      ); // Perfect score at 30% savings rate
    }

    // 3. Savings Goal Progress (Weight: 20%)
    double savingsScore = 0.0;
    final saved = totalIncome - totalExpenses;
    if (savingsGoal > 0 && saved > 0) {
      savingsScore = (saved / savingsGoal).clamp(0.0, 1.0);
    }

    // 4. Logging Consistency (Weight: 15%)
    // Perfect consistency at 7 consecutive logged days
    final double consistencyScore = (consecutiveLoggedDays / 7.0).clamp(
      0.0,
      1.0,
    );

    // 5. Large Spikes / Vulnerability (Weight: 15%)
    double vulnerabilityScore = 1.0;
    if (totalExpenses > 0) {
      final singleRatio = maxSingleExpense / totalExpenses;
      if (singleRatio > 0.25) {
        // High single transaction spikes lower the score
        vulnerabilityScore = (1.0 - (singleRatio - 0.25)).clamp(0.0, 1.0);
      }
    }

    // Overall Weighted Score
    final rawScore =
        (budgetScore * 20.0) +
        (cashFlowScore * 30.0) +
        (savingsScore * 20.0) +
        (consistencyScore * 15.0) +
        (vulnerabilityScore * 15.0);
    final finalScore = rawScore.round().clamp(0, 100);

    // Risk Mapping
    MLHealthRisk risk = MLHealthRisk.low;
    if (finalScore < 50) {
      risk = MLHealthRisk.high;
    } else if (finalScore < 75) {
      risk = MLHealthRisk.medium;
    }

    // Headline and supportive context resolving
    String headline;
    String note;

    if (finalScore >= 85) {
      headline = 'Your finances are in excellent standing';
      note =
          'Keep it up! Your savings rate is strong and you are adhering to your budgets. Consider setting aside extra savings for long-term goals.';
    } else if (finalScore >= 70) {
      headline = 'Your finances look stable';
      note =
          'Good progress! Small adjustments to category thresholds will help you build a bigger buffer. Try keeping daily dining expenses slightly lower this week.';
    } else if (finalScore >= 50) {
      headline = 'A few budget areas need adjustment';
      note =
          'Your income is covering costs, but high singular spending categories are leaving less room for savings goals. We can review category limits together.';
    } else {
      headline = 'Focus on building breathing room';
      note =
          'Unplanned expenses exceeded active limits this month. Let\'s prioritize logging consistency first—simply tracking where cash goes is the best first step to control.';
    }

    return MLFinancialHealth(
      score: finalScore,
      budgetScore: budgetScore,
      cashFlowScore: cashFlowScore,
      savingsScore: savingsScore,
      consistencyScore: consistencyScore,
      goalProgressScore: savingsScore,
      riskLevel: risk,
      headline: headline,
      educationalNote: note,
    );
  }
}
