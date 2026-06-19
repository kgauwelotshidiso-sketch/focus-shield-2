import '../../core/utils/date_key.dart';

class FocusShieldState {
  FocusShieldState({
    required this.listeningWinsToday,
    required this.missionTarget,
    required this.xp,
    required this.blockedAttempts,
    required this.recoveredAttempts,
    required this.focusSessionsToday,
    required this.reflectionsToday,
    required this.concentrationWinsToday,
    required this.protectionEnabled,
    required this.morningCommandSet,
    required this.endReviewsToday,
    required this.lastActiveDate,
    required this.currentStreak,
    required this.longestStreak,
    required this.completedDays,
  });

  factory FocusShieldState.initial() {
    return FocusShieldState(
      listeningWinsToday: 0,
      missionTarget: 3,
      xp: 45,
      blockedAttempts: 0,
      recoveredAttempts: 0,
      focusSessionsToday: 0,
      reflectionsToday: 0,
      concentrationWinsToday: 0,
      protectionEnabled: true,
      morningCommandSet: false,
      endReviewsToday: 0,
      lastActiveDate: DateKey.today(),
      currentStreak: 0,
      longestStreak: 0,
      completedDays: 0,
    );
  }

  factory FocusShieldState.fromMap(Map<String, Object?> map) {
    return FocusShieldState(
      listeningWinsToday: (map['listeningWinsToday'] as int?) ?? 0,
      missionTarget: (map['missionTarget'] as int?) ?? 3,
      xp: (map['xp'] as int?) ?? 45,
      blockedAttempts: (map['blockedAttempts'] as int?) ?? 0,
      recoveredAttempts: (map['recoveredAttempts'] as int?) ?? 0,
      focusSessionsToday: (map['focusSessionsToday'] as int?) ?? 0,
      reflectionsToday: (map['reflectionsToday'] as int?) ?? 0,
      concentrationWinsToday: (map['concentrationWinsToday'] as int?) ?? 0,
      protectionEnabled: (map['protectionEnabled'] as bool?) ?? true,
      morningCommandSet: (map['morningCommandSet'] as bool?) ?? false,
      endReviewsToday: (map['endReviewsToday'] as int?) ?? 0,
      lastActiveDate: (map['lastActiveDate'] as String?) ?? DateKey.today(),
      currentStreak: (map['currentStreak'] as int?) ?? 0,
      longestStreak: (map['longestStreak'] as int?) ?? 0,
      completedDays: (map['completedDays'] as int?) ?? 0,
    );
  }

  int listeningWinsToday;
  int missionTarget;
  int xp;
  int blockedAttempts;
  int recoveredAttempts;
  int focusSessionsToday;
  int reflectionsToday;
  int concentrationWinsToday;
  bool protectionEnabled;
  bool morningCommandSet;
  int endReviewsToday;
  String lastActiveDate;
  int currentStreak;
  int longestStreak;
  int completedDays;

  int get level => (xp ~/ 100) + 1;

  int get recoveryRate {
    if (blockedAttempts == 0) return 100;
    return ((recoveredAttempts / blockedAttempts) * 100).round();
  }

  int get pendingRecoveries {
    final pending = blockedAttempts - recoveredAttempts;
    return pending < 0 ? 0 : pending;
  }

  int get missionScore {
    if (missionTarget == 0) return 100;
    return ((listeningWinsToday / missionTarget) * 100).clamp(0, 100).round();
  }

  int get coachScore {
    final morningScore = morningCommandSet ? 25 : 0;
    final missionPart = (missionScore * 0.35).round();
    final recoveryPart = (recoveryRate * 0.25).round();
    final activityPart =
        ((focusSessionsToday + reflectionsToday + concentrationWinsToday) * 10).clamp(0, 15);
    return (morningScore + missionPart + recoveryPart + activityPart).clamp(0, 100);
  }

  bool get missionComplete => listeningWinsToday >= missionTarget;

  void recordCompletedDay({required bool missionWasComplete}) {
    completedDays += 1;

    if (missionWasComplete) {
      currentStreak += 1;
      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }
      return;
    }

    currentStreak = 0;
  }

  bool applyDailyResetIfNeeded({DateTime? now}) {
    final todayKey = DateKey.today(now);

    if (lastActiveDate == todayKey) {
      return false;
    }

    listeningWinsToday = 0;
    focusSessionsToday = 0;
    reflectionsToday = 0;
    concentrationWinsToday = 0;
    morningCommandSet = false;
    endReviewsToday = 0;
    lastActiveDate = todayKey;

    return true;
  }

  FocusShieldState copy() {
    return FocusShieldState(
      listeningWinsToday: listeningWinsToday,
      missionTarget: missionTarget,
      xp: xp,
      blockedAttempts: blockedAttempts,
      recoveredAttempts: recoveredAttempts,
      focusSessionsToday: focusSessionsToday,
      reflectionsToday: reflectionsToday,
      concentrationWinsToday: concentrationWinsToday,
      protectionEnabled: protectionEnabled,
      morningCommandSet: morningCommandSet,
      endReviewsToday: endReviewsToday,
      lastActiveDate: lastActiveDate,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      completedDays: completedDays,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'listeningWinsToday': listeningWinsToday,
      'missionTarget': missionTarget,
      'xp': xp,
      'blockedAttempts': blockedAttempts,
      'recoveredAttempts': recoveredAttempts,
      'focusSessionsToday': focusSessionsToday,
      'reflectionsToday': reflectionsToday,
      'concentrationWinsToday': concentrationWinsToday,
      'protectionEnabled': protectionEnabled,
      'morningCommandSet': morningCommandSet,
      'endReviewsToday': endReviewsToday,
      'lastActiveDate': lastActiveDate,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'completedDays': completedDays,
      'level': level,
      'recoveryRate': recoveryRate,
      'coachScore': coachScore,
      'missionComplete': missionComplete,
    };
  }
}
