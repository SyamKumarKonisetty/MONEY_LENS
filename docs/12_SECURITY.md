# 12: Security

## Purpose
To document the mechanisms protecting the user's local financial data.

## Overview
Since MoneyLens operates 100% offline, traditional network-based attack vectors (MITM, SQL injection via web form) are inapplicable. Security focuses entirely on device-level protection.

## PIN Authentication
1. **Setup**: The user inputs a 4-digit PIN.
2. **Hashing**: The PIN is hashed using `crypto` (SHA-256) with a local salt.
3. **Storage**: The hash is saved to `SharedPreferences`.
4. **Validation**: Subsequent launches require PIN entry, which is hashed and compared.

## Recovery Flow
A local security question provides a fallback if the PIN is forgotten. The answer is stored alongside the PIN hash.

## Threat Model
- **Physical Device Theft**: Protected by OS lock screen and MoneyLens PIN.
- **Malicious App Interaction**: Drift SQLite is stored in the application's isolated sandboxed directory, inaccessible to other apps without Root.

## Future Enhancements
Migrate to `local_auth` for OS-level Biometric (Fingerprint/FaceID) integration.
