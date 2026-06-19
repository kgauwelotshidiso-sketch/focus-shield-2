import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sqflite;

import '../contracts/database_contract.dart';
import 'database_migrations.dart';

class DatabaseProvider {
  DatabaseProvider({
    String? overridePath,
    sqflite.DatabaseFactory? databaseFactory,
  })  : _overridePath = overridePath,
        _databaseFactory = databaseFactory;

  final String? _overridePath;
  final sqflite.DatabaseFactory? _databaseFactory;

  sqflite.Database? _database;

  Future<sqflite.Database> get database async {
    final currentDatabase = _database;

    if (currentDatabase != null) {
      return currentDatabase;
    }

    final openedDatabase = await _openDatabase();
    _database = openedDatabase;

    return openedDatabase;
  }

  Future<sqflite.Database> _openDatabase() async {
    final factory = _databaseFactory ?? sqflite.databaseFactory;
    final databasePath = _overridePath ?? await _defaultDatabasePath();

    return factory.openDatabase(
      databasePath,
      options: sqflite.OpenDatabaseOptions(
        version: DatabaseContract.databaseVersion,
        onCreate: (db, version) async {
          for (final statement in DatabaseMigrations.creationScripts()) {
            await db.execute(statement);
          }
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          for (final statement in DatabaseMigrations.upgradeScripts(
            oldVersion: oldVersion,
            newVersion: newVersion,
          )) {
            await db.execute(statement);
          }
        },
      ),
    );
  }

  Future<String> _defaultDatabasePath() async {
    final databaseDirectory = await sqflite.getDatabasesPath();
    return path.join(databaseDirectory, DatabaseContract.databaseName);
  }

  Future<void> close() async {
    final currentDatabase = _database;

    if (currentDatabase != null) {
      await currentDatabase.close();
      _database = null;
    }
  }
}
