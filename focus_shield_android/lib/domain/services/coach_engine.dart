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

    if (listeningWins < targetWins) {
      return CoachSummary(
        command: 'Pause, listen fully, then speak.',
        weakness: 'Listening Consistency',
        score: ((listeningWins / targetWins) * 100).round(),
      );
    }

    if (recoveryRate < 100) {
      return CoachSummary(
        command: 'Finish every recovery loop after a block.',
        weakness: 'Recovery Completion',
        score: recoveryRate,
      );
    }

    return const CoachSummary(
      command: 'Maintain discipline and complete your evening review.',
      weakness: 'Maintain Discipline',
      score: 100,
    );
  }
}
