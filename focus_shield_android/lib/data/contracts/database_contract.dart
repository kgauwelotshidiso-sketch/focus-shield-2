class DatabaseContract {
  static const databaseName = 'focus_shield.db';
  static const databaseVersion = 3;

  static const tableAppState = 'app_state';
  static const tableBlockedAttempts = 'blocked_attempts';
  static const tableSettings = 'settings';
  static const tableGoals = 'goals';
  static const tableAffirmations = 'affirmations';
  static const tableBlockedDomains = 'blocked_domains';
  static const tableDailySummaries = 'daily_summaries';

  static const columnId = 'id';
  static const columnCreatedAt = 'created_at';
  static const columnUpdatedAt = 'updated_at';
}
