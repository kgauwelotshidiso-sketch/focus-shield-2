class SecuritySettings {
  const SecuritySettings({
    required this.pinHash,
    required this.lockEnabled,
    required this.delayedDisableHours,
    required this.protectedSettings,
  });

  final String pinHash;
  final bool lockEnabled;
  final int delayedDisableHours;
  final bool protectedSettings;
}
