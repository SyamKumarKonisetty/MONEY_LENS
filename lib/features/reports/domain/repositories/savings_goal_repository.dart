import '../entities/savings_goal_entity.dart';

abstract class SavingsGoalRepository {
  Future<SavingsGoalEntity?> getSavingsGoal(int month, int year);
  Stream<SavingsGoalEntity?> watchSavingsGoal(int month, int year);
  Future<void> setSavingsGoal(SavingsGoalEntity goal);
}
