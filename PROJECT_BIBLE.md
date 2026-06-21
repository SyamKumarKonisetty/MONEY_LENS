# MoneyLens V2 — Project Bible

MoneyLens is a premium, privacy-first, offline-first personal finance application that empowers users to track expenses, establish budgets, monitor transactions, and check their financial health without sending any sensitive information to the cloud.

---

## 1. Product Core Pillars

1.  **Privacy Above All**: Zero internet connections, no cloud sync, no tracking trackers, and no user registration database. Data is owned by the user.
2.  **Seamless Automation**: The Smart Inbox reads incoming financial SMS notifications locally on-device, parsing them into visual ledger entries in real-time.
3.  **Premium Craftsmanship**: Designed with micro-interactions, spring mechanics, tactile haptic patterns, and a pure OLED black backdrop for Dark Mode.
4.  **Absolute Resilience**: Database schema migrations, low-memory handling, secure keypad entry, and isolate-based background processing.

---

## 2. Design Foundations (MLDS)

We implement **MLDS (MoneyLens Design System)**, code-named **Project AURA**:
- **FTS (Financial Typography System)**: Using Google Fonts Inter for readability/amounts and NothingDotMatrix for small uppercase status tags.
- **ECS (Emotional Color System)**: Non- neon, calming status color parameters to reduce user financial anxiety.
- **FIL (Financial Interaction Language)**: Interactive spring physics and semantic haptic responses on user inputs.

---

## 3. Tech Stack

- **Framework**: Flutter SDK (`^3.12.2`)
- **State Management**: Riverpod (`^2.6.1`)
- **Routing**: GoRouter (`^14.6.2`)
- **Local Storage**: Drift (SQLite) database and SharedPreferences.
- **Charts**: fl_chart (`^0.70.0`)
