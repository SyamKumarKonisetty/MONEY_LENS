class SavingsGoalEntity {
  final int? id;
  final double amount;
  final int month;
  final int year;

  const SavingsGoalEntity({
    this.id,
    required this.amount,
    required this.month,
    required this.year,
  });

  SavingsGoalEntity copyWith({
    int? id,
    double? amount,
    int? month,
    int? year,
  }) {
    return SavingsGoalEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }
}
