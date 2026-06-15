import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/app_database.dart';

class BackupHelper {
  /// Serialize all database data to a JSON String.
  static Future<String> serializeData() async {
    final db = AppDatabase.instance;
    
    // 1. Query expenses/transactions
    final expensesList = await db.select(db.expenses).get();
    final expensesJson = expensesList.map((e) => {
      'title': e.title,
      'amount': e.amount,
      'category': e.category,
      'notes': e.notes,
      'createdAt': e.createdAt.toIso8601String(),
      'updatedAt': e.updatedAt.toIso8601String(),
      'transactionType': e.transactionType,
    }).toList();

    // 2. Query budgets
    final budgetsList = await db.select(db.budgets).get();
    final budgetsJson = budgetsList.map((b) => {
      'category': b.category,
      'monthlyLimit': b.monthlyLimit,
      'createdAt': b.createdAt.toIso8601String(),
      'updatedAt': b.updatedAt.toIso8601String(),
    }).toList();

    // 3. Query savings goals
    final savingsList = await db.select(db.savingsGoals).get();
    final savingsJson = savingsList.map((s) => {
      'amount': s.amount,
      'month': s.month,
      'year': s.year,
    }).toList();

    final data = {
      'version': 1,
      'expenses': expensesJson,
      'budgets': budgetsJson,
      'savingsGoals': savingsJson,
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Deserialize a JSON String and reload it into the database tables.
  static Future<void> deserializeData(String jsonString) async {
    final db = AppDatabase.instance;
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    // 1. Clear database completely
    await db.clearAllData();

    // 2. Import all data inside a single transaction
    await db.transaction(() async {
      // Import expenses
      if (data['expenses'] != null) {
        final expenses = data['expenses'] as List;
        for (final item in expenses) {
          final row = ExpensesCompanion.insert(
            title: item['title'] as String,
            amount: (item['amount'] as num).toDouble(),
            category: item['category'] as String,
            notes: Value(item['notes'] as String?),
            createdAt: DateTime.parse(item['createdAt'] as String),
            updatedAt: item['updatedAt'] != null
                ? DateTime.parse(item['updatedAt'] as String)
                : DateTime.now(),
            transactionType: Value(item['transactionType'] as String? ?? 'expense'),
          );
          await db.into(db.expenses).insert(row);
        }
      }

      // Import budgets
      if (data['budgets'] != null) {
        final budgets = data['budgets'] as List;
        for (final item in budgets) {
          final row = BudgetsCompanion.insert(
            category: item['category'] as String,
            monthlyLimit: (item['monthlyLimit'] as num).toDouble(),
            createdAt: item['createdAt'] != null
                ? DateTime.parse(item['createdAt'] as String)
                : DateTime.now(),
            updatedAt: item['updatedAt'] != null
                ? DateTime.parse(item['updatedAt'] as String)
                : DateTime.now(),
          );
          await db.into(db.budgets).insert(row);
        }
      }

      // Import savings goals
      if (data['savingsGoals'] != null) {
        final savings = data['savingsGoals'] as List;
        for (final item in savings) {
          final row = SavingsGoalsCompanion.insert(
            amount: (item['amount'] as num).toDouble(),
            month: (item['month'] as num).toInt(),
            year: (item['year'] as num).toInt(),
          );
          await db.into(db.savingsGoals).insert(row);
        }
      }
    });
  }

  /// Export database to a JSON file and trigger system sharing sheet.
  static Future<void> shareBackupFile() async {
    final jsonStr = await serializeData();
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/moneylens_backup.json');
    await file.writeAsString(jsonStr);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'MoneyLens Backup Data File (JSON)',
      ),
    );
  }
}
