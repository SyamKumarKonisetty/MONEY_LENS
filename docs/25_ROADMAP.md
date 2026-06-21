# 25: Roadmap

## Purpose
To outline the long-term vision for MoneyLens over the next 2-5 years.

## V2.0: The Portability Update (Target: Next Year)
- **Multi-Bank Support**: Expand the SMS parser regex library to cover all major Indian and international banks.
- **Encrypted Cloud Sync**: Integrate with Google Drive API / iCloud API to allow users to backup and restore their SQLite database.
- **Cross-Platform**: Support iOS natively (requires fallback manual entry mechanisms since iOS blocks SMS reading).

## V3.0: The AI Update
- **Local Small Language Models (SLM)**: Use quantized, on-device models to allow users to ask questions like, "Did I spend more on food this month than last month?" without sending data to a server.
- **OCR Engine**: Allow users to snap photos of receipts. The app will extract the text, parse the amount, and categorize it locally.

## V4.0: The Automation Update
- **Subscriptions Engine**: Auto-detect recurring payments (Netflix, Spotify, Rent) and forecast cash-flow.
- **Goals Automation**: Tie specific transaction categories directly to visual savings goals.
