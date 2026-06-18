class SessionRepository {
  Future<void> insertFocusSession({
    required int durationSeconds,
    required bool completed,
    required String dateKey,
  }) async {
    // TODO: Insert focus session.
  }

  Future<void> insertConcentrationSession({
    required int durationSeconds,
    required bool completed,
    String? affirmation,
    required String dateKey,
  }) async {
    // TODO: Insert concentration session.
  }

  Future<int> countCompletedFocusSessions() async {
    // TODO: Count completed focus sessions.
    return 0;
  }

  Future<int> countCompletedConcentrationSessions() async {
    // TODO: Count completed concentration sessions.
    return 0;
  }
}
