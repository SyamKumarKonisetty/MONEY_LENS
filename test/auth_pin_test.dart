import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_lens/features/auth/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthNotifier Secure PIN & Change PIN Tests', () {
    late SharedPreferences prefs;
    late AuthNotifier authNotifier;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      authNotifier = AuthNotifier(prefs);
    });

    test('setupPinAndRecovery hashes the PIN and recovery answer securely', () {
      authNotifier.setupPinAndRecovery('1234', 50000.0, 'salaried');
      
      final storedValue = prefs.getString('auth_pin');
      expect(storedValue, isNotNull);
      expect(storedValue!.length, 64);
      expect(storedValue, hashPin('1234'));

      final storedAnswer = prefs.getString('recovery_answer_hash');
      expect(storedAnswer, isNotNull);
      expect(storedAnswer, hashPin('50000.00'));
    });

    test('authenticate verifies hashed PIN correctly', () {
      authNotifier.setupPinAndRecovery('1234', 50000.0, 'salaried');
      
      // Verification with correct PIN
      final authenticatedSuccess = authNotifier.authenticate('1234');
      expect(authenticatedSuccess, isTrue);
      expect(authNotifier.isAuthenticated, isTrue);

      // Verification with incorrect PIN
      final authenticatedFailure = authNotifier.authenticate('5555');
      expect(authenticatedFailure, isFalse);
    });

    test('auto-migration upgrades plain text PIN to SHA-256 hash', () {
      // 1. Store plain-text PIN manually
      prefs.setString('auth_pin', '5678');
      prefs.setString('recovery_answer_hash', hashPin('50000.00')); // Set recovery to pass isPinSetup
      
      // 2. Instantiate new provider representing app restart
      final newNotifier = AuthNotifier(prefs);
      
      // 3. Verify it is set up and authenticates correctly
      expect(newNotifier.isPinSetup, isTrue);
      expect(newNotifier.authenticate('5678'), isTrue);
      
      // 4. Verify that the SharedPreferences value was migrated to the hash
      final storedValue = prefs.getString('auth_pin');
      expect(storedValue, hashPin('5678'));
      expect(storedValue!.length, 64);
    });

    test('changePin updates stored PIN securely on correct current PIN', () {
      authNotifier.setupPinAndRecovery('1111', 50000.0, 'salaried');

      // 1. Mismatched confirm PIN or wrong length should be rejected by validation (handled by UI, but changePin does length checks)
      final changeFailedWrongLength = authNotifier.changePin('1111', '123'); // too short
      expect(changeFailedWrongLength, isFalse);

      // 2. Incorrect current PIN should be rejected
      final changeFailedWrongCurrent = authNotifier.changePin('2222', '3333');
      expect(changeFailedWrongCurrent, isFalse);
      expect(prefs.getString('auth_pin'), hashPin('1111')); // unchanged

      // 3. Correct PIN change should succeed
      final changeSucceeded = authNotifier.changePin('1111', '3333');
      expect(changeSucceeded, isTrue);
      expect(prefs.getString('auth_pin'), hashPin('3333')); // updated to new hash

      // 4. Check new authentication works
      expect(authNotifier.authenticate('3333'), isTrue);
      expect(authNotifier.authenticate('1111'), isFalse);
    });

    test('reset clears auth session and removes stored PIN key', () {
      authNotifier.setupPinAndRecovery('4321', 50000.0, 'salaried');
      expect(authNotifier.isPinSetup, isTrue);
      expect(authNotifier.isAuthenticated, isTrue);

      authNotifier.reset();

      expect(authNotifier.isPinSetup, isFalse);
      expect(authNotifier.isAuthenticated, isFalse);
      expect(prefs.getString('auth_pin'), isNull);
      expect(prefs.getString('recovery_answer_hash'), isNull);
    });

    test('verifyRecoveryAnswer works correctly', () {
      authNotifier.setupPinAndRecovery('1234', 45000.50, 'salaried');
      
      expect(authNotifier.verifyRecoveryAnswer('45000.50'), isTrue);
      expect(authNotifier.verifyRecoveryAnswer(' 45000.50 '), isTrue);
      expect(authNotifier.verifyRecoveryAnswer('45,000.50'), isTrue);
      expect(authNotifier.verifyRecoveryAnswer('10000'), isFalse);
      expect(authNotifier.verifyRecoveryAnswer('invalid'), isFalse);
    });

    test('resetPinWithRecovery resets PIN successfully', () {
      authNotifier.setupPinAndRecovery('1234', 50000.0, 'salaried');
      expect(authNotifier.resetPinWithRecovery('9999'), isTrue);
      expect(authNotifier.authenticate('9999'), isTrue);
    });

    test('setupPinAndRecovery supports student profile', () {
      authNotifier.setupPinAndRecovery('1234', 25000.0, 'student');
      expect(authNotifier.profileType, 'student');
      expect(authNotifier.verifyRecoveryAnswer('25000.00'), isTrue);
    });
  });
}
