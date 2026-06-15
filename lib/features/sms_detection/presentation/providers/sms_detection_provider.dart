import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../../transactions/domain/models.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

enum SmsDetectionStatus { pending, approved, rejected }

class SmsTransaction {
  final String id;
  final String smsBody;
  final double amount;
  final String merchant;
  final DateTime timestamp;
  final String referenceNumber;
  final TransactionType type;
  final SmsDetectionStatus status;
  final String category;
  final String senderAddress;

  SmsTransaction({
    required this.id,
    required this.smsBody,
    required this.amount,
    required this.merchant,
    required this.timestamp,
    required this.referenceNumber,
    required this.type,
    required this.status,
    required this.category,
    this.senderAddress = '',
  });

  SmsTransaction copyWith({
    String? id,
    String? smsBody,
    double? amount,
    String? merchant,
    DateTime? timestamp,
    String? referenceNumber,
    TransactionType? type,
    SmsDetectionStatus? status,
    String? category,
    String? senderAddress,
  }) {
    return SmsTransaction(
      id: id ?? this.id,
      smsBody: smsBody ?? this.smsBody,
      amount: amount ?? this.amount,
      merchant: merchant ?? this.merchant,
      timestamp: timestamp ?? this.timestamp,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      category: category ?? this.category,
      senderAddress: senderAddress ?? this.senderAddress,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'smsBody': smsBody,
        'amount': amount,
        'merchant': merchant,
        'timestamp': timestamp.toIso8601String(),
        'referenceNumber': referenceNumber,
        'type': type.name,
        'status': status.name,
        'category': category,
        'senderAddress': senderAddress,
      };

  factory SmsTransaction.fromJson(Map<String, dynamic> json) => SmsTransaction(
        id: json['id'] as String,
        smsBody: json['smsBody'] as String,
        amount: (json['amount'] as num).toDouble(),
        merchant: json['merchant'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        referenceNumber: json['referenceNumber'] as String,
        type: json['type'] == 'income' ? TransactionType.income : TransactionType.expense,
        status: SmsDetectionStatus.values.firstWhere((e) => e.name == json['status']),
        category: json['category'] as String,
        senderAddress: json['senderAddress'] as String? ?? '',
      );
}

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
    StateNotifierProvider<SmsPrivacySettingsNotifier, SmsPrivacySettings>((ref) {
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
}

final smsScanStatusProvider =
    StateNotifierProvider<SmsScanStatusNotifier, SmsScanStatus>((ref) {
  return SmsScanStatusNotifier();
});

// ─── SMS Detection List / State Notifier ───────────────────────────────────

class SmsDetectionNotifier extends StateNotifier<List<SmsTransaction>> {
  final SharedPreferences _prefs;
  final Ref _ref;
  static const _channel = MethodChannel('com.moneylens/sms');

  SmsDetectionNotifier(this._prefs, this._ref) : super([]) {
    _loadSmsInbox();
  }

  static const String _keySmsList = 'sms_detection_list';

  void _loadSmsInbox() {
    final jsonStr = _prefs.getString(_keySmsList);
    if (jsonStr != null) {
      try {
        final list = jsonDecode(jsonStr) as List;
        state = list
            .map((item) => SmsTransaction.fromJson(item as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      } catch (_) {
        state = [];
      }
    }
  }

  Future<void> _saveSmsInbox() async {
    final list = state.map((item) => item.toJson()).toList();
    await _prefs.setString(_keySmsList, jsonEncode(list));
  }

  /// Request READ_SMS permission at runtime and update privacy settings.
  Future<bool> requestSmsPermission() async {
    final status = await Permission.sms.request();
    final granted = status.isGranted;
    await _ref.read(smsPrivacySettingsProvider.notifier).setPermissionGranted(granted);
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

  /// Scan the device SMS inbox for financial messages.
  /// This reads real SMS via the native MethodChannel.
  Future<void> scanDeviceSmsInbox({int limit = 500}) async {
    final scanNotifier = _ref.read(smsScanStatusProvider.notifier);

    // Start scanning
    scanNotifier.update(SmsScanStatus(isScanning: true));

    try {
      // 1. Check native permission
      final hasPermission = await checkNativePermission();
      if (!hasPermission) {
        scanNotifier.update(SmsScanStatus(
          isScanning: false,
          errorMessage: 'SMS permission not granted. Please grant permission from Settings.',
        ));
        return;
      }

      // 2. Read SMS from device via MethodChannel
      final List<dynamic>? rawMessages = await _channel.invokeMethod<List<dynamic>>(
        'getSmsMessages',
        {'limit': limit},
      );

      if (rawMessages == null || rawMessages.isEmpty) {
        scanNotifier.update(SmsScanStatus(
          isScanning: false,
          totalSmsCount: 0,
          financialSmsCount: 0,
          newTransactionCount: 0,
          lastScanTime: DateTime.now(),
          errorMessage: 'No SMS messages found on this device.',
        ));
        return;
      }

      final totalSmsCount = rawMessages.length;
      int financialCount = 0;
      int newCount = 0;

      // 3. Parse each SMS for financial content
      for (final raw in rawMessages) {
        final msg = Map<String, dynamic>.from(raw as Map);
        final body = msg['body'] as String? ?? '';
        final address = msg['address'] as String? ?? '';
        final dateMs = msg['date'] as int? ?? 0;
        final smsDate = dateMs > 0
            ? DateTime.fromMillisecondsSinceEpoch(dateMs)
            : DateTime.now();

        // Try parsing as financial SMS
        final parsed = parseSms(body, smsDate: smsDate, senderAddress: address);
        if (parsed == null) continue;

        financialCount++;

        // 4. Duplicate detection - check against existing items
        final isDuplicate = state.any((existing) =>
            (existing.amount == parsed.amount &&
                existing.referenceNumber == parsed.referenceNumber &&
                parsed.referenceNumber.isNotEmpty) ||
            (existing.smsBody == parsed.smsBody));
        if (isDuplicate) continue;

        newCount++;
        state = [parsed, ...state];
      }

      // Sort by timestamp descending
      state = List.from(state)..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      await _saveSmsInbox();

      scanNotifier.update(SmsScanStatus(
        isScanning: false,
        totalSmsCount: totalSmsCount,
        financialSmsCount: financialCount,
        newTransactionCount: newCount,
        lastScanTime: DateTime.now(),
      ));

      // Trigger notification if new transactions were found
      if (newCount > 0) {
        _ref.read(notificationsListProvider.notifier).addNotification(
              title: '📱 SMS Scan Complete',
              body: 'Found $newCount new financial transaction${newCount > 1 ? 's' : ''} from $financialCount financial SMS (out of $totalSmsCount total).',
              type: 'reminder',
              metadata: {'scanCount': newCount.toString()},
            );
      }
    } on PlatformException catch (e) {
      scanNotifier.update(SmsScanStatus(
        isScanning: false,
        errorMessage: 'Platform error: ${e.message}',
      ));
    } catch (e) {
      scanNotifier.update(SmsScanStatus(
        isScanning: false,
        errorMessage: 'Unexpected error: $e',
      ));
    }
  }

  /// Parses an SMS body for financial content.
  /// Returns null if not a financial SMS.
  SmsTransaction? parseSms(String body, {DateTime? smsDate, String senderAddress = ''}) {
    // Filter: only parse messages that look financial
    final bodyLower = body.toLowerCase();
    final hasFinancialKeyword = bodyLower.contains('debit') ||
        bodyLower.contains('credit') ||
        bodyLower.contains('debited') ||
        bodyLower.contains('credited') ||
        bodyLower.contains('payment') ||
        bodyLower.contains('transferred') ||
        bodyLower.contains('received') ||
        bodyLower.contains('withdrawal') ||
        bodyLower.contains('spent') ||
        bodyLower.contains('txn') ||
        bodyLower.contains('transaction') ||
        bodyLower.contains('upi') ||
        bodyLower.contains('neft') ||
        bodyLower.contains('imps') ||
        bodyLower.contains('salary') ||
        bodyLower.contains('a/c') ||
        bodyLower.contains('acct') ||
        bodyLower.contains('account');

    if (!hasFinancialKeyword) return null;

    // Look for Amount
    final amountReg = RegExp(
      r'(?:Rs\.?\s*|INR\.?\s*|₹\s*)([0-9,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    );
    final matchAmount = amountReg.firstMatch(body);
    if (matchAmount == null) return null;

    final amtStr = matchAmount.group(1)!.replaceAll(',', '');
    final amount = double.tryParse(amtStr) ?? 0.0;
    if (amount <= 0.0) return null;

    // Look for Transaction Type
    var type = TransactionType.expense;
    if (bodyLower.contains('credited') ||
        bodyLower.contains('received') ||
        bodyLower.contains('salary') ||
        bodyLower.contains('refund')) {
      type = TransactionType.income;
    }

    // Look for Reference Number — extract digits, skipping optional alpha prefix
    final refReg = RegExp(
      r'(?:Ref\.?\s*(?:No\.?\s*)?:?\s*|Reference\s*(?:No\.?\s*)?:?\s*|txn\s*(?:id\s*)?:?\s*|UPI/)[A-Za-z]*(\d+)',
      caseSensitive: false,
    );
    final matchRef = refReg.firstMatch(body);
    final referenceNumber = matchRef != null ? matchRef.group(1) ?? '' : '';

    // Auto-detect Merchant & Category
    var merchant = 'Unknown';
    var category = 'Other';

    final merchantMappings = {
      'swiggy': ('Swiggy', 'Food'),
      'zomato': ('Zomato', 'Food'),
      'uber': ('Uber', 'Transport'),
      'ola': ('Ola', 'Transport'),
      'rapido': ('Rapido', 'Transport'),
      'amazon': ('Amazon', 'Shopping'),
      'flipkart': ('Flipkart', 'Shopping'),
      'myntra': ('Myntra', 'Shopping'),
      'ajio': ('Ajio', 'Shopping'),
      'apollo': ('Apollo', 'Medical'),
      'pharmeasy': ('PharmEasy', 'Medical'),
      'netmeds': ('Netmeds', 'Medical'),
      'shell': ('Shell', 'Fuel'),
      'fuel': ('Fuel Station', 'Fuel'),
      'petrol': ('Petrol Pump', 'Fuel'),
      'hp petrol': ('HP Petrol', 'Fuel'),
      'indian oil': ('Indian Oil', 'Fuel'),
      'electricity': ('Electricity', 'Bills'),
      'bescom': ('BESCOM', 'Bills'),
      'airtel': ('Airtel', 'Bills'),
      'jio': ('Jio', 'Bills'),
      'vodafone': ('Vodafone', 'Bills'),
      'bsnl': ('BSNL', 'Bills'),
      'netflix': ('Netflix', 'Entertainment'),
      'spotify': ('Spotify', 'Entertainment'),
      'hotstar': ('Hotstar', 'Entertainment'),
      'google play': ('Google Play', 'Entertainment'),
      'bigbasket': ('BigBasket', 'Groceries'),
      'blinkit': ('Blinkit', 'Groceries'),
      'zepto': ('Zepto', 'Groceries'),
      'instamart': ('Instamart', 'Groceries'),
      'dmart': ('DMart', 'Groceries'),
      'paytm': ('Paytm', 'Transfer'),
      'phonepe': ('PhonePe', 'Transfer'),
      'gpay': ('GPay', 'Transfer'),
      'google pay': ('Google Pay', 'Transfer'),
      'irctc': ('IRCTC', 'Travel'),
      'makemytrip': ('MakeMyTrip', 'Travel'),
    };

    for (final entry in merchantMappings.entries) {
      if (bodyLower.contains(entry.key)) {
        merchant = entry.value.$1;
        category = entry.value.$2;
        break;
      }
    }

    // If no known merchant matched, try extracting from SMS
    if (merchant == 'Unknown') {
      final merchantPatterns = [
        RegExp(r'(?:to|at|for|towards)\s+([A-Za-z][A-Za-z0-9\s]{2,20}?)(?:\s*\.|\s+Ref|\s+UPI|\s+on|\s+via|\s+dated|\s+w\.e\.f|\s*$)', caseSensitive: false),
        RegExp(r'VPA\s+([a-zA-Z0-9.@]+)', caseSensitive: false),
      ];
      for (final pattern in merchantPatterns) {
        final match = pattern.firstMatch(body);
        if (match != null) {
          var extracted = match.group(1)!.trim();
          // Clean up VPA format
          if (extracted.contains('@')) {
            extracted = extracted.split('@').first;
          }
          // Capitalize words
          merchant = extracted
              .split(RegExp(r'\s+'))
              .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1).toLowerCase() : '')
              .join(' ')
              .trim();
          if (merchant.isEmpty) merchant = 'Unknown';
          break;
        }
      }
    }

    final ts = smsDate ?? DateTime.now();

    return SmsTransaction(
      id: 'sms_${ts.millisecondsSinceEpoch}_${(amount * 100).toInt()}_${referenceNumber.hashCode.abs() % 10000}',
      smsBody: body,
      amount: amount,
      merchant: merchant,
      timestamp: ts,
      referenceNumber: referenceNumber,
      type: type,
      status: SmsDetectionStatus.pending,
      category: category,
      senderAddress: senderAddress,
    );
  }

  /// Process a single incoming SMS (for real-time detection).
  Future<void> receiveIncomingSms(String smsBody) async {
    final privacy = _ref.read(smsPrivacySettingsProvider);
    if (!privacy.detectionEnabled || !privacy.permissionGranted) return;

    final parsed = parseSms(smsBody);
    if (parsed == null) return;

    // Duplicate Detection
    final isDuplicate = state.any((t) =>
        (t.amount == parsed.amount &&
            t.referenceNumber == parsed.referenceNumber &&
            parsed.referenceNumber.isNotEmpty) ||
        (t.smsBody == parsed.smsBody));
    if (isDuplicate) return;

    state = [parsed, ...state];
    await _saveSmsInbox();

    _ref.read(notificationsListProvider.notifier).addNotification(
          title: '💬 SMS Transaction Detected',
          body:
              'Found ${parsed.type == TransactionType.income ? 'credit' : 'debit'} of ₹${parsed.amount.toStringAsFixed(0)} to ${parsed.merchant}. Tap to review.',
          type: 'reminder',
          metadata: {'smsId': parsed.id},
        );
  }

  Future<void> approveTransaction(String id,
      {String? category, double? amount, String? merchant}) async {
    final list = List<SmsTransaction>.from(state);
    final idx = list.indexWhere((t) => t.id == id);
    if (idx == -1) return;

    final sms = list[idx];
    final finalCategory = category ?? sms.category;
    final finalAmount = amount ?? sms.amount;
    final finalMerchant = merchant ?? sms.merchant;

    // Log transaction in App Database
    await _ref.read(expenseNotifierProvider.notifier).addExpense(
          title: finalMerchant,
          amount: finalAmount,
          category: finalCategory,
          notes: 'SMS Auto-detected • Ref: ${sms.referenceNumber}',
        );

    // Update status to approved
    list[idx] = sms.copyWith(
      status: SmsDetectionStatus.approved,
      category: finalCategory,
      amount: finalAmount,
      merchant: finalMerchant,
    );
    state = list;
    await _saveSmsInbox();
  }

  Future<void> rejectTransaction(String id) async {
    state = state
        .map((t) => t.id == id ? t.copyWith(status: SmsDetectionStatus.rejected) : t)
        .toList();
    await _saveSmsInbox();
  }

  Future<void> clearCache() async {
    state = [];
    await _saveSmsInbox();
  }

  Future<void> deleteParsedData() async {
    state = [];
    await _prefs.remove(_keySmsList);
  }
}

final smsDetectionNotifierProvider =
    StateNotifierProvider<SmsDetectionNotifier, List<SmsTransaction>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SmsDetectionNotifier(prefs, ref);
});
