import '../../core/utils/date_key.dart';
import '../../domain/models/focus_shield_state.dart';

class FocusShieldStateMapper {
  static Map<String, Object?> toDatabaseMap(FocusShieldState state) {
    return {
      'id': 1,
      'listening_wins_today': state.listeningWinsToday,
      'mission_target': state.missionTarget,
      'xp': state.xp,
      'blocked_attempts': state.blockedAttempts,
      'recovered_attempts': state.recoveredAttempts,
      'focus_sessions_today': state.focusSessionsToday,
      'reflections_today': state.reflectionsToday,
      'concentration_wins_today': state.concentrationWinsToday,
      'protection_enabled': state.protectionEnabled ? 1 : 0,
      'morning_command_set': state.morningCommandSet ? 1 : 0,
      'end_reviews_today': state.endReviewsToday,
      'last_active_date': state.lastActiveDate,
      'current_streak': state.currentStreak,
      'longest_streak': state.longestStreak,
      'completed_days': state.completedDays,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  static FocusShieldState fromDatabaseMap(Map<String, Object?> map) {
    return FocusShieldState(
      listeningWinsToday: (map['listening_wins_today'] as int?) ?? 0,
      missionTarget: (map['mission_target'] as int?) ?? 3,
      xp: (map['xp'] as int?) ?? 45,
      blockedAttempts: (map['blocked_attempts'] as int?) ?? 0,
      recoveredAttempts: (map['recovered_attempts'] as int?) ?? 0,
      focusSessionsToday: (map['focus_sessions_today'] as int?) ?? 0,
      reflectionsToday: (map['reflections_today'] as int?) ?? 0,
      concentrationWinsToday: (map['concentration_wins_today'] as int?) ?? 0,
      protectionEnabled: ((map['protection_enabled'] as int?) ?? 1) == 1,
      morningCommandSet: ((map['morning_command_set'] as int?) ?? 0) == 1,
      endReviewsToday: (map['end_reviews_today'] as int?) ?? 0,
      lastActiveDate: (map['last_active_date'] as String?) ?? DateKey.today(),
      currentStreak: (map['current_streak'] as int?) ?? 0,
      longestStreak: (map['longest_streak'] as int?) ?? 0,
      completedDays: (map['completed_days'] as int?) ?? 0,
    );
  }
}
