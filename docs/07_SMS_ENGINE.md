# 07: SMS Engine

## Purpose
To detail the automated, regex-based SMS parsing engine that converts raw text messages into structured financial transactions.

## Overview
The SMS Engine is a native Android feature that uses `permission_handler` to read inbox data. It does NOT upload SMS data anywhere.

## Architecture

![SMS Flow](diagrams/sms_flow.mmd)

## Regex Pipeline
The engine employs bank-specific RegEx profiles.

1. **HDFC Filter**: Matches strings like `"Rs. XXXXX debited from a/c YYYY at ZZZZ"`.
2. **Extraction**:
   - Amount: Extracted via lookarounds (`(?<=Rs\.?)\s*[\d,]+`).
   - Date: Parsed from standard DD-MM-YYYY or DD/MM/YY formats.
   - Merchant: Captured from the string suffix following `info:` or `at `.

## Inbox Workflow
Since RegEx is imperfect and false positives occur:
1. Parsed messages do NOT enter the main `Transactions` ledger immediately.
2. They enter a `Pending` queue in the Inbox UI.
3. The user reviews them and clicks the `Check` mark to confirm accuracy and category assignment.

## Future Improvements
- Expand parser library to SBI, ICICI, Axis.
- Apply local NLP (Natural Language Processing) to predict categories based on the Merchant name.
