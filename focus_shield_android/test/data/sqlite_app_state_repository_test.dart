import 'package:flutter_test/flutter_test.dart';
import 'package:focus_shield_android/data/contracts/database_contract.dart';

void main() {
  test('SQLite database contract is configured', () {
    expect(DatabaseContract.databaseName, 'focus_shield.db');
    expect(DatabaseContract.databaseVersion, greaterThanOrEqualTo(3));
    expect(DatabaseContract.tableAppState, 'app_state');
    expect(DatabaseContract.tableBlockedAttempts, 'blocked_attempts');
    expect(DatabaseContract.tableBlockedDomains, 'blocked_domains');
    expect(DatabaseContract.tableDailySummaries, 'daily_summaries');
    expect(DatabaseContract.tableGoals, 'goals');
    expect(DatabaseContract.tableAffirmations, 'affirmations');
  });
}
