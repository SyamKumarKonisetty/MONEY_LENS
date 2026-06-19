import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';
import 'package:money_lens/features/settings/presentation/providers/settings_provider.dart';
import 'package:money_lens/features/sms_detection/presentation/sms_inbox_screen.dart';
import 'package:money_lens/features/sms_detection/presentation/providers/sms_detection_provider.dart';
import 'package:money_lens/features/transactions/presentation/widgets/add_expense_bottom_sheet.dart';
import 'package:money_lens/core/database/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.moneylens/sms');

  group('SMS Inbox Screen Widget Tests', () {
    late SharedPreferences prefs;
    late AppDatabase db;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      db = AppDatabase(NativeDatabase.memory());

      // Set up default non-intrusive method channel mock handlers
      TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'checkSmsPermission') {
              return true;
            }
            if (methodCall.method == 'getSmsMessages') {
              return <
                dynamic
              >[]; // Return empty by default to prevent auto-scan duplication
            }
            return null;
          });
    });

    tearDown(() async {
      TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      await db.close();
    });

    testWidgets('renders all screen elements and mock SMS cards', (
      WidgetTester tester,
    ) async {
      // Save initial state to DB
      await db
          .into(db.rawSmsTable)
          .insert(
            RawSms(
              id: 'sms_123',
              sender: 'HDFCBK',
              body: 'Sent Rs.129.00 from HDFC Bank',
              receivedDate: DateTime.now(),
              processed: false,
              ignored: false,
            ),
          );

      await prefs.setBool('sms_permission_granted', true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            smsDetectionNotifierProvider.overrideWith((ref) {
              return SmsDetectionNotifier(prefs, ref, db: db);
            }),
          ],
          child: const MaterialApp(home: SmsInboxScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Verify header titles
      expect(find.text('Smart SMS Inbox'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget); // Search input

      // Verify SMS details inside card
      expect(find.text('HDFCBK'), findsOneWidget);
      expect(find.text('Sent Rs.129.00 from HDFC Bank'), findsOneWidget);

      // Verify operation buttons
      expect(find.text('Ignore Message'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
    });

    testWidgets('search box filters SMS messages correctly', (
      WidgetTester tester,
    ) async {
      await db
          .into(db.rawSmsTable)
          .insert(
            RawSms(
              id: 'sms_1',
              sender: 'BANK_ONE',
              body: 'Debit of Rs.500 at StoreA',
              receivedDate: DateTime.now(),
              processed: false,
              ignored: false,
            ),
          );
      await db
          .into(db.rawSmsTable)
          .insert(
            RawSms(
              id: 'sms_2',
              sender: 'BANK_TWO',
              body: 'Credit of Rs.1000 from CompanyB',
              receivedDate: DateTime.now().subtract(const Duration(minutes: 5)),
              processed: false,
              ignored: false,
            ),
          );

      await prefs.setBool('sms_permission_granted', true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            smsDetectionNotifierProvider.overrideWith((ref) {
              return SmsDetectionNotifier(prefs, ref, db: db);
            }),
          ],
          child: const MaterialApp(home: SmsInboxScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Initially both show up
      expect(find.text('BANK_ONE'), findsOneWidget);
      expect(find.text('BANK_TWO'), findsOneWidget);

      // Type "StoreA" into search text field
      await tester.enterText(find.byType(TextField), 'StoreA');
      await tester.pumpAndSettle();

      // Only BANK_ONE should remain
      expect(find.text('BANK_ONE'), findsOneWidget);
      expect(find.text('BANK_TWO'), findsNothing);

      // Clear search
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      // Both show up again
      expect(find.text('BANK_ONE'), findsOneWidget);
      expect(find.text('BANK_TWO'), findsOneWidget);
    });

    testWidgets('clicking Expense opens AddExpenseBottomSheet', (
      WidgetTester tester,
    ) async {
      await db
          .into(db.rawSmsTable)
          .insert(
            RawSms(
              id: 'sms_123',
              sender: 'HDFCBK',
              body: 'Sent Rs.129.00 from HDFC Bank',
              receivedDate: DateTime.now(),
              processed: false,
              ignored: false,
            ),
          );

      await prefs.setBool('sms_permission_granted', true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            smsDetectionNotifierProvider.overrideWith((ref) {
              return SmsDetectionNotifier(prefs, ref, db: db);
            }),
          ],
          child: const MaterialApp(home: SmsInboxScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Click "Expense"
      await tester.tap(find.text('Expense'));
      await tester.pumpAndSettle();

      // Verify the AddExpenseBottomSheet shows
      expect(find.byType(AddExpenseBottomSheet), findsOneWidget);
    });
  });
}
