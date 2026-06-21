import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/app_database.dart';

class BackupHelper {
  /// Generates a formatted filename for the CSV backup.
  static String generateBackupFileName() {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return 'MoneyLens_Backup_${year}_${month}_$day.csv';
  }

  /// Helper to escape dynamic fields for CSV.
  static String _escapeCsvField(dynamic field) {
    if (field == null) return '';
    final str = field.toString();
    if (str.contains(',') ||
        str.contains('"') ||
        str.contains('\n') ||
        str.contains('\r')) {
      return '"${str.replaceAll('"', '""')}"';
    }
    return str;
  }

  /// Convert list of fields to a single CSV row line.
  static String _toCsvLine(List<dynamic> fields) {
    return fields.map(_escapeCsvField).join(',');
  }

  /// Parses entire CSV string character-by-character supporting quotes, commas, and embedded newlines.
  static List<List<String>> parseCsv(String csvText) {
    final List<List<String>> rows = [];
    List<String> currentRow = [];
    final StringBuffer buffer = StringBuffer();
    bool inQuotes = false;

    int i = 0;
    while (i < csvText.length) {
      final char = csvText[i];
      if (char == '"') {
        if (inQuotes && i + 1 < csvText.length && csvText[i + 1] == '"') {
          buffer.write('"');
          i += 2;
          continue;
        } else {
          inQuotes = !inQuotes;
          i++;
          continue;
        }
      } else if (char == ',' && !inQuotes) {
        currentRow.add(buffer.toString());
        buffer.clear();
      } else if ((char == '\n' || char == '\r') && !inQuotes) {
        if (char == '\r' && i + 1 < csvText.length && csvText[i + 1] == '\n') {
          i++;
        }
        currentRow.add(buffer.toString());
        buffer.clear();
        if (currentRow.isNotEmpty &&
            (currentRow.length > 1 || currentRow[0].isNotEmpty)) {
          rows.add(currentRow);
        }
        currentRow = [];
      } else {
        buffer.write(char);
      }
      i++;
    }
    if (buffer.isNotEmpty || currentRow.isNotEmpty) {
      currentRow.add(buffer.toString());
      if (currentRow.isNotEmpty &&
          (currentRow.length > 1 || currentRow[0].isNotEmpty)) {
        rows.add(currentRow);
      }
    }
    return rows;
  }

  /// Serialize all database data to a unified CSV string.
  static Future<String> serializeDataToCsv() async {
    final db = AppDatabase.instance;
    final buffer = StringBuffer();

    // CSV Header row
    buffer.writeln(
      'Record Type,Name,Amount,Category/Month,Notes/Year,Created At,Updated At,Transaction Type',
    );

    // 1. Serialize expenses/transactions
    final expensesList = await db.select(db.expenses).get();
    for (final e in expensesList) {
      buffer.writeln(
        _toCsvLine([
          'Expense',
          e.title,
          e.amount,
          e.category,
          e.notes ?? '',
          e.createdAt.toIso8601String(),
          e.updatedAt.toIso8601String(),
          e.transactionType,
        ]),
      );
    }

    // 2. Serialize budgets
    final budgetsList = await db.select(db.budgets).get();
    for (final b in budgetsList) {
      buffer.writeln(
        _toCsvLine([
          'Budget',
          b.category,
          b.monthlyLimit,
          b.spentAmount,
          b.remainingAmount,
          b.createdAt.toIso8601String(),
          b.updatedAt.toIso8601String(),
          '',
        ]),
      );
    }

    // 3. Serialize savings goals
    final savingsList = await db.select(db.savingsGoals).get();
    for (final s in savingsList) {
      buffer.writeln(
        _toCsvLine(['SavingsGoal', '', s.amount, s.month, s.year, '', '', '']),
      );
    }

    return buffer.toString();
  }

  /// Parse the CSV and generate a preview count map without modifying the database.
  static Map<String, int> getImportPreviewFromCsv(String csvString) {
    final rows = parseCsv(csvString);
    int expensesCount = 0;
    int budgetsCount = 0;
    int savingsCount = 0;

    for (final row in rows) {
      if (row.isEmpty) continue;
      final type = row[0];
      if (type == 'Expense') {
        expensesCount++;
      } else if (type == 'Budget') {
        budgetsCount++;
      } else if (type == 'SavingsGoal') {
        savingsCount++;
      }
    }

    return {
      'expenses': expensesCount,
      'budgets': budgetsCount,
      'savingsGoals': savingsCount,
    };
  }

