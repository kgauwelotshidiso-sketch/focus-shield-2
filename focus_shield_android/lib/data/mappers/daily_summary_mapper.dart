import '../../domain/models/daily_summary.dart';

class DailySummaryMapper {
  static Map<String, Object?> toDatabaseMap(DailySummary summary) {
    return {
      'id': summary.id,
      'date_key': summary.dateKey,
      'listening_wins': summary.listeningWins,
      'mission_target': summary.missionTarget,
      'mission_complete': summary.missionComplete ? 1 : 0,
      'xp_total': summary.xpTotal,
      'focus_sessions': summary.focusSessions,
      'reflections': summary.reflections,
      'concentration_wins': summary.concentrationWins,
      'blocked_attempts': summary.blockedAttempts,
      'recovered_attempts': summary.recoveredAttempts,
      'recovery_rate': summary.recoveryRate,
      'coach_score': summary.coachScore,
      'created_at': summary.createdAt.toIso8601String(),
    };
  }

  static DailySummary fromDatabaseMap(Map<String, Object?> map) {
    return DailySummary(
      id: (map['id'] as int?) ?? 0,
      dateKey: (map['date_key'] as String?) ?? '',
      listeningWins: (map['listening_wins'] as int?) ?? 0,
      missionTarget: (map['mission_target'] as int?) ?? 3,
      missionComplete: ((map['mission_complete'] as int?) ?? 0) == 1,
      xpTotal: (map['xp_total'] as int?) ?? 45,
      focusSessions: (map['focus_sessions'] as int?) ?? 0,
      reflections: (map['reflections'] as int?) ?? 0,
      concentrationWins: (map['concentration_wins'] as int?) ?? 0,
      blockedAttempts: (map['blocked_attempts'] as int?) ?? 0,
      recoveredAttempts: (map['recovered_attempts'] as int?) ?? 0,
      recoveryRate: (map['recovery_rate'] as int?) ?? 100,
      coachScore: (map['coach_score'] as int?) ?? 0,
      createdAt:
          DateTime.tryParse((map['created_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
