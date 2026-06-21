/// Typesafe declarations of MoneyLens privacy and data retention policies.
class MLPrivacyPolicy {
  MLPrivacyPolicy._();

  /// Offline storage configuration policies.
  static const String offlineFirstDisclosure = '''
MoneyLens V2 is built as an offline-first personal finance application.
All transactions, budget limits, SMS automated logs, and calculations are kept strictly inside the sandboxed device container.
No transaction data is exported to external networks.
''';

  /// SMS inbox read permissions and security policies.
  static const String smsDataRetentionPolicy = '''
SMS automated sweeps run entirely offline.
The transaction identification heuristics target local data templates.
Original message contents are not stored, kept, or shared outside of the device context.
''';
}
