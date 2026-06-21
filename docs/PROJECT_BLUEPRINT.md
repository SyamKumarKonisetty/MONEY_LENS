# PROJECT BLUEPRINT (Master Index)

Welcome to the **MoneyLens Master Blueprint**. This document serves as the top-level aggregator for the entire Knowledge Base ecosystem.

## 📌 Project Overview
MoneyLens is a premium, privacy-first, offline personal finance application. It parses SMS messages natively on the device and visualizes data using a custom-built 60 FPS Glassmorphism UI Engine.

## 🏗️ Architecture Summary
- **UI Framework**: Flutter `^3.12.2`
- **State Management**: `flutter_riverpod`
- **Database**: `drift` (SQLite)
- **Routing**: `go_router`
- **Core Pattern**: Layered Architecture (Presentation -> Provider -> Repository -> Data)

## 📁 Knowledge Base Graph

1. **Start Here**:
   - [01_PRODUCT_VISION.md](01_PRODUCT_VISION.md)
   - [02_PRODUCT_REQUIREMENTS.md](02_PRODUCT_REQUIREMENTS.md)

2. **System Design**:
   - [03_SYSTEM_ARCHITECTURE.md](03_SYSTEM_ARCHITECTURE.md)
   - [04_DATABASE_DESIGN.md](04_DATABASE_DESIGN.md)
   - [05_STATE_MANAGEMENT.md](05_STATE_MANAGEMENT.md)

3. **Core Engines**:
   - [07_SMS_ENGINE.md](07_SMS_ENGINE.md)
   - [08_ANALYTICS_ENGINE.md](08_ANALYTICS_ENGINE.md)
   - [09_UI_ENGINE.md](09_UI_ENGINE.md)

4. **Engineering Guidelines**:
   - [20_CODING_STANDARDS.md](20_CODING_STANDARDS.md)
   - [22_AI_CONTEXT.md](22_AI_CONTEXT.md) (Crucial for AI Assistants)
   - [23_DEVELOPER_GUIDE.md](23_DEVELOPER_GUIDE.md)

5. **Release & Operations**:
   - [16_PLAYSTORE.md](16_PLAYSTORE.md)
   - [24_RELEASE_GUIDE.md](24_RELEASE_GUIDE.md)

*Refer to [00_INDEX.md](00_INDEX.md) for the complete list of 33 documents.*

## 🚀 Developer Onboarding
If you are a new developer, clone the repository, run `dart run build_runner build` to generate the Drift and Riverpod code, and review the [UI Engine Document](09_UI_ENGINE.md) before making any visual changes.
