/// Semantic types of financial reports.
enum MLReportType {
  daily,
  weekly,
  monthly,
  yearly,
  budget,
  category,
  merchant,
  cashFlow,
}

/// Metadata model defining report structure and data contracts.
class MLReportMetadata {
  const MLReportMetadata({
    required this.id,
    required this.type,
    required this.title,
    required this.dateGenerated,
    required this.startDate,
    required this.endDate,
    required this.totalIncome,
    required this.totalExpenses,
    required this.transactionCount,
    required this.categoryBreakdown,
    required this.merchantBreakdown,
    this.budgetLimit,
    this.budgetSpent,
    this.notes,
  });

  final String id;
  final MLReportType type;
  final String title;
  final DateTime dateGenerated;
  final DateTime startDate;
  final DateTime endDate;
  final double totalIncome;
  final double totalExpenses;
  final int transactionCount;

  /// Categorized breakdown values: Map of category name to sum spent.
  final Map<String, double> categoryBreakdown;

  /// Merchant spending summaries: Map of merchant name to sum spent.
  final Map<String, double> merchantBreakdown;

  /// Budget metrics if type is budget
  final double? budgetLimit;
  final double? budgetSpent;

  final String? notes;

  /// Compiles a CSV representation of the report structure.
  String toCsvSummary() {
    final buffer = StringBuffer();
    buffer.writeln('MoneyLens Financial Statement Report Summary');
    buffer.writeln('Report ID,$id');
    buffer.writeln('Report Type,${type.name.toUpperCase()}');
    buffer.writeln('Title,$title');
    buffer.writeln('Date Generated,${dateGenerated.toIso8601String()}');
    buffer.writeln(
      'Period,${startDate.toIso8601String()} to ${endDate.toIso8601String()}',
    );
    buffer.writeln('Total Income,${totalIncome.toStringAsFixed(2)}');
    buffer.writeln('Total Expenses,${totalExpenses.toStringAsFixed(2)}');
    buffer.writeln(
      'Net Savings,${(totalIncome - totalExpenses).toStringAsFixed(2)}',
    );
    buffer.writeln('Transaction Count,$transactionCount');

    if (categoryBreakdown.isNotEmpty) {
      buffer.writeln('\nCategory Breakdown');
      buffer.writeln('Category,Amount,Percentage');
      categoryBreakdown.forEach((cat, amt) {
        final pct = totalExpenses > 0 ? (amt / totalExpenses) * 100 : 0.0;
        buffer.writeln(
          '$cat,${amt.toStringAsFixed(2)},${pct.toStringAsFixed(1)}%',
        );
      });
    }

    if (merchantBreakdown.isNotEmpty) {
      buffer.writeln('\nMerchant Breakdown');
      buffer.writeln('Merchant,Amount');
      merchantBreakdown.forEach((merch, amt) {
        buffer.writeln('$merch,${amt.toStringAsFixed(2)}');
      });
    }

    return buffer.toString();
  }
}
