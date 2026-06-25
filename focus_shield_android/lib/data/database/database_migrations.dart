import 'sqlite_schema.dart';

class DatabaseMigrations {
  static const currentVersion = 4;

  static List<String> creationScripts() {
    return SqliteSchema.statements;
  }

  static List<String> upgradeScripts({
    required int oldVersion,
    required int newVersion,
  }) {
    final scripts = <String>[];

    if (oldVersion < 2 && newVersion >= 2) {
      scripts.add(
        "ALTER TABLE app_state ADD COLUMN last_active_date TEXT NOT NULL DEFAULT '1970-01-01';",
      );
    }

    if (oldVersion < 3 && newVersion >= 3) {
      scripts.addAll([
        'ALTER TABLE app_state ADD COLUMN current_streak INTEGER NOT NULL DEFAULT 0;',
        'ALTER TABLE app_state ADD COLUMN longest_streak INTEGER NOT NULL DEFAULT 0;',
        'ALTER TABLE app_state ADD COLUMN completed_days INTEGER NOT NULL DEFAULT 0;',
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
      ]);
    }

    if (oldVersion < 4 && newVersion >= 4) {
      scripts.addAll([
        'ALTER TABLE app_state ADD COLUMN commitment_days INTEGER NOT NULL DEFAULT 0;',
        "ALTER TABLE app_state ADD COLUMN commitment_start_date TEXT NOT NULL DEFAULT '';",
        'ALTER TABLE app_state ADD COLUMN total_websites_scanned INTEGER NOT NULL DEFAULT 0;',
        'ALTER TABLE app_state ADD COLUMN websites_scanned_today INTEGER NOT NULL DEFAULT 0;',
        'ALTER TABLE app_state ADD COLUMN new_websites_scanned_today INTEGER NOT NULL DEFAULT 0;',
        "ALTER TABLE app_state ADD COLUMN scanned_domains_today TEXT NOT NULL DEFAULT '';",
        "ALTER TABLE app_state ADD COLUMN last_reflection_text TEXT NOT NULL DEFAULT '';",
      ]);
    }

    return scripts;
  }

  static List<String> migrationScriptsForVersion(int version) {
    return creationScripts();
  }
}
