import 'package:sqflite/sqflite.dart' as sqflite;

import '../../domain/models/app_snapshot.dart';
import '../../domain/models/attempt_record.dart';
import '../../domain/models/focus_shield_state.dart';
import '../../domain/models/settings_record.dart';
import '../../domain/repositories/app_state_repository.dart';
import '../contracts/database_contract.dart';
import '../database/database_provider.dart';
import '../mappers/attempt_record_mapper.dart';
import '../mappers/focus_shield_state_mapper.dart';
import '../mappers/settings_record_mapper.dart';

class SqliteAppStateRepository implements AppStateRepository {
  SqliteAppStateRepository({
    DatabaseProvider? databaseProvider,
  }) : _databaseProvider = databaseProvider ?? DatabaseProvider();

  final DatabaseProvider _databaseProvider;

  Future<sqflite.Database> get _db => _databaseProvider.database;

  @override
  Future<AppSnapshot> loadSnapshot() async {
    final db = await _db;

    final rows = await db.query(
      DatabaseContract.tableAppState,
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (rows.isEmpty) {
      final initialState = FocusShieldState.initial();
      await saveState(initialState);

      return AppSnapshot(
        state: initialState,
        createdAt: DateTime.now(),
        version: DatabaseContract.databaseVersion,
      );
    }

    return AppSnapshot(
      state: FocusShieldStateMapper.fromDatabaseMap(rows.first),
      createdAt: DateTime.now(),
      version: DatabaseContract.databaseVersion,
    );
  }

  @override
  Future<void> saveState(FocusShieldState state) async {
    final db = await _db;

    await db.insert(
      DatabaseContract.tableAppState,
      FocusShieldStateMapper.toDatabaseMap(state),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> saveAttempt(AttemptRecord attempt) async {
    final db = await _db;
    final map = AttemptRecordMapper.toDatabaseMap(attempt);

    if (attempt.id == 0) {
      map.remove('id');
    }

    await db.insert(
      DatabaseContract.tableBlockedAttempts,
      map,
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<AttemptRecord>> loadAttempts() async {
    final db = await _db;

    final rows = await db.query(
      DatabaseContract.tableBlockedAttempts,
      orderBy: 'id DESC',
    );

    return rows.map(AttemptRecordMapper.fromDatabaseMap).toList();
  }

  @override
  Future<void> markLatestAttemptRecovered() async {
    final db = await _db;

    final latestRows = await db.query(
      DatabaseContract.tableBlockedAttempts,
      where: 'recovered = ?',
      whereArgs: [0],
      orderBy: 'id DESC',
      limit: 1,
    );

    if (latestRows.isEmpty) return;

    final latestId = latestRows.first['id'];

    await db.update(
      DatabaseContract.tableBlockedAttempts,
      {'recovered': 1},
      where: 'id = ?',
      whereArgs: [latestId],
    );
  }

  @override
  Future<void> saveSettings(SettingsRecord settings) async {
    final db = await _db;

    await db.insert(
      DatabaseContract.tableSettings,
      SettingsRecordMapper.toDatabaseMap(settings),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
  }

  @override
  Future<SettingsRecord> loadSettings() async {
    final db = await _db;

    final rows = await db.query(
      DatabaseContract.tableSettings,
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (rows.isEmpty) {
      final defaultSettings = SettingsRecord(
        protectionEnabled: true,
        lockEnabled: true,
        delayedDisableHours: 24,
        updatedAt: DateTime.now(),
      );

      await saveSettings(defaultSettings);

      return defaultSettings;
    }

    return SettingsRecordMapper.fromDatabaseMap(rows.first);
  }

  @override
  Future<void> clearAll() async {
    final db = await _db;

    await db.delete(DatabaseContract.tableBlockedAttempts);
    await db.delete(DatabaseContract.tableAppState);
    await db.delete(DatabaseContract.tableSettings);

    await saveState(FocusShieldState.initial());
    await saveSettings(
      SettingsRecord(
        protectionEnabled: true,
        lockEnabled: true,
        delayedDisableHours: 24,
        updatedAt: DateTime.now(),
      ),
    );
  }
}
