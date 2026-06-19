import '../../domain/models/app_snapshot.dart';
import '../../domain/models/attempt_record.dart';
import '../../domain/models/focus_shield_state.dart';
import '../../domain/models/settings_record.dart';
import '../../domain/repositories/app_state_repository.dart';

class InMemoryAppStateRepository implements AppStateRepository {
  InMemoryAppStateRepository({
    FocusShieldState? initialState,
    SettingsRecord? initialSettings,
  })  : _state = initialState?.copy() ?? FocusShieldState.initial(),
        _settings = initialSettings ??
            SettingsRecord(
              protectionEnabled: true,
              lockEnabled: true,
              delayedDisableHours: 24,
              updatedAt: DateTime.now(),
            );

  FocusShieldState _state;
  SettingsRecord _settings;
  final List<AttemptRecord> _attempts = [];

  @override
  Future<AppSnapshot> loadSnapshot() async {
    return AppSnapshot(
      state: _state.copy(),
      createdAt: DateTime.now(),
      version: 1,
    );
  }

  @override
  Future<void> saveState(FocusShieldState state) async {
    _state = state.copy();
  }

  @override
  Future<void> saveAttempt(AttemptRecord attempt) async {
    final nextId = attempt.id == 0 ? _attempts.length + 1 : attempt.id;
    _attempts.add(attempt.copyWith(id: nextId));
  }

  @override
  Future<List<AttemptRecord>> loadAttempts() async {
    return List<AttemptRecord>.unmodifiable(_attempts);
  }

  @override
  Future<void> markLatestAttemptRecovered() async {
    if (_attempts.isEmpty) return;

    final latest = _attempts.last;
    _attempts[_attempts.length - 1] = latest.copyWith(recovered: true);
  }

  @override
  Future<void> saveSettings(SettingsRecord settings) async {
    _settings = settings.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<SettingsRecord> loadSettings() async {
    return _settings;
  }

  @override
  Future<void> clearAll() async {
    _state = FocusShieldState.initial();
    _attempts.clear();
    _settings = SettingsRecord(
      protectionEnabled: true,
      lockEnabled: true,
      delayedDisableHours: 24,
      updatedAt: DateTime.now(),
    );
  }
}
