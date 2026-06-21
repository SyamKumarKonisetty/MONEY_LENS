# Contributing Standards

Welcome! We maintain high quality standards to ensure MoneyLens V2 remains secure, fast, and maintainable.

## 1. Code Style Guidelines

- **Format Code**: Always execute `dart format .` before staging any changes.
- **Static Analysis**: Verify there are zero errors or warnings using `flutter analyze`.
- **State Separation**: Do not place business logic or database queries directly inside presentation widgets. Delegate logic to Riverpod notifier controllers.
- **PII Logging**: Never log raw transactions, amounts, category configurations, phone numbers, or SMS bodies. Use `MLSensitiveDataFilter` to mask sensitive logs.

---

## 2. Design System Guidelines (MLDS)

- Do not introduce raw custom hex color strings or absolute typography styles. Use standard MLDS tokens.
- Use `MLText` widgets rather than standard `Text` widgets with manual font styles.
- Ensure all interactive buttons, cards, and input fields integrate spring micro-interactions and the unified semantic haptic triggers (`MLHaptics`).
