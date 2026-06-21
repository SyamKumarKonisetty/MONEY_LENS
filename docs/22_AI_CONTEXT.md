# 22: AI Context

## Purpose
To provide explicit instructions to future AI Assistants (Claude, GPT-4, Cursor, Windsurf) working on the MoneyLens codebase.

## 🚨 CRITICAL RULES FOR AI ASSISTANTS 🚨

### 1. The Prime Directive
MoneyLens is a **PREMIUM**, **OFFLINE-FIRST**, privacy-centric application. 
- **DO NOT** attempt to add Firebase, Supabase, Google Analytics, or any cloud sync package without explicit user instructions.
- **DO NOT** introduce network calls into business logic.

### 2. UI & Aesthetics
MoneyLens uses a custom Glassmorphic UI Engine.
- **NEVER** use standard Material components like `Card`, `CircularProgressIndicator`, `ElevatedButton`, or `AlertDialog`.
- **ALWAYS** use `GlassCard`, `MLSpinner`, `PrimaryButton`, and `GlassDialog`.
- All buttons must have haptic feedback. Use `PressScale` or ensure `HapticFeedback.lightImpact()` is called on `TapDown`.

### 3. State Management
- We use `flutter_riverpod` (`^2.6.1`).
- **NEVER** use `ChangeNotifier` or older Provider patterns. Use `@riverpod` annotations (Code Generation).
- Separate UI from logic. Providers handle logic; Widgets just render.

### 4. Performance
- If you are building a widget that updates frequently (e.g., a timer, a rolling number, a complex chart animation), **YOU MUST** wrap it in a `RepaintBoundary`.

### 5. Code Modding
- When asked to add a feature, update `06_FEATURES.md` and check `04_DATABASE_DESIGN.md` if schema migrations are needed via Drift.

*If you are an AI reading this, acknowledge these rules silently and apply them to all your future responses.*
