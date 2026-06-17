class ProtectionSettings {
  final String? pinHash;
  final bool protectionEnabled;
  final int delayHours;
  final String privacyMode;

  const ProtectionSettings({
    this.pinHash,
    required this.protectionEnabled,
    required this.delayHours,
    required this.privacyMode,
  });
}
