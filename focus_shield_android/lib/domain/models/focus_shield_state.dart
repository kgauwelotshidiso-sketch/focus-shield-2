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
      xp: 0,
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

  factory FocusShieldState.fromMap(Map map) {
    final state = FocusShieldState(
      listeningWinsToday: (map['listeningWinsToday'] as int?) ?? 0,
      missionTarget: (map['missionTarget'] as int?) ?? 3,
      xp: (map['xp'] as int?) ?? 0,
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

    state.normalizeLegacyStarterXp();
    return state;
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

  int get xpForNextLevel => 100;

  int get level => (xp ~/ xpForNextLevel) + 1;

  int get xpInCurrentLevel => xp % xpForNextLevel;

  double get levelProgress {
    if (xpForNextLevel == 0) return 0;
    return xpInCurrentLevel / xpForNextLevel;
  }

  bool get focusSessionCompletedToday => focusSessionsToday > 0;

  bool get reflectionCompletedToday => reflectionsToday > 0;

  bool get concentrationCompletedToday => concentrationWinsToday > 0;

  bool get dailyCoreTasksComplete {
    return focusSessionCompletedToday &&
        reflectionCompletedToday &&
        concentrationCompletedToday;
  }

  bool get hasTrackedActivity {
    return listeningWinsToday > 0 ||
        blockedAttempts > 0 ||
        recoveredAttempts > 0 ||
        focusSessionsToday > 0 ||
        reflectionsToday > 0 ||
        concentrationWinsToday > 0 ||
        morningCommandSet ||
        endReviewsToday > 0 ||
        currentStreak > 0 ||
        longestStreak > 0 ||
        completedDays > 0;
  }

  void normalizeLegacyStarterXp() {
    if (xp == 45 && !hasTrackedActivity) {
      xp = 0;
    }

    if (xp < 0) {
      xp = 0;
    }
  }

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
        ((focusSessionsToday + reflectionsToday + concentrationWinsToday) * 10)
            .clamp(0, 15)
            .toInt();

    return (morningScore + missionPart + recoveryPart + activityPart).clamp(
      0,
      100,
    );
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

  Map toMap() {
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
      'xpInCurrentLevel': xpInCurrentLevel,
      'xpForNextLevel': xpForNextLevel,
      'levelProgress': levelProgress,
      'recoveryRate': recoveryRate,
      'coachScore': coachScore,
      'missionComplete': missionComplete,
      'dailyCoreTasksComplete': dailyCoreTasksComplete,
    };
  }
}
