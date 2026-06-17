class SqliteSchemaV1 {
  static const tables = [
    'blocked_domains',
    'blocked_attempts',
    'recovery_actions',
    'protection_settings',
    'goals',
    'daily_reflections',
    'daily_end_reviews',
    'timeline_events',
    'coach_memory',
    'xp_events',
    'badges',
    'streaks',
    'focus_sessions',
    'concentration_sessions',
  ];

  static const protectedTables = [
    'blocked_domains',
    'blocked_attempts',
    'recovery_actions',
    'protection_settings',
  ];

  static const disciplineTables = [
    'goals',
    'daily_reflections',
    'daily_end_reviews',
    'timeline_events',
    'focus_sessions',
    'concentration_sessions',
  ];

  static const progressTables = [
    'coach_memory',
    'xp_events',
    'badges',
    'streaks',
  ];
}
