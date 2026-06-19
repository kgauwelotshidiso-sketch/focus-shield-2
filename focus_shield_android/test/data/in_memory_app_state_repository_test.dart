import 'package:flutter_test/flutter_test.dart';
import 'package:focus_shield_android/data/repositories/in_memory_app_state_repository.dart';
import 'package:focus_shield_android/domain/models/affirmation.dart';
import 'package:focus_shield_android/domain/models/attempt_record.dart';
import 'package:focus_shield_android/domain/models/blocked_domain.dart';
import 'package:focus_shield_android/domain/models/daily_summary.dart';
import 'package:focus_shield_android/domain/models/focus_shield_state.dart';
import 'package:focus_shield_android/domain/models/goal.dart';

void main() {
  test('in-memory repository saves and loads app state', () async {
    final repository = InMemoryAppStateRepository();

    final state = FocusShieldState.initial()
      ..xp = 200
      ..listeningWinsToday = 3;

    await repository.saveState(state);

    final snapshot = await repository.loadSnapshot();

    expect(snapshot.state.xp, 200);
    expect(snapshot.state.listeningWinsToday, 3);
  });

  test('in-memory repository saves attempts and marks recovered', () async {
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

    expect(attempts.length, 1);
    expect(attempts.first.recovered, false);

    await repository.markAttemptRecovered(attempts.first.id);

    final updated = await repository.loadAttempts();

    expect(updated.first.recovered, true);
  });

  test('in-memory repository saves blocked domains', () async {
    final repository = InMemoryAppStateRepository();

    await repository.saveBlockedDomain(
      BlockedDomain(
        id: 0,
        domain: 'custom-risk.test',
        category: 'custom-blocklist',
        updatedAt: DateTime(2026),
      ),
    );

    final domains = await repository.loadBlockedDomains();

    expect(domains.any((item) => item.domain == 'custom-risk.test'), true);
  });

  test('in-memory repository saves daily summaries', () async {
    final repository = InMemoryAppStateRepository();

    await repository.saveDailySummary(
      DailySummary(
        id: 0,
        dateKey: '2026-01-01',
        listeningWins: 3,
        missionTarget: 3,
        missionComplete: true,
        xpTotal: 250,
        focusSessions: 2,
        reflections: 1,
        concentrationWins: 1,
        blockedAttempts: 1,
        recoveredAttempts: 1,
        recoveryRate: 100,
        coachScore: 90,
        createdAt: DateTime(2026),
      ),
    );

    final summaries = await repository.loadDailySummaries();

    expect(summaries.length, 1);
    expect(summaries.first.dateKey, '2026-01-01');
  });

  test('in-memory repository saves goals and affirmations', () async {
    final repository = InMemoryAppStateRepository();

    await repository.saveGoal(
      Goal(
        id: 0,
        title: 'Custom discipline goal',
        description: 'Stay consistent.',
      ),
    );

    await repository.saveAffirmation(
      Affirmation(
        id: 0,
        text: 'I return to my goals immediately.',
        favorite: true,
      ),
    );

    final goals = await repository.loadGoals();
    final affirmations = await repository.loadAffirmations();

    expect(goals.any((goal) => goal.title == 'Custom discipline goal'), true);
    expect(
      affirmations.any(
        (affirmation) =>
            affirmation.text == 'I return to my goals immediately.',
      ),
      true,
    );
  });
}
