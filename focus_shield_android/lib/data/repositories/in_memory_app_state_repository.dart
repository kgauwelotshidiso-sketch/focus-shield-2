import '../../domain/models/app_snapshot.dart';
import '../../domain/models/attempt_record.dart';
import '../../domain/models/blocked_domain.dart';
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
            ) {
    _blockedDomains.addAll(_defaultBlockedDomains());
  }

  FocusShieldState _state;
  SettingsRecord _settings;
  final List<AttemptRecord> _attempts = [];
  final List<BlockedDomain> _blockedDomains = [];

  List<BlockedDomain> _defaultBlockedDomains() {
    final now = DateTime.now();

    return [
      BlockedDomain(
        id: 1,
        domain: 'blocked-example.com',
        category: 'local-blocklist',
        updatedAt: now,
      ),
      BlockedDomain(
        id: 2,
        domain: 'temptation-test.net',
        category: 'local-blocklist',
        updatedAt: now,
      ),
      BlockedDomain(
        id: 3,
        domain: 'focus-risk.org',
        category: 'local-blocklist',
        updatedAt: now,
      ),
    ];
  }

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
  Future<List<BlockedDomain>> loadBlockedDomains() async {
    return List<BlockedDomain>.unmodifiable(_blockedDomains);
  }

  @override
  Future<void> saveBlockedDomain(BlockedDomain blockedDomain) async {
    final normalizedDomain = blockedDomain.domain.trim().toLowerCase();
    if (normalizedDomain.isEmpty) return;

    final existingIndex = _blockedDomains.indexWhere(
      (item) => item.domain == normalizedDomain,
    );

    if (existingIndex >= 0) {
      _blockedDomains[existingIndex] = _blockedDomains[existingIndex].copyWith(
        category: blockedDomain.category,
        updatedAt: DateTime.now(),
      );
      return;
    }

    final nextId = _blockedDomains.isEmpty
        ? 1
        : _blockedDomains.map((item) => item.id).reduce((a, b) => a > b ? a : b) + 1;

    _blockedDomains.add(
      blockedDomain.copyWith(
        id: nextId,
        domain: normalizedDomain,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> deleteBlockedDomain(int id) async {
    _blockedDomains.removeWhere((item) => item.id == id);
  }

  @override
  Future<void> clearAll() async {
    _state = FocusShieldState.initial();
    _attempts.clear();
    _blockedDomains
      ..clear()
      ..addAll(_defaultBlockedDomains());

    _settings = SettingsRecord(
      protectionEnabled: true,
      lockEnabled: true,
      delayedDisableHours: 24,
      updatedAt: DateTime.now(),
    );
  }
}
