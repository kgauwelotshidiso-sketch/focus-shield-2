import 'package:shared_preferences/shared_preferences.dart';

class CommitmentSnapshot {
  const CommitmentSnapshot({
    required this.isSet,
    required this.days,
    required this.daysLeft,
    required this.startedAtMs,
  });

  final bool isSet;
  final int days;
  final int daysLeft;
  final int startedAtMs;

  String get statusLabel => isSet ? 'Active' : 'Required';

  String get daysLeftLabel {
    if (!isSet) return 'Set commitment';
    if (daysLeft <= 0) return 'Completed';
    return '$daysLeft days left';
  }

  String get progressLabel {
    if (!isSet) return 'Not set';
    if (daysLeft <= 0) return 'Completed';
    return '$daysLeft days left';
  }
}

class CommitmentSyncService {
  static const String phase4DaysKey = 'phase4a_commitment_days';
  static const String phase4StartKey = 'phase4a_commitment_start_ms';

  static const String phase6DaysKey = 'phase6j_commitment_days';
  static const String phase6StartKey = 'phase6j_commitment_start_ms';
  static const String phase6SyncedKey = 'phase6j_commitment_synced';

  static Future<CommitmentSnapshot> load({
    int? fallbackDays,
    bool forceDefaultIfMissing = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    int days =
        prefs.getInt(phase6DaysKey) ??
        prefs.getInt(phase4DaysKey) ??
        fallbackDays ??
        0;

    int startedAtMs =
        prefs.getInt(phase6StartKey) ?? prefs.getInt(phase4StartKey) ?? 0;

    if (forceDefaultIfMissing && days <= 0) {
      days = 365;
      startedAtMs = DateTime.now().millisecondsSinceEpoch;
      await save(days);
    } else if (days > 0 && startedAtMs <= 0) {
      startedAtMs = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(phase6StartKey, startedAtMs);
    }

    if (days > 0) {
      await prefs.setInt(phase6DaysKey, days);
      await prefs.setInt(phase4DaysKey, days);
      await prefs.setInt(phase6StartKey, startedAtMs);
      await prefs.setInt(phase4StartKey, startedAtMs);
      await prefs.setBool(phase6SyncedKey, true);
    }

    final daysLeft = _daysLeft(days, startedAtMs);

    return CommitmentSnapshot(
      isSet: days > 0,
      days: days,
      daysLeft: daysLeft,
      startedAtMs: startedAtMs,
    );
  }

  static Future<CommitmentSnapshot> save(int days) async {
    final prefs = await SharedPreferences.getInstance();
    final startedAtMs = DateTime.now().millisecondsSinceEpoch;

    await prefs.setInt(phase6DaysKey, days);
    await prefs.setInt(phase4DaysKey, days);
    await prefs.setInt(phase6StartKey, startedAtMs);
    await prefs.setInt(phase4StartKey, startedAtMs);
    await prefs.setBool(phase6SyncedKey, true);

    return CommitmentSnapshot(
      isSet: true,
      days: days,
      daysLeft: days,
      startedAtMs: startedAtMs,
    );
  }

  static Future<void> ensureDailyUseDefaults() async {
    final prefs = await SharedPreferences.getInstance();

    // Phase 6J rule:
    // real daily-use mode is the default. Testing tools stay hidden
    // unless the user intentionally enables Testing Mode.
    final bool hasChosenTestingMode =
        prefs.containsKey('phase6i_testing_mode') ||
        prefs.containsKey('phase6j_testing_mode') ||
        prefs.containsKey('focus_shield_testing_mode');

    if (!hasChosenTestingMode) {
      await prefs.setBool('phase6i_testing_mode', false);
      await prefs.setBool('phase6j_testing_mode', false);
      await prefs.setBool('focus_shield_testing_mode', false);
      await prefs.setBool('phase6i_testing_tools_visible', false);
      await prefs.setBool('phase6j_testing_tools_visible', false);
      await prefs.setBool('focus_shield_testing_tools_visible', false);
      await prefs.setBool('phase6i_real_use_mode', true);
      await prefs.setBool('phase6j_real_use_mode', true);
      await prefs.setBool('focus_shield_real_use_mode', true);
    }

    // Keep the commitment state copied into every legacy key family
    // that older screens may still read.
    final snapshot = await load(forceDefaultIfMissing: true);
    if (snapshot.isSet) {
      await prefs.setInt('commitment_days', snapshot.days);
      await prefs.setInt('commitment_start_ms', snapshot.startedAtMs);
      await prefs.setInt('commitment_days_left', snapshot.daysLeft);
      await prefs.setBool('commitment_active', true);

      await prefs.setInt('phase4a_commitment_days', snapshot.days);
      await prefs.setInt('phase4a_commitment_start_ms', snapshot.startedAtMs);

      await prefs.setInt('phase6j_commitment_days', snapshot.days);
      await prefs.setInt('phase6j_commitment_start_ms', snapshot.startedAtMs);
      await prefs.setInt('phase6j_commitment_days_left', snapshot.daysLeft);
      await prefs.setBool('phase6j_commitment_active', true);
    }
  }

  static int _daysLeft(int days, int startedAtMs) {
    if (days <= 0) return 0;
    if (startedAtMs <= 0) return days;

    final started = DateTime.fromMillisecondsSinceEpoch(startedAtMs);
    final elapsed = DateTime.now().difference(started).inDays;
    final left = days - elapsed;

    if (left < 0) return 0;
    return left;
  }
}
