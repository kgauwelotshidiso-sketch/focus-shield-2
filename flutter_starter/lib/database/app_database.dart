class AppDatabase {
  static const databaseName = 'focus_shield.db';
  static const databaseVersion = 1;

  static const createBlockedDomainsTable = '''
    CREATE TABLE blocked_domains (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      domain TEXT UNIQUE NOT NULL,
      category TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
  ''';

  static const createBlockedAttemptsTable = '''
    CREATE TABLE blocked_attempts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      website TEXT,
      category TEXT,
      reason TEXT,
      confidence REAL,
      timestamp TEXT NOT NULL
    );
  ''';

  static const createGoalsTable = '''
    CREATE TABLE goals (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT,
      completed INTEGER DEFAULT 0,
      created_at TEXT NOT NULL
    );
  ''';

  static const createProtectionSettingsTable = '''
    CREATE TABLE protection_settings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      pin_hash TEXT,
      protection_enabled INTEGER DEFAULT 1,
      delay_hours INTEGER DEFAULT 24,
      disable_requested_at TEXT,
      disable_available_at TEXT,
      privacy_mode TEXT DEFAULT 'stats-only'
    );
  ''';
}
