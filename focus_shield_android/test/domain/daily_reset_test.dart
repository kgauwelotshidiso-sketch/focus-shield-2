import 'package:flutter_test/flutter_test.dart';
import 'package:focus_shield_android/domain/models/focus_shield_state.dart';

void main() {
  test('daily reset clears daily counters but preserves lifetime values', () {
    final state = FocusShieldState.initial()
      ..listeningWinsToday = 3
      ..focusSessionsToday = 2
      ..reflectionsToday = 1
      ..concentrationWinsToday = 1
      ..morningCommandSet = true
      ..endReviewsToday = 1
      ..xp = 500
      ..blockedAttempts = 4
      ..recoveredAttempts = 3
      ..lastActiveDate = '2026-01-01';

    final applied = state.applyDailyResetIfNeeded(now: DateTime(2026, 1, 2));

    expect(applied, true);
    expect(state.listeningWinsToday, 0);
    expect(state.focusSessionsToday, 0);
    expect(state.reflectionsToday, 0);
    expect(state.concentrationWinsToday, 0);
    expect(state.morningCommandSet, false);
    expect(state.endReviewsToday, 0);

    expect(state.xp, 500);
    expect(state.blockedAttempts, 4);
    expect(state.recoveredAttempts, 3);
    expect(state.lastActiveDate, '2026-01-02');
  });

  test('daily reset does nothing when date is unchanged', () {
    final state = FocusShieldState.initial()
      ..listeningWinsToday = 2
      ..xp = 100
      ..lastActiveDate = '2026-01-02';

    final applied = state.applyDailyResetIfNeeded(now: DateTime(2026, 1, 2));

    expect(applied, false);
    expect(state.listeningWinsToday, 2);
    expect(state.xp, 100);
    expect(state.lastActiveDate, '2026-01-02');
  });
}
