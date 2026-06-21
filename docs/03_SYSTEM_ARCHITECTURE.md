# 03: System Architecture

## Purpose
To provide a high-level overview of the MoneyLens architecture, its layers, and module separation.

## Overview
MoneyLens follows a clean, layered architecture customized for Flutter and Riverpod. It heavily enforces the separation of Presentation (UI), Domain (Business Logic), and Data (Persistence/API).

## Architecture Diagram
![Architecture Diagram](diagrams/architecture.mmd)

## Layered Architecture

### 1. Presentation Layer (`lib/features/.../presentation`)
Contains dumb widgets and screens. This layer only reads state via `ref.watch` and dispatches actions to providers via `ref.read`. It does not contain business logic.

### 2. Provider Layer (`lib/features/.../providers`)
Acts as the controller layer. Riverpod `Notifier` and `AsyncNotifier` classes live here. They orchestrate interactions between the UI and Repositories, handling loading, error, and success states.

### 3. Repository Layer (`lib/features/.../data`)
Abstracts the data sources. The rest of the app does not know whether data comes from SQLite or memory. Repositories handle the mapping of raw database entities to pure Dart models.

### 4. Data Layer (`lib/core/database`)
The lowest level. Contains Drift table definitions, compiled SQL statements, and DAO (Data Access Object) classes.

### 5. Service Layer (`lib/core/services`)
Handles native device interactions: SMS interception, file system access, sharing intents, and cryptographic hashing.

## Best Practices
- Never import `package:drift` inside the Presentation layer.
- Ensure all complex UI components are abstracted into `lib/core/ui_engine` to maintain consistency.
- Providers should be kept granular to prevent unnecessary widget rebuilds.

## Common Mistakes
- **Leaking Data Models**: Passing Drift generated classes directly to the UI. Always map them to Domain models.
- **State Mutation in UI**: Calling database functions directly from a widget instead of routing through a Notifier.
