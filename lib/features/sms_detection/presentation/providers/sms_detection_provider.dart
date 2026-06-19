// ignore_for_file: avoid_print
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart';
import 'package:money_lens/core/database/app_database.dart';
import 'package:money_lens/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:money_lens/features/settings/presentation/providers/settings_provider.dart';

// ─── SMS Detection Privacy Settings ────────────────────────────────────────

class SmsPrivacySettings {
  final bool detectionEnabled;
  final bool permissionGranted;

  SmsPrivacySettings({
    this.detectionEnabled = true,
    this.permissionGranted = false,
  });

  SmsPrivacySettings copyWith({
    bool? detectionEnabled,
    bool? permissionGranted,
  }) {
    return SmsPrivacySettings(
      detectionEnabled: detectionEnabled ?? this.detectionEnabled,
      permissionGranted: permissionGranted ?? this.permissionGranted,
    );
  }
}

class SmsPrivacySettingsNotifier extends StateNotifier<SmsPrivacySettings> {
  final SharedPreferences _prefs;

  SmsPrivacySettingsNotifier(this._prefs) : super(SmsPrivacySettings()) {
    _loadSettings();
  }

  static const String _keySmsEnabled = 'sms_detection_enabled';
  static const String _keySmsPermission = 'sms_permission_granted';

  void _loadSettings() {
    final enabled = _prefs.getBool(_keySmsEnabled) ?? true;
    final permission = _prefs.getBool(_keySmsPermission) ?? false;
    state = SmsPrivacySettings(
      detectionEnabled: enabled,
      permissionGranted: permission,
    );
  }

  Future<void> setDetectionEnabled(bool val) async {
    await _prefs.setBool(_keySmsEnabled, val);
    state = state.copyWith(detectionEnabled: val);
  }

  Future<void> setPermissionGranted(bool val) async {
    await _prefs.setBool(_keySmsPermission, val);
    state = state.copyWith(permissionGranted: val);
  }
}

final smsPrivacySettingsProvider =
    StateNotifierProvider<SmsPrivacySettingsNotifier, SmsPrivacySettings>((
      ref,
    ) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return SmsPrivacySettingsNotifier(prefs);
    });

// ─── SMS Scan Status ───────────────────────────────────────────────────────

class SmsScanStatus {
  final bool isScanning;
  final int totalSmsCount;
  final int financialSmsCount;
  final int newTransactionCount;
  final String? errorMessage;
  final DateTime? lastScanTime;

  SmsScanStatus({
    this.isScanning = false,
    this.totalSmsCount = 0,
    this.financialSmsCount = 0,
    this.newTransactionCount = 0,
    this.errorMessage,
    this.lastScanTime,
  });

  SmsScanStatus copyWith({
    bool? isScanning,
    int? totalSmsCount,
    int? financialSmsCount,
    int? newTransactionCount,
    String? errorMessage,
    DateTime? lastScanTime,
  }) {
    return SmsScanStatus(
      isScanning: isScanning ?? this.isScanning,
      totalSmsCount: totalSmsCount ?? this.totalSmsCount,
      financialSmsCount: financialSmsCount ?? this.financialSmsCount,
      newTransactionCount: newTransactionCount ?? this.newTransactionCount,
      errorMessage: errorMessage,
      lastScanTime: lastScanTime ?? this.lastScanTime,
    );
  }
}

class SmsScanStatusNotifier extends StateNotifier<SmsScanStatus> {
  SmsScanStatusNotifier() : super(SmsScanStatus());

