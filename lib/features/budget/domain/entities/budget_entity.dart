class BudgetEntity {
  final int? id;
  final String category;
  final double monthlyLimit;
  final double spentAmount;
  final double remainingAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String period; // 'monthly', 'weekly', 'yearly'
  final bool isEnabled;
  final bool isArchived;

  const BudgetEntity({
    this.id,
    required this.category,
    required this.monthlyLimit,
    this.spentAmount = 0.0,
    this.remainingAmount = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.period = 'monthly',
    this.isEnabled = true,
    this.isArchived = false,
  });

  double get monthlyLimitEquivalent {
    switch (period.toLowerCase()) {
      case 'weekly':
        return monthlyLimit * (30 / 7);
      case 'yearly':
        return monthlyLimit / 12;
      case 'monthly':
      default:
        return monthlyLimit;
    }
  }

  BudgetEntity copyWith({
    int? id,
    String? category,
    double? monthlyLimit,
    double? spentAmount,
    double? remainingAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? period,
    bool? isEnabled,
    bool? isArchived,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      category: category ?? this.category,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      spentAmount: spentAmount ?? this.spentAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      period: period ?? this.period,
      isEnabled: isEnabled ?? this.isEnabled,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
