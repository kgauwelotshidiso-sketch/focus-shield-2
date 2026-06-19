import '../../domain/models/app_snapshot.dart';
import '../../domain/models/attempt_record.dart';
import '../../domain/models/blocked_domain.dart';
import '../../domain/models/focus_shield_state.dart';
import '../../domain/models/settings_record.dart';
import '../../domain/repositories/app_state_repository.dart';

class SqliteAppStateRepositoryStub implements AppStateRepository {
  const SqliteAppStateRepositoryStub();

  @override
  Future<AppSnapshot> loadSnapshot() {
    throw UnimplementedError('SQLite repository is connected in sqlite_app_state_repository.dart.');
  }

  @override
  Future<void> saveState(FocusShieldState state) {
    throw UnimplementedError('SQLite repository is connected in sqlite_app_state_repository.dart.');
  }

  @override
  Future<void> saveAttempt(AttemptRecord attempt) {
    throw UnimplementedError('SQLite repository is connected in sqlite_app_state_repository.dart.');
  }

  @override
  Future<List<AttemptRecord>> loadAttempts() {
    throw UnimplementedError('SQLite repository is connected in sqlite_app_state_repository.dart.');
  }

  @override
  Future<void> markLatestAttemptRecovered() {
    throw UnimplementedError('SQLite repository is connected in sqlite_app_state_repository.dart.');
  }

  @override
  Future<void> saveSettings(SettingsRecord settings) {
    throw UnimplementedError('SQLite repository is connected in sqlite_app_state_repository.dart.');
  }

  @override
  Future<SettingsRecord> loadSettings() {
    throw UnimplementedError('SQLite repository is connected in sqlite_app_state_repository.dart.');
  }

  @override
  Future<List<BlockedDomain>> loadBlockedDomains() {
    throw UnimplementedError('SQLite repository is connected in sqlite_app_state_repository.dart.');
  }

  @override
  Future<void> saveBlockedDomain(BlockedDomain blockedDomain) {
    throw UnimplementedError('SQLite repository is connected in sqlite_app_state_repository.dart.');
  }

  @override
  Future<void> deleteBlockedDomain(int id) {
    throw UnimplementedError('SQLite repository is connected in sqlite_app_state_repository.dart.');
  }

  @override
  Future<void> clearAll() {
    throw UnimplementedError('SQLite repository is connected in sqlite_app_state_repository.dart.');
  }
}
