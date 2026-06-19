class SqliteSchema {
  static const statements = [
    '''
CREATE TABLE IF NOT EXISTS app_state (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  listening_wins_today INTEGER NOT NULL DEFAULT 0,
  mission_target INTEGER NOT NULL DEFAULT 3,
  xp INTEGER NOT NULL DEFAULT 45,
  blocked_attempts INTEGER NOT NULL DEFAULT 0,
  recovered_attempts INTEGER NOT NULL DEFAULT 0,
  focus_sessions_today INTEGER NOT NULL DEFAULT 0,
  reflections_today INTEGER NOT NULL DEFAULT 0,
  concentration_wins_today INTEGER NOT NULL DEFAULT 0,
  protection_enabled INTEGER NOT NULL DEFAULT 1,
  morning_command_set INTEGER NOT NULL DEFAULT 0,
  end_reviews_today INTEGER NOT NULL DEFAULT 0,
  updated_at TEXT NOT NULL
);
''',
    '''
CREATE TABLE IF NOT EXISTS blocked_attempts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  domain TEXT NOT NULL,
  category TEXT NOT NULL,
  confidence REAL NOT NULL,
  recovered INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL
);
''',
    '''
CREATE TABLE IF NOT EXISTS settings (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  protection_enabled INTEGER NOT NULL DEFAULT 1,
  lock_enabled INTEGER NOT NULL DEFAULT 1,
  delayed_disable_hours INTEGER NOT NULL DEFAULT 24,
  updated_at TEXT NOT NULL
);
''',
    '''
CREATE TABLE IF NOT EXISTS goals (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  description TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
''',
    '''
CREATE TABLE IF NOT EXISTS affirmations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  text TEXT NOT NULL,
  favorite INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
''',
    '''
CREATE TABLE IF NOT EXISTS blocked_domains (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  domain TEXT UNIQUE NOT NULL,
  category TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
''',
  ];

  static const schema = '''
Focus Shield SQLite schema version 1.

Tables:
- app_state
- blocked_attempts
- settings
- goals
- affirmations
- blocked_domains
''';
}
