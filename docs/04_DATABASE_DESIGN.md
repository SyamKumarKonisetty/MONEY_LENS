# 04: Database Design

## Purpose
To map the relational data structure supporting MoneyLens, utilizing Drift (SQLite) as the underlying engine.

## Overview
The database is strictly offline, stored in the application's secure documents directory (`path_provider`). It relies on standard relational SQL concepts.

## ER Diagram
![Database Diagram](diagrams/database.mmd)

## Tables

### 1. Transactions
Stores individual expense or income records.
- `id` (Int, Primary Key, AutoIncrement)
- `amount` (Real)
- `title` (Text)
- `date` (DateTime)
- `type` (Text: "income", "expense")
- `categoryId` (Int, Foreign Key to Categories)

### 2. Categories
Groups transactions for budgeting.
- `id` (Int, Primary Key, AutoIncrement)
- `name` (Text, Unique)
- `color` (Text, Hex format)
- `budgetLimit` (Real, optional)

### 3. Settings
Stores core user preferences locally.
- `key` (Text, Primary Key)
- `value` (Text)

## Migration Strategy
Drift manages schema versioning.
1. Increment schema version in `AppDatabase`.
2. Provide a migration strategy in the `migration` property.
3. Write raw SQL `ALTER TABLE` statements for additions, avoiding destructive drops where possible to prevent user data loss.

## Future Improvements
- Add `RecurringTransactions` table.
- Add `Attachments` table mapping local URIs of receipt images to transaction IDs.
