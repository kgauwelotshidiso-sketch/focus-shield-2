import 'package:flutter_test/flutter_test.dart';
import 'package:focus_shield_android/data/repositories/in_memory_app_state_repository.dart';
import 'package:focus_shield_android/domain/models/attempt_record.dart';
import 'package:focus_shield_android/domain/models/blocked_domain.dart';
import 'package:focus_shield_android/domain/models/focus_shield_state.dart';
import 'package:focus_shield_android/domain/models/settings_record.dart';

void main() {
  test('repository saves and loads app state snapshot', () async {
    final repository = InMemoryAppStateRepository();
    final state = FocusShieldState.initial()
      ..xp = 200
      ..listeningWinsToday = 3;

    await repository.saveState(state);

    final snapshot = await repository.loadSnapshot();

    expect(snapshot.version, 1);
    expect(snapshot.state.xp, 200);
    expect(snapshot.state.listeningWinsToday, 3);
  });

  test('repository saves attempts and marks latest recovered', () async {
    final repository = InMemoryAppStateRepository();

    await repository.saveAttempt(
      AttemptRecord(
        id: 0,
        domain: 'blocked-example.com',
        category: 'local-blocklist',
        confidence: 0.96,
        recovered: false,
        createdAt: DateTime(2026),
      ),
    );

    var attempts = await repository.loadAttempts();

    expect(attempts.length, 1);
    expect(attempts.first.id, 1);
    expect(attempts.first.recovered, false);

    await repository.markLatestAttemptRecovered();

    attempts = await repository.loadAttempts();

    expect(attempts.first.recovered, true);
  });

  test('repository saves and loads settings', () async {
    final repository = InMemoryAppStateRepository();

    await repository.saveSettings(
      SettingsRecord(
        protectionEnabled: false,
        lockEnabled: true,
        delayedDisableHours: 24,
        updatedAt: DateTime(2026),
      ),
    );

    final settings = await repository.loadSettings();

    expect(settings.protectionEnabled, false);
    expect(settings.lockEnabled, true);
    expect(settings.delayedDisableHours, 24);
  });

  test('repository marks a specific attempt recovered', () async {
    final repository = InMemoryAppStateRepository();

    await repository.saveAttempt(
      AttemptRecord(
        id: 0,
        domain: 'blocked-example.com',
        category: 'local-blocklist',
        confidence: 0.96,
        recovered: false,
        createdAt: DateTime(2026),
      ),
    );

    final attempts = await repository.loadAttempts();
    final attemptId = attempts.first.id;

    await repository.markAttemptRecovered(attemptId);

    final updatedAttempts = await repository.loadAttempts();

    expect(updatedAttempts.first.recovered, true);
  });

  test('repository saves and deletes blocked domains', () async {
    final repository = InMemoryAppStateRepository();

    await repository.saveBlockedDomain(
      BlockedDomain(
        id: 0,
        domain: 'custom-risk.test',
        category: 'custom-blocklist',
        updatedAt: DateTime(2026),
      ),
    );

    var domains = await repository.loadBlockedDomains();

    expect(domains.any((item) => item.domain == 'custom-risk.test'), true);

    final customDomain = domains.firstWhere((item) => item.domain == 'custom-risk.test');
    await repository.deleteBlockedDomain(customDomain.id);

    domains = await repository.loadBlockedDomains();

    expect(domains.any((item) => item.domain == 'custom-risk.test'), false);
  });

  test('repository clearAll resets state and attempts', () async {
    final repository = InMemoryAppStateRepository();

    final state = FocusShieldState.initial()..xp = 300;
    await repository.saveState(state);

    await repository.saveAttempt(
      AttemptRecord(
        id: 0,
        domain: 'blocked-example.com',
        category: 'local-blocklist',
        confidence: 0.96,
        recovered: false,
        createdAt: DateTime(2026),
      ),
    );

    await repository.clearAll();

    final snapshot = await repository.loadSnapshot();
    final attempts = await repository.loadAttempts();
    final domains = await repository.loadBlockedDomains();

    expect(snapshot.state.xp, 45);
    expect(attempts, isEmpty);
    expect(domains.any((item) => item.domain == 'blocked-example.com'), true);
  });
}
