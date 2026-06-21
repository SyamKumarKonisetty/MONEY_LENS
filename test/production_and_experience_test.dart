import 'package:flutter_test/flutter_test.dart';
import 'package:money_lens/features/experience/greetings/greeting_engine.dart';
import 'package:money_lens/production/security/sensitive_data_filter.dart';
import 'package:money_lens/production/security/input_validator.dart';
import 'package:money_lens/production/monitoring/crash_monitoring.dart';


void main() {
  group('Production & Experience Framework tests', () {
    test('Greeting Engine generates correct greetings contextually', () {
      final morningGreeting = MLGreetingEngine.generate(
        userName: 'Syam',
        hour: 8,
      );
      expect(morningGreeting.headline, 'Good morning, Syam');
      expect(morningGreeting.subtitle, contains('Ready to track'));

      final afternoonGreeting = MLGreetingEngine.generate(
        userName: 'Syam',
        hour: 14,
        weeklyProgress: 1.2,
      );
      expect(afternoonGreeting.headline, 'Good afternoon, Syam');
      expect(afternoonGreeting.subtitle, contains('exceeded'));
    });

    test('Log Redactor masks PII correctly', () {
      final log =
          'User logged transaction of ₹ 12000.50 for account 987654321 with phone +919876543210';
      final redacted = MLSensitiveDataFilter.redact(log);
      expect(redacted, contains('₹[REDACTED]'));
      expect(redacted, contains('[PHONE_REDACTED]'));
      expect(redacted, contains('[SECURE_REDACTED]'));
    });

    test('Input Validator sanitizes inputs against injection keywords', () {
      expect(MLInputValidator.isValidInput('SELECT * FROM users'), false);
      expect(MLInputValidator.isValidInput('<script>alert(1)</script>'), false);
      expect(MLInputValidator.isValidInput('Regular Notes'), true);

      final sanitized = MLInputValidator.sanitize(
        "Syam's Account <script>alert(1)</script>",
      );
      expect(sanitized, "Syam''s Account");
    });

    test('Crash Monitoring registers reports locally', () {
      MLCrashMonitoring.clearReports();
      expect(MLCrashMonitoring.reports.length, 0);

      MLCrashMonitoring.reportError(
        StateError('Test error'),
        StackTrace.current,
      );
      expect(MLCrashMonitoring.reports.length, 1);
      expect(MLCrashMonitoring.reports.first.error, contains('Test error'));
    });
  });
}
