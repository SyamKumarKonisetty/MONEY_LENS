import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';
import 'package:money_lens/features/sms_detection/presentation/providers/sms_detection_provider.dart';
import 'package:money_lens/features/settings/presentation/providers/settings_provider.dart';
import 'package:money_lens/core/database/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Simple SMS Detection MVP Tests', () {
    late SharedPreferences prefs;
    late AppDatabase db;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('Parser correctly extracts amount from expense SMS', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          smsDetectionNotifierProvider.overrideWith((ref) {
            return SmsDetectionNotifier(prefs, ref, db: db);
          }),
        ],
      );
      final notifier = container.read(smsDetectionNotifierProvider.notifier);

      final sms = RawSms(
        id: '1',
        sender: 'HDFCBK',
        body: 'Sent Rs.129.00\nFrom HDFC Bank A/C *1712',
        receivedDate: DateTime.now(),
        processed: false,
        ignored: false,
      );
      final parsed = notifier.parseSmsOnDemand(sms);

      expect(parsed, isNotNull);
      expect(parsed.amount, 129.0);
    });

    test('Parser correctly extracts amount from income SMS', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          smsDetectionNotifierProvider.overrideWith((ref) {
            return SmsDetectionNotifier(prefs, ref, db: db);
          }),
        ],
      );
      final notifier = container.read(smsDetectionNotifierProvider.notifier);

      final sms = RawSms(
        id: '2',
        sender: 'HDFCBK',
        body: 'Credit Alert!\nRs.2010.00 credited to HDFC Bank A/c XX1712',
        receivedDate: DateTime.now(),
        processed: false,
        ignored: false,
      );
      final parsed = notifier.parseSmsOnDemand(sms);

      expect(parsed, isNotNull);
      expect(parsed.amount, 2010.0);
    });

    test('Parser sets amount to 0.0 if amount fails to parse', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          smsDetectionNotifierProvider.overrideWith((ref) {
            return SmsDetectionNotifier(prefs, ref, db: db);
          }),
        ],
      );
      final notifier = container.read(smsDetectionNotifierProvider.notifier);

      final sms = RawSms(
        id: '3',
        sender: 'HDFCBK',
        body: 'Sent Rs.abc\nFrom HDFC Bank',
        receivedDate: DateTime.now(),
        processed: false,
        ignored: false,
      );
      final parsed = notifier.parseSmsOnDemand(sms);

      expect(parsed, isNotNull);
      expect(parsed.amount, 0.0);
    });
  });
}
