import 'sqlite_schema.dart';

class DatabaseMigrations {
  static const currentVersion = 1;

  static List<String> migrationScriptsForVersion(int version) {
    if (version <= 1) {
      return [SqliteSchema.schema];
    }

    return const [];
  }
}
