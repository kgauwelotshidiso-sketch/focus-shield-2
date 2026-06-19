import 'package:flutter_test/flutter_test.dart';
import 'package:focus_shield_android/domain/models/attempt_record.dart';
import 'package:focus_shield_android/domain/services/coach_engine.dart';

void main() {
  test('CoachEngine gives clean recovery insight when no attempts exist', () {
    final insight = CoachEngine().analyzeRecoveryHistory([]);

    expect(insight.totalAttempts, 0);
    expect(insight.pendingAttempts, 0);
    expect(insight.recoveryRate, 100);
    expect(insight.grade, 'Clean');
  });

  test('CoachEngine detects pending recovery attempts', () {
    final insight = CoachEngine().analyzeRecoveryHistory([
      AttemptRecord(
        id: 1,
        domain: 'blocked-example.com',
        category: 'local-blocklist',
        confidence: 0.96,
        recovered: false,
        createdAt: DateTime(2026),
      ),
    ]);

    expect(insight.totalAttempts, 1);
    expect(insight.pendingAttempts, 1);
    expect(insight.recoveryRate, 0);
    expect(insight.grade, 'Needs Action');
  });

  test('CoachEngine detects strong recovery discipline', () {
    final insight = CoachEngine().analyzeRecoveryHistory([
      AttemptRecord(
        id: 1,
        domain: 'blocked-example.com',
        category: 'local-blocklist',
        confidence: 0.96,
        recovered: true,
        createdAt: DateTime(2026),
      ),
    ]);

    expect(insight.totalAttempts, 1);
    expect(insight.pendingAttempts, 0);
    expect(insight.recoveryRate, 100);
    expect(insight.grade, 'Strong');
  });
}
