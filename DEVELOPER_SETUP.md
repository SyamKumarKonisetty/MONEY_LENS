# Developer Setup Guide

This guide details the steps required to configure your local development environment and run MoneyLens.

## 1. Prerequisites
- **Flutter SDK**: `^3.12.2` (run `flutter doctor` to verify setup)
- **Dart SDK**: `^3.0.0`
- **IDE**: VS Code or Android Studio with Flutter/Dart extensions.

---

## 2. Setting Up the Project

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/syamkumar/money_lens.git
    cd money_lens
    ```
2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run Code Generation**:
    MoneyLens utilizes Drift for SQLite. Generate the schema models and database adapters:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```
4.  **Run the Application**:
    Ensure an emulator or physical test device is connected:
    ```bash
    flutter run
    ```
5.  **Run Unit Tests**:
    ```bash
    flutter test
    ```
6.  **Verify Formatting and Linting**:
    ```bash
    dart format .
    flutter analyze
    ```
