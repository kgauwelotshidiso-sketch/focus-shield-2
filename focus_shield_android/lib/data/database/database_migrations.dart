import 'sqlite_schema.dart';

class DatabaseMigrations {
  static const currentVersion = 2;

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

    return scripts;
  }

  static List<String> migrationScriptsForVersion(int version) {
    return creationScripts();
  }
}
