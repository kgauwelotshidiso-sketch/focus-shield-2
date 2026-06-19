class CoachRecoveryInsight {
  const CoachRecoveryInsight({
    required this.pendingAttempts,
    required this.recoveredAttempts,
    required this.totalAttempts,
    required this.recoveryRate,
    required this.command,
    required this.warning,
    required this.grade,
  });

  final int pendingAttempts;
  final int recoveredAttempts;
  final int totalAttempts;
  final int recoveryRate;
  final String command;
  final String warning;
  final String grade;
}
