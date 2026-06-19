import '../../domain/models/settings_record.dart';

class SettingsRecordMapper {
  static Map<String, Object?> toDatabaseMap(SettingsRecord settings) {
    return {
      'id': 1,
      'protection_enabled': settings.protectionEnabled ? 1 : 0,
      'lock_enabled': settings.lockEnabled ? 1 : 0,
      'delayed_disable_hours': settings.delayedDisableHours,
      'updated_at': settings.updatedAt.toIso8601String(),
    };
  }

  static SettingsRecord fromDatabaseMap(Map<String, Object?> map) {
    return SettingsRecord(
      protectionEnabled: ((map['protection_enabled'] as int?) ?? 1) == 1,
      lockEnabled: ((map['lock_enabled'] as int?) ?? 1) == 1,
      delayedDisableHours: (map['delayed_disable_hours'] as int?) ?? 24,
      updatedAt: DateTime.tryParse((map['updated_at'] as String?) ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
