/// Domain entity representing a transaction (Expense or Income).
class ExpenseEntity {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  /// Supported types: 'income', 'expense'
  final String transactionType;

  const ExpenseEntity({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.transactionType = 'expense',
  });

  /// Copy constructor for creating modified instances.
  ExpenseEntity copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? transactionType,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      transactionType: transactionType ?? this.transactionType,
    );
  }
}
