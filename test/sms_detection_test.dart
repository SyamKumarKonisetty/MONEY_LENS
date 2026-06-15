import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_lens/features/sms_detection/presentation/providers/sms_detection_provider.dart';
import 'package:money_lens/features/settings/presentation/providers/settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Simple SMS Detection MVP Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('Parser correctly extracts amount from expense SMS', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      final notifier = container.read(smsDetectionNotifierProvider.notifier);

      const sms = 'Sent Rs.129.00\nFrom HDFC Bank A/C *1712';
      final parsed = notifier.parseSms(sms);

      expect(parsed, isNotNull);
      expect(parsed.amount, 129.0);
      expect(parsed.merchant, isNull);
      expect(parsed.type, isNull);
      expect(parsed.parserFailed, isFalse);
    });

    test('Parser correctly extracts amount from income SMS', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      final notifier = container.read(smsDetectionNotifierProvider.notifier);

      const sms = 'Credit Alert!\nRs.2010.00 credited to HDFC Bank A/c XX1712';
      final parsed = notifier.parseSms(sms);

      expect(parsed, isNotNull);
      expect(parsed.amount, 2010.0);
      expect(parsed.merchant, isNull);
      expect(parsed.type, isNull);
      expect(parsed.parserFailed, isFalse);
    });

    test('Parser sets amount to null and parserFailed to true if amount fails to parse', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      final notifier = container.read(smsDetectionNotifierProvider.notifier);

      const sms = 'Sent Rs.abc\nFrom HDFC Bank';
      final parsed = notifier.parseSms(sms);

      expect(parsed, isNotNull);
      expect(parsed.amount, isNull);
      expect(parsed.parserFailed, isTrue);
    });
  });
}
