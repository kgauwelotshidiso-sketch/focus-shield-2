import 'package:sqflite/sqflite.dart' as sqflite;

import '../../domain/models/affirmation.dart';
import '../../domain/models/app_snapshot.dart';
import '../../domain/models/attempt_record.dart';
import '../../domain/models/blocked_domain.dart';
import '../../domain/models/daily_summary.dart';
import '../../domain/models/focus_shield_state.dart';
import '../../domain/models/goal.dart';
import '../../domain/models/settings_record.dart';
import '../../domain/repositories/app_state_repository.dart';
import '../contracts/database_contract.dart';
import '../database/database_provider.dart';
import '../mappers/affirmation_mapper.dart';
import '../mappers/attempt_record_mapper.dart';
import '../mappers/blocked_domain_mapper.dart';
import '../mappers/daily_summary_mapper.dart';
import '../mappers/focus_shield_state_mapper.dart';
import '../mappers/goal_mapper.dart';
import '../mappers/settings_record_mapper.dart';

class SqliteAppStateRepository implements AppStateRepository {
  SqliteAppStateRepository({DatabaseProvider? databaseProvider})
    : _databaseProvider = databaseProvider ?? DatabaseProvider();

  final DatabaseProvider _databaseProvider;

  Future<sqflite.Database> get _db => _databaseProvider.database;

  List<BlockedDomain> _defaultBlockedDomains() {
    final now = DateTime.now();

    return [
      BlockedDomain(
        id: 0,
        domain: 'blocked-example.com',
        category: 'local-blocklist',
        updatedAt: now,
      ),
      BlockedDomain(
        id: 0,
        domain: 'temptation-test.net',
        category: 'local-blocklist',
        updatedAt: now,
      ),
      BlockedDomain(
        id: 0,
        domain: 'focus-risk.org',
        category: 'local-blocklist',
        updatedAt: now,
      ),
    ];
  }

