# Architecture Reference Guide

MoneyLens is structured using a feature-first clean architecture model designed for separation of concerns, readability, and long-term testability.

## 1. Directory Architecture

```
lib/
├── core/               # Shared cross-cutting concerns
│   ├── database/       # Drift SQLite setup (AppDatabase)
│   ├── routing/        # GoRouter navigation boundaries (AppScaffold)
│   ├── theme/          # Typography and color palettes
│   └── utils/          # CSV parsers and helpers
├── design_system/       # Reusable components and tokens (MLDS / Project AURA)
├── features/           # Feature modules
│   ├── auth/           # PIN setup and verification
│   ├── dashboard/      # Metrics and layout assembly
│   ├── transactions/   # Ledger database management
│   ├── sms_detection/  # Local SMS parser and smart inbox
│   └── settings/       # Settings and profile management
└── production/         # Privacy filters and security validations
```

---

## 2. Core Framework Design Patterns

1.  **Repository Pattern**: Features decoupling local drift tables into clear domain entities and repositories (e.g. `BudgetRepository`, `ExpenseRepository`).
2.  **State Management**: Riverpod `StateNotifier` and `ChangeNotifierProvider` governance. Handlers are structured as pure logic controllers separated from presentation layers.
3.  **Local Persistence**: 
    - **Drift (SQLite)**: Provides reactive streams of data from the database, automatically updating the UI when transactions are deleted or added.
    - **SharedPreferences**: Stores minor configurations (App PIN hashes, onboarding preferences, theme selection) typesafely.
