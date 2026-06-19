class SettingsRecord {
  const SettingsRecord({
    required this.protectionEnabled,
    required this.lockEnabled,
    required this.delayedDisableHours,
    required this.updatedAt,
  });

  final bool protectionEnabled;
  final bool lockEnabled;
  final int delayedDisableHours;
  final DateTime updatedAt;

  SettingsRecord copyWith({
    bool? protectionEnabled,
    bool? lockEnabled,
    int? delayedDisableHours,
    DateTime? updatedAt,
  }) {
    return SettingsRecord(
      protectionEnabled: protectionEnabled ?? this.protectionEnabled,
      lockEnabled: lockEnabled ?? this.lockEnabled,
      delayedDisableHours: delayedDisableHours ?? this.delayedDisableHours,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
