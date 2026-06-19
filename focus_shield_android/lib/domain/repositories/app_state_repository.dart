import '../models/affirmation.dart';
import '../models/app_snapshot.dart';
import '../models/attempt_record.dart';
import '../models/blocked_domain.dart';
import '../models/daily_summary.dart';
import '../models/focus_shield_state.dart';
import '../models/goal.dart';
import '../models/settings_record.dart';

abstract class AppStateRepository {
  Future<AppSnapshot> loadSnapshot();

  Future<void> saveState(FocusShieldState state);

  Future<void> saveAttempt(AttemptRecord attempt);

  Future<List<AttemptRecord>> loadAttempts();

  Future<void> markLatestAttemptRecovered();

  Future<void> markAttemptRecovered(int id);

  Future<void> saveSettings(SettingsRecord settings);

  Future<SettingsRecord> loadSettings();

  Future<List<BlockedDomain>> loadBlockedDomains();

  Future<void> saveBlockedDomain(BlockedDomain blockedDomain);

  Future<void> deleteBlockedDomain(int id);

  Future<void> saveDailySummary(DailySummary summary);

  Future<List<DailySummary>> loadDailySummaries();

  Future<List<Goal>> loadGoals();

  Future<void> saveGoal(Goal goal);

  Future<void> deleteGoal(int id);

  Future<List<Affirmation>> loadAffirmations();

  Future<void> saveAffirmation(Affirmation affirmation);

  Future<void> deleteAffirmation(int id);

  Future<void> clearAll();
}