  /// Deserialize CSV rows and reload them into database tables.
  static Future<void> deserializeDataFromCsv(String csvString) async {
    final db = AppDatabase.instance;
    final rows = parseCsv(csvString);

    // 1. Clear database completely
    await db.clearAllData();

    // 2. Import all data inside a single transaction
    await db.transaction(() async {
      for (final row in rows) {
        if (row.isEmpty || row[0] == 'Record Type') continue;

        final type = row[0];
        if (type == 'Expense') {
          if (row.length < 8) continue;
          final titleVal = row[1];
          final amountVal = double.tryParse(row[2]) ?? 0.0;
          final categoryVal = row[3];
          final notesVal = row[4].isEmpty ? null : row[4];
          final createdVal = DateTime.tryParse(row[5]) ?? DateTime.now();
          final updatedVal = DateTime.tryParse(row[6]) ?? DateTime.now();
          final txTypeVal = row[7];

          final expenseRow = ExpensesCompanion.insert(
            title: titleVal,
            amount: amountVal,
            category: categoryVal,
            notes: Value(notesVal),
            createdAt: createdVal,
            updatedAt: updatedVal,
            transactionType: Value(
              txTypeVal.isNotEmpty ? txTypeVal : 'expense',
            ),
          );
          await db.into(db.expenses).insert(expenseRow);
        } else if (type == 'Budget') {
          if (row.length < 7) continue;
          final categoryVal = row[1];
          final limitVal = double.tryParse(row[2]) ?? 0.0;
          final spentVal = double.tryParse(row[3]) ?? 0.0;
          final remainingVal = double.tryParse(row[4]) ?? 0.0;
          final createdVal = DateTime.tryParse(row[5]) ?? DateTime.now();
          final updatedVal = DateTime.tryParse(row[6]) ?? DateTime.now();

          final budgetRow = BudgetsCompanion.insert(
            category: categoryVal,
            monthlyLimit: limitVal,
            spentAmount: Value(spentVal),
            remainingAmount: Value(remainingVal),
            createdAt: createdVal,
            updatedAt: updatedVal,
          );
          await db.into(db.budgets).insert(budgetRow);
        } else if (type == 'SavingsGoal') {
          if (row.length < 5) continue;
          final amountVal = double.tryParse(row[2]) ?? 0.0;
          final monthVal = int.tryParse(row[3]) ?? 1;
          final yearVal = int.tryParse(row[4]) ?? DateTime.now().year;

          final savingsRow = SavingsGoalsCompanion.insert(
            amount: amountVal,
            month: monthVal,
            year: yearVal,
          );
          await db.into(db.savingsGoals).insert(savingsRow);
        }
      }
    });
  }

  /// Save the backup string to a file locally.
  /// On Android, try writing to the public /storage/emulated/0/Download/MoneyLens/ folder first.
  /// Fallback to external storage directory or application documents directory if restricted.
  static Future<File> saveBackupLocally(String csvStr, String fileName) async {
    Directory? targetDir;

    if (Platform.isAndroid) {
      final downloadDir = Directory('/storage/emulated/0/Download/MoneyLens');
      try {
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        final testFile = File('${downloadDir.path}/$fileName');
        await testFile.writeAsString(csvStr);
        return testFile;
      } catch (e) {
        // Fallback if public downloads is restricted
        final extDir = await getExternalStorageDirectory();
        if (extDir != null) {
          targetDir = Directory('${extDir.path}/MoneyLens');
        }
      }
    }

    if (targetDir == null) {
      if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        final downloadDir = await getDownloadsDirectory();
        if (downloadDir != null) {
          targetDir = Directory('${downloadDir.path}/MoneyLens');
        }
      }
    }

    // Default fallback to application documents directory
    targetDir ??= await getApplicationDocumentsDirectory();

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final file = File('${targetDir.path}/$fileName');
    await file.writeAsString(csvStr);
    return file;
  }

  /// Share the backup file directly using SharePlus.
  static Future<void> shareBackupFile(String csvStr, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(csvStr);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'MoneyLens Backup Data File (CSV)',
      ),
    );
  }
}
