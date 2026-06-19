import 'package:flutter_test/flutter_test.dart';
import 'package:focus_shield_android/domain/models/daily_summary.dart';
import 'package:focus_shield_android/domain/models/focus_shield_state.dart';

void main() {
  test('recordCompletedDay increases streak when mission is complete', () {
    final state = FocusShieldState.initial();

    state.recordCompletedDay(missionWasComplete: true);

    expect(state.completedDays, 1);
    expect(state.currentStreak, 1);
    expect(state.longestStreak, 1);
  });

  test('recordCompletedDay resets current streak when mission fails', () {
    final state = FocusShieldState.initial()
      ..currentStreak = 3
      ..longestStreak = 3
      ..completedDays = 3;

    state.recordCompletedDay(missionWasComplete: false);

    expect(state.completedDays, 4);
    expect(state.currentStreak, 0);
    expect(state.longestStreak, 3);
  });

  test('DailySummary captures state before reset', () {
    final state = FocusShieldState.initial()
      ..listeningWinsToday = 3
      ..focusSessionsToday = 2
      ..xp = 250
      ..lastActiveDate = '2026-01-01';

    final summary = DailySummary.fromState(state);

    expect(summary.dateKey, '2026-01-01');
    expect(summary.listeningWins, 3);
    expect(summary.missionComplete, true);
    expect(summary.focusSessions, 2);
    expect(summary.xpTotal, 250);
  });
}
