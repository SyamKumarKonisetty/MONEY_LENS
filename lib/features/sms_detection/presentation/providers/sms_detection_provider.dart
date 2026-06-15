// ignore_for_file: avoid_print
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
  final double? amount;
  final String? merchant;
  final DateTime timestamp;
  final String referenceNumber;
  final TransactionType? type;
  final SmsDetectionStatus status;
  final String? category;
  final String? senderAddress;
  final bool parserFailed;

  SmsTransaction({
    required this.id,
    required this.smsBody,
    this.amount,
    this.merchant,
    required this.timestamp,
    required this.referenceNumber,
    this.type,
    required this.status,
    this.category,
    this.senderAddress,
    this.parserFailed = false,
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
    bool? parserFailed,
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
      parserFailed: parserFailed ?? this.parserFailed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'smsBody': smsBody,
        'amount': amount,
        'merchant': merchant,
        'timestamp': timestamp.toIso8601String(),
        'referenceNumber': referenceNumber,
        'type': type?.name,
        'status': status.name,
        'category': category,
        'senderAddress': senderAddress,
        'parserFailed': parserFailed,
      };

  factory SmsTransaction.fromJson(Map<String, dynamic> json) => SmsTransaction(
        id: json['id'] as String? ?? '',
        smsBody: json['smsBody'] as String? ?? '',
        amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
        merchant: json['merchant'] as String?,
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
        referenceNumber: json['referenceNumber'] as String? ?? '',
        type: json['type'] == null
            ? null
            : (json['type'] == 'income' ? TransactionType.income : TransactionType.expense),
        status: SmsDetectionStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => SmsDetectionStatus.pending,
        ),
        category: json['category'] as String?,
        senderAddress: json['senderAddress'] as String?,
        parserFailed: json['parserFailed'] as bool? ?? false,
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
  static const String _keySmsList = 'sms_detection_list';
  static const String _keyIgnoredList = 'sms_ignored_ids';
  Set<String> _ignoredIds = {};

  SmsDetectionNotifier(this._prefs, this._ref) : super([]) {
    _loadIgnoredIds();
    _loadSmsInbox();
  }

  void _loadIgnoredIds() {
    final list = _prefs.getStringList(_keyIgnoredList);
    if (list != null) {
      _ignoredIds = list.toSet();
    }
  }

  Future<void> _saveIgnoredIds() async {
    await _prefs.setStringList(_keyIgnoredList, _ignoredIds.toList());
  }

  void _loadSmsInbox() {
    final jsonStr = _prefs.getString(_keySmsList);
    if (jsonStr != null) {
      try {
        final list = jsonDecode(jsonStr) as List;
        state = list
            .map((item) => SmsTransaction.fromJson(item as Map<String, dynamic>))
            .where((t) => !_ignoredIds.contains(t.id))
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

  /// Scan the device SMS inbox for all messages (MVP - no initial bank filter).
  Future<void> scanDeviceSmsInbox({int limit = 500}) async {
    final scanNotifier = _ref.read(smsScanStatusProvider.notifier);
    scanNotifier.update(SmsScanStatus(isScanning: true));

    try {
      final hasPermission = await checkNativePermission();
      if (!hasPermission) {
        scanNotifier.update(SmsScanStatus(
          isScanning: false,
          errorMessage: 'SMS permission not granted. Please grant permission from Settings.',
        ));
        return;
      }

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
      final List<SmsTransaction> scannedList = [];

      for (final raw in rawMessages) {
        final msg = Map<String, dynamic>.from(raw as Map);
        final body = msg['body'] as String? ?? '';
        final address = msg['address'] as String? ?? '';
        final dateMs = msg['date'] as int? ?? 0;
        final smsDate = dateMs > 0
            ? DateTime.fromMillisecondsSinceEpoch(dateMs)
            : DateTime.now();

        final parsed = parseSms(body, smsDate: smsDate, senderAddress: address);
        
        // Skip ignored transactions
        if (_ignoredIds.contains(parsed.id)) {
          continue;
        }
        scannedList.add(parsed);
      }

      // Merge scanned list with existing list reactively, eliminating duplicates
      final Map<String, SmsTransaction> mergedMap = {};
      for (final item in state) {
        if (!_ignoredIds.contains(item.id)) {
          mergedMap[item.id] = item;
        }
      }
      for (final item in scannedList) {
        mergedMap[item.id] = item;
      }

      state = mergedMap.values.toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      await _saveSmsInbox();

      scanNotifier.update(SmsScanStatus(
        isScanning: false,
        totalSmsCount: totalSmsCount,
        financialSmsCount: scannedList.length,
        newTransactionCount: scannedList.length,
        lastScanTime: DateTime.now(),
      ));
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

  /// Parses an SMS body for details.
  /// For the MVP approach, it extracts the amount if available but parses ALL SMS.
  SmsTransaction parseSms(String body, {DateTime? smsDate, String senderAddress = ''}) {
    final amountReg = RegExp(
      r'(?:Rs\.?|INR|₹)\s*([0-9,]+(?:\.[0-9]{1,2})?)',
      caseSensitive: false,
    );
    final matchAmount = amountReg.firstMatch(body);
    
    double? amount;
    bool parserFailed = false;

    if (matchAmount != null) {
      final matchedGroup = matchAmount.group(1);
      if (matchedGroup != null) {
        final amtStr = matchedGroup.replaceAll(',', '');
        amount = double.tryParse(amtStr);
      }
    }
    
    if (amount == null || amount <= 0.0) {
      amount = null;
      parserFailed = true;
    }

    final ts = smsDate ?? DateTime.now();
    final amountInt = amount != null ? (amount * 100).toInt() : 0;

    return SmsTransaction(
      id: 'sms_${ts.millisecondsSinceEpoch}_${amountInt}_${body.hashCode.abs() % 10000}',
      smsBody: body,
      amount: amount,
      merchant: null,
      timestamp: ts,
      referenceNumber: '',
      type: null,
      status: SmsDetectionStatus.pending,
      category: null,
      senderAddress: senderAddress.isEmpty ? 'Unknown' : senderAddress,
      parserFailed: parserFailed,
    );
  }

  /// Process a single incoming SMS (for real-time detection).
  Future<void> receiveIncomingSms(String smsBody) async {
    final privacy = _ref.read(smsPrivacySettingsProvider);
    if (!privacy.detectionEnabled || !privacy.permissionGranted) return;

    final parsed = parseSms(smsBody);
    if (_ignoredIds.contains(parsed.id)) return;

    state = [parsed, ...state];
    await _saveSmsInbox();

    _ref.read(notificationsListProvider.notifier).addNotification(
          title: '💬 SMS Received',
          body: 'New SMS from ${parsed.senderAddress}. Tap to review.',
          type: 'reminder',
          metadata: {'smsId': parsed.id},
        );
  }

  Future<void> approveTransaction(
    String id, {
    String? category,
    double? amount,
    String? merchant,
    TransactionType? type,
  }) async {
    final list = List<SmsTransaction>.from(state);
    final idx = list.indexWhere((t) => t.id == id);
    if (idx == -1) return;

    final sms = list[idx];
    final finalCategory = category ?? 'Other';
    final finalAmount = amount ?? 0.0;
    final finalMerchant = merchant ?? sms.senderAddress ?? 'Unknown';
    final finalType = type ?? TransactionType.expense;

    try {
      await _ref.read(expenseNotifierProvider.notifier).addExpense(
            title: finalMerchant,
            amount: finalAmount,
            category: finalCategory,
            notes: 'SMS Auto-detected',
            transactionType: finalType.name,
          );
      
      _ignoredIds.add(id);
      await _saveIgnoredIds();
      
      state = state.where((t) => t.id != id).toList();
      await _saveSmsInbox();
    } catch (e) {
      print('Failed to approve transaction: $e');
      rethrow;
    }
  }

  Future<void> ignoreTransaction(String id) async {
    _ignoredIds.add(id);
    await _saveIgnoredIds();
    state = state.where((t) => t.id != id).toList();
    await _saveSmsInbox();
  }

  Future<void> rejectTransaction(String id) async {
    await ignoreTransaction(id);
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
