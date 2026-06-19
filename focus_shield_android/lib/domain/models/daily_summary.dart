import 'focus_shield_state.dart';

class DailySummary {
  const DailySummary({
    required this.id,
    required this.dateKey,
    required this.listeningWins,
    required this.missionTarget,
    required this.missionComplete,
    required this.xpTotal,
    required this.focusSessions,
    required this.reflections,
    required this.concentrationWins,
    required this.blockedAttempts,
    required this.recoveredAttempts,
    required this.recoveryRate,
    required this.coachScore,
    required this.createdAt,
  });

  factory DailySummary.fromState(FocusShieldState state) {
    return DailySummary(
      id: 0,
      dateKey: state.lastActiveDate,
      listeningWins: state.listeningWinsToday,
      missionTarget: state.missionTarget,
      missionComplete: state.missionComplete,
      xpTotal: state.xp,
      focusSessions: state.focusSessionsToday,
      reflections: state.reflectionsToday,
      concentrationWins: state.concentrationWinsToday,
      blockedAttempts: state.blockedAttempts,
      recoveredAttempts: state.recoveredAttempts,
      recoveryRate: state.recoveryRate,
      coachScore: state.coachScore,
      createdAt: DateTime.now(),
    );
  }

  final int id;
  final String dateKey;
  final int listeningWins;
  final int missionTarget;
  final bool missionComplete;
  final int xpTotal;
  final int focusSessions;
  final int reflections;
  final int concentrationWins;
  final int blockedAttempts;
  final int recoveredAttempts;
  final int recoveryRate;
  final int coachScore;
  final DateTime createdAt;

  DailySummary copyWith({
    int? id,
    String? dateKey,
    int? listeningWins,
    int? missionTarget,
    bool? missionComplete,
    int? xpTotal,
    int? focusSessions,
    int? reflections,
    int? concentrationWins,
    int? blockedAttempts,
    int? recoveredAttempts,
    int? recoveryRate,
    int? coachScore,
    DateTime? createdAt,
  }) {
    return DailySummary(
      id: id ?? this.id,
      dateKey: dateKey ?? this.dateKey,
      listeningWins: listeningWins ?? this.listeningWins,
      missionTarget: missionTarget ?? this.missionTarget,
      missionComplete: missionComplete ?? this.missionComplete,
      xpTotal: xpTotal ?? this.xpTotal,
      focusSessions: focusSessions ?? this.focusSessions,
      reflections: reflections ?? this.reflections,
      concentrationWins: concentrationWins ?? this.concentrationWins,
      blockedAttempts: blockedAttempts ?? this.blockedAttempts,
      recoveredAttempts: recoveredAttempts ?? this.recoveredAttempts,
      recoveryRate: recoveryRate ?? this.recoveryRate,
      coachScore: coachScore ?? this.coachScore,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
