import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// ─── SMS Detection List / State Notifier ───────────────────────────────────

class SmsDetectionNotifier extends StateNotifier<List<SmsTransaction>> {
  final SharedPreferences _prefs;
  final Ref _ref;

  SmsDetectionNotifier(this._prefs, this._ref) : super([]) {
    _loadSmsInbox();
  }

  static const String _keySmsList = 'sms_detection_list';

  void _loadSmsInbox() {
    final jsonStr = _prefs.getString(_keySmsList);
    if (jsonStr != null) {
      try {
        final list = jsonDecode(jsonStr) as List;
        state = list.map((item) => SmsTransaction.fromJson(item as Map<String, dynamic>)).toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      } catch (_) {
        state = [];
      }
    } else {
      _seedDemoInbox();
    }
  }

  void _seedDemoInbox() {
    state = [
      SmsTransaction(
        id: 'sms_demo1',
        smsBody: 'Rs.485 debited from Account XX1234 for Swiggy. Ref No: 99812739.',
        amount: 485.0,
        merchant: 'Swiggy',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        referenceNumber: '99812739',
        type: TransactionType.expense,
        status: SmsDetectionStatus.pending,
        category: 'Food',
      ),
      SmsTransaction(
        id: 'sms_demo2',
        smsBody: 'UPI payment of Rs.245 successful to Uber. Ref: 481920.',
        amount: 245.0,
        merchant: 'Uber',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        referenceNumber: '481920',
        type: TransactionType.expense,
        status: SmsDetectionStatus.pending,
        category: 'Transport',
      ),
    ];
    _saveSmsInbox();
  }

  Future<void> _saveSmsInbox() async {
    final list = state.map((item) => item.toJson()).toList();
    await _prefs.setString(_keySmsList, jsonEncode(list));
  }

  // Parses incoming SMS string on device
  Future<void> receiveIncomingSms(String smsBody) async {
    final privacy = _ref.read(smsPrivacySettingsProvider);
    if (!privacy.detectionEnabled || !privacy.permissionGranted) return;

    // 1. Check parsing
    final parsed = parseSms(smsBody);
    if (parsed == null) return;

    // 2. Duplicate Detection
    final isDuplicate = state.any((t) =>
        t.amount == parsed.amount &&
        (t.referenceNumber == parsed.referenceNumber && parsed.referenceNumber.isNotEmpty));
    if (isDuplicate) return;

    // Add to inbox
    state = [parsed, ...state];
    await _saveSmsInbox();

    // Trigger push notification reminder
    _ref.read(notificationsListProvider.notifier).addNotification(
          title: '💬 SMS Transaction Detected',
          body: 'Found ${parsed.type == TransactionType.income ? 'credit' : 'debit'} of ₹${parsed.amount.toStringAsFixed(0)} to ${parsed.merchant}. Tap to review.',
          type: 'reminder',
          metadata: {'smsId': parsed.id},
        );
  }

  SmsTransaction? parseSms(String body) {
    // Look for Amount
    final amountReg = RegExp(r'(?:Rs\.?|INR)\s*([\d,]+(?:\.\d+)?)', caseSensitive: false);
    final matchAmount = amountReg.firstMatch(body);
    if (matchAmount == null) return null;

    final amtStr = matchAmount.group(1)!.replaceAll(',', '');
    final amount = double.tryParse(amtStr) ?? 0.0;
    if (amount <= 0.0) return null;

    // Look for Transaction Type
    var type = TransactionType.expense;
    if (body.toLowerCase().contains('credited') || body.toLowerCase().contains('received')) {
      type = TransactionType.income;
    }

    // Look for Reference Number
    final refReg = RegExp(r'(?:Ref\D*?|UPI/|Reference\D*?)(\d+)', caseSensitive: false);
    final matchRef = refReg.firstMatch(body);
    final referenceNumber = matchRef != null ? matchRef.group(1) ?? '' : '';

    // Auto-detect Merchant & Category
    var merchant = 'Merchant';
    var category = 'Other';

    final bodyLower = body.toLowerCase();
    if (bodyLower.contains('swiggy')) {
      merchant = 'Swiggy';
      category = 'Food';
    } else if (bodyLower.contains('zomato')) {
      merchant = 'Zomato';
      category = 'Food';
    } else if (bodyLower.contains('uber')) {
      merchant = 'Uber';
      category = 'Transport';
    } else if (bodyLower.contains('amazon')) {
      merchant = 'Amazon';
      category = 'Shopping';
    } else if (bodyLower.contains('apollo')) {
      merchant = 'Apollo';
      category = 'Medical';
    } else if (bodyLower.contains('shell') || bodyLower.contains('fuel') || bodyLower.contains('petrol')) {
      merchant = 'Shell Petrol';
      category = 'Fuel';
    } else if (bodyLower.contains('electricity') || bodyLower.contains('bescom') || bodyLower.contains('bill')) {
      merchant = 'Electricity';
      category = 'Bills';
    } else {
      // Attempt to extract generic merchant after "for" or "to"
      final merchantReg = RegExp(r'(?:to|for|at)\s+([\w\s]{3,15}?)(?:\.|\s+Ref|\s+UPI|\s+Acc|\Z)', caseSensitive: false);
      final matchMerch = merchantReg.firstMatch(body);
      if (matchMerch != null) {
        merchant = matchMerch.group(1)!.trim();
        // Capitalize words
        merchant = merchant.split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '').join(' ');
      }
    }

    return SmsTransaction(
      id: 'sms_${DateTime.now().millisecondsSinceEpoch}_${(amount * 10).toInt()}',
      smsBody: body,
      amount: amount,
      merchant: merchant,
      timestamp: DateTime.now(),
      referenceNumber: referenceNumber,
      type: type,
      status: SmsDetectionStatus.pending,
      category: category,
    );
  }

  Future<void> approveTransaction(String id, {String? category, double? amount, String? merchant}) async {
    final list = List<SmsTransaction>.from(state);
    final idx = list.indexWhere((t) => t.id == id);
    if (idx == -1) return;

    final sms = list[idx];
    final finalCategory = category ?? sms.category;
    final finalAmount = amount ?? sms.amount;
    final finalMerchant = merchant ?? sms.merchant;

    // 1. Log transaction in App Database
    await _ref.read(expenseNotifierProvider.notifier).addExpense(
          title: finalMerchant,
          amount: finalAmount,
          category: finalCategory,
          notes: 'SMS Auto-detected • Ref: ${sms.referenceNumber}',
        );

    // 2. Update status to approved
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
    state = state.map((t) => t.id == id ? t.copyWith(status: SmsDetectionStatus.rejected) : t).toList();
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
