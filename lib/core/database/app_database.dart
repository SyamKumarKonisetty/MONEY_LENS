import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// SQLite Expenses table definition.
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  TextColumn get category => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  /// Supported types: 'income', 'expense'
  TextColumn get transactionType =>
      text().withDefault(const Constant('expense'))();
}

/// SQLite Budgets table definition.
class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text()();
  RealColumn get monthlyLimit => real()();
  RealColumn get spentAmount => real().withDefault(const Constant(0.0))();
  RealColumn get remainingAmount => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get period => text().withDefault(const Constant('monthly'))();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}

/// SQLite SavingsGoals table definition.
class SavingsGoals extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  IntColumn get month => integer()();
  IntColumn get year => integer()();
}

/// SQLite RawSms table definition for Inbox 2.0.
@DataClassName('RawSms')
class RawSmsTable extends Table {
  TextColumn get id => text()();
  TextColumn get sender => text()();
  TextColumn get body => text()();
  DateTimeColumn get receivedDate => dateTime()();
  BoolColumn get processed => boolean().withDefault(const Constant(false))();
  BoolColumn get ignored => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local database instance class utilizing Drift.
@DriftDatabase(tables: [Expenses, Budgets, SavingsGoals, RawSmsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// Singleton shared instance of the database.
  static final AppDatabase instance = AppDatabase();

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(expenses, expenses.transactionType);
      }
      if (from < 3) {
        await m.createTable(budgets);
      }
      if (from < 4) {
        await m.addColumn(budgets, budgets.category);
      }
      if (from < 5) {
        await m.createTable(savingsGoals);
      }
      if (from < 6) {
        await m.drop(budgets);
        await m.createTable(budgets);
      }
      if (from < 7) {
        await m.createTable(rawSmsTable);
      }
      if (from < 8) {
        await m.addColumn(budgets, budgets.period);
        await m.addColumn(budgets, budgets.isEnabled);
        await m.addColumn(budgets, budgets.isArchived);
      }
    },
  );

  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(expenses).go();
      await delete(budgets).go();
      await delete(savingsGoals).go();
      await delete(rawSmsTable).go();
    });
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'money_lens');
  }
}
