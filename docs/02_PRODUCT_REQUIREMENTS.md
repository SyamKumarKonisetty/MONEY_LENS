# 02: Product Requirements

## Purpose
To detail the functional and non-functional requirements that the MoneyLens application must fulfill to be considered complete for Version 1.2.0.

## Functional Requirements
- **Authentication**: Users must be able to lock the app using a 4-digit PIN.
- **SMS Detection**: The app must listen for incoming SMS messages and extract transaction amounts, dates, and vendors based on banking RegEx patterns.
- **Manual Entry**: Users must have the ability to manually input cash transactions.
- **Dashboard Visualization**: The app must display a Hero widget with a dynamically rolling balance counter.
- **Categorization & Budgeting**: Transactions must be assignable to specific categories, which track spending against predefined monthly budgets.
- **Data Portability**: Users must be able to export their transactions to PDF and CSV formats locally.
- **Data Persistence**: Data must persist securely using a local SQLite database.

## Non-Functional Requirements
- **Performance**: The UI must render consistently at 60 FPS.
- **Size**: The final App Bundle (AAB) must be under 40 MB.
- **Startup Time**: The application must reach an interactive state in under 1 second.
- **Privacy**: The app must function 100% offline without requiring internet permissions for core functionality.
- **Accessibility**: Screen readers must be able to parse core actionable items, and contrast ratios must meet WCAG 2.1 AA standards.

## Dependencies
- Native Android SMS permissions.
- Local Storage access.
- Cryptographic hashing for PINs.

## Future Improvements
- Cross-platform parity (iOS currently lacks native SMS interception; alternative manual or OCR input methods required).
- OCR parsing for physical receipts.
