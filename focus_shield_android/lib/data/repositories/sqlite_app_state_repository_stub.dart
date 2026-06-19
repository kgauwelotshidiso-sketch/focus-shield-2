import '../../domain/models/app_snapshot.dart';
import '../../domain/models/attempt_record.dart';
import '../../domain/models/focus_shield_state.dart';
import '../../domain/models/settings_record.dart';
import '../../domain/repositories/app_state_repository.dart';

class SqliteAppStateRepositoryStub implements AppStateRepository {
  const SqliteAppStateRepositoryStub();

  @override
  Future<AppSnapshot> loadSnapshot() {
    throw UnimplementedError('SQLite repository will be connected in Phase 6.7.');
  }

  @override
  Future<void> saveState(FocusShieldState state) {
    throw UnimplementedError('SQLite repository will be connected in Phase 6.7.');
  }

  @override
  Future<void> saveAttempt(AttemptRecord attempt) {
    throw UnimplementedError('SQLite repository will be connected in Phase 6.7.');
  }

  @override
  Future<List<AttemptRecord>> loadAttempts() {
    throw UnimplementedError('SQLite repository will be connected in Phase 6.7.');
  }

  @override
  Future<void> markLatestAttemptRecovered() {
    throw UnimplementedError('SQLite repository will be connected in Phase 6.7.');
  }

  @override
  Future<void> saveSettings(SettingsRecord settings) {
    throw UnimplementedError('SQLite repository will be connected in Phase 6.7.');
  }

  @override
  Future<SettingsRecord> loadSettings() {
    throw UnimplementedError('SQLite repository will be connected in Phase 6.7.');
  }

  @override
  Future<void> clearAll() {
    throw UnimplementedError('SQLite repository will be connected in Phase 6.7.');
  }
}
