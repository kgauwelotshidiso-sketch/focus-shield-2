class CoachMemoryRepository {
  Future<void> insertMemory({
    required String dateKey,
    required String recommendation,
    required String actionTaken,
    required bool followThrough,
    required String source,
  }) async {
    // TODO: Insert coach memory entry.
  }

  Future<List<Map<String, Object?>>> getMemoryForDate(String dateKey) async {
    // TODO: Query coach_memory by date_key.
    return [];
  }

  Future<List<Map<String, Object?>>> getRecentMemory({int limit = 30}) async {
    // TODO: Query recent coach memory entries.
    return [];
  }
}
