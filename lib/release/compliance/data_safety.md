# Google Play Data Safety Declarations

Use the declarations below to complete the Google Play Console **Data Safety Form** for MoneyLens.

## 1. Data Collection and Security

*   **Does your app collect or share any of the required user data types?**
    - **No**. MoneyLens is an offline-first app. All transaction information, preferences, and profile details are stored in a local SQLite database (via Drift) and in secure local storage (SharedPreferences). No data is transmitted to external servers.
*   **Is all of the user data collected by your app encrypted in transit?**
    - **Not Applicable**. Because MoneyLens does not transmit any data over the internet, no data is in transit.
*   **Do you provide a way for users to request that their data be deleted?**
    - **Yes**. Users can delete all local application configurations, credentials, transaction entries, settings, and database tables instantly by utilizing the "Clear All App Data" function under settings, which wipes the local SQLite ledger and Shared Preferences database files.

## 2. Data Types Collected & Declared

Because the application requires permissions to read SMS messages to populate the ledger locally, select the following declarations in the Google Play Console:

*   **SMS Messages**:
    - **Type**: Personal info / SMS (Read-Only)
    - **Collection**: Declared as **Collected** (from a Play Store technical perspective, the app reads text messages locally via Flutter APIs to process and record transactions).
    - **Sharing**: **No** (data is never shared or transmitted).
    - **Processing**: **Local processing only**. The SMS content is processed entirely on the user's device and is not saved to any external servers.
    - **Ephemeral**: **No** (the transaction info extracted from SMS notifications is persisted locally in the local SQLite ledger on-device for tracking purposes).
    - **Required / Optional**: **Optional** (the app functions as a manual expense tracker if the user denies SMS scanning permissions).

## 3. Local Permissions Justification

*   **POST_NOTIFICATIONS**: Required to show notifications to the user about budget limits and transaction summaries.
*   **READ_SMS**: Required only for the "Smart Inbox" SMS transaction detection feature. If denied, the app remains fully functional using manual ledger inputs.
*   **PACKAGE_USAGE_STATS**: Configured locally to detect foreground applications if matching merchant context is active.
