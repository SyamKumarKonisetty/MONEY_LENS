# 31: Contributing

## Purpose
Guidelines for external developers or internal team members contributing to MoneyLens.

## The Rule of Quality
MoneyLens is a premium product. Do not submit a PR if:
1. It breaks the 60 FPS guarantee.
2. It introduces generic Material Design components instead of utilizing the `UI Engine`.
3. It requires an internet connection to function.

## Pull Request Process
1. Create a feature branch (`feat/your-feature`).
2. Adhere to [20_CODING_STANDARDS.md](20_CODING_STANDARDS.md).
3. Ensure `flutter analyze` runs clean.
4. If you modified database models, commit the updated `*.g.dart` generated files.
5. Request a review from a core maintainer.

## Reporting Bugs
Use GitHub Issues. Provide:
- OS Version (e.g., Android 14)
- Device Model
- Logs if the crash bypassed the `ErrorWidget.builder`.
