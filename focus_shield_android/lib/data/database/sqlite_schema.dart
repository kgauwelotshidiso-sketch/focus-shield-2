class SqliteSchema {
  static const statements = [
    '''
    CREATE TABLE IF NOT EXISTS app_state (
      id INTEGER PRIMARY KEY CHECK (id = 1),
      listening_wins_today INTEGER NOT NULL DEFAULT 0,
      mission_target INTEGER NOT NULL DEFAULT 3,
      xp INTEGER NOT NULL DEFAULT 0,
      blocked_attempts INTEGER NOT NULL DEFAULT 0,
      recovered_attempts INTEGER NOT NULL DEFAULT 0,
      focus_sessions_today INTEGER NOT NULL DEFAULT 0,
      reflections_today INTEGER NOT NULL DEFAULT 0,
      concentration_wins_today INTEGER NOT NULL DEFAULT 0,
      protection_enabled INTEGER NOT NULL DEFAULT 0,
      morning_command_set INTEGER NOT NULL DEFAULT 0,
      end_reviews_today INTEGER NOT NULL DEFAULT 0,
      last_active_date TEXT NOT NULL,
      current_streak INTEGER NOT NULL DEFAULT 0,
      longest_streak INTEGER NOT NULL DEFAULT 0,
      completed_days INTEGER NOT NULL DEFAULT 0,
      commitment_days INTEGER NOT NULL DEFAULT 0,
      commitment_start_date TEXT NOT NULL DEFAULT '',
      total_websites_scanned INTEGER NOT NULL DEFAULT 0,
      websites_scanned_today INTEGER NOT NULL DEFAULT 0,
      new_websites_scanned_today INTEGER NOT NULL DEFAULT 0,
      scanned_domains_today TEXT NOT NULL DEFAULT '',
      last_reflection_text TEXT NOT NULL DEFAULT '',
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
      protection_enabled INTEGER NOT NULL DEFAULT 0,
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
    '''
    CREATE TABLE IF NOT EXISTS daily_summaries (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date_key TEXT UNIQUE NOT NULL,
      listening_wins INTEGER NOT NULL DEFAULT 0,
      mission_target INTEGER NOT NULL DEFAULT 3,
      mission_complete INTEGER NOT NULL DEFAULT 0,
      xp_total INTEGER NOT NULL DEFAULT 0,
      focus_sessions INTEGER NOT NULL DEFAULT 0,
      reflections INTEGER NOT NULL DEFAULT 0,
      concentration_wins INTEGER NOT NULL DEFAULT 0,
      blocked_attempts INTEGER NOT NULL DEFAULT 0,
      recovered_attempts INTEGER NOT NULL DEFAULT 0,
      recovery_rate INTEGER NOT NULL DEFAULT 100,
      coach_score INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL
    );
    ''',
  ];

  static const schema = '''
  Focus Shield SQLite schema version 4.
  Version 4 adds commitment duration, scanner metrics, and saved reflection text.
  ''';
}
