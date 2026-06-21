# 17: Testing

## Purpose
To document the testing strategy for ensuring the reliability of MoneyLens.

## Overview
Testing is currently weighted toward Unit Testing for core mathematical logic and Manual QA for UI fidelity.

## Unit Tests
- Focus: `AnalyticsEngine`, `SMSRegexParser`, and `CryptoHash` utilities.
- Execution: `flutter test`

## Widget Tests
- Focus: Ensuring that `GlassCard` and `MLSpinner` render correctly under different theme conditions.

## Manual QA Checklist
Before any release, the following critical paths must be verified manually on a physical device:
1. **First Launch**: Does Onboarding appear?
2. **Permissions**: Does the app degrade gracefully if SMS permissions are denied?
3. **PIN Lock**: Does backgrounding the app for >1 minute trigger the lock screen?
4. **Transactions**: Can a manual transaction be added, edited, and deleted?
5. **Charts**: Do the analytics charts rebuild accurately when a new transaction is added?
6. **Export**: Can the CSV file be successfully opened in an external application?

## Future Improvements
- Integrate `integration_test` to automate the Manual QA checklist using Flutter Driver.
