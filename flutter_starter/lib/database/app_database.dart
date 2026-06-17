class AppDatabase {
  static const databaseName = 'focus_shield.db';
  static const databaseVersion = 1;

  static const createBlockedDomainsTable = '''
    CREATE TABLE blocked_domains (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      domain TEXT UNIQUE NOT NULL,
      category TEXT NOT NULL,
      source TEXT DEFAULT 'manual',
      is_active INTEGER DEFAULT 1,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
  ''';

  static const createBlockedAttemptsTable = '''
    CREATE TABLE blocked_attempts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      website TEXT,
      domain TEXT,
      category TEXT NOT NULL,
      reason TEXT,
      confidence REAL DEFAULT 0,
      decision TEXT DEFAULT 'block',
      privacy_mode TEXT DEFAULT 'stats-only',
      recovered INTEGER DEFAULT 0,
      timestamp TEXT NOT NULL,
      date_key TEXT NOT NULL
    );
  ''';

  static const createRecoveryActionsTable = '''
    CREATE TABLE recovery_actions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      attempt_id INTEGER,
      action_name TEXT NOT NULL,
      notes TEXT,
      timestamp TEXT NOT NULL,
      date_key TEXT NOT NULL,
      FOREIGN KEY (attempt_id) REFERENCES blocked_attempts(id)
    );
  ''';

  static const createProtectionSettingsTable = '''
    CREATE TABLE protection_settings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      pin_hash TEXT,
      protection_enabled INTEGER DEFAULT 1,
      lock_enabled INTEGER DEFAULT 0,
      blocklist_edit_locked INTEGER DEFAULT 1,
      privacy_settings_locked INTEGER DEFAULT 1,
      delay_hours INTEGER DEFAULT 24,
      disable_requested_at TEXT,
      disable_available_at TEXT,
      privacy_mode TEXT DEFAULT 'stats-only',
      updated_at TEXT NOT NULL
    );
  ''';

  static const createGoalsTable = '''
    CREATE TABLE goals (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT,
      category TEXT,
      target_value REAL DEFAULT 0,
      current_value REAL DEFAULT 0,
      unit TEXT,
      completed INTEGER DEFAULT 0,
      created_at TEXT NOT NULL,
      completed_at TEXT
    );
  ''';

  static const createDailyReflectionsTable = '''
    CREATE TABLE daily_reflections (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date_key TEXT UNIQUE NOT NULL,
      what_happened TEXT,
      lesson TEXT,
      improvement TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
  ''';

  static const createDailyEndReviewsTable = '''
    CREATE TABLE daily_end_reviews (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date_key TEXT UNIQUE NOT NULL,
      score INTEGER DEFAULT 0,
      verdict TEXT,
      completed_today TEXT,
      missed_actions TEXT,
      tomorrow_correction TEXT,
      strongest_action TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
  ''';

  static const createTimelineEventsTable = '''
    CREATE TABLE timeline_events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      event_type TEXT NOT NULL,
      title TEXT NOT NULL,
      detail TEXT,
      value REAL DEFAULT 0,
      date_key TEXT NOT NULL,
      timestamp TEXT NOT NULL
    );
  ''';

  static const createCoachMemoryTable = '''
    CREATE TABLE coach_memory (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date_key TEXT NOT NULL,
      recommendation TEXT,
      action_taken TEXT,
      follow_through INTEGER DEFAULT 0,
      source TEXT,
      timestamp TEXT NOT NULL
    );
  ''';

  static const createXpEventsTable = '''
    CREATE TABLE xp_events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date_key TEXT NOT NULL,
      source TEXT NOT NULL,
      amount INTEGER NOT NULL,
      reason TEXT,
      timestamp TEXT NOT NULL
    );
  ''';

  static const createBadgesTable = '''
    CREATE TABLE badges (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      badge_key TEXT UNIQUE NOT NULL,
      title TEXT NOT NULL,
      description TEXT,
      unlocked INTEGER DEFAULT 0,
      unlocked_at TEXT
    );
  ''';

  static const createStreaksTable = '''
    CREATE TABLE streaks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      streak_key TEXT UNIQUE NOT NULL,
      current_streak INTEGER DEFAULT 0,
      longest_streak INTEGER DEFAULT 0,
      last_active_date TEXT,
      updated_at TEXT NOT NULL
    );
  ''';

  static const createFocusSessionsTable = '''
    CREATE TABLE focus_sessions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      session_type TEXT DEFAULT 'focus',
      duration_seconds INTEGER NOT NULL,
      completed INTEGER DEFAULT 0,
      date_key TEXT NOT NULL,
      started_at TEXT NOT NULL,
      completed_at TEXT
    );
  ''';

  static const createConcentrationSessionsTable = '''
    CREATE TABLE concentration_sessions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      duration_seconds INTEGER NOT NULL,
      completed INTEGER DEFAULT 0,
      affirmation TEXT,
      date_key TEXT NOT NULL,
      started_at TEXT NOT NULL,
      completed_at TEXT
    );
  ''';

  static const allCreateStatements = [
    createBlockedDomainsTable,
    createBlockedAttemptsTable,
    createRecoveryActionsTable,
    createProtectionSettingsTable,
    createGoalsTable,
    createDailyReflectionsTable,
    createDailyEndReviewsTable,
    createTimelineEventsTable,
    createCoachMemoryTable,
    createXpEventsTable,
    createBadgesTable,
    createStreaksTable,
    createFocusSessionsTable,
    createConcentrationSessionsTable,
  ];
}
