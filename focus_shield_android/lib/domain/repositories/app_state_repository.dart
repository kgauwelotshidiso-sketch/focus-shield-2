import '../models/app_snapshot.dart';
import '../models/attempt_record.dart';
import '../models/blocked_domain.dart';
import '../models/focus_shield_state.dart';
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

  Future<void> clearAll();
}
