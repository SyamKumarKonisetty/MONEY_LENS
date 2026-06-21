# Maintenance Guide

This document describes standard operational maintenance procedures for MoneyLens V2, covering database schema updates, dependency upgrades, and troubleshooting.

## 1. Database Schema Migrations (Drift)

When adding tables or columns:
1.  Define the table classes in `lib/core/database/app_database.dart`.
2.  Increment the `schemaVersion` in the `AppDatabase` class.
3.  Write the migration logic inside the `onUpgrade` callback inside the `AppDatabase` class:
    ```dart
    onUpgrade: (m, from, to) async {
      if (from < 8) {
        // Migration code e.g. await m.createTable(newTable);
      }
    }
    ```
4.  Run build_runner to update models:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```
5.  Always write tests validating upgrading configurations from older versions to the new scheme under `test/`.

---

## 2. Dependency Upgrades

To upgrade project dependencies:
1.  Review package compatibility in `pubspec.yaml`.
2.  Check for breaking API changes, particularly for Drift, Riverpod, and fl_chart.
3.  Run dependency updates:
    ```bash
    flutter pub upgrade
    ```
4.  Run the full unit test suite to verify no package regression:
    ```bash
    flutter test
    ```
