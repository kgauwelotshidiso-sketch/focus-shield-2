class RecoveryActionRepository {
  Future<void> insertRecoveryAction({
    int? attemptId,
    required String actionName,
    String? notes,
    required String dateKey,
  }) async {
    // TODO: Insert recovery action into recovery_actions table.
  }

  Future<int> countRecoveriesForDate(String dateKey) async {
    // TODO: Count recovery actions by date_key.
    return 0;
  }

  Future<List<Map<String, Object?>>> getRecentRecoveries({int limit = 20}) async {
    // TODO: Query recent recovery actions.
    return [];
  }
}
