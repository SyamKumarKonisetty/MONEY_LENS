/// Represents a dynamic, context-aware greeting message.
class MLGreeting {
  const MLGreeting({
    required this.headline,
    required this.subtitle,
    required this.accessibilityLabel,
  });

  final String headline;
  final String subtitle;
  final String accessibilityLabel;
}

/// Evaluator generating greetings contextually based on time of day, profile details, and budget metrics.
class MLGreetingEngine {
  MLGreetingEngine._();

  /// Programmatically compiles a greeting message.
  static MLGreeting generate({
    required String userName,
    required int hour,
    double? weeklyProgress,
    int? currentStreak,
  }) {
    String timeGreeting;
    if (hour >= 5 && hour < 12) {
      timeGreeting = 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      timeGreeting = 'Good afternoon';
    } else if (hour >= 17 && hour < 22) {
      timeGreeting = 'Good evening';
    } else {
      timeGreeting = 'Good night';
    }

    final headline = '$timeGreeting, $userName';
    String subtitle = 'Ready to track today\'s spending?';

    if (weeklyProgress != null) {
      if (weeklyProgress > 1.0) {
        subtitle =
            'A few budget thresholds were exceeded. Let\'s review items together.';
      } else if (weeklyProgress >= 0.85) {
        subtitle =
            'Approaching weekly limits. You\'re doing great maintaining discipline.';
      } else if (weeklyProgress >= 0.5) {
        subtitle =
            'Weekly budgets are stable. Consider transferring surplus to savings.';
      } else {
        subtitle = 'Excellent pace! You are well within your limits this week.';
      }
    } else if (currentStreak != null && currentStreak > 0) {
      subtitle = 'You\'re on a $currentStreak-day logging streak! Keep it up.';
    }

    return MLGreeting(
      headline: headline,
      subtitle: subtitle,
      accessibilityLabel: '$headline. $subtitle',
    );
  }
}
