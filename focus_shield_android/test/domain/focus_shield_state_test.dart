import 'package:flutter_test/flutter_test.dart';
import 'package:focus_shield_android/domain/models/focus_shield_state.dart';

void main() {
  test('FocusShieldState calculates level, recovery rate, and coach score', () {
    final state = FocusShieldState.initial()
      ..xp = 145
      ..blockedAttempts = 2
      ..recoveredAttempts = 1
      ..listeningWinsToday = 2
      ..morningCommandSet = true;

    expect(state.level, 2);
    expect(state.recoveryRate, 50);
    expect(state.pendingRecoveries, 1);
    expect(state.coachScore, greaterThan(0));
  });

  test('FocusShieldState can map to and from memory map', () {
    final state = FocusShieldState.initial()
      ..xp = 120
      ..listeningWinsToday = 3
      ..protectionEnabled = false;

    final restored = FocusShieldState.fromMap(state.toMap());

    expect(restored.xp, 120);
    expect(restored.listeningWinsToday, 3);
    expect(restored.protectionEnabled, false);
  });
}
