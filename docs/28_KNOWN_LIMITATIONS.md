# 28: Known Limitations

## Purpose
To document the current physical and technical limitations of the MoneyLens architecture.

## 1. iOS Parity
**Limitation**: Apple does not expose an API to passively read incoming SMS messages for privacy reasons. 
**Impact**: The automated SMS Engine feature works strictly on Android.
**Workaround**: iOS users must rely on manual entry or future OCR/Apple Shortcuts integrations.

## 2. Shared Expenses
**Limitation**: The local SQLite database has no native multiplayer functionality.
**Impact**: Users cannot natively "split" a bill with a partner in real-time across two devices.
**Workaround**: A future "Export Bill" feature could generate a split request, but true synchronization is currently out of scope.

## 3. RegEx Brittleness
**Limitation**: Banks frequently change their SMS formatting.
**Impact**: A parser that works today might break tomorrow if HDFC adds a new word to their template.
**Workaround**: The `Pending Inbox` catches failed validations. Future V3 NLP processing will supersede rigid RegEx.
