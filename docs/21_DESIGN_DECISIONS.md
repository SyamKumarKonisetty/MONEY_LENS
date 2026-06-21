# 21: Design Decisions

## Purpose
To record the rationale behind major engineering choices, preventing future teams from retreading old debates.

## 1. Why Local SQLite (Drift) instead of Firebase?
**Decision**: The core value proposition of MoneyLens is absolute privacy. Utilizing Firebase would immediately compromise the "offline-first" promise and require extensive Data Safety declarations on the Play Store. Drift provides robust relational capabilities with Reactive Streams.

## 2. Why Riverpod instead of BLoC?
**Decision**: BLoC requires significant boilerplate and introduces strict event-driven overhead. Riverpod provides compile-time safety and dependency injection capabilities seamlessly out of the box, mapping perfectly to Drift's stream outputs.

## 3. Why Glassmorphism instead of Material 3?
**Decision**: Standard Material Design apps feel utilitarian. Glassmorphism establishes an immediate emotional connection, conveying a "premium" and "modern" feel akin to native iOS or Nothing OS experiences.

## 4. Why manual approval for SMS parsed transactions?
**Decision**: Regex is imperfect. Automatically injecting parsed SMS directly into the main ledger would eventually lead to corrupted budgets due to promotional texts or false positives. The "Inbox" approval step ensures 100% ledger accuracy.
