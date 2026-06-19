import 'package:flutter_test/flutter_test.dart';
import 'package:focus_shield_android/data/database/database_provider.dart';
import 'package:focus_shield_android/data/repositories/sqlite_app_state_repository.dart';
import 'package:focus_shield_android/domain/models/attempt_record.dart';
import 'package:focus_shield_android/domain/models/blocked_domain.dart';
import 'package:focus_shield_android/domain/models/focus_shield_state.dart';
import 'package:focus_shield_android/domain/models/settings_record.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DatabaseProvider provider;
  late SqliteAppStateRepository repository;

  setUp(() {
    sqfliteFfiInit();

    provider = DatabaseProvider(
      overridePath: inMemoryDatabasePath,
      databaseFactory: databaseFactoryFfi,
    );

    repository = SqliteAppStateRepository(databaseProvider: provider);
  });

  tearDown(() async {
    await provider.close();
  });

  test('SQLite repository saves and loads state', () async {
    final state = FocusShieldState.initial()
      ..xp = 250
      ..listeningWinsToday = 3
      ..protectionEnabled = false;

    await repository.saveState(state);

    final snapshot = await repository.loadSnapshot();

    expect(snapshot.state.xp, 250);
    expect(snapshot.state.listeningWinsToday, 3);
    expect(snapshot.state.protectionEnabled, false);
  });

  test('SQLite repository saves attempts and marks latest recovered', () async {
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
    expect(attempts.first.domain, 'blocked-example.com');
    expect(attempts.first.recovered, false);

    await repository.markLatestAttemptRecovered();

    attempts = await repository.loadAttempts();

    expect(attempts.first.recovered, true);
  });

  test('SQLite repository saves and loads settings', () async {
    await repository.saveSettings(
      SettingsRecord(
        protectionEnabled: false,
        lockEnabled: true,
        delayedDisableHours: 48,
        updatedAt: DateTime(2026),
      ),
    );

    final settings = await repository.loadSettings();

    expect(settings.protectionEnabled, false);
    expect(settings.lockEnabled, true);
    expect(settings.delayedDisableHours, 48);
  });

  test('SQLite repository seeds, saves, and deletes blocked domains', () async {
    var domains = await repository.loadBlockedDomains();

    expect(domains.any((item) => item.domain == 'blocked-example.com'), true);

    await repository.saveBlockedDomain(
      BlockedDomain(
        id: 0,
        domain: 'custom-risk.test',
        category: 'custom-blocklist',
        updatedAt: DateTime(2026),
      ),
    );

    domains = await repository.loadBlockedDomains();

    expect(domains.any((item) => item.domain == 'custom-risk.test'), true);

    final customDomain = domains.firstWhere((item) => item.domain == 'custom-risk.test');
    await repository.deleteBlockedDomain(customDomain.id);

    domains = await repository.loadBlockedDomains();

    expect(domains.any((item) => item.domain == 'custom-risk.test'), false);
  });

  test('SQLite repository clearAll resets data and restores default blocklist', () async {
    final state = FocusShieldState.initial()..xp = 500;

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
