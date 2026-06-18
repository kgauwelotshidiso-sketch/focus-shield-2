class XpRepository {
  Future<void> insertXpEvent({
    required String dateKey,
    required String source,
    required int amount,
    String? reason,
  }) async {
    // TODO: Insert XP event.
  }

  Future<int> getTotalXp() async {
    // TODO: Sum xp_events.amount.
    return 0;
  }

  Future<int> getXpForDate(String dateKey) async {
    // TODO: Sum xp for one date.
    return 0;
  }
}
