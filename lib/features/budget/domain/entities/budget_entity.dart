class BudgetEntity {
  final int? id;
  final String category;
  final double monthlyLimit;
  final double spentAmount;
  final double remainingAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BudgetEntity({
    this.id,
    required this.category,
    required this.monthlyLimit,
    this.spentAmount = 0.0,
    this.remainingAmount = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  BudgetEntity copyWith({
    int? id,
    String? category,
    double? monthlyLimit,
    double? spentAmount,
    double? remainingAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      category: category ?? this.category,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      spentAmount: spentAmount ?? this.spentAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
