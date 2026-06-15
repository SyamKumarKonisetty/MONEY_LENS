import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_lens/features/settings/presentation/providers/settings_provider.dart';
import 'package:money_lens/features/sms_detection/presentation/sms_inbox_screen.dart';
import 'package:money_lens/features/sms_detection/presentation/providers/sms_detection_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.moneylens/sms');

  group('SMS Inbox Screen Widget Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      
      // Set up default non-intrusive method channel mock handlers
      TestWidgetsFlutterBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'checkSmsPermission') {
            return true;
          }
          if (methodCall.method == 'getSmsMessages') {
            return <dynamic>[]; // Return empty by default to prevent auto-scan duplication
          }
          return null;
        },
      );
    });

    tearDown(() {
      TestWidgetsFlutterBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      );
    });

    testWidgets('renders all screen elements and mock SMS cards', (WidgetTester tester) async {
      // Save initial state to SharedPreferences
      final mockSms = SmsTransaction(
        id: 'sms_123',
        smsBody: 'Sent Rs.129.00 from HDFC Bank',
        amount: 129.0,
        merchant: null,
        timestamp: DateTime.now(),
        referenceNumber: '',
        type: null,
        status: SmsDetectionStatus.pending,
        category: null,
        senderAddress: 'HDFCBK',
      );

      await prefs.setString('sms_detection_list', jsonEncode([mockSms.toJson()]));
      await prefs.setBool('sms_permission_granted', true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: SmsInboxScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify header titles
      expect(find.text('Smart SMS Inbox'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget); // Search input

      // Verify SMS details inside card
      expect(find.text('Sender: HDFCBK'), findsOneWidget);
      expect(find.text('Sent Rs.129.00 from HDFC Bank'), findsOneWidget);

      // Verify operation buttons
      expect(find.text('Ignore'), findsOneWidget);
      expect(find.text('Mark Income'), findsOneWidget);
      expect(find.text('Mark Expense'), findsOneWidget);
    });

    testWidgets('search box filters SMS messages correctly', (WidgetTester tester) async {
      final mockSms1 = SmsTransaction(
        id: 'sms_1',
        smsBody: 'Debit of Rs.500 at StoreA',
        amount: 500.0,
        timestamp: DateTime.now(),
        referenceNumber: '',
        status: SmsDetectionStatus.pending,
        senderAddress: 'BANK_ONE',
      );
      final mockSms2 = SmsTransaction(
        id: 'sms_2',
        smsBody: 'Credit of Rs.1000 from CompanyB',
        amount: 1000.0,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        referenceNumber: '',
        status: SmsDetectionStatus.pending,
        senderAddress: 'BANK_TWO',
      );

      await prefs.setString('sms_detection_list', jsonEncode([mockSms1.toJson(), mockSms2.toJson()]));
      await prefs.setBool('sms_permission_granted', true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: SmsInboxScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially both show up
      expect(find.text('Sender: BANK_ONE'), findsOneWidget);
      expect(find.text('Sender: BANK_TWO'), findsOneWidget);

      // Type "StoreA" into search text field
      await tester.enterText(find.byType(TextField), 'StoreA');
      await tester.pumpAndSettle();

      // Only BANK_ONE should remain
      expect(find.text('Sender: BANK_ONE'), findsOneWidget);
      expect(find.text('Sender: BANK_TWO'), findsNothing);

      // Clear search
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      // Both show up again
      expect(find.text('Sender: BANK_ONE'), findsOneWidget);
      expect(find.text('Sender: BANK_TWO'), findsOneWidget);
    });

    testWidgets('clicking Mark Expense opens confirm dialog', (WidgetTester tester) async {
      final mockSms = SmsTransaction(
        id: 'sms_123',
        smsBody: 'Sent Rs.129.00 from HDFC Bank',
        amount: 129.0,
        timestamp: DateTime.now(),
        referenceNumber: '',
        status: SmsDetectionStatus.pending,
        senderAddress: 'HDFCBK',
      );

      await prefs.setString('sms_detection_list', jsonEncode([mockSms.toJson()]));
      await prefs.setBool('sms_permission_granted', true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: SmsInboxScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Click "Mark Expense"
      await tester.tap(find.text('Mark Expense'));
      await tester.pumpAndSettle();

      // Verify the confirm expense dialog shows
      expect(find.text('Confirm Expense'), findsOneWidget);
      expect(find.text('Amount (₹)'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}
