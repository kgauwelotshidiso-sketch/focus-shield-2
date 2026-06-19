import '../models/attempt_record.dart';
import '../models/coach_recovery_insight.dart';

class CoachSummary {
  const CoachSummary({
    required this.command,
    required this.weakness,
    required this.score,
  });

  final String command;
  final String weakness;
  final int score;
}

class CoachEngine {
  CoachSummary analyze({
    required int listeningWins,
    required int targetWins,
    required int recoveryRate,
    required bool morningCommandSet,
  }) {
    if (!morningCommandSet) {
      return const CoachSummary(
        command: 'Set your morning command before the day gets noisy.',
        weakness: 'Morning Command',
        score: 45,
      );
    }

    if (recoveryRate < 70) {
      return CoachSummary(
        command: 'Close your recovery loops before chasing new progress.',
        weakness: 'Recovery Discipline',
        score: recoveryRate,
      );
    }

    if (listeningWins < targetWins) {
      return CoachSummary(
        command: 'Pause, listen fully, then speak.',
        weakness: 'Listening Consistency',
        score: ((listeningWins / targetWins) * 100).round(),
      );
    }

    return const CoachSummary(
      command: 'Maintain discipline and complete your evening review.',
      weakness: 'Maintain Discipline',
      score: 100,
    );
  }

  CoachRecoveryInsight analyzeRecoveryHistory(List<AttemptRecord> attempts) {
    final total = attempts.length;
    final recovered = attempts.where((attempt) => attempt.recovered).length;
    final pending = attempts.where((attempt) => !attempt.recovered).length;
    final recoveryRate = total == 0 ? 100 : ((recovered / total) * 100).round();

    if (total == 0) {
      return const CoachRecoveryInsight(
        pendingAttempts: 0,
        recoveredAttempts: 0,
        totalAttempts: 0,
        recoveryRate: 100,
        command: 'Keep protection active and stay ahead of temptation.',
        warning: 'No saved attempts yet.',
        grade: 'Clean',
      );
    }

    if (pending == 0) {
      return CoachRecoveryInsight(
        pendingAttempts: pending,
        recoveredAttempts: recovered,
        totalAttempts: total,
        recoveryRate: recoveryRate,
        command: 'Strong recovery discipline. Keep closing every loop.',
        warning: 'All attempts are recovered.',
        grade: 'Strong',
      );
    }

    if (pending == 1) {
      return CoachRecoveryInsight(
        pendingAttempts: pending,
        recoveredAttempts: recovered,
        totalAttempts: total,
        recoveryRate: recoveryRate,
        command: 'Recover the pending attempt before it becomes a pattern.',
        warning: 'One recovery loop is still open.',
        grade: 'Needs Action',
      );
    }

    return CoachRecoveryInsight(
      pendingAttempts: pending,
      recoveredAttempts: recovered,
      totalAttempts: total,
      recoveryRate: recoveryRate,
      command: 'Stop everything and close your pending recovery loops.',
      warning: '$pending recovery loops are still open.',
      grade: 'Weak Recovery',
    );
  }
}
