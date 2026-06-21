# 20: Coding Standards

## Purpose
To maintain a clean, readable, and predictable codebase across future contributions.

## Architectural Rules
- **No Logic in UI**: Never make a database call directly from a `Widget`. Route it through a `Notifier`.
- **No UI in Logic**: Never pass `BuildContext` into a Riverpod provider or Repository.

## Widget Rules
- **Stateless Preferred**: Always default to `StatelessWidget` or `ConsumerWidget`. Use `StatefulWidget` only when managing explicit, ephemeral animation controllers.
- **Component Reusability**: If a custom layout is used twice, extract it into `lib/core/design/widgets/`.

## Styling Rules
- **Never Hardcode Colors**: Use `AppColors` or `context.theme.colorScheme`.
- **Never Hardcode Dimensions**: Use `AppSpacing` (e.g., `AppSpacing.md`) rather than `16.0`.

## Git & Commits
Use Conventional Commits:
- `feat: Added SMS inbox parsing.`
- `fix: Resolved NullPointer in Analytics loop.`
- `refactor: Migrated legacy cards to GlassCard.`
