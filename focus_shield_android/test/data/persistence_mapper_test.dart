import 'package:flutter_test/flutter_test.dart';
import 'package:focus_shield_android/data/mappers/attempt_record_mapper.dart';
import 'package:focus_shield_android/data/mappers/focus_shield_state_mapper.dart';
import 'package:focus_shield_android/data/mappers/settings_record_mapper.dart';
import 'package:focus_shield_android/domain/models/attempt_record.dart';
import 'package:focus_shield_android/domain/models/focus_shield_state.dart';
import 'package:focus_shield_android/domain/models/settings_record.dart';

void main() {
  test('FocusShieldStateMapper maps state to database format', () {
    final state = FocusShieldState.initial()
      ..xp = 90
      ..protectionEnabled = false;

    final map = FocusShieldStateMapper.toDatabaseMap(state);
    final restored = FocusShieldStateMapper.fromDatabaseMap(map);

    expect(map['protection_enabled'], 0);
    expect(restored.xp, 90);
    expect(restored.protectionEnabled, false);
    expect(map['last_active_date'], state.lastActiveDate);
  });

  test('AttemptRecordMapper maps attempt to database format', () {
    final attempt = AttemptRecord(
      id: 7,
      domain: 'blocked-example.com',
      category: 'local-blocklist',
      confidence: 0.96,
      recovered: true,
      createdAt: DateTime(2026),
    );

    final map = AttemptRecordMapper.toDatabaseMap(attempt);
    final restored = AttemptRecordMapper.fromDatabaseMap(map);

    expect(map['recovered'], 1);
    expect(restored.id, 7);
    expect(restored.domain, 'blocked-example.com');
    expect(restored.recovered, true);
  });

  test('SettingsRecordMapper maps settings to database format', () {
    final settings = SettingsRecord(
      protectionEnabled: true,
      lockEnabled: false,
      delayedDisableHours: 48,
      updatedAt: DateTime(2026),
    );

    final map = SettingsRecordMapper.toDatabaseMap(settings);
    final restored = SettingsRecordMapper.fromDatabaseMap(map);

    expect(map['lock_enabled'], 0);
    expect(restored.protectionEnabled, true);
    expect(restored.lockEnabled, false);
    expect(restored.delayedDisableHours, 48);
  });
}
