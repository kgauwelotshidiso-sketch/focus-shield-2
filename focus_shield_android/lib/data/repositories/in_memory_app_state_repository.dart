import '../../domain/models/affirmation.dart';
import '../../domain/models/app_snapshot.dart';
import '../../domain/models/attempt_record.dart';
import '../../domain/models/blocked_domain.dart';
import '../../domain/models/daily_summary.dart';
import '../../domain/models/focus_shield_state.dart';
import '../../domain/models/goal.dart';
import '../../domain/models/settings_record.dart';
import '../../domain/repositories/app_state_repository.dart';

class InMemoryAppStateRepository implements AppStateRepository {
  InMemoryAppStateRepository({
    FocusShieldState? initialState,
    SettingsRecord? initialSettings,
  }) : _state = initialState?.copy() ?? FocusShieldState.initial(),
       _settings =
           initialSettings ??
           SettingsRecord(
             protectionEnabled: true,
             lockEnabled: true,
             delayedDisableHours: 24,
             updatedAt: DateTime.now(),
           ) {
    _blockedDomains.addAll(_defaultBlockedDomains());
    _goals.addAll(_defaultGoals());
    _affirmations.addAll(_defaultAffirmations());
  }

  FocusShieldState _state;
  SettingsRecord _settings;
  final List<AttemptRecord> _attempts = [];
  final List<BlockedDomain> _blockedDomains = [];
  final List<DailySummary> _dailySummaries = [];
  final List<Goal> _goals = [];
  final List<Affirmation> _affirmations = [];

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

  List<Goal> _defaultGoals() {
    final now = DateTime.now();

    return [
      Goal(
        id: 1,
        title: 'Master fully listening',
        description:
            'Pause and wait for the person to finish speaking before responding.',
        createdAt: now,
        updatedAt: now,
      ),
      Goal(
        id: 2,
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
        id: 1,
        text: 'I pause, I listen, and I follow my dreams.',
        favorite: true,
        createdAt: now,
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
    final index = _attempts.lastIndexWhere((attempt) => !attempt.recovered);
    if (index < 0) return;

    _attempts[index] = _attempts[index].copyWith(recovered: true);
  }

  @override
  Future<void> markAttemptRecovered(int id) async {
    final index = _attempts.indexWhere((attempt) => attempt.id == id);
    if (index < 0) return;

    _attempts[index] = _attempts[index].copyWith(recovered: true);
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
        : _blockedDomains
                  .map((item) => item.id)
                  .reduce((a, b) => a > b ? a : b) +
              1;

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
  Future<void> saveDailySummary(DailySummary summary) async {
    final existingIndex = _dailySummaries.indexWhere(
      (item) => item.dateKey == summary.dateKey,
    );

    if (existingIndex >= 0) {
      _dailySummaries[existingIndex] = summary.copyWith(
        id: _dailySummaries[existingIndex].id,
        createdAt: DateTime.now(),
      );
      return;
    }

    final nextId = _dailySummaries.isEmpty
        ? 1
        : _dailySummaries
                  .map((item) => item.id)
                  .reduce((a, b) => a > b ? a : b) +
              1;

    _dailySummaries.add(summary.copyWith(id: nextId));
  }

  @override
  Future<List<DailySummary>> loadDailySummaries() async {
    final summaries = [..._dailySummaries]
      ..sort((a, b) => b.dateKey.compareTo(a.dateKey));
    return List<DailySummary>.unmodifiable(summaries);
  }

  @override
  Future<List<Goal>> loadGoals() async {
    return List<Goal>.unmodifiable(_goals);
  }

  @override
  Future<void> saveGoal(Goal goal) async {
    final title = goal.title.trim();
    if (title.isEmpty) return;

    if (goal.id != 0) {
      final index = _goals.indexWhere((item) => item.id == goal.id);
      if (index >= 0) {
        _goals[index] = goal.copyWith(title: title, updatedAt: DateTime.now());
        return;
      }
    }

    final nextId = _goals.isEmpty
        ? 1
        : _goals.map((item) => item.id).reduce((a, b) => a > b ? a : b) + 1;

    _goals.add(
      goal.copyWith(id: nextId, title: title, updatedAt: DateTime.now()),
    );
  }

  @override
  Future<void> deleteGoal(int id) async {
    _goals.removeWhere((item) => item.id == id);
  }

  @override
  Future<List<Affirmation>> loadAffirmations() async {
    return List<Affirmation>.unmodifiable(_affirmations);
  }

  @override
  Future<void> saveAffirmation(Affirmation affirmation) async {
    final text = affirmation.text.trim();
    if (text.isEmpty) return;

    if (affirmation.favorite) {
      for (var i = 0; i < _affirmations.length; i++) {
        _affirmations[i] = _affirmations[i].copyWith(favorite: false);
      }
    }

    if (affirmation.id != 0) {
      final index = _affirmations.indexWhere(
        (item) => item.id == affirmation.id,
      );
      if (index >= 0) {
        _affirmations[index] = affirmation.copyWith(
          text: text,
          updatedAt: DateTime.now(),
        );
        return;
      }
    }

    final nextId = _affirmations.isEmpty
        ? 1
        : _affirmations.map((item) => item.id).reduce((a, b) => a > b ? a : b) +
              1;

    _affirmations.add(
      affirmation.copyWith(id: nextId, text: text, updatedAt: DateTime.now()),
    );
  }

  @override
  Future<void> deleteAffirmation(int id) async {
    _affirmations.removeWhere((item) => item.id == id);
  }

  @override
  Future<void> clearAll() async {
    _state = FocusShieldState.initial();
    _attempts.clear();
    _dailySummaries.clear();

    _blockedDomains
      ..clear()
      ..addAll(_defaultBlockedDomains());

    _goals
      ..clear()
      ..addAll(_defaultGoals());

    _affirmations
      ..clear()
      ..addAll(_defaultAffirmations());

    _settings = SettingsRecord(
      protectionEnabled: true,
      lockEnabled: true,
      delayedDisableHours: 24,
      updatedAt: DateTime.now(),
    );
  }
}