  void update(SmsScanStatus newStatus) {
    state = newStatus;
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final smsScanStatusProvider =
    StateNotifierProvider<SmsScanStatusNotifier, SmsScanStatus>((ref) {
      return SmsScanStatusNotifier();
    });

// ─── Parsed SMS Model (On-Demand) ──────────────────────────────────────────

class ParsedSms {
  final double amount;
  final DateTime date;
  final String sender;
  final String merchant;

  ParsedSms({
    required this.amount,
    required this.date,
    required this.sender,
    required this.merchant,
  });
}

// ─── SMS Detection List / State Notifier ───────────────────────────────────

class SmsDetectionNotifier extends StateNotifier<List<RawSms>> {
  final SharedPreferences _prefs;
  final Ref _ref;
  final AppDatabase _db;
  static const _channel = MethodChannel('com.moneylens/sms');
  static const String _keyInstallTimestamp = 'app_install_timestamp';

  SmsDetectionNotifier(this._prefs, this._ref, {AppDatabase? db})
    : _db = db ?? AppDatabase.instance,
      super([]) {
    _ensureInstallTimestamp();
    _loadSmsInbox();
  }

  void _ensureInstallTimestamp() {
    if (!_prefs.containsKey(_keyInstallTimestamp)) {
      _prefs.setInt(
        _keyInstallTimestamp,
        DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  Future<void> _loadSmsInbox() async {
    final db = _db;
    try {
      final items =
          await (db.select(db.rawSmsTable)
                ..where(
                  (t) => t.processed.equals(false) & t.ignored.equals(false),
                )
                ..orderBy([
                  (t) => OrderingTerm(
                    expression: t.receivedDate,
                    mode: OrderingMode.desc,
                  ),
                ]))
              .get();
      state = items;
    } catch (_) {
      state = [];
    }
  }

  /// Request READ_SMS permission at runtime and update privacy settings.
  Future<bool> requestSmsPermission() async {
    final status = await Permission.sms.request();
    final granted = status.isGranted;
    await _ref
        .read(smsPrivacySettingsProvider.notifier)
        .setPermissionGranted(granted);
    return granted;
  }

  /// Check if READ_SMS permission is currently granted (native check).
  Future<bool> checkNativePermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('checkSmsPermission');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Extremely light filter: Rs/RS/rs/₹ + digit, excluding OTP/Verification/Recharges
  bool isValidFinancialSms(String body) {
    final bodyLower = body.toLowerCase();

    // Reject common non-transaction alerts
    if (bodyLower.contains('otp') ||
        bodyLower.contains('one time password') ||
        bodyLower.contains('one-time password') ||
        bodyLower.contains('verification code') ||
        bodyLower.contains('code:') ||
        bodyLower.contains('recharge') ||
        bodyLower.contains('promo') ||
        bodyLower.contains('coupon') ||
        bodyLower.contains('delivery') ||
        bodyLower.contains('package') ||
        bodyLower.contains('greetings')) {
      return false;
    }

    // Must contain Rs/RS/rs/₹ and at least one numeric digit
    final hasCurrency =
        body.contains('Rs') ||
        body.contains('RS') ||
        body.contains('rs') ||
        body.contains('₹');
    final hasDigit = body.contains(RegExp(r'\d'));

    return hasCurrency && hasDigit;
  }

  /// Scan the device SMS inbox for raw messages and insert into raw_sms table.
  Future<void> scanDeviceSmsInbox({int limit = 500}) async {
    final scanNotifier = _ref.read(smsScanStatusProvider.notifier);
    scanNotifier.update(SmsScanStatus(isScanning: true));

    try {
      final hasPermission = await checkNativePermission();
      if (!hasPermission) {
        scanNotifier.update(
          SmsScanStatus(
            isScanning: false,
            errorMessage:
                'No SMS permission granted. Please enable it in Settings.',
          ),
        );
        return;
      }

      final List<dynamic>? rawMessages = await _channel
          .invokeMethod<List<dynamic>>('getSmsMessages', {'limit': limit});

      if (rawMessages == null || rawMessages.isEmpty) {
        scanNotifier.update(
          SmsScanStatus(
            isScanning: false,
            totalSmsCount: 0,
            financialSmsCount: 0,
            newTransactionCount: 0,
            lastScanTime: DateTime.now(),
            errorMessage: 'No SMS messages found on this device.',
          ),
        );
        return;
      }

      final totalSmsCount = rawMessages.length;
      final installTimeMs =
          _prefs.getInt(_keyInstallTimestamp) ??
          DateTime.now().millisecondsSinceEpoch;
      final installDateTime = DateTime.fromMillisecondsSinceEpoch(
        installTimeMs,
      );

      final db = _db;
      final existingRecords = await db.select(db.rawSmsTable).get();
      final existingIds = existingRecords.map((r) => r.id).toSet();
      int insertedCount = 0;

      for (final raw in rawMessages) {
        final msg = Map<String, dynamic>.from(raw as Map);
        final body = msg['body'] as String? ?? '';
        final address = msg['address'] as String? ?? '';
        final dateMs = msg['date'] as int? ?? 0;
        final smsDate = dateMs > 0
            ? DateTime.fromMillisecondsSinceEpoch(dateMs)
            : DateTime.now();

        // Step 1: Ignore historical messages before install timestamp
        if (smsDate.isBefore(installDateTime)) {
          continue;
        }

        // Step 3: Very light filter
        if (!isValidFinancialSms(body)) {
          continue;
        }

        // Generate unique deterministic ID for RawSms
        final androidId = msg['id'] as String?;
        final id = androidId != null && androidId.isNotEmpty
            ? 'sms_android_$androidId'
            : 'sms_hash_${(address + body + dateMs.toString()).hashCode.abs()}';

        // Skip if already exists in the database (preserving its ignored/processed state)
        if (existingIds.contains(id)) {
          continue;
        }

        await db
            .into(db.rawSmsTable)
            .insert(
              RawSmsTableCompanion.insert(
                id: id,
                sender: address,
                body: body,
                receivedDate: smsDate,
                processed: const Value(false),
                ignored: const Value(false),
              ),
            );
        insertedCount++;
      }

      await _loadSmsInbox();

      scanNotifier.update(
        SmsScanStatus(
          isScanning: false,
          totalSmsCount: totalSmsCount,
          financialSmsCount: insertedCount,
          newTransactionCount: insertedCount,
          lastScanTime: DateTime.now(),
        ),
      );
    } on PlatformException catch (e) {
      scanNotifier.update(
        SmsScanStatus(
          isScanning: false,
          errorMessage: 'Platform error: ${e.message}',
        ),
      );
    } catch (e) {
      scanNotifier.update(
        SmsScanStatus(isScanning: false, errorMessage: 'Unexpected error: $e'),
      );
    }
  }

  /// Process a single incoming SMS (for real-time detection).
  Future<void> receiveIncomingSms(
    String smsBody, {
    String senderAddress = 'Unknown',
  }) async {
    final privacy = _ref.read(smsPrivacySettingsProvider);
    if (!privacy.detectionEnabled || !privacy.permissionGranted) return;

    if (!isValidFinancialSms(smsBody)) return;

    final db = _db;
    final now = DateTime.now();
    final id =
        'sms_hash_${(senderAddress + smsBody + now.millisecondsSinceEpoch.toString()).hashCode.abs()}';

    final existing = await (db.select(
      db.rawSmsTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (existing != null) return;

    await db
        .into(db.rawSmsTable)
        .insert(
          RawSmsTableCompanion.insert(
            id: id,
            sender: senderAddress,
            body: smsBody,
            receivedDate: now,
            processed: const Value(false),
            ignored: const Value(false),
          ),
        );

    await _loadSmsInbox();

    _ref
        .read(notificationsListProvider.notifier)
        .addNotification(
          title: '💬 SMS Received',
          body: 'New financial SMS from $senderAddress. Tap to review.',
          type: 'reminder',
          metadata: {'smsId': id},
        );
  }

  /// Parse the SMS on-demand when the user clicks Expense/Income
  ParsedSms parseSmsOnDemand(RawSms sms) {
    final body = sms.body;

    // Extract the amount matching Rs/₹ patterns
    final amountReg = RegExp(
      r'(?:Rs\.?|RS|rs|₹)\s*([0-9,]+(?:\.[0-9]{1,2})?)|([0-9,]+(?:\.[0-9]{1,2})?)\s*(?:Rs\.?|RS|rs|₹)',
      caseSensitive: false,
    );
    final matchAmount = amountReg.firstMatch(body);

    double? amount;
    if (matchAmount != null) {
      final matchedGroup = matchAmount.group(1) ?? matchAmount.group(2);
      if (matchedGroup != null) {
        final amtStr = matchedGroup.replaceAll(',', '');
        amount = double.tryParse(amtStr);
      }
    }

    // Extract potential merchant Name or fallback to Unknown
    String merchant = 'Unknown';
    final cleanSender = sms.sender
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), ' ')
        .trim();
    if (cleanSender.isNotEmpty) {
      merchant = cleanSender;
    }

    final atMatch = RegExp(
      r'(?:at|to|in|vpa)\s+([A-Za-z0-9\s#\-_\*]+?)(?:\s+on|\s+for|\s+Ref|\s+Bal|\s+using|\s+Rs|\s+RS|\s+rs|\s+₹|\.|$)',
      caseSensitive: false,
    ).firstMatch(body);
    if (atMatch != null) {
      final parsedM = atMatch.group(1)?.trim();
      if (parsedM != null && parsedM.isNotEmpty && parsedM.length > 2) {
        merchant = parsedM;
      }
    }

    return ParsedSms(
      amount: amount ?? 0.0,
      date: sms.receivedDate,
      sender: sms.sender,
      merchant: merchant,
    );
  }

  Future<void> markProcessed(String id) async {
    final db = _db;
    await (db.update(db.rawSmsTable)..where((t) => t.id.equals(id))).write(
      const RawSmsTableCompanion(processed: Value(true)),
    );
    await _loadSmsInbox();
  }

  Future<void> ignoreTransaction(String id) async {
    final db = _db;
    await (db.update(db.rawSmsTable)..where((t) => t.id.equals(id))).write(
      const RawSmsTableCompanion(ignored: Value(true)),
    );
    await _loadSmsInbox();
  }

  Future<void> ignoreAllPending() async {
    final db = _db;
    await (db.update(db.rawSmsTable)
          ..where((t) => t.processed.equals(false) & t.ignored.equals(false)))
        .write(const RawSmsTableCompanion(ignored: Value(true)));
    await _loadSmsInbox();
  }

  Future<void> clearCache() async {
    final db = _db;
    await db.delete(db.rawSmsTable).go();
    await _loadSmsInbox();
  }

  Future<void> deleteParsedData() async {
    await clearCache();
  }
}

final smsDetectionNotifierProvider =
    StateNotifierProvider<SmsDetectionNotifier, List<RawSms>>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return SmsDetectionNotifier(prefs, ref);
    });
