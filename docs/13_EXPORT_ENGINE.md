# 13: Export Engine

## Purpose
To allow users data portability without relying on a proprietary cloud sync mechanism.

## Formats

### 1. CSV
- **Generation**: Raw string formatting of the Drift Database rows. 
- **Use Case**: Importing into Excel or alternative accounting software.

### 2. PDF
- **Generation**: Utilizes the `pdf` package. Draws a structured table report of transactions and includes simple visual graphs of category breakdowns.
- **Use Case**: Printing or sending to an accountant.

## Workflow
![Export Flow](diagrams/export_flow.mmd)

1. User requests Export.
2. Provider reads all transactions.
3. Formatter generates the file in `getTemporaryDirectory()`.
4. Native `share_plus` intent is triggered.
5. User shares the file via OS Share Sheet (Email, Drive, WhatsApp).

## Future Enhancements
Automated weekly CSV backups to a specified Google Drive folder.
