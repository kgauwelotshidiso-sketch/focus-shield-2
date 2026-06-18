import '../models/blocked_attempt.dart';

class BlockedAttemptRepository {
  Future<void> insertAttempt(BlockedAttempt attempt) async {
    // TODO: Insert blocked attempt into blocked_attempts table.
  }

  Future<List<BlockedAttempt>> getAttemptsForDate(String dateKey) async {
    // TODO: Query blocked_attempts by date_key.
    return [];
  }

  Future<List<BlockedAttempt>> getRecentAttempts({int limit = 20}) async {
    // TODO: Query recent blocked attempts ordered by timestamp.
    return [];
  }

  Future<void> markRecovered(int attemptId) async {
    // TODO: Set recovered = 1 for attempt.
  }
}
