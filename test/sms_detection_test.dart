import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_lens/features/sms_detection/presentation/providers/sms_detection_provider.dart';
import 'package:money_lens/features/settings/presentation/providers/settings_provider.dart';
import 'package:money_lens/features/transactions/domain/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SMS Detection & Parsing Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('Parser correctly extracts Swiggy Debit SMS details', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      final notifier = container.read(smsDetectionNotifierProvider.notifier);

      const sms = 'Rs.499 debited from Account XX1234 for Swiggy. Ref No: 99812739.';
      final parsed = notifier.parseSms(sms);

      expect(parsed, isNotNull);
      expect(parsed!.amount, 499.0);
      expect(parsed.merchant, 'Swiggy');
      expect(parsed.referenceNumber, '99812739');
      expect(parsed.type, TransactionType.expense);
      expect(parsed.category, 'Food');
    });

    test('Parser correctly extracts Uber UPI SMS details', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      final notifier = container.read(smsDetectionNotifierProvider.notifier);

      const sms = 'UPI payment of Rs.245.50 successful to Uber. Ref: 481920.';
      final parsed = notifier.parseSms(sms);

      expect(parsed, isNotNull);
      expect(parsed!.amount, 245.50);
      expect(parsed.merchant, 'Uber');
      expect(parsed.referenceNumber, '481920');
      expect(parsed.type, TransactionType.expense);
      expect(parsed.category, 'Transport');
    });

    test('Parser correctly extracts Credit / Income SMS details', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      final notifier = container.read(smsDetectionNotifierProvider.notifier);

      const sms = 'Salary of Rs.75000 credited to Account XX9876. Ref: UPI772211.';
      final parsed = notifier.parseSms(sms);

      expect(parsed, isNotNull);
      expect(parsed!.amount, 75000.0);
      expect(parsed.type, TransactionType.income);
      expect(parsed.referenceNumber, '772211');
    });
  });
}
