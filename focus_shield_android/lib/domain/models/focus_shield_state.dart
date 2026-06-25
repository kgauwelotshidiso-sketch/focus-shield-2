import '../../core/utils/date_key.dart';

class FocusShieldState {
  FocusShieldState({
    this.listeningWinsToday = 0,
    this.missionTarget = 3,
    this.xp = 0,
    this.blockedAttempts = 0,
    this.recoveredAttempts = 0,
    this.focusSessionsToday = 0,
    this.reflectionsToday = 0,
    this.concentrationWinsToday = 0,
    this.protectionEnabled = false,
    this.morningCommandSet = false,
    this.endReviewsToday = 0,
    String? lastActiveDate,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.completedDays = 0,
    this.commitmentDays = 0,
    this.commitmentStartDate = '',
    this.totalWebsitesScanned = 0,
    this.websitesScannedToday = 0,
    this.newWebsitesScannedToday = 0,
    this.scannedDomainsToday = '',
    this.lastReflectionText = '',
  }) : lastActiveDate = lastActiveDate ?? DateKey.today();

  factory FocusShieldState.initial() {
    return FocusShieldState();
  }

  factory FocusShieldState.fromMap(Map<String, dynamic> map) {
    final state = FocusShieldState(
      listeningWinsToday: (map['listeningWinsToday'] as int?) ?? 0,
      missionTarget: (map['missionTarget'] as int?) ?? 3,
      xp: (map['xp'] as int?) ?? 0,
      blockedAttempts: (map['blockedAttempts'] as int?) ?? 0,
      recoveredAttempts: (map['recoveredAttempts'] as int?) ?? 0,
      focusSessionsToday: (map['focusSessionsToday'] as int?) ?? 0,
      reflectionsToday: (map['reflectionsToday'] as int?) ?? 0,
      concentrationWinsToday: (map['concentrationWinsToday'] as int?) ?? 0,
      protectionEnabled: (map['protectionEnabled'] as bool?) ?? false,
      morningCommandSet: (map['morningCommandSet'] as bool?) ?? false,
      endReviewsToday: (map['endReviewsToday'] as int?) ?? 0,
      lastActiveDate: (map['lastActiveDate'] as String?) ?? DateKey.today(),
      currentStreak: (map['currentStreak'] as int?) ?? 0,
      longestStreak: (map['longestStreak'] as int?) ?? 0,
      completedDays: (map['completedDays'] as int?) ?? 0,
      commitmentDays: (map['commitmentDays'] as int?) ?? 0,
      commitmentStartDate: (map['commitmentStartDate'] as String?) ?? '',
      totalWebsitesScanned: (map['totalWebsitesScanned'] as int?) ?? 0,
      websitesScannedToday: (map['websitesScannedToday'] as int?) ?? 0,
      newWebsitesScannedToday: (map['newWebsitesScannedToday'] as int?) ?? 0,
      scannedDomainsToday: (map['scannedDomainsToday'] as String?) ?? '',
      lastReflectionText: (map['lastReflectionText'] as String?) ?? '',
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

  int commitmentDays;
  String commitmentStartDate;

  int totalWebsitesScanned;
  int websitesScannedToday;
  int newWebsitesScannedToday;
  String scannedDomainsToday;

  String lastReflectionText;

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

  bool get commitmentSet {
    return commitmentDays > 0 && commitmentStartDate.trim().isNotEmpty;
  }

  DateTime? get commitmentStart {
    if (!commitmentSet) return null;
    return DateTime.tryParse(commitmentStartDate);
  }

  DateTime? get commitmentEnd {
    final start = commitmentStart;
    if (start == null) return null;
    return start.add(Duration(days: commitmentDays));
  }

  int get commitmentDaysRemaining {
    final end = commitmentEnd;
    if (end == null) return 0;
    final difference = end.difference(DateTime.now()).inDays + 1;
    return difference < 0 ? 0 : difference;
  }

  bool get commitmentActive {
    return commitmentSet && commitmentDaysRemaining > 0;
  }

  bool get protectionReady {
    return commitmentSet;
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
        completedDays > 0 ||
        totalWebsitesScanned > 0;
  }

  void normalizeLegacyStarterXp() {
    if (xp == 45 && !hasTrackedActivity) {
      xp = 0;
    }
    if (xp < 0) {
      xp = 0;
    }
  }

  void setCommitment(int days) {
    if (commitmentActive) {
      return;
    }
    commitmentDays = days;
    commitmentStartDate = DateTime.now().toIso8601String();
    protectionEnabled = true;
  }

  void recordWebsiteScan(String rawDomain) {
    final domain = rawDomain.trim().toLowerCase();
    if (domain.isEmpty) return;

    totalWebsitesScanned += 1;
    websitesScannedToday += 1;

    final seen = scannedDomainsToday
        .split('|')
        .where((item) => item.trim().isNotEmpty)
        .toSet();

    if (!seen.contains(domain)) {
      newWebsitesScannedToday += 1;
      seen.add(domain);
    }

    scannedDomainsToday = seen.join('|');
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
    websitesScannedToday = 0;
    newWebsitesScannedToday = 0;
    scannedDomainsToday = '';
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
      commitmentDays: commitmentDays,
      commitmentStartDate: commitmentStartDate,
      totalWebsitesScanned: totalWebsitesScanned,
      websitesScannedToday: websitesScannedToday,
      newWebsitesScannedToday: newWebsitesScannedToday,
      scannedDomainsToday: scannedDomainsToday,
      lastReflectionText: lastReflectionText,
    );
  }

  Map<String, dynamic> toMap() {
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
      'commitmentDays': commitmentDays,
      'commitmentStartDate': commitmentStartDate,
      'commitmentDaysRemaining': commitmentDaysRemaining,
      'commitmentActive': commitmentActive,
      'commitmentSet': commitmentSet,
      'totalWebsitesScanned': totalWebsitesScanned,
      'websitesScannedToday': websitesScannedToday,
      'newWebsitesScannedToday': newWebsitesScannedToday,
      'scannedDomainsToday': scannedDomainsToday,
      'lastReflectionText': lastReflectionText,
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
