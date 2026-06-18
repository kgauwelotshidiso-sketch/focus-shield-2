import '../models/goal.dart';

class GoalRepository {
  Future<List<Goal>> getActiveGoals() async {
    // TODO: Query goals where completed = 0.
    return [];
  }

  Future<List<Goal>> getCompletedGoals() async {
    // TODO: Query goals where completed = 1.
    return [];
  }

  Future<void> insertGoal(Goal goal) async {
    // TODO: Insert goal.
  }

  Future<void> markGoalCompleted(int goalId) async {
    // TODO: Update completed = 1 and completed_at.
  }
}
