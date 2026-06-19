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
    final activityPart = ((focusSessionsToday + reflectionsToday + concentrationWinsToday) * 10).clamp(0, 15);
    return (morningScore + missionPart + recoveryPart + activityPart).clamp(0, 100);
  }

  bool get missionComplete => listeningWinsToday >= missionTarget;
}
