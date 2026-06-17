class DataMigrationSpec {
  static const version = 1;

  static const localStorageToSqliteMap = {
    'fsProtectionBlockedDomains': 'blocked_domains',
    'fsProtectionBlockedAttempts': 'blocked_attempts',
    'fsProtectionRecoveryLog': 'recovery_actions',
    'fsProtectionLockSettings': 'protection_settings',
    'fsProtectionPrivacyMode': 'protection_settings.privacy_mode',
    'goals': 'goals',
    'dailyReflections': 'daily_reflections',
    'endReviews': 'daily_end_reviews',
    'timelineEvents': 'timeline_events',
    'coachMemory': 'coach_memory',
    'xpHistory': 'xp_events',
    'badges': 'badges',
    'focusSessions': 'focus_sessions',
    'concentrationSessions': 'concentration_sessions',
  };

  static const migrationOrder = [
    'protection_settings',
    'blocked_domains',
    'blocked_attempts',
    'recovery_actions',
    'goals',
    'daily_reflections',
    'daily_end_reviews',
    'timeline_events',
    'coach_memory',
    'xp_events',
    'badges',
    'focus_sessions',
    'concentration_sessions',
  ];
}