  List<Goal> _defaultGoals() {
    final now = DateTime.now();

    return [
      Goal(
        id: 0,
        title: 'Master fully listening',
        description:
            'Pause and wait for the person to finish speaking before responding.',
        createdAt: now,
        updatedAt: now,
      ),
      Goal(
        id: 0,
        title: 'Build fitness discipline',
        description: 'Train consistently and protect your energy.',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  List<Affirmation> _defaultAffirmations() {
    final now = DateTime.now();

    return [
      Affirmation(
        id: 0,
        text: 'I pause, I listen, and I follow my dreams.',
        favorite: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

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
  Future<void> markAttemptRecovered(int id) async {
    final db = await _db;

    await db.update(
      DatabaseContract.tableBlockedAttempts,
      {'recovered': 1},
      where: 'id = ?',
      whereArgs: [id],
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
  Future<List<BlockedDomain>> loadBlockedDomains() async {
    final db = await _db;

    final rows = await db.query(
      DatabaseContract.tableBlockedDomains,
      orderBy: 'domain ASC',
    );

    if (rows.isEmpty) {
      for (final blockedDomain in _defaultBlockedDomains()) {
        await saveBlockedDomain(blockedDomain);
      }

      final seededRows = await db.query(
        DatabaseContract.tableBlockedDomains,
        orderBy: 'domain ASC',
      );

      return seededRows.map(BlockedDomainMapper.fromDatabaseMap).toList();
    }

    return rows.map(BlockedDomainMapper.fromDatabaseMap).toList();
  }

  @override
  Future<void> saveBlockedDomain(BlockedDomain blockedDomain) async {
    final db = await _db;

    final normalizedDomain = blockedDomain.domain.trim().toLowerCase();
    if (normalizedDomain.isEmpty) return;

    final map = BlockedDomainMapper.toDatabaseMap(
      blockedDomain.copyWith(
        domain: normalizedDomain,
        updatedAt: DateTime.now(),
      ),
    );

    if (blockedDomain.id == 0) {
      map.remove('id');
    }

    await db.insert(
      DatabaseContract.tableBlockedDomains,
      map,
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteBlockedDomain(int id) async {
    final db = await _db;

    await db.delete(
      DatabaseContract.tableBlockedDomains,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> saveDailySummary(DailySummary summary) async {
    final db = await _db;
    final map = DailySummaryMapper.toDatabaseMap(summary);

    if (summary.id == 0) {
      map.remove('id');
    }

    await db.insert(
      DatabaseContract.tableDailySummaries,
      map,
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<DailySummary>> loadDailySummaries() async {
    final db = await _db;

    final rows = await db.query(
      DatabaseContract.tableDailySummaries,
      orderBy: 'date_key DESC',
    );

    return rows.map(DailySummaryMapper.fromDatabaseMap).toList();
  }

  @override
  Future<List<Goal>> loadGoals() async {
    final db = await _db;

    final rows = await db.query(DatabaseContract.tableGoals, orderBy: 'id ASC');

    if (rows.isEmpty) {
      for (final goal in _defaultGoals()) {
        await saveGoal(goal);
      }

      final seededRows = await db.query(
        DatabaseContract.tableGoals,
        orderBy: 'id ASC',
      );

      return seededRows.map(GoalMapper.fromDatabaseMap).toList();
    }

    return rows.map(GoalMapper.fromDatabaseMap).toList();
  }

  @override
  Future<void> saveGoal(Goal goal) async {
    final db = await _db;

    final title = goal.title.trim();
    if (title.isEmpty) return;

    final map = GoalMapper.toDatabaseMap(
      goal.copyWith(title: title, updatedAt: DateTime.now()),
    );

    if (goal.id == 0) {
      map.remove('id');
    }

    await db.insert(
      DatabaseContract.tableGoals,
      map,
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteGoal(int id) async {
    final db = await _db;

    await db.delete(
      DatabaseContract.tableGoals,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Affirmation>> loadAffirmations() async {
    final db = await _db;

    final rows = await db.query(
      DatabaseContract.tableAffirmations,
      orderBy: 'favorite DESC, id ASC',
    );

    if (rows.isEmpty) {
      for (final affirmation in _defaultAffirmations()) {
        await saveAffirmation(affirmation);
      }

      final seededRows = await db.query(
        DatabaseContract.tableAffirmations,
        orderBy: 'favorite DESC, id ASC',
      );

      return seededRows.map(AffirmationMapper.fromDatabaseMap).toList();
    }

    return rows.map(AffirmationMapper.fromDatabaseMap).toList();
  }

  @override
  Future<void> saveAffirmation(Affirmation affirmation) async {
    final db = await _db;

    final text = affirmation.text.trim();
    if (text.isEmpty) return;

    if (affirmation.favorite) {
      await db.update(DatabaseContract.tableAffirmations, {'favorite': 0});
    }

    final map = AffirmationMapper.toDatabaseMap(
      affirmation.copyWith(text: text, updatedAt: DateTime.now()),
    );

    if (affirmation.id == 0) {
      map.remove('id');
    }

    await db.insert(
      DatabaseContract.tableAffirmations,
      map,
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteAffirmation(int id) async {
    final db = await _db;

    await db.delete(
      DatabaseContract.tableAffirmations,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> clearAll() async {
    final db = await _db;

    await db.delete(DatabaseContract.tableBlockedAttempts);
    await db.delete(DatabaseContract.tableAppState);
    await db.delete(DatabaseContract.tableSettings);
    await db.delete(DatabaseContract.tableBlockedDomains);
    await db.delete(DatabaseContract.tableDailySummaries);
    await db.delete(DatabaseContract.tableGoals);
    await db.delete(DatabaseContract.tableAffirmations);

    await saveState(FocusShieldState.initial());
    await saveSettings(
      SettingsRecord(
        protectionEnabled: true,
        lockEnabled: true,
        delayedDisableHours: 24,
        updatedAt: DateTime.now(),
      ),
    );

    for (final blockedDomain in _defaultBlockedDomains()) {
      await saveBlockedDomain(blockedDomain);
    }

    for (final goal in _defaultGoals()) {
      await saveGoal(goal);
    }

    for (final affirmation in _defaultAffirmations()) {
      await saveAffirmation(affirmation);
    }
  }
}
